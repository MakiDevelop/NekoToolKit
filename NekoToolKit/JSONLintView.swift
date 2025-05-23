//
//  JSONLintView.swift
//  NekoToolKit
//
//  Created by 千葉牧人 on 2025/5/23.
//



import SwiftUI

struct JSONLintView: View {
    @State private var inputText: String = ""
    @State private var resultText: String = ""
    @State private var resultColor: Color = .primary
    @State private var copyStatusMessage: String? = nil
    @State private var enablePrettyPrint: Bool = false
    @State private var enableMinify: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            Text("JSON 格式檢查工具")
                .font(.headline)

            HStack(spacing: 12) {
                VStack(alignment: .leading) {
                    Text("輸入 JSON")
                        .font(.subheadline)
                    TextEditor(text: $inputText)
                        .frame(minHeight: 240)
                        .border(Color.gray)
                }

                VStack {
                    Button("檢查格式") {
                        lintJSON()
                    }
                }

                VStack(alignment: .leading) {
                    Text("檢查結果")
                        .font(.subheadline)
                    Text(resultText)
                        .foregroundColor(resultColor)
                        .frame(minHeight: 240, alignment: .topLeading)
                        .padding()
                        .border(Color.gray)

                    Button("複製結果") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(resultText, forType: .string)
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

            Toggle("自動格式化 JSON（Pretty）", isOn: $enablePrettyPrint)
                .onChange(of: enablePrettyPrint) { newValue in
                    if newValue { enableMinify = false }
                }
            Toggle("輸出為壓縮格式（Minify）", isOn: $enableMinify)
                .onChange(of: enableMinify) { newValue in
                    if newValue { enablePrettyPrint = false }
                }

            Button("清除") {
                inputText = ""
                resultText = ""
                resultColor = .primary
                copyStatusMessage = nil
            }
        }
        .padding()
    }

    private func lintJSON() {
        guard let data = inputText.data(using: .utf8) else {
            resultText = "⚠️ 輸入內容無法轉為 UTF-8"
            resultColor = .red
            return
        }

        do {
            let decoder = JSONDecoder()
            _ = try decoder.decode(JSONValue.self, from: data)

            if enablePrettyPrint || enableMinify {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
                let outputData = try JSONSerialization.data(
                    withJSONObject: jsonObject,
                    options: enablePrettyPrint ? [.prettyPrinted] : []
                )
                if let formatted = String(data: outputData, encoding: .utf8) {
                    resultText = formatted
                }
            } else {
                resultText = "✅ 格式正確"
            }
            resultColor = .green

        } catch {
            resultText = "❌ 錯誤：\(error.localizedDescription)\n\n請檢查是否有多餘逗號、單引號、錯誤括號等格式錯誤。"
            resultColor = .red
        }
    }

// 通用型 JSONValue 型別，可解出任意 JSON 結構
private enum JSONValue: Decodable {
    case string(String)
    case number(Double)
    case object([String: JSONValue])
    case array([JSONValue])
    case bool(Bool)
    case null

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let str = try? container.decode(String.self) {
            self = .string(str)
        } else if let num = try? container.decode(Double.self) {
            self = .number(num)
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let arr = try? container.decode([JSONValue].self) {
            self = .array(arr)
        } else if let dict = try? container.decode([String: JSONValue].self) {
            self = .object(dict)
        } else {
            throw DecodingError.typeMismatch(JSONValue.self, .init(codingPath: decoder.codingPath, debugDescription: "Unsupported JSON value"))
        }
    }
}
}
