//
//  NDJSONConvertView.swift
//  NekoToolKit
//
//  Created by 千葉牧人 on 2025/5/22.
//


import SwiftUI
import UniformTypeIdentifiers

struct NDJSONConvertView: View {
    enum OutputFormat: String, CaseIterable, Identifiable {
        case csv = "CSV"
        case tsv = "TSV"
        case jsonArray = "JSON Array"
        case yaml = "YAML"
        case markdown = "Markdown"
        case swiftStruct = "Swift Struct"
        case tsInterface = "TypeScript Interface"

        var id: String { self.rawValue }
    }

    @State private var selectedFormat: OutputFormat = .csv
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    @State private var copyStatusMessage: String? = nil

    var body: some View {
        VStack(spacing: 12) {
            Picker("輸出格式", selection: $selectedFormat) {
                ForEach(OutputFormat.allCases) { format in
                    Text(format.rawValue).tag(format)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedFormat) { _ in
                convert()
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
        .navigationTitle("NDJSON 轉換功能")
    }

    private func convert() {
        let lines = inputText
            .split(separator: "\n")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !lines.isEmpty else {
            outputText = "請輸入有效的 NDJSON 內容。"
            return
        }

        let jsonObjects: [[String: Any]] = lines.compactMap { line in
            guard let data = line.data(using: .utf8),
                  let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return nil
            }
            return obj
        }

        guard !jsonObjects.isEmpty else {
            outputText = "解析失敗：無法轉換為 JSON 物件陣列。"
            return
        }

        let table = jsonObjects.map { $0.mapValues { "\($0)" } }
        let headers = Array(Set(table.flatMap { $0.keys })).sorted()

        switch selectedFormat {
        case .csv:
            let rows = ([headers] + table.map { row in headers.map { row[$0] ?? "" } })
            outputText = rows.map { $0.joined(separator: ",") }.joined(separator: "\n")

        case .tsv:
            let rows = ([headers] + table.map { row in headers.map { row[$0] ?? "" } })
            outputText = rows.map { $0.joined(separator: "\t") }.joined(separator: "\n")

        case .jsonArray:
            if let data = try? JSONSerialization.data(withJSONObject: jsonObjects, options: [.prettyPrinted]),
               let str = String(data: data, encoding: .utf8) {
                outputText = str
            } else {
                outputText = "JSON 陣列輸出失敗。"
            }

        case .yaml:
            let yaml = table.map { row in
                let lines = row.map { "  \($0): \($1)" }
                return "-\n" + lines.joined(separator: "\n")
            }
            outputText = yaml.joined(separator: "\n")

        case .markdown:
            var out = "| " + headers.joined(separator: " | ") + " |\n"
            out += "| " + headers.map { _ in "---" }.joined(separator: " | ") + " |\n"
            for row in table {
                out += "| " + headers.map { row[$0] ?? "" }.joined(separator: " | ") + " |\n"
            }
            outputText = out

        case .swiftStruct:
            let fields = headers.map { "    let \($0): String" }.joined(separator: "\n")
            outputText = "struct MyModel: Codable {\n\(fields)\n}"

        case .tsInterface:
            let fields = headers.map { "  \($0): string;" }.joined(separator: "\n")
            outputText = "interface MyModel {\n\(fields)\n}"
        }
    }

    private func saveOutputToFile() {
        let panel = NSSavePanel()
        let fileExtension: String

        switch selectedFormat {
        case .csv: fileExtension = "csv"
        case .tsv: fileExtension = "tsv"
        case .jsonArray: fileExtension = "json"
        case .yaml: fileExtension = "yaml"
        case .markdown: fileExtension = "md"
        case .swiftStruct: fileExtension = "swift"
        case .tsInterface: fileExtension = "ts"
        }

        let contentType = UTType(filenameExtension: fileExtension) ?? .plainText
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
    NDJSONConvertView()
}
