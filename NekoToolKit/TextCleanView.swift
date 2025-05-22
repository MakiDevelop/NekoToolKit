
import SwiftUI

struct TextCleanView: View {
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    @State private var trimWhitespace = true
    @State private var removeEmptyLines = true
    @State private var removePunctuation = false
    @State private var copyStatusMessage: String? = nil

    var body: some View {
        VStack(spacing: 16) {
            Text("文字清理工具")
                .font(.headline)

            VStack(alignment: .leading) {
                Toggle("去除前後空白", isOn: $trimWhitespace)
                Toggle("移除空行", isOn: $removeEmptyLines)
                Toggle("移除標點符號", isOn: $removePunctuation)
            }
            .padding(.horizontal)

            HStack(spacing: 12) {
                VStack(alignment: .leading) {
                    Text("原始文字")
                        .font(.subheadline)
                    TextEditor(text: $inputText)
                        .frame(minHeight: 240)
                        .border(Color.gray)
                }

                VStack {
                    Button("清理") {
                        cleanText()
                    }
                }

                VStack(alignment: .leading) {
                    Text("清理後結果")
                        .font(.subheadline)
                    TextEditor(text: $outputText)
                        .frame(minHeight: 240)
                        .border(Color.gray)

                    Button("複製結果") {
                        #if os(macOS)
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(outputText, forType: .string)
                        #endif
                        copyStatusMessage = "已複製到剪貼簿 ✅"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            copyStatusMessage = nil
                        }
                    }

                    if let msg = copyStatusMessage {
                        Text(msg)
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }

            Button("清除") {
                inputText = ""
                outputText = ""
                copyStatusMessage = nil
            }
            .padding(.top)
        }
        .padding()
    }

    private func cleanText() {
        var lines = inputText.components(separatedBy: .newlines)

        if trimWhitespace {
            lines = lines.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        }

        if removeEmptyLines {
            lines = lines.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        }

        var result = lines.joined(separator: "\n")

        if removePunctuation {
            result = result.components(separatedBy: CharacterSet.punctuationCharacters).joined()
        }

        outputText = result
    }
}

#Preview {
    TextCleanView()
}

