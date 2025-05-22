//
//  TextEncodingConvertView.swift
//  NekoToolKit
//
//  Created by 千葉牧人 on 2025/5/22.
//



import SwiftUI
import UniformTypeIdentifiers

struct TextEncodingConvertView: View {
    enum EncodingType: String, CaseIterable, Identifiable {
        case utf8 = "UTF-8"
        case big5 = "Big5"
        case latin1 = "ISO Latin1"

        var id: String { self.rawValue }

        var encoding: String.Encoding {
            switch self {
            case .utf8: return .utf8
            case .big5:
                return String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.big5.rawValue)))
            case .latin1: return .isoLatin1
            }
        }

        init?(rawValue: String) {
            switch rawValue {
            case "UTF-8": self = .utf8
            case "Big5": self = .big5
            case "ISO Latin1": self = .latin1
            default: return nil
            }
        }
    }

    @State private var inputText: String = ""
    @State private var outputText: String = ""
    @State private var fromEncoding: EncodingType = .big5
    @State private var toEncoding: EncodingType = .utf8
    @State private var copyStatusMessage: String? = nil

    var body: some View {
        VStack(spacing: 16) {
            Text("編碼轉換工具（Big5 ⇄ UTF-8）")
                .font(.headline)

            HStack {
                Picker("來源編碼", selection: $fromEncoding) {
                    ForEach(EncodingType.allCases) { enc in
                        Text(enc.rawValue).tag(enc)
                    }
                }
                Picker("目標編碼", selection: $toEncoding) {
                    ForEach(EncodingType.allCases) { enc in
                        Text(enc.rawValue).tag(enc)
                    }
                }
                Button("選擇檔案") {
                    importFile()
                }
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading) {
                    Text("來源內容（\(fromEncoding.rawValue)）")
                        .font(.subheadline)
                    TextEditor(text: $inputText)
                        .frame(minHeight: 240)
                        .border(Color.gray)
                }

                VStack {
                    Button("轉換") {
                        convertEncoding()
                    }
                }

                VStack(alignment: .leading) {
                    Text("轉換結果（\(toEncoding.rawValue)）")
                        .font(.subheadline)
                    TextEditor(text: $outputText)
                        .frame(minHeight: 240)
                        .border(Color.gray)

                    Button("複製結果") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(outputText, forType: .string)
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
        }
        .padding()
    }

    private func importFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.plainText]
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.begin { response in
            if response == .OK, let url = panel.url {
                guard let data = try? Data(contentsOf: url) else {
                    self.inputText = "⚠️ 無法讀取檔案內容"
                    return
                }

                // 自動偵測編碼：依序嘗試 UTF-8, Big5, Latin1
                let encodingsToTry: [(String.Encoding, String)] = [
                    (.utf8, "UTF-8"),
                    (String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.big5.rawValue))), "Big5"),
                    (.isoLatin1, "ISO Latin1")
                ]

                for (encoding, label) in encodingsToTry {
                    if let str = String(data: data, encoding: encoding) {
                        DispatchQueue.main.async {
                            self.inputText = str
                            self.fromEncoding = EncodingType(rawValue: label) ?? self.fromEncoding
                        }
                        return
                    }
                }

                self.inputText = "⚠️ 無法解碼檔案內容（不支援的編碼格式）"
            }
        }
    }

    private func convertEncoding() {
        guard let data = inputText.data(using: toEncoding.encoding),
              let str = String(data: data, encoding: toEncoding.encoding) else {
            outputText = "⚠️ 轉換失敗，無法以 \(toEncoding.rawValue) 表示。"
            return
        }
        outputText = str
    }
}

#Preview {
    TextEncodingConvertView()
}
