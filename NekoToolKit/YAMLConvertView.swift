//
//  YAMLConvertView.swift
//  NekoToolKit
//
//  Created by 千葉牧人 on 2025/5/22.
//


import SwiftUI
import UniformTypeIdentifiers

struct YAMLConvertView: View {
    enum OutputFormat: String, CaseIterable, Identifiable {
        case json = "JSON"
        case csv = "CSV"
        case tsv = "TSV"
        case markdown = "Markdown"
        case swiftStruct = "Swift Struct"
        case tsInterface = "TypeScript Interface"

        var id: String { self.rawValue }
    }

    @State private var selectedFormat: OutputFormat = .json
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
        .navigationTitle("YAML 轉換功能")
    }

    private func convert() {
        // Step 1: Parse YAML into [[String: String]]
        let lines = inputText
            .split(separator: "\n")
            .map { String($0).trimmingCharacters(in: .whitespaces) }

        var current: [String: String] = [:]
        var parsed: [[String: String]] = []

        for line in lines {
            if line.hasPrefix("-") {
                if !current.isEmpty {
                    parsed.append(current)
                    current = [:]
                }
            } else if line.contains(":") {
                let parts = line.split(separator: ":", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
                if parts.count == 2 {
                    current[parts[0]] = parts[1].replacingOccurrences(of: "^\"|\"$", with: "", options: .regularExpression)
                }
            }
        }
        if !current.isEmpty {
            parsed.append(current)
        }

        // Find all keys (headers)
        let headers = Array(Set(parsed.flatMap { $0.keys })).sorted()

        switch selectedFormat {
        case .json:
            if let jsonData = try? JSONSerialization.data(withJSONObject: parsed, options: [.prettyPrinted]),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                outputText = jsonString
            } else {
                outputText = "JSON 輸出失敗。"
            }

        case .csv:
            let rows = ([headers] + parsed.map { row in headers.map { row[$0] ?? "" } })
            outputText = rows.map { $0.joined(separator: ",") }.joined(separator: "\n")

        case .tsv:
            let rows = ([headers] + parsed.map { row in headers.map { row[$0] ?? "" } })
            outputText = rows.map { $0.joined(separator: "\t") }.joined(separator: "\n")

        case .markdown:
            var out = "| " + headers.joined(separator: " | ") + " |\n"
            out += "| " + headers.map { _ in "---" }.joined(separator: " | ") + " |\n"
            for row in parsed {
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
        case .json: fileExtension = "json"
        case .csv: fileExtension = "csv"
        case .tsv: fileExtension = "tsv"
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
    YAMLConvertView()
}
