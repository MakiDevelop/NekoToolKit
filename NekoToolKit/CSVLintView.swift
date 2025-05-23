//
//  CSVLintView.swift
//  NekoToolKit
//
//  Created by 千葉牧人 on 2025/5/23.
//



import SwiftUI

struct CSVLintView: View {
    @State private var inputText: String = ""
    @State private var resultText: String = ""
    @State private var resultColor: Color = .primary
    @State private var copyStatusMessage: String? = nil
    @State private var errorLines: Set<Int> = []

    var body: some View {
        VStack(spacing: 16) {
            Text("CSV 格式檢查工具")
                .font(.headline)

            HStack(spacing: 12) {
                VStack(alignment: .leading) {
                    Text("輸入 CSV")
                        .font(.subheadline)
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $inputText)
                            .font(.system(.body, design: .monospaced))
                            .padding(4)
                            .border(Color.gray)

                        GeometryReader { geometry in
                            let lines = inputText.components(separatedBy: .newlines)
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(Array(lines.enumerated()), id: \.offset) { index, _ in
                                    Rectangle()
                                        .fill(errorLines.contains(index + 1) ? Color.red.opacity(0.2) : Color.clear)
                                        .frame(height: 20)
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
                        lintCSV()
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

    private func lintCSV() {
        let rows = inputText.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        guard let firstRow = rows.first else {
            resultText = "⚠️ 無資料可檢查"
            resultColor = .red
            return
        }

        let expectedCount = firstRow.split(separator: ",", omittingEmptySubsequences: false).count
        var invalidLines: [Int] = []
        errorLines = []

        for (index, row) in rows.enumerated() {
            let count = row.split(separator: ",", omittingEmptySubsequences: false).count
            if count != expectedCount {
                invalidLines.append(index + 1)
                errorLines.insert(index + 1)
            }
        }

        if invalidLines.isEmpty {
            resultText = "✅ 格式正確，共 \(rows.count) 行，欄位數一致（\(expectedCount) 欄）。"
            resultColor = .green
        } else {
            resultText = """
            ❌ 發現欄位數不一致：
            預期欄數：\(expectedCount)
            異常行號：\(invalidLines.map(String.init).joined(separator: ", "))
            """
            resultColor = .red
        }
    }
}
