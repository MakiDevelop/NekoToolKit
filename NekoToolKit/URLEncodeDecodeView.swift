//
//  URLEncodeDecodeView.swift
//  NekoToolKit
//
//  Created by 千葉牧人 on 2025/5/22.
//



import SwiftUI

struct URLEncodeDecodeView: View {
    @State private var leftText: String = ""
    @State private var rightText: String = ""
    @State private var errorMessage: String? = nil
    @State private var copyStatusMessage: String? = nil

    var body: some View {
        VStack(spacing: 16) {
            Text("URL 編碼／解碼工具")
                .font(.headline)

            HStack(spacing: 12) {
                VStack(alignment: .leading) {
                    Text("URL")
                        .font(.subheadline)
                    TextEditor(text: $leftText)
                        .frame(minHeight: 240)
                        .border(Color.gray)
                }

                VStack {
                    Button("轉換") {
                        convertURL()
                    }
                }

                VStack(alignment: .leading) {
                    Text("編碼後 URL")
                        .font(.subheadline)
                    TextEditor(text: $rightText)
                        .frame(minHeight: 240)
                        .border(Color.gray)

                    Button("複製結果") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(rightText, forType: .string)
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

            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button("清除") {
                leftText = ""
                rightText = ""
                errorMessage = nil
            }
            .padding(.top)
        }
        .padding()
    }

    private func convertURL() {
        errorMessage = nil

        // Case 1: 使用者貼在右邊（編碼內容） → decode 到左邊
        if !rightText.isEmpty,
           let decoded = rightText.removingPercentEncoding,
           decoded != rightText {
            leftText = decoded
            return
        }

        // Case 2: 使用者貼在左邊（原始內容） → encode 到右邊
        if !leftText.isEmpty,
           let encoded = leftText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           encoded != leftText {
            rightText = encoded
            return
        }

        errorMessage = "⚠️ 無法判斷要轉換哪一邊，請確認貼上的內容是否有效。"
    }
}

#Preview {
    URLEncodeDecodeView()
}
