//
//  YAMLLintView.swift
//  NekoToolKit
//
//  Created by 千葉牧人 on 2025/5/23.
//



import SwiftUI
import Yams

struct YAMLLintView: View {
    @State private var inputText: String = ""
    @State private var resultText: String = ""
    @State private var resultColor: Color = .primary
    @State private var copyStatusMessage: String? = nil
    @State private var errorLines: Set<Int> = []

    var body: some View {
        VStack(spacing: 16) {
            Text("YAML 格式檢查工具")
                .font(.headline)

            HStack(spacing: 12) {
                VStack(alignment: .leading) {
                    Text("輸入 YAML")
                        .font(.subheadline)
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $inputText)
                            .font(.system(.body, design: .monospaced))
                            .padding(4)
                            .border(Color.gray)

                        // 高亮錯誤行（僅視覺提示，不可選取）
                        GeometryReader { geometry in
                            let lines = inputText.components(separatedBy: .newlines)
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                                    Rectangle()
                                        .fill(errorLines.contains(index + 1) ? Color.red.opacity(0.2) : Color.clear)
                                        .frame(height: 20) // 假設一行高度約 20pt
                                }
                            }
                            .frame(width: geometry.size.width, alignment: .topLeading)
                        }
                        .allowsHitTesting(false)
                    }
                    .frame(minHeight: 240)
                }

                VStack {
                    Button("檢查格式") {
                        lintYAML()
                    }
                    Button("使用 Yams 精確解析") {
                        lintYAMLUsingYams()
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
                errorLines = []
            }
        }
        .padding()
    }

    private func lintYAML() {
        do {
            _ = try Yams.load(yaml: inputText)
            resultText = "✅ 格式正確（已使用 Yams 精確解析）"
            resultColor = .green
            errorLines = []
        } catch {
            let lines = inputText.components(separatedBy: .newlines)
            var errors: [String] = []
            errorLines = []

            for (index, line) in lines.enumerated() {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                let cleaned = trimmed.trimmingCharacters(in: .whitespacesAndNewlines)
                if cleaned.hasPrefix("- ") || cleaned.contains(": ") {
                    continue
                }
                if cleaned.isEmpty || cleaned.hasPrefix("#") {
                    continue
                }
                errors.append("第 \(index + 1) 行格式可能錯誤：未偵測到冒號或項目符號")
                errorLines.insert(index + 1)
            }

            if errors.isEmpty {
                resultText = "⚠️ 無法精確解析，但未發現明顯語法錯誤"
                resultColor = .orange
            } else {
                resultText = "❌ 偵測到以下潛在問題：\n" + errors.joined(separator: "\n")
                resultColor = .red
            }
        }
    }

    private func lintYAMLUsingYams() {
        do {
            _ = try Yams.load(yaml: inputText)
            resultText = "✅ Yams 檢查結果：格式正確"
            resultColor = .green
            errorLines = []
        } catch {
            resultText = "❌ Yams 檢查錯誤：\(error.localizedDescription)"
            resultColor = .red
        }
    }
}
