//
//  TextDiffView.swift
//  NekoToolKit
//
//  Created by 千葉牧人 on 2025/5/23.
//

import SwiftUI

struct TextDiffView: View {
    @State private var originalText: String = ""
    @State private var comparedText: String = ""
    @State private var diffResult: String = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("文字差異比對工具")
                .font(.headline)

            HStack(spacing: 12) {
                VStack(alignment: .leading) {
                    Text("原始文字")
                        .font(.subheadline)
                    TextEditor(text: $originalText)
                        .frame(minHeight: 200)
                        .border(Color.gray)
                }

                VStack(alignment: .leading) {
                    Text("比較文字")
                        .font(.subheadline)
                    TextEditor(text: $comparedText)
                        .frame(minHeight: 200)
                        .border(Color.gray)
                }
            }

            Button("比對差異") {
                diffResult = computeDiff(from: originalText, to: comparedText)
            }

            VStack(alignment: .leading) {
                Text("差異結果")
                    .font(.subheadline)
                ScrollView {
                    Text(diffResult)
                        .font(.system(size: 13, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
                .frame(minHeight: 240)
                .border(Color.gray)
            }

            Button("清除") {
                originalText = ""
                comparedText = ""
                diffResult = ""
            }
        }
        .padding()
    }

    private func computeDiff(from old: String, to new: String) -> String {
        let oldLines = old.components(separatedBy: .newlines)
        let newLines = new.components(separatedBy: .newlines)

        var result: [String] = []
        let maxCount = max(oldLines.count, newLines.count)

        for i in 0..<maxCount {
            let oldLine = i < oldLines.count ? oldLines[i] : nil
            let newLine = i < newLines.count ? newLines[i] : nil

            if oldLine == newLine {
                if let line = oldLine {
                    result.append("  \(line)")
                }
            } else {
                if let oldLine = oldLine {
                    result.append("- \(oldLine)")
                }
                if let newLine = newLine {
                    result.append("+ \(newLine)")
                }
            }
        }

        return result.joined(separator: "\n")
    }
}
