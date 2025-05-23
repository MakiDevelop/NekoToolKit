//
//  ContentView.swift
//  NekoToolKit
//
//  Created by 千葉牧人 on 2025/5/22.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTool: ToolDefinitions.Tool? = nil

    var body: some View {
        NavigationSplitView {
            ToolSidebarView(selectedTool: $selectedTool)
        } detail: {
            if let tool = selectedTool {
                switch tool {
                case .convertJSON:
                    JSONConvertView()
                case .universalConvert:
                    UniversalConvertView()
                case .convertNDJSON:
                    NDJSONConvertView()
                case .convertYAML:
                    YAMLConvertView()
                case .convertXML:
                    XMLConvertView()
                case .imageBase64:
                    ImageBase64ConvertView()
                case .base64:
                    Base64ConvertView()
                case .urlEncode:
                    URLEncodeDecodeView()
                case .zhConvert:
                    ChineseConvertView()
                case .stringSplit:
                    StringSplitView()
                case .stringClean:
                    TextCleanView()
                case .deduplicate:
                    DeduplicateLinesView()
                case .numberList:
                    NumberListGeneratorView()
                case .stripNewline:
                    SingleLineConvertView()
                case .textStats:
                    TextStatisticsView()
                case .textEncodingConvert:
                    TextEncodingConvertView()
                case .unitConvert:
                    UnitConverterView()
                case .timestampConvert:
                    TimestampConvertView()
                case .hashGen:
                    HashGeneratorView()
                case .passwordGen:
                    PasswordGeneratorView()
                case .qrcodeGen:
                    QRCodeGeneratorView()
                case .jsonLint:
                    JSONLintView()
                case .csvLint:
                    CSVLintView()
                case .tsvLint:
                    TSVLintView()
                case .ndjsonLint:
                    NDJSONLintView()
                case .yamlLint:
                    YAMLLintView()
                case .xmlLint:
                    XMLLintView()
                case .jwtDecoder:
                    JWTDecoderView()
                case .jsMinify:
                    JavaScriptMinifyView()
                case .cssMinify:
                    CSSMinifyView()
                case .httpHeader:
                    HTTPHeaderInspectorView()
                case .textDiff:
                    TextDiffView()
                case .uuidGen:
                    UUIDGeneratorView()
                case .imageResize:
                    ImageResizeView()
                case .imageConvert:
                    ImageFormatConvertView()
                case .imageJoin:
                    ImageJoinView()
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "wand.and.stars")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.accentColor)

                    Text("歡迎使用 NekoToolKit")
                        .font(.title2)
                        .bold()

                    Text("請從左側選擇一個工具開始使用。")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

#Preview {
    ContentView()
}
