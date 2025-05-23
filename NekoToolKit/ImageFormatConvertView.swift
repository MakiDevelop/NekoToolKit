//
//  ImageFormatConvertView.swift
//  NekoToolKit
//
//  Created by 千葉牧人 on 2025/5/23.
//



import SwiftUI
import UniformTypeIdentifiers

struct ImageFormatConvertView: View {
    @State private var originalImage: NSImage?
    @State private var originalImageFilename: String?
    @State private var selectedFormat: String = "png"
    @State private var formatOptions = ["png", "jpeg", "tiff", "bmp"]

    var body: some View {
        VStack(spacing: 16) {
            Text("圖片格式轉換工具")
                .font(.headline)

            if let image = originalImage {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 400)
                    .border(Color.gray)
                Text("目前圖片格式：\(currentFormat()?.uppercased() ?? "未知")")
                Text("尺寸：\(Int(image.size.width)) x \(Int(image.size.height))")
            } else {
                Button(action: openImageFile) {
                    Text("請拖曳或點擊上傳圖片")
                        .frame(height: 400)
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
                                }
                            }
                        }
                        return true
                    }
                    return false
                }
            }

            HStack {
                Text("輸出格式")
                Picker("", selection: $selectedFormat) {
                    ForEach(formatOptions, id: \.self) { format in
                        Text(format.uppercased()).tag(format)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 240)
            }

            if originalImage != nil {
                Button("轉換並另存新檔") {
                    convertAndSave()
                }
            }

            Button("清除") {
                originalImage = nil
                originalImageFilename = nil
            }
        }
        .padding()
    }

    private func currentFormat() -> String? {
        guard let name = originalImageFilename else { return nil }
        return name.components(separatedBy: ".").last
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
                originalImageFilename = url.lastPathComponent
            }
        }
    }

    private func convertAndSave() {
        guard let image = originalImage else { return }

        let panel = NSSavePanel()
        let fileExtension = selectedFormat.lowercased()
        let baseName = originalImageFilename?.components(separatedBy: ".").dropLast().joined(separator: ".") ?? "converted"
        panel.nameFieldStringValue = "\(baseName).\(fileExtension)"

        switch selectedFormat {
        case "png":
            panel.allowedContentTypes = [.png]
        case "jpeg":
            panel.allowedContentTypes = [.jpeg]
        case "tiff":
            panel.allowedContentTypes = [.tiff]
        case "bmp":
            panel.allowedContentTypes = [.bmp]
        default:
            return
        }

        panel.begin { response in
            if response == .OK, let url = panel.url {
                guard let tiffData = image.tiffRepresentation,
                      let bitmap = NSBitmapImageRep(data: tiffData) else { return }

                var imageData: Data?
                switch selectedFormat {
                case "png":
                    imageData = bitmap.representation(using: .png, properties: [:])
                case "jpeg":
                    imageData = bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.8])
                case "tiff":
                    imageData = bitmap.representation(using: .tiff, properties: [:])
                case "bmp":
                    imageData = bitmap.representation(using: .bmp, properties: [:])
                default:
                    break
                }

                if let data = imageData {
                    try? data.write(to: url)
                }
            }
        }
    }
}
