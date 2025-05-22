//
//  NumberListGeneratorView.swift
//  NekoToolKit
//
//  Created by 千葉牧人 on 2025/5/22.
//

import SwiftUI

struct NumberListGeneratorView: View {
    @State private var start: Int = 1
    @State private var end: Int = 10
    @State private var step: Int = 1
    @State private var paddingLength: Int = 0
    @State private var delimiter: String = "\n"
    @State private var result: String = ""
    @State private var copyStatusMessage: String? = nil

    var body: some View {
        VStack(spacing: 16) {
            Text("數字列表產生器")
                .font(.headline)

            HStack(spacing: 12) {
                VStack(alignment: .leading) {
                    HStack {
                        Text("起始：")
                        TextField("Start", value: $start, formatter: NumberFormatter())
                            .frame(width: 80)
                    }
                    HStack {
                        Text("結束：")
                        TextField("End", value: $end, formatter: NumberFormatter())
                            .frame(width: 80)
                    }
                    HStack {
                        Text("間距：")
                        TextField("Step", value: $step, formatter: NumberFormatter())
                            .frame(width: 80)
                    }
                    HStack {
                        Text("補零位數：")
                        TextField("0 表示不補", value: $paddingLength, formatter: NumberFormatter())
                            .frame(width: 80)
                    }
                    HStack {
                        Text("分隔符號：")
                        TextField("預設為換行", text: $delimiter)
                            .frame(width: 120)
                    }
                }

                VStack {
                    Button("產生") {
                        generate()
                    }
                }

                VStack(alignment: .leading) {
                    Text("結果")
                        .font(.subheadline)
                    TextEditor(text: $result)
                        .frame(minHeight: 240)
                        .border(Color.gray)

                    Button("複製結果") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(result, forType: .string)
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
                result = ""
                copyStatusMessage = nil
            }
        }
        .padding()
    }

    private func generate() {
        guard step != 0 else {
            result = "⚠️ 間距不可為 0"
            return
        }

        let direction = start <= end ? 1 : -1
        let actualStep = abs(step) * direction

        var numbers: [String] = []
        var current = start

        while (direction > 0 && current <= end) || (direction < 0 && current >= end) {
            let formatted = String(format: "%0\(paddingLength)d", current)
            numbers.append(paddingLength > 0 ? formatted : "\(current)")
            current += actualStep
        }

        result = numbers.joined(separator: delimiter.isEmpty ? "\n" : delimiter)
    }
}

#Preview {
    NumberListGeneratorView()
}
