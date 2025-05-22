//
//  Base64ConvertView.swift
//  NekoToolKit
//
//  Created by 千葉牧人 on 2025/5/22.
//


import SwiftUI

struct Base64ConvertView: View {
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    @State private var copyStatusMessage: String? = nil

    var body: some View {
        VStack(spacing: 16) {
            Text("Base64 編碼／解碼工具")
                .font(.headline)

            HStack(spacing: 12) {
                // 左側輸入區
                VStack(alignment: .leading) {
                    Text("原始文字")
                        .font(.subheadline)
                    TextEditor(text: $inputText)
                        .frame(minHeight: 240)
                        .border(Color.gray)
                }

                // 中間按鈕區
                VStack {
                    Button("編碼成 Base64") {
                        encodeBase64()
                    }
                    .padding(.bottom)

                    Button("解碼回原文") {
                        decodeBase64()
                    }
                }

                // 右側輸出區
                VStack(alignment: .leading) {
                    Text("結果")
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

            // 清除按鈕
            Button("清除") {
                inputText = ""
                outputText = ""
            }
            .padding(.top)
        }
        .padding()
    }

    private func encodeBase64() {
        let data = inputText.data(using: .utf8) ?? Data()
        outputText = data.base64EncodedString()
    }

    private func decodeBase64() {
        guard let data = Data(base64Encoded: outputText),
              let str = String(data: data, encoding: .utf8) else {
            inputText = "❌ 解碼失敗，請確認輸入的 Base64 是否正確。"
            return
        }
        inputText = str
    }
}

#Preview {
    Base64ConvertView()
}
