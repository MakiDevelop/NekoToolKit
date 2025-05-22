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
        // TODO: 實作轉換邏輯
    }

    private func importImage() {
        // TODO: 實作圖片選擇邏輯
    }

    private func saveImage() {
        // TODO: 實作圖片儲存邏輯
    }
}
