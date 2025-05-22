//
//  DeduplicateLinesView.swift
//  NekoToolKit
//
//  Created by 千葉牧人 on 2025/5/22.
//


import SwiftUI

struct DeduplicateLinesView: View {
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    @State private var copyStatusMessage: String? = nil

    var body: some View {
        VStack(spacing: 16) {
            Text("重複行清理工具")
                .font(.headline)

            HStack(spacing: 12) {
                VStack(alignment: .leading) {
                    Text("原始文字")
                        .font(.subheadline)
                    TextEditor(text: $inputText)
                        .frame(minHeight: 240)
                        .border(Color.gray)
                }

                VStack {
                    Button("去除重複") {
                        deduplicateLines()
                    }
                }

                VStack(alignment: .leading) {
                    Text("清理後結果")
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
            .padding(.top)
        }
        .padding()
    }

    private func deduplicateLines() {
        let lines = inputText.components(separatedBy: .newlines)
        let uniqueLines = Array(NSOrderedSet(array: lines)) as! [String]
        outputText = uniqueLines.joined(separator: "\n")
    }
}

#Preview {
    DeduplicateLinesView()
}
