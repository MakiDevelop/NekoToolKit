
//
//  PasswordGeneratorView.swift
//  NekoToolKit
//
//  Created by 千葉牧人 on 2025/5/23.
//

import SwiftUI

struct PasswordGeneratorView: View {
    @State private var length: Double = 12
    @State private var includeLowercase = true
    @State private var includeUppercase = true
    @State private var includeNumbers = true
    @State private var includeSymbols = false
    @State private var generatedPassword = ""
    @State private var copyStatusMessage: String? = nil

    var body: some View {
        VStack(spacing: 16) {
            Text("密碼生成器")
                .font(.headline)

            HStack {
                Text("長度：\(Int(length))")
                Slider(value: $length, in: 4...64, step: 1)
                    .frame(width: 200)
            }

            Toggle("包含小寫字母（a-z）", isOn: $includeLowercase)
            Toggle("包含大寫字母（A-Z）", isOn: $includeUppercase)
            Toggle("包含數字（0-9）", isOn: $includeNumbers)
            Toggle("包含符號（!@#$%^&*...）", isOn: $includeSymbols)

            Button("產生密碼") {
                generatedPassword = generatePassword()
            }

            VStack(alignment: .leading) {
                Text("結果")
                    .font(.subheadline)
                Text(generatedPassword)
                    .font(.system(size: 16, design: .monospaced))
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(NSColor.textBackgroundColor))
                    .border(Color.gray)
            }

            HStack {
                Button("複製結果") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(generatedPassword, forType: .string)
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
                    generatedPassword = ""
                    copyStatusMessage = nil
                }
            }
        }
        .padding()
    }

    private func generatePassword() -> String {
        var characters = ""
        if includeLowercase { characters += "abcdefghijklmnopqrstuvwxyz" }
        if includeUppercase { characters += "ABCDEFGHIJKLMNOPQRSTUVWXYZ" }
        if includeNumbers { characters += "0123456789" }
        if includeSymbols { characters += "!@#$%^&*()-_=+[]{}|;:,.<>?/`~" }

        guard !characters.isEmpty else { return "⚠️ 請至少勾選一種字元類型" }

        return String((0..<Int(length)).compactMap { _ in characters.randomElement() })
    }
}

