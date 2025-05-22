import SwiftUI
import UniformTypeIdentifiers

struct XMLConvertView: View {
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
        .navigationTitle("XML 轉換功能")
    }

    private func convert() {
        guard let data = inputText.data(using: .utf8) else {
            outputText = "無法轉換為 UTF-8。"
            return
        }

        let parser = XMLParser(data: data)
        let delegate = SimpleXMLTableParser()
        parser.delegate = delegate

        guard parser.parse() else {
            outputText = "XML 解析失敗。"
            return
        }

        let table = delegate.rows
        let headers = Array(Set(table.flatMap { $0.keys })).sorted()

        switch selectedFormat {
        case .json:
            if let jsonData = try? JSONSerialization.data(withJSONObject: table, options: [.prettyPrinted]),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                outputText = jsonString
            } else {
                outputText = "JSON 輸出失敗。"
            }
        case .csv:
            let rows = ([headers] + table.map { row in headers.map { row[$0] ?? "" } })
            outputText = rows.map { $0.joined(separator: ",") }.joined(separator: "\n")
        case .tsv:
            let rows = ([headers] + table.map { row in headers.map { row[$0] ?? "" } })
            outputText = rows.map { $0.joined(separator: "\t") }.joined(separator: "\n")
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
    XMLConvertView()
}

// MARK: - SimpleXMLTableParser

class SimpleXMLTableParser: NSObject, XMLParserDelegate {
    var rows: [[String: String]] = []
    private var currentRow: [String: String] = [:]
    private var currentElement: String = ""
    private var currentValue: String = ""
    private var elementStack: [String] = []

    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        elementStack.append(elementName)
        currentElement = elementName
        // 偵測到重複的物件元素（如 user/item/row），開始新 row
        if let parent = elementStack.dropLast().last,
           (parent.hasSuffix("s") && elementName == String(parent.dropLast())) ||
            elementName == "item" || elementName == "row"
        {
            currentRow = [:]
        }
        currentValue = ""
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentValue += string
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?) {
        // 跳過集合元素
        if let parent = elementStack.dropLast().last,
           (parent.hasSuffix("s") && elementName == String(parent.dropLast())) ||
            elementName == "item" || elementName == "row"
        {
            // 完成一個 row
            if !currentRow.isEmpty {
                rows.append(currentRow)
                currentRow = [:]
            }
        } else if elementStack.count >= 2 {
            // 屬性元素
            let trimmed = currentValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                currentRow[elementName] = trimmed
            }
        }
        elementStack.removeLast()
        currentValue = ""
    }
}
