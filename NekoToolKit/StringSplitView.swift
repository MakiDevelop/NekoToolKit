//
//  StringSplitView.swift
//  NekoToolKit
//
//  Created by 千葉牧人 on 2025/5/22.
//


import SwiftUI

struct StringSplitView: View {
    enum SplitMode: String, CaseIterable, Identifiable {
        case newline = "換行"
        case comma = "逗號"
        case space = "空白"
        case custom = "自訂"

        var id: String { self.rawValue }
    }

    @State private var inputText: String = ""
    @State private var outputText: String = ""
    @State private var selectedMode: SplitMode = .newline
    @State private var customDelimiter: String = ""
    @State private var copyStatusMessage: String? = nil

    var body: some View {
        VStack(spacing: 16) {
            Text("字串切割工具")
                .font(.headline)

            Picker("切割方式", selection: $selectedMode) {
                ForEach(SplitMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            if selectedMode == .custom {
                HStack {
                    Text("自訂分隔符：")
                    TextField("請輸入分隔符號", text: $customDelimiter)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 150)
                }
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading) {
                    Text("原始文字")
                        .font(.subheadline)
                    TextEditor(text: $inputText)
                        .frame(minHeight: 240)
                        .border(Color.gray)
                }

                VStack {
                    Button("切割") {
                        splitText()
                    }
                }

                VStack(alignment: .leading) {
                    Text("切割結果")
                        .font(.subheadline)
                    TextEditor(text: $outputText)
                        .frame(minHeight: 240)
                        .border(Color.gray)

                    Button("複製結果") {
                        #if os(macOS)
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(outputText, forType: .string)
                        #endif
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

            Button("清除") {
                inputText = ""
                outputText = ""
                customDelimiter = ""
            }
            .padding(.top)
        }
        .padding()
    }

    private func splitText() {
        let delimiter: String
        switch selectedMode {
        case .newline:
            delimiter = "\n"
        case .comma:
            delimiter = ","
        case .space:
            delimiter = " "
        case .custom:
            delimiter = customDelimiter.isEmpty ? "," : customDelimiter
        }

        let parts = inputText.components(separatedBy: delimiter)
        outputText = parts.joined(separator: "\n")
    }
}

#Preview {
    StringSplitView()
}
