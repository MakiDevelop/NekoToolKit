//
//  ChineseConvertView.swift
//  NekoToolKit
//
//  Created by 千葉牧人 on 2025/5/22.
//

import SwiftUI

struct ChineseConvertView: View {
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    @State private var isToSimplified: Bool = true
    @State private var copyStatusMessage: String? = nil

    var body: some View {
        VStack(spacing: 16) {
            Text("繁體／簡體轉換工具")
                .font(.headline)

            Picker("轉換方向", selection: $isToSimplified) {
                Text("繁體 ➜ 簡體").tag(true)
                Text("簡體 ➜ 繁體").tag(false)
            }
            .pickerStyle(.segmented)

            HStack(spacing: 12) {
                VStack(alignment: .leading) {
                    Text("原始文字")
                        .font(.subheadline)
                    TextEditor(text: $inputText)
                        .frame(minHeight: 240)
                        .border(Color.gray)
                }

                VStack {
                    Button("轉換") {
                        convert()
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

    private func convert() {
        if isToSimplified {
            outputText = convertToSimplified(inputText)
        } else {
            outputText = convertToTraditional(inputText)
        }
    }

    private func convertToSimplified(_ text: String) -> String {
        let mutableString = NSMutableString(string: text)
        CFStringTransform(mutableString, nil, "Traditional-Simplified" as CFString, false)
        return mutableString as String
    }

    private func convertToTraditional(_ text: String) -> String {
        let mutableString = NSMutableString(string: text)
        CFStringTransform(mutableString, nil, "Simplified-Traditional" as CFString, false)
        return mutableString as String
    }
}

#Preview {
    ChineseConvertView()
}
