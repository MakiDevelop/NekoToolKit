//
//  HashGeneratorView.swift.swift
//  NekoToolKit
//
//  Created by 千葉牧人 on 2025/5/23.
//


import SwiftUI
import CryptoKit

struct HashGeneratorView: View {
    enum HashType: String, CaseIterable, Identifiable {
        case md5 = "MD5"
        case sha1 = "SHA1"
        case sha256 = "SHA256"
        case sha384 = "SHA384"
        case sha512 = "SHA512"

        var id: String { rawValue }
    }

    @State private var inputText: String = ""
    @State private var selectedHash: HashType = .md5
    @State private var outputHash: String = ""
    @State private var copyStatusMessage: String? = nil

    var body: some View {
        VStack(spacing: 16) {
            Text("雜湊生成器")
                .font(.headline)

            Picker("演算法", selection: $selectedHash) {
                ForEach(HashType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)

            TextEditor(text: $inputText)
                .frame(height: 160)
                .border(Color.gray)

            Button("產生雜湊") {
                generateHash()
            }

            VStack(alignment: .leading) {
                Text("結果")
                    .font(.subheadline)
                Text(outputHash)
                    .font(.system(size: 14, design: .monospaced))
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(NSColor.textBackgroundColor))
                    .border(Color.gray)
            }

            HStack {
                Button("複製結果") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(outputHash, forType: .string)
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

                Spacer()

                Button("清除") {
                    inputText = ""
                    outputHash = ""
                    copyStatusMessage = nil
                }
            }
        }
        .padding()
    }

    private func generateHash() {
        guard let data = inputText.data(using: .utf8) else {
            outputHash = "⚠️ 無法編碼文字"
            return
        }

        switch selectedHash {
        case .md5:
            let digest = Insecure.MD5.hash(data: data)
            outputHash = digest.map { String(format: "%02hhx", $0) }.joined()
        case .sha1:
            let digest = Insecure.SHA1.hash(data: data)
            outputHash = digest.map { String(format: "%02hhx", $0) }.joined()
        case .sha256:
            let digest = SHA256.hash(data: data)
            outputHash = digest.map { String(format: "%02hhx", $0) }.joined()
        case .sha384:
            let digest = SHA384.hash(data: data)
            outputHash = digest.map { String(format: "%02hhx", $0) }.joined()
        case .sha512:
            let digest = SHA512.hash(data: data)
            outputHash = digest.map { String(format: "%02hhx", $0) }.joined()
        }
    }
}
