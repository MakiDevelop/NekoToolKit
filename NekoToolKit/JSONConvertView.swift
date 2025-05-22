import SwiftUI
import UniformTypeIdentifiers

struct JSONConvertView: View {
    enum OutputFormat: String, CaseIterable, Identifiable {
        case csv = "CSV"
        case tsv = "TSV"
        case yaml = "YAML"
        case markdown = "Markdown"
        case swiftStruct = "Swift Struct"
        case tsInterface = "TypeScript Interface"
        case prettyJSON = "Pretty JSON"
        case xml = "XML"

        var id: String { self.rawValue }
    }

    @State private var selectedFormat: OutputFormat = .csv
    @State private var inputText: String = ""
    @State private var outputText: String = ""

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

                Spacer()

                Button("另存新檔") {
                    saveOutputToFile()
                }
            }
            .padding(.top, 8)
        }
        .padding()
        .navigationTitle("JSON 轉換功能")
    }

    private func convert() {
        guard let data = inputText.data(using: .utf8) else {
            outputText = "輸入內容不是有效的 UTF-8 編碼文字。"
            return
        }

        guard let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            outputText = "JSON 格式錯誤，必須是物件陣列（Array of Objects）。"
            return
        }

        // 收集所有欄位名稱
        let headers = Array(Set(jsonArray.flatMap { $0.keys })).sorted()
        let rows = jsonArray.map { row in
            headers.map { key in
                if let value = row[key] {
                    return "\(value)"
                } else {
                    return ""
                }
            }
        }

        switch selectedFormat {
        case .csv:
            // CSV 需處理逗號與引號
            func escapeCSV(_ value: String) -> String {
                if value.contains(",") || value.contains("\"") || value.contains("\n") {
                    let escaped = value.replacingOccurrences(of: "\"", with: "\"\"")
                    return "\"\(escaped)\""
                }
                return value
            }
            var output = headers.joined(separator: ",") + "\n"
            output += rows.map { $0.map(escapeCSV).joined(separator: ",") }.joined(separator: "\n")
            outputText = output

        case .tsv:
            var output = headers.joined(separator: "\t") + "\n"
            output += rows.map { $0.joined(separator: "\t") }.joined(separator: "\n")
            outputText = output

        case .yaml:
            let yaml = jsonArray.map { obj in
                let lines = obj.map { (key, value) in
                    // YAML 字串值加引號（簡單處理）
                    let strVal: String
                    if value is String {
                        strVal = "\"\(value)\""
                    } else {
                        strVal = "\(value)"
                    }
                    return "  \(key): \(strVal)"
                }.joined(separator: "\n")
                return "-\n\(lines)"
            }
            outputText = yaml.joined(separator: "\n")

        case .markdown:
            var output = "| " + headers.joined(separator: " | ") + " |\n"
            output += "| " + headers.map { _ in "---" }.joined(separator: " | ") + " |\n"
            output += rows.map { "| " + $0.joined(separator: " | ") + " |" }.joined(separator: "\n")
            outputText = output
            
        case .swiftStruct:
            let structName = "MyModel"
            let fields = headers.map { "    let \($0): String" }.joined(separator: "\n")
            outputText = "struct \(structName): Codable {\n\(fields)\n}"
            
        case .tsInterface:
            let fields = headers.map { "  \($0): string;" }.joined(separator: "\n")
            outputText = "interface MyModel {\n\(fields)\n}"
            
        case .prettyJSON:
            if let data = try? JSONSerialization.data(withJSONObject: jsonArray, options: [.prettyPrinted]),
               let pretty = String(data: data, encoding: .utf8) {
                outputText = pretty
            } else {
                outputText = "無法格式化 JSON。"
            }
            
        case .xml:
            var xml = "<items>\n"
            for dict in jsonArray {
                xml += "  <item>\n"
                for (key, value) in dict {
                    let escaped = "\(value)".replacingOccurrences(of: "&", with: "&amp;")
                                              .replacingOccurrences(of: "<", with: "&lt;")
                                              .replacingOccurrences(of: ">", with: "&gt;")
                    xml += "    <\(key)>\(escaped)</\(key)>\n"
                }
                xml += "  </item>\n"
            }
            xml += "</items>"
            outputText = xml
        }
    }

    private func saveOutputToFile() {
        let panel = NSSavePanel()

        let fileExtension: String
        switch selectedFormat {
        case .csv: fileExtension = "csv"
        case .tsv: fileExtension = "tsv"
        case .yaml: fileExtension = "yaml"
        case .markdown: fileExtension = "md"
        case .swiftStruct: fileExtension = "swift"
        case .tsInterface: fileExtension = "ts"
        case .prettyJSON: fileExtension = "json"
        case .xml: fileExtension = "xml"
        }

        let contentType: UTType
        switch selectedFormat {
        case .csv: contentType = .commaSeparatedText
        case .tsv: contentType = .tabSeparatedText
        case .yaml: contentType = UTType(filenameExtension: "yaml") ?? .plainText
        case .markdown: contentType = .plainText
        case .swiftStruct: contentType = UTType(filenameExtension: "swift") ?? .plainText
        case .tsInterface: contentType = UTType(filenameExtension: "ts") ?? .plainText
        case .prettyJSON: contentType = UTType.json
        case .xml: contentType = UTType(filenameExtension: "xml") ?? .plainText
        }

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
    JSONConvertView()
}
