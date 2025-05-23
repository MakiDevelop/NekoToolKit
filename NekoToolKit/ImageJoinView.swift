//
//  ImageJoinView.swift
//  NekoToolKit
//
//  Created by 千葉牧人 on 2025/5/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct ImageJoinView: View {
    @State private var outputFormat: String = "png"
    @State private var images: [NSImage] = []
    @State private var direction: Axis = .vertical
    @State private var draggingIndex: Int?
    @State private var previewImage: NSImage?
    @State private var previewSize: CGSize = .zero

    var body: some View {
        VStack(spacing: 16) {
            Text("圖片合併工具")
                .font(.headline)

            if images.isEmpty {
                Button(action: selectImages) {
                    Text("請拖曳或點擊上傳多張圖片")
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                }
                .buttonStyle(PlainButtonStyle())
                .onDrop(of: [.image], isTargeted: nil) { providers in
                    for provider in providers {
                        _ = provider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, _ in
                            if let data = data, let image = NSImage(data: data) {
                                DispatchQueue.main.async {
                                    images.append(image)
                                    previewImage = generatePreview()
                                }
                            }
                        }
                    }
                    return true
                }
            } else {
                // 新增說明文字
                Text("可拖曳縮圖以調整圖片合併順序")
                    .font(.caption)
                    .foregroundColor(.secondary)
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack(spacing: 8) {
                        ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                            VStack {
                                Image(nsImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                                    .border(Color.gray)
                                Button(action: {
                                    images.remove(at: index)
                                    previewImage = generatePreview()
                                }) {
                                    Text("刪除")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                            .onDrag {
                                self.draggingIndex = index
                                return NSItemProvider(object: "\(index)" as NSString)
                            }
                            .onDrop(of: [.text], delegate: DropViewDelegate(currentIndex: index, images: $images, draggingIndex: $draggingIndex))
                        }
                    }
                }

                Picker("拼接方向", selection: $direction) {
                    Text("縱向").tag(Axis.vertical)
                    Text("橫向").tag(Axis.horizontal)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 200)
                .onChange(of: direction) { _ in
                    previewImage = generatePreview()
                }

                Picker("輸出格式", selection: $outputFormat) {
                    Text("PNG").tag("png")
                    Text("JPEG").tag("jpeg")
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 200)

                Button("合併並另存新檔") {
                    joinImages()
                }

                Button("清除") {
                    images = []
                    previewImage = nil
                }
            }
        }
        .padding()
    }

    private func selectImages() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.image]
        panel.allowsMultipleSelection = true
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.begin { response in
            if response == .OK {
                let selected: [NSImage] = panel.urls.compactMap { url in
                    guard let data = try? Data(contentsOf: url),
                          let image = NSImage(data: data) else { return nil }
                    return image
                }
                images.append(contentsOf: selected)
                previewImage = generatePreview()
            }
        }
    }

    private func generatePreview() -> NSImage? {
        guard !images.isEmpty else { return nil }
        let sizes = images.map { $0.size }
        let totalSize: CGSize
        switch direction {
        case .vertical:
            totalSize = CGSize(
                width: sizes.map { $0.width }.max() ?? 0,
                height: sizes.reduce(0) { $0 + $1.height }
            )
        case .horizontal:
            totalSize = CGSize(
                width: sizes.reduce(0) { $0 + $1.width },
                height: sizes.map { $0.height }.max() ?? 0
            )
        }

        let maxSide: CGFloat = 8000
        var scaledTotalSize = totalSize
        var scale: CGFloat = 1.0
        if totalSize.width > maxSide || totalSize.height > maxSide {
            scale = min(maxSide / totalSize.width, maxSide / totalSize.height)
            scaledTotalSize = CGSize(width: totalSize.width * scale, height: totalSize.height * scale)
        }

        let resultImage = NSImage(size: scaledTotalSize)
        resultImage.lockFocus()

        var offset: CGFloat = 0

        for image in images {
            let scaledSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
            let drawRect: CGRect
            switch direction {
            case .vertical:
                drawRect = CGRect(x: 0, y: offset, width: scaledSize.width, height: scaledSize.height)
                offset += scaledSize.height
            case .horizontal:
                drawRect = CGRect(x: offset, y: 0, width: scaledSize.width, height: scaledSize.height)
                offset += scaledSize.width
            }
            image.draw(in: drawRect)
        }
        resultImage.unlockFocus()
        previewSize = scaledTotalSize
        return resultImage
    }

    private func joinImages() {
        guard !images.isEmpty else { return }

        let resultImage = generatePreview()
        previewImage = resultImage

        guard let resultImage = resultImage else { return }

        let panel = NSSavePanel()
        panel.allowedContentTypes = outputFormat == "jpeg" ? [.jpeg] : [.png]
        panel.nameFieldStringValue = "joined.\(outputFormat)"
        panel.begin { response in
            if response == .OK, let url = panel.url,
               let tiff = resultImage.tiffRepresentation,
               let rep = NSBitmapImageRep(data: tiff) {
                let imageData: Data?
                if outputFormat == "jpeg" {
                    imageData = rep.representation(using: .jpeg, properties: [.compressionFactor: 0.9])
                } else {
                    imageData = rep.representation(using: .png, properties: [:])
                }
                if let data = imageData {
                    try? data.write(to: url)
                }
            }
        }
    }
}

struct DropViewDelegate: DropDelegate {
    let currentIndex: Int
    @Binding var images: [NSImage]
    @Binding var draggingIndex: Int?

    func performDrop(info: DropInfo) -> Bool {
        guard let from = draggingIndex else { return false }
        if from == currentIndex { return false }
        let item = images.remove(at: from)
        let to = currentIndex > from ? currentIndex : currentIndex + 1
        images.insert(item, at: to)
        draggingIndex = nil
        return true
    }

    func dropEntered(info: DropInfo) {
        guard let from = draggingIndex, from != currentIndex else { return }
        withAnimation {
            let item = images.remove(at: from)
            images.insert(item, at: currentIndex > from ? currentIndex - 1 : currentIndex)
            draggingIndex = currentIndex
        }
    }
}
