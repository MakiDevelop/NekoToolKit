//
//  JavaScriptMinifyView.swift
//  NekoToolKit
//
//  Created by 千葉牧人 on 2025/5/23.
//



import SwiftUI

struct JavaScriptMinifyView: View {
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    @State private var copyStatusMessage: String? = nil
    @State private var compressionRateMessage: String? = nil

    var body: some View {
        VStack(spacing: 16) {
            Text("JavaScript 壓縮／展開")
                .font(.headline)

            HStack(spacing: 12) {
                VStack(alignment: .leading) {
                    Text("輸入 JavaScript")
                        .font(.subheadline)
                    TextEditor(text: $inputText)
                        .frame(minHeight: 240)
                        .border(Color.gray)
                }

                VStack(spacing: 16) {
                    Button("壓縮 JavaScript") {
                        outputText = minifyJS(inputText)
                    }
                    Button("展開 JavaScript") {
                        outputText = beautifyJS(inputText)
                    }
                }

                VStack(alignment: .leading) {
                    Text("輸出結果")
                        .font(.subheadline)
                    TextEditor(text: $outputText)
                        .frame(minHeight: 240)
                        .border(Color.gray)

                    if let msg = compressionRateMessage {
                        Text(msg)
                            .font(.caption)
                            .foregroundColor(.blue)
                    }

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
                compressionRateMessage = nil
            }
        }
        .padding()
    }

    private func minifyJS(_ code: String) -> String {
        let lines = code
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.hasPrefix("//") && !$0.isEmpty }
        let result = lines.joined()
        let originalLength = code.count
        let minifiedLength = result.count
        if originalLength > 0 {
            let rate = 100 - (Double(minifiedLength) / Double(originalLength) * 100)
            compressionRateMessage = String(format: "🔻 壓縮率：%.1f%%（%d → %d 字元）", rate, originalLength, minifiedLength)
        } else {
            compressionRateMessage = nil
        }
        return result
    }

    private func beautifyJS(_ code: String) -> String {
        compressionRateMessage = nil
        return code
            .replacingOccurrences(of: ";", with: ";\n")
            .replacingOccurrences(of: "{", with: " {\n")
            .replacingOccurrences(of: "}", with: "\n}\n")
    }
}
