//
//  CSSMinifyView.swift
//  NekoToolKit
//
//  Created by 千葉牧人 on 2025/5/23.
//


import SwiftUI

struct CSSMinifyView: View {
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    @State private var copyStatusMessage: String? = nil
    @State private var compressionRateMessage: String? = nil

    var body: some View {
        VStack(spacing: 16) {
            Text("CSS 壓縮／展開")
                .font(.headline)

            HStack(spacing: 12) {
                VStack(alignment: .leading) {
                    Text("輸入 CSS")
                        .font(.subheadline)
                    TextEditor(text: $inputText)
                        .frame(minHeight: 240)
                        .border(Color.gray)
                }

                VStack(spacing: 16) {
                    Button("壓縮 CSS") {
                        outputText = minifyCSS(inputText)
                    }
                    Button("展開 CSS") {
                        outputText = beautifyCSS(inputText)
                    }
                }

                VStack(alignment: .leading) {
                    Text("輸出結果")
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
                    if let rate = compressionRateMessage {
                        Text(rate)
                            .font(.caption)
                            .foregroundColor(.blue)
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

    private func minifyCSS(_ css: String) -> String {
        var result = css
        result = result.replacingOccurrences(of: "/\\*.*?\\*/", with: "", options: .regularExpression)
        result = result.replacingOccurrences(of: "\\s*{\\s*", with: "{", options: .regularExpression)
        result = result.replacingOccurrences(of: "\\s*}\\s*", with: "}", options: .regularExpression)
        result = result.replacingOccurrences(of: "\\s*;\\s*", with: ";", options: .regularExpression)
        result = result.replacingOccurrences(of: "\\s*:\\s*", with: ":", options: .regularExpression)
        result = result.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        let originalLength = css.count
        let minifiedLength = result.count
        if originalLength > 0 {
            let rate = 100 - (Double(minifiedLength) / Double(originalLength) * 100)
            compressionRateMessage = String(format: "🔻 壓縮率：%.1f%%（%d → %d 字元）", rate, originalLength, minifiedLength)
        } else {
            compressionRateMessage = nil
        }
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func beautifyCSS(_ css: String) -> String {
        var result = css
        result = result.replacingOccurrences(of: "}", with: "}\n")
        result = result.replacingOccurrences(of: "{", with: " {\n    ")
        result = result.replacingOccurrences(of: ";", with: ";\n    ")
        result = result.replacingOccurrences(of: "\n    \n", with: "\n")
        compressionRateMessage = nil
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
