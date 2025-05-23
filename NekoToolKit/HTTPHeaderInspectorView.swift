//
//  HTTPHeaderInspectorView.swift
//  NekoToolKit
//
//  Created by 千葉牧人 on 2025/5/23.
//

import SwiftUI

struct HTTPHeaderInspectorView: View {
    @State private var urlString: String = ""
    @State private var statusCode: String = ""
    @State private var responseHeaders: [String: String] = [:]
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack(spacing: 16) {
#if DEBUG
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                Text("⚠️ 預覽模式無法使用網路功能，請在 App 中執行此工具。")
                    .foregroundColor(.orange)
            }
#endif
            Text("HTTP Header 檢查工具")
                .font(.headline)

            HStack {
                TextField("請輸入網址（https://...）", text: $urlString)
                    .textFieldStyle(.roundedBorder)
                    .frame(minWidth: 400)
                Button("送出請求") {
                    fetchHeaders()
                }
            }

            if let error = errorMessage {
                Text("❌ 錯誤：\(error)")
                    .foregroundColor(.red)
            }

            if !statusCode.isEmpty {
                Text("HTTP 狀態碼：\(statusCode)")
                    .font(.subheadline)
                    .padding(.top)
            }

            if !responseHeaders.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("回應 Headers")
                        .font(.subheadline)
                    ScrollView {
                        ForEach(responseHeaders.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(key)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(value)
                                    .font(.system(size: 13, design: .monospaced))
                            }
                            Divider()
                        }
                    }
                    .frame(minHeight: 300)
                    .border(Color.gray)
                }
            }

            Spacer()
        }
        .padding()
    }

    private func fetchHeaders() {
        guard let url = URL(string: urlString) else {
            errorMessage = "無效的網址格式"
            return
        }

        errorMessage = nil
        statusCode = ""
        responseHeaders = [:]

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15", forHTTPHeaderField: "User-Agent")

        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    errorMessage = "無法取得有效的 HTTP 回應"
                    return
                }

                statusCode = "\(httpResponse.statusCode)"
                responseHeaders = httpResponse.allHeaderFields.reduce(into: [String: String]()) { result, pair in
                    if let key = pair.key as? String {
                        result[key] = "\(pair.value)"
                    }
                }
            }
        }.resume()
    }
}
