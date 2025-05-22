import SwiftUI
import UniformTypeIdentifiers

struct ImageBase64ConvertView: View {
    @State private var image: NSImage? = nil
    @State private var outputText: String = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("圖片與 Base64 轉換工具")
                .font(.headline)

            HStack(spacing: 12) {
                // 左圖區
                VStack {
                    ZStack {
                        Rectangle()
                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5]))
                            .background(Color(NSColor.controlBackgroundColor))
                            .frame(minWidth: 200, minHeight: 240)

                        if let image = image {
                            Image(nsImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(minWidth: 200, minHeight: 240)
                                .drawingGroup()
                        } else {
                            Text("拖曳圖片到此處\n或點此選擇圖片")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                                .onTapGesture {
                                    importImage()
                                }
                        }
                    }
                    .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                        if let item = providers.first {
                            _ = item.loadObject(ofClass: URL.self) { url, _ in
                                if let url = url, let nsImage = NSImage(contentsOf: url) {
                                    DispatchQueue.main.async {
                                        self.image = nsImage
                                    }
                                }
                            }
                            return true
                        }
                        return false
                    }

                    Button("下載圖片") {
                        saveImage()
                    }
                    .disabled(image == nil)
                    .padding(.top, 4)
                }

                // 中間按鈕
                VStack {
                    Spacer()
                    Button("轉換") {
                        processInput()
                    }
                    Spacer()
                }

                // 右Base64區
                VStack(alignment: .leading) {
                    TextEditor(text: $outputText)
                        .frame(minHeight: 240)
                        .border(Color.gray)

                    Button("複製 Base64") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(outputText, forType: .string)
                    }
                    .padding(.top, 4)
                }
            }

            // 下方清除按鈕
            Button("清除") {
                outputText = ""
                image = nil
            }
            .padding(.top, 12)
        }
        .padding()
    }

    private func processInput() {
        // 嘗試從 Base64 還原為圖片
        if let data = Data(base64Encoded: outputText),
           let nsImage = NSImage(data: data),
           nsImage.size.width > 0, nsImage.size.height > 0 {
            self.image = nsImage
            return
        }

        // 否則嘗試將圖片轉為 Base64
        guard let image = image,
              let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let pngData = bitmap.representation(using: .png, properties: [:]) else {
            self.outputText = "⚠️ 尚未載入圖片，或轉換 PNG 時失敗。"
            return
        }

        let base64 = pngData.base64EncodedString()
        self.outputText = base64
    }

    private func importImage() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.png, .jpeg, .heic]
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.begin { response in
            if response == .OK, let url = panel.url {
                if let nsImage = NSImage(contentsOf: url) {
                    self.image = nsImage
                }
            }
        }
    }

    private func saveImage() {
        guard let image = image,
              let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let pngData = bitmap.representation(using: .png, properties: [:]) else {
            return
        }

        let panel = NSSavePanel()
        panel.allowedContentTypes = [.png]
        panel.nameFieldStringValue = "export.png"
        panel.canCreateDirectories = true

        panel.begin { response in
            if response == .OK, let url = panel.url {
                try? pngData.write(to: url)
            }
        }
    }
}
