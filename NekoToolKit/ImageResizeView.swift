//
//  ImageResizeView.swift
//  NekoToolKit
//
//  Created by 千葉牧人 on 2025/5/23.
//



import SwiftUI
import UniformTypeIdentifiers

struct ImageResizeView: View {
    @State private var originalImage: NSImage?
    @State private var resizedImage: NSImage?
    @State private var targetWidth: String = ""
    @State private var targetHeight: String = ""
    @State private var keepAspectRatio: Bool = true
    @State private var originalSize: CGSize = .zero
    @State private var showSavePanel = false
    @State private var isEditingWidth = false
    @State private var isEditingHeight = false
    @State private var originalImageFilename: String?

    var body: some View {
        VStack(spacing: 16) {
            Text("圖片尺寸調整工具")
                .font(.headline)

            if let image = originalImage {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .border(Color.gray)
                Text("原始尺寸：\(Int(originalSize.width)) x \(Int(originalSize.height))")
                    .font(.caption)
            } else {
                Button(action: {
                    openImageFile()
                }) {
                    Text("請拖曳或點擊上傳圖片")
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                }
                .buttonStyle(PlainButtonStyle())
                .onDrop(of: [.image], isTargeted: nil) { providers in
                    if let provider = providers.first {
                        _ = provider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, _ in
                            if let data = data, let image = NSImage(data: data) {
                                DispatchQueue.main.async {
                                    originalImage = image
                                    resizedImage = nil
                                    originalSize = image.size
                                    targetWidth = String(Int(image.size.width))
                                    targetHeight = String(Int(image.size.height))
                                }
                            }
                        }
                        return true
                    }
                    return false
                }
            }

            HStack {
                VStack(alignment: .leading) {
                    Text("目標寬度：")
                    TextField("寬度", text: $targetWidth, onEditingChanged: { editing in
                        isEditingWidth = editing
                    })
                    .frame(width: 100)
                    .onChange(of: targetWidth) { newValue in
                        guard keepAspectRatio,
                              isEditingWidth,
                              let width = Double(newValue),
                              let original = originalImage else { return }
                        let newHeight = width / original.size.width * original.size.height
                        targetHeight = String(Int(newHeight))
                    }
                }

                VStack(alignment: .leading) {
                    Text("目標高度：")
                    TextField("高度", text: $targetHeight, onEditingChanged: { editing in
                        isEditingHeight = editing
                    })
                    .frame(width: 100)
                    .onChange(of: targetHeight) { newValue in
                        guard keepAspectRatio,
                              isEditingHeight,
                              let height = Double(newValue),
                              let original = originalImage else { return }
                        let newWidth = height / original.size.height * original.size.width
                        targetWidth = String(Int(newWidth))
                    }
                }

                Toggle("等比例縮放", isOn: $keepAspectRatio)
                    .toggleStyle(.checkbox)

                Button("調整尺寸") {
                    resizeImage()
                }
            }

            if let preview = resizedImage {
                Image(nsImage: preview)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .border(Color.green)
                Text("調整後尺寸：\(Int(preview.size.width)) x \(Int(preview.size.height))")
                    .font(.caption)

                Button("另存新檔") {
                    saveImage(preview)
                }
            }

            Button("清除") {
                originalImage = nil
                resizedImage = nil
                originalSize = .zero
                targetWidth = ""
                targetHeight = ""
            }
        }
        .padding()
    }

    private func resizeImage() {
        guard let original = originalImage,
              let width = Double(targetWidth),
              let height = Double(targetHeight) else {
            return
        }

        let targetSize: CGSize
        if keepAspectRatio {
            let scale = min(width / original.size.width, height / original.size.height)
            targetSize = CGSize(width: original.size.width * scale,
                                height: original.size.height * scale)
        } else {
            targetSize = CGSize(width: width, height: height)
        }

        let newImage = NSImage(size: targetSize)
        newImage.lockFocus()
        original.draw(in: CGRect(origin: .zero, size: targetSize),
                      from: .zero,
                      operation: .copy,
                      fraction: 1.0)
        newImage.unlockFocus()
        resizedImage = newImage
    }

    private func saveImage(_ image: NSImage) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.png]
        let baseName = originalImageFilename?.components(separatedBy: ".").dropLast().joined(separator: ".") ?? "resized"
        let suggestedName = baseName + "_resize.png"
        panel.nameFieldStringValue = suggestedName
        panel.begin { response in
            if response == .OK, let url = panel.url {
                let size = image.size
                let rep = NSBitmapImageRep(
                    bitmapDataPlanes: nil,
                    pixelsWide: Int(size.width),
                    pixelsHigh: Int(size.height),
                    bitsPerSample: 8,
                    samplesPerPixel: 4,
                    hasAlpha: true,
                    isPlanar: false,
                    colorSpaceName: .deviceRGB,
                    bytesPerRow: 0,
                    bitsPerPixel: 0
                )

                if let rep = rep {
                    NSGraphicsContext.saveGraphicsState()
                    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
                    image.draw(in: CGRect(origin: .zero, size: size))
                    NSGraphicsContext.restoreGraphicsState()

                    if let pngData = rep.representation(using: .png, properties: [:]) {
                        try? pngData.write(to: url)
                    }
                }
            }
        }
    }

    private func openImageFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.image]
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.begin { response in
            if response == .OK, let url = panel.url,
               let data = try? Data(contentsOf: url),
               let image = NSImage(data: data) {
                originalImage = image
                resizedImage = nil
                originalSize = image.size
                targetWidth = String(Int(image.size.width))
                targetHeight = String(Int(image.size.height))
                originalImageFilename = url.lastPathComponent
            }
        }
    }
}
