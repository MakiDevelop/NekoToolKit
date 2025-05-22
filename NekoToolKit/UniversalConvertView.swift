//
//  UniversalConvertView.swift
//  NekoToolKit
//
//  Created by 千葉牧人 on 2025/5/22.
//


import SwiftUI
import UniformTypeIdentifiers

struct UniversalConvertView: View {
    enum Format: String, CaseIterable, Identifiable {
        case csv = "CSV"
        case tsv = "TSV"
        case json = "JSON"
        case yaml = "YAML"
        case markdown = "Markdown"
        case xml = "XML"

        var id: String { self.rawValue }
    }

    @State private var inputFormat: Format = .csv
    @State private var outputFormat: Format = .json
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    @State private var detectedFormatMessage: String?
    @State private var copyStatusMessage: String? = nil

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Picker("輸入格式", selection: $inputFormat) {
                    ForEach(Format.allCases) { format in
                        Text(format.rawValue).tag(format)
                    }
                }
                .pickerStyle(.segmented)

                Picker("輸出格式", selection: $outputFormat) {
                    ForEach(Format.allCases) { format in
                        Text(format.rawValue).tag(format)
                    }
                }
                .pickerStyle(.segmented)
            }
            if let message = detectedFormatMessage {
                Text(message)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 12) {
                TextEditor(text: $inputText)
                    .border(Color.gray)
                    .frame(minHeight: 300)

                VStack {
                    Button("轉換") {
                        convert()
                    }
                    .padding(.horizontal)
                }

                TextEditor(text: $outputText)
                    .border(Color.gray)
                    .frame(minHeight: 300)
            }

            HStack {
                Button("清除") {
                    inputText = ""
                    outputText = ""
                }

                VStack(spacing: 2) {
                    Button("複製內容") {
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

                Spacer()

                Button("另存新檔") {
                    saveOutputToFile()
                }
            }
            .padding(.top, 8)
        }
        .padding()
        .navigationTitle("格式轉換工具")
        .onChange(of: inputText) { newValue in
            if let detected = detectFormat(from: newValue) {
                if detected != inputFormat {
                    detectedFormatMessage = "⚠️ 系統偵測為 \(detected.rawValue)，但目前選擇為 \(inputFormat.rawValue)。可能會導致錯誤。"
                } else {
                    detectedFormatMessage = "已自動偵測到格式：\(detected.rawValue)"
                }
            } else {
                detectedFormatMessage = nil
            }
        }
    }

    private func convert() {
        if inputFormat == outputFormat {
            outputText = inputText
            return
        }
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            outputText = "請輸入內容。"
            return
        }

        // Step 1: Parse to intermediate [[String: String]]
        let table: [[String: String]]
        let headers: [String]

        switch inputFormat {
        case .csv:
            let rows = inputText.split(separator: "\n").map {
                $0.split(separator: ",", omittingEmptySubsequences: false).map(String.init)
            }
            guard let first = rows.first else {
                outputText = "CSV 格式錯誤。"
                return
            }
            headers = first
            table = rows.dropFirst().map { row in
                Dictionary(uniqueKeysWithValues: zip(headers, row))
            }

        case .tsv:
            let rows = inputText.split(separator: "\n").map {
                $0.split(separator: "\t", omittingEmptySubsequences: false).map(String.init)
            }
            guard let first = rows.first else {
                outputText = "TSV 格式錯誤。"
                return
            }
            headers = first
            table = rows.dropFirst().map { row in
                Dictionary(uniqueKeysWithValues: zip(headers, row))
            }

        case .json:
            guard let data = inputText.data(using: .utf8),
                  let array = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                outputText = "JSON 格式錯誤或不是物件陣列。"
                return
            }
            table = array.map { dict in
                dict.mapValues { "\($0)" }
            }
            headers = Array(Set(table.flatMap { $0.keys })).sorted()

        case .markdown:
            let lines = inputText.split(separator: "\n").map { $0.trimmingCharacters(in: .whitespaces) }
            guard lines.count >= 3 else {
                outputText = "Markdown 表格內容不足。"
                return
            }

            let headerLine = lines[0]
            let headersParsed = headerLine
                .trimmingCharacters(in: CharacterSet(charactersIn: "| "))
                .components(separatedBy: "|")
                .map { $0.trimmingCharacters(in: .whitespaces) }

            let dataLines = lines.dropFirst(2)
            let tableParsed = dataLines.map { line in
                let values = line
                    .trimmingCharacters(in: CharacterSet(charactersIn: "| "))
                    .components(separatedBy: "|")
                    .map { $0.trimmingCharacters(in: .whitespaces) }
                return Dictionary(uniqueKeysWithValues: zip(headersParsed, values))
            }

            headers = headersParsed
            table = tableParsed

        case .yaml:
            let lines = inputText.split(separator: "\n").map { String($0).trimmingCharacters(in: .whitespaces) }

            var currentItem: [String: String] = [:]
            var parsedTable: [[String: String]] = []

            for line in lines {
                if line.hasPrefix("-") {
                    if !currentItem.isEmpty {
                        parsedTable.append(currentItem)
                        currentItem = [:]
                    }
                } else if line.contains(":") {
                    let parts = line.split(separator: ":", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
                    if parts.count == 2 {
                        currentItem[parts[0]] = parts[1].replacingOccurrences(of: "^\"|\"$", with: "", options: .regularExpression)
                    }
                }
            }
            if !currentItem.isEmpty {
                parsedTable.append(currentItem)
            }

            table = parsedTable
            headers = Array(Set(parsedTable.flatMap { $0.keys })).sorted()
        case .xml:
            outputText = "尚未支援作為輸入格式：XML"
            return
        }

        // Step 2: Export to output format
        switch outputFormat {
        case .csv:
            let result = ([headers] + table.map { row in headers.map { row[$0] ?? "" } })
            let csvRows = result
                .map { $0.joined(separator: ",") }
                .joined(separator: "\n")
            outputText = csvRows

        case .tsv:
            let tsvRows = ([headers] + table.map { row in headers.map { row[$0] ?? "" } })
                .map { $0.joined(separator: "\t") }
                .joined(separator: "\n")
            outputText = tsvRows

        case .json:
            if let data = try? JSONSerialization.data(withJSONObject: table, options: [.prettyPrinted]),
               let jsonStr = String(data: data, encoding: .utf8) {
                outputText = jsonStr
            } else {
                outputText = "轉換 JSON 時失敗。"
            }

        case .yaml:
            let yaml = table.map { row in
                let lines = row.map { "  \($0): \($1)" }.joined(separator: "\n")
                return "-\n\(lines)"
            }.joined(separator: "\n")
            outputText = yaml

        case .markdown:
            var result = "| " + headers.joined(separator: " | ") + " |\n"
            result += "| " + headers.map { _ in "---" }.joined(separator: " | ") + " |\n"
            for row in table {
                let line = headers.map { row[$0] ?? "" }.joined(separator: " | ")
                result += "| \(line) |\n"
            }
            outputText = result

        case .xml:
            var xml = "<items>\n"
            for row in table {
                xml += "  <item>\n"
                for (key, value) in row {
                    xml += "    <\(key)>\(value)</\(key)>\n"
                }
                xml += "  </item>\n"
            }
            xml += "</items>"
            outputText = xml
        }
    }

    private func saveOutputToFile() {
        let panel = NSSavePanel()

        let fileExtension: String = outputFormat.rawValue.lowercased()
        let contentType: UTType = UTType(filenameExtension: fileExtension) ?? .plainText

        panel.allowedContentTypes = [contentType]
        panel.nameFieldStringValue = "export.\(fileExtension)"
        panel.canCreateDirectories = true

        panel.begin { response in
            if response == .OK, let url = panel.url {
                do {
                    try outputText.write(to: url, atomically: true, encoding: .utf8)
                } catch {
                    print("儲存失敗：\(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    UniversalConvertView()
}

    private func detectFormat(from text: String) -> UniversalConvertView.Format? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasPrefix("{") || trimmed.hasPrefix("[") {
            return .json
        } else if trimmed.contains("\t") {
            return .tsv
        } else if trimmed.contains(",") {
            return .csv
        } else if trimmed.contains(":") && trimmed.contains("-") {
            return .yaml
        } else {
            return nil
        }
    }
