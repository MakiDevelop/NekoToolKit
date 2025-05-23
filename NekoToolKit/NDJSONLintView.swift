//
//  NDJSONLintView.swift
//  NekoToolKit
//
//  Created by 千葉牧人 on 2025/5/23.
//

import SwiftUI

struct NDJSONLintView: View {
    @State private var inputText: String = ""
    @State private var resultText: String = ""
    @State private var resultColor: Color = .primary
    @State private var copyStatusMessage: String? = nil
    @State private var onlyAllowObjects: Bool = true
    @State private var errorLineNumbers: Set<Int> = []

    var body: some View {
        VStack(spacing: 16) {
            Text("NDJSON 格式檢查工具")
                .font(.headline)

            HStack(spacing: 12) {
                VStack(alignment: .leading) {
                    Text("輸入 NDJSON（每行一個 JSON 物件）")
                        .font(.subheadline)
                    TextEditor(text: $inputText)
                        .frame(minHeight: 240)
                        .border(Color.gray)
                }

                VStack {
                    Toggle("只接受 JSON 物件", isOn: $onlyAllowObjects)
                    Button("檢查格式") {
                        lintNDJSON()
                    }
                }

                VStack(alignment: .leading) {
                    Text("檢查結果")
                        .font(.subheadline)
                    ScrollView {
                        VStack(alignment: .leading, spacing: 2) {
                            let lines = inputText.components(separatedBy: .newlines)
                            ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                                Text(line)
                                    .padding(4)
                                    .background(errorLineNumbers.contains(index + 1) ? Color.red.opacity(0.2) : Color.clear)
                                    .font(.system(.body, design: .monospaced))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .frame(minHeight: 240)
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
                errorLineNumbers = []
            }
        }
        .padding()
    }

    private func lintNDJSON() {
        let lines = inputText.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        var invalidLines: [String] = []
        errorLineNumbers = []

        for (index, line) in lines.enumerated() {
            guard let data = line.data(using: .utf8) else {
                invalidLines.append("第 \(index + 1) 行：無法轉換為 UTF-8")
                errorLineNumbers.insert(index + 1)
                continue
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if onlyAllowObjects {
                    if !(json is [String: Any]) {
                        invalidLines.append("第 \(index + 1) 行不是 JSON 物件")
                        errorLineNumbers.insert(index + 1)
                    }
                }
            } catch {
                invalidLines.append("第 \(index + 1) 行錯誤：\(error.localizedDescription)")
                errorLineNumbers.insert(index + 1)
            }
        }

        if invalidLines.isEmpty {
            resultText = "✅ 格式正確，共 \(lines.count) 筆 JSON。"
            resultColor = .green
        } else {
            resultText = "❌ 格式錯誤：\n" + invalidLines.joined(separator: "\n")
            resultColor = .red
        }
    }
}
