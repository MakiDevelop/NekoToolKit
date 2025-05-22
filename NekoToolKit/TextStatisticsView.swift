//
//  TextStatisticsView.swift
//  NekoToolKit
//
//  Created by 千葉牧人 on 2025/5/22.
//


import SwiftUI
import AppKit

struct TextStatisticsView: View {
    @State private var inputText: String = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("文字統計工具")
                .font(.headline)

            HStack(spacing: 12) {
                VStack(alignment: .leading) {
                    Text("輸入文字")
                        .font(.subheadline)
                    TextEditor(text: $inputText)
                        .frame(minHeight: 240)
                        .border(Color.gray)

                    HStack {
                        Button("清除") {
                            inputText = ""
                        }
                        .padding(.top)

                        Button("複製") {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(inputText, forType: .string)
                        }
                        .padding(.top)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("統計結果")
                        .font(.subheadline)
                    Group {
                        Text("總字數（不含換行）：\(inputText.replacingOccurrences(of: "\n", with: "").count)")
                        Text("全形字數：\(countFullWidthCharacters(in: inputText))")
                        Text("半形字數：\(countHalfWidthCharacters(in: inputText))")
                        Text("空白字元數：\(inputText.filter { $0.isWhitespace }.count)")
                        Text("標點符號數：\(countPunctuationCharacters(in: inputText))")
                    }
                    .font(.system(size: 14, design: .monospaced))
                }
                .frame(minWidth: 280, alignment: .leading)
            }
        }
        .padding()
    }

    private func countFullWidthCharacters(in text: String) -> Int {
        text.unicodeScalars.filter { ($0.value >= 0xFF01 && $0.value <= 0xFF60) || ($0.value >= 0xFFE0 && $0.value <= 0xFFE6) }.count
    }

    private func countHalfWidthCharacters(in text: String) -> Int {
        text.unicodeScalars.filter { $0.value <= 0x007E }.count
    }

    private func countPunctuationCharacters(in text: String) -> Int {
        let punctuation = CharacterSet.punctuationCharacters
            .union(.symbols)
            .union(.init(charactersIn: "、。！？；：「」『』（）《》【】—～…"))
        return text.unicodeScalars.filter { punctuation.contains($0) }.count
    }
}

#Preview {
    TextStatisticsView()
}
