//
//  ToolSidebarView.swift
//  NekoToolKit
//
//  Created by 千葉牧人 on 2025/5/22.
//

import SwiftUI

enum ToolDefinitions {
    enum ToolCategory: String, CaseIterable, Identifiable {
        case format = "資料格式轉換功能"
        case text = "文字處理工具"
        case convert = "轉換工具"
        case dev = "程式開發小工具"

        var id: String { self.rawValue }
    }

    enum Tool: String, CaseIterable, Identifiable {
        // 資料格式轉換功能
        case universalConvert = "通用格式轉換工具"
        case convertJSON = "JSON 轉換功能"
        case convertNDJSON = "NDJSON 轉換功能"
        case convertYAML = "YAML 轉換功能"
        case convertXML = "XML 轉換功能"
        case imageBase64 = "圖片 Base64 轉換功能"
        case base64 = "Base64 編碼／解碼"
        case urlEncode = "URL 編碼／解碼"

        // 文字處理工具
        case zhConvert = "繁體簡體轉換"
        case stringSplit = "字串切割"
        case stringClean = "文字清理"
        case deduplicate = "重複行清理"
        case numberList = "數字列表生成"
        case stripNewline = "轉成單行（移除換行）"
        case textStats = "文字統計工具（字元數、全半形）"
        case textEncodingConvert = "編碼轉換工具（Big5/UTF-8）"

        // 轉換工具
        case unitConvert = "單位轉換器"
        case timestampConvert = "時間戳轉換器"
        case hashGen = "雜湊生成器（MD5/SHA1/SHA256）"
        case passwordGen = "密碼生成器"
        case qrcodeGen = "QRCode 生成器"

        // 程式開發小工具
        case csvLint = "CSV Lint"
        case tsvLint = "TSV Lint"
        case jsonLint = "JSON Lint"
        case ndjsonLint = "NDJSON Lint"
        case yamlLint = "YAML Lint"
        case xmlLint = "XML Lint"
        case jwtDecoder = "JWT 解碼器"
        case jsMinify = "Javascript 壓縮／展開"
        case cssMinify = "CSS 壓縮／展開"
        case httpHeader = "HTTP Header 檢查工具"
        case textDiff = "文字差異比對工具（Diff 工具）"

        var id: String { self.rawValue }

        var category: ToolCategory {
            switch self {
            case .universalConvert:
                return .format
            case .convertJSON, .convertNDJSON, .convertYAML, .convertXML,
                 .imageBase64, .base64, .urlEncode:
                return .format
            case .zhConvert, .stringSplit, .stringClean, .deduplicate, .numberList, .stripNewline, .textStats, .textEncodingConvert:
                return .text
            case .unitConvert, .timestampConvert, .hashGen, .passwordGen, .qrcodeGen:
                return .convert
            case .csvLint, .tsvLint, .jsonLint, .ndjsonLint, .yamlLint, .xmlLint,
                 .jwtDecoder, .jsMinify, .cssMinify, .httpHeader, .textDiff:
                return .dev
            }
        }
    }
}

struct ToolSidebarView: View {
    @Binding var selectedTool: ToolDefinitions.Tool?
    @State private var searchText = ""

    var filteredTools: [ToolDefinitions.Tool] {
        if searchText.isEmpty {
            return ToolDefinitions.Tool.allCases
        } else {
            return ToolDefinitions.Tool.allCases.filter {
                $0.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        List(selection: $selectedTool) {
            Section {
                TextField("搜尋工具...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
            }

            ForEach(ToolDefinitions.ToolCategory.allCases) { category in
                let toolsInCategory = filteredTools.filter { $0.category == category }
                if !toolsInCategory.isEmpty {
                    Section(header: Text(category.rawValue)) {
                        ForEach(toolsInCategory) { tool in
                            Text(tool.rawValue)
                                .tag(tool)
                        }
                    }
                }
            }
        }
        .navigationTitle("工具列表")
    }
}
