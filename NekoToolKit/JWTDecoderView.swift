//
//  JWTDecoderView.swift
//  NekoToolKit
//
//  Created by 千葉牧人 on 2025/5/23.
//

import SwiftUI

struct JWTDecoderView: View {
    @State private var jwtInput: String = ""
    @State private var headerOutput: String = ""
    @State private var payloadOutput: String = ""
    @State private var decodeError: String? = nil

    var body: some View {
        VStack(spacing: 16) {
            Text("JWT 解碼器")
                .font(.headline)

            TextField("貼上 JWT（格式為 xxx.yyy.zzz）", text: $jwtInput)
                .textFieldStyle(.roundedBorder)

            Button("解碼") {
                decodeJWT()
            }

            if let error = decodeError {
                Text("❌ 錯誤：\(error)")
                    .foregroundColor(.red)
            } else {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Header")
                            .font(.subheadline)
                        TextEditor(text: $headerOutput)
                            .font(.system(size: 13, design: .monospaced))
                            .frame(minHeight: 160)
                            .border(Color.gray)
                    }

                    VStack(alignment: .leading) {
                        Text("Payload")
                            .font(.subheadline)
                        TextEditor(text: $payloadOutput)
                            .font(.system(size: 13, design: .monospaced))
                            .frame(minHeight: 160)
                            .border(Color.gray)
                    }
                }
            }

            Button("清除") {
                jwtInput = ""
                headerOutput = ""
                payloadOutput = ""
                decodeError = nil
            }
        }
        .padding()
    }

    private func decodeJWT() {
        headerOutput = ""
        payloadOutput = ""
        decodeError = nil

        let parts = jwtInput.split(separator: ".")
        guard parts.count >= 2 else {
            decodeError = "JWT 必須至少包含兩段（header.payload）"
            return
        }

        func decodeBase64URL(_ str: Substring) -> Data? {
            var base64 = str.replacingOccurrences(of: "-", with: "+")
                              .replacingOccurrences(of: "_", with: "/")
            let remainder = base64.count % 4
            if remainder > 0 {
                base64 += String(repeating: "=", count: 4 - remainder)
            }
            return Data(base64Encoded: base64)
        }

        func formatJSON(_ data: Data) -> String {
            if let object = try? JSONSerialization.jsonObject(with: data, options: []),
               let prettyData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
               let jsonString = String(data: prettyData, encoding: .utf8) {
                return jsonString
            } else {
                return String(decoding: data, as: UTF8.self)
            }
        }

        if let headerData = decodeBase64URL(parts[0]),
           let payloadData = decodeBase64URL(parts[1]) {
            headerOutput = formatJSON(headerData)
            payloadOutput = formatJSON(payloadData)
        } else {
            decodeError = "Base64 解碼失敗，請確認 JWT 是否正確。"
        }
    }
}
