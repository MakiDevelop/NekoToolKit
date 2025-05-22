//
//  SingleLineConvertView.swift
//  NekoToolKit
//
//  Created by 千葉牧人 on 2025/5/22.
//



import SwiftUI

struct SingleLineConvertView: View {
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    @State private var copyStatusMessage: String? = nil

    var body: some View {
        VStack(spacing: 16) {
            Text("轉成單行工具")
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
                    Button("轉成單行") {
                        convertToSingleLine()
                    }
                }

                VStack(alignment: .leading) {
                    Text("轉換結果")
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

    private func convertToSingleLine() {
        // 轉換：去除換行符號，換成單一空白
        outputText = inputText
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}

#Preview {
    SingleLineConvertView()
}
