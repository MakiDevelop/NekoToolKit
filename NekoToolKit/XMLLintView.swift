//
//  XMLLintView.swift
//  NekoToolKit
//
//  Created by 千葉牧人 on 2025/5/23.
//



import SwiftUI
import Foundation

struct XMLLintView: View {
    @State private var inputText: String = ""
    @State private var resultText: String = ""
    @State private var resultColor: Color = .primary
    @State private var copyStatusMessage: String? = nil

    var body: some View {
        VStack(spacing: 16) {
            Text("XML 格式檢查工具")
                .font(.headline)

            HStack(spacing: 12) {
                VStack(alignment: .leading) {
                    Text("輸入 XML")
                        .font(.subheadline)
                    TextEditor(text: $inputText)
                        .frame(minHeight: 240)
                        .border(Color.gray)
                }

                VStack {
                    Button("檢查格式") {
                        lintXML()
                    }
                    Button("展開 XML") {
                        prettifyXML()
                    }
                }

                VStack(alignment: .leading) {
                    Text("檢查結果")
                        .font(.subheadline)
                    Text(resultText)
                        .foregroundColor(resultColor)
                        .frame(minHeight: 240, alignment: .topLeading)
                        .padding()
                        .border(Color.gray)

                    Button("複製結果") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(resultText, forType: .string)
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
                resultText = ""
                resultColor = .primary
                copyStatusMessage = nil
            }
        }
        .padding()
    }

    private func lintXML() {
        guard let data = inputText.data(using: .utf8) else {
            resultText = "⚠️ 輸入無法轉為 UTF-8 編碼"
            resultColor = .red
            return
        }

        let parser = XMLParser(data: data)
        let delegate = XMLValidationDelegate()
        parser.delegate = delegate

        if parser.parse() {
            resultText = "✅ XML 格式正確"
            resultColor = .green
        } else {
            let location = delegate.line != nil ? "（第 \(delegate.line!) 行，第 \(delegate.column ?? 0) 列）" : ""
            resultText = "❌ XML 格式錯誤：\(delegate.errorMessage ?? "未知錯誤") \(location)"
            resultColor = .red
        }
    }

    private func prettifyXML() {
        do {
            let xmlDoc = try XMLDocument(xmlString: inputText, options: [.nodePrettyPrint])
            resultText = xmlDoc.xmlString(options: [.nodePrettyPrint])
            resultColor = .green
        } catch {
            resultText = "⚠️ 無法展開：\(error.localizedDescription)"
            resultColor = .red
        }
    }
}

class XMLValidationDelegate: NSObject, XMLParserDelegate {
    var errorMessage: String?
    var line: Int?
    var column: Int?

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        errorMessage = parseError.localizedDescription
        line = parser.lineNumber
        column = parser.columnNumber
    }
}
