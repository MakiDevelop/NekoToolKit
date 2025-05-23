import SwiftUI

struct TimestampConvertView: View {
    enum Mode: String, CaseIterable, Identifiable {
        case timestampToDate = "時間戳 ➜ 日期"
        case dateToTimestamp = "日期 ➜ 時間戳"

        var id: String { self.rawValue }
    }

    @State private var mode: Mode = .timestampToDate
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    @State private var selectedFormat: String = "yyyy/MM/dd HH:mm:ss"
    @State private var copyStatusMessage: String? = nil

    let formats = [
        "yyyy/MM/dd HH:mm:ss",
        "yyyy-MM-dd HH:mm:ss",
        "yyyy-MM-dd'T'HH:mm:ssZ", // ISO 8601
        "yyyy年MM月dd日 HH時mm分ss秒",
        "MM/dd/yyyy HH:mm"
    ]

    var body: some View {
        VStack(spacing: 16) {
            Text("時間戳轉換工具")
                .font(.headline)

            Picker("模式", selection: $mode) {
                ForEach(Mode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            HStack {
                TextField("請輸入 \(mode == .timestampToDate ? "timestamp" : "日期")", text: $inputText)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 300)

                if mode == .timestampToDate {
                    Picker("格式", selection: $selectedFormat) {
                        ForEach(formats, id: \.self) { format in
                            Text(format).tag(format)
                        }
                    }
                    .frame(width: 260)
                }

                Button("轉換") {
                    convert()
                }
            }

            Text("結果：\(outputText)")
                .font(.system(size: 16, design: .monospaced))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)

            HStack {
                Button("複製結果") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(outputText, forType: .string)
                    copyStatusMessage = "已複製到剪貼簿 ✅"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        copyStatusMessage = nil
                    }
                }

                Button("取得當下時間") {
                    let now = Date()
                    let formatter = DateFormatter()
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    formatter.timeZone = TimeZone.current

                    if mode == .timestampToDate {
                        formatter.dateFormat = selectedFormat
                        self.inputText = "\(Int(now.timeIntervalSince1970))"
                        self.outputText = formatter.string(from: now)
                    } else {
                        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
                        self.inputText = formatter.string(from: now)
                        self.outputText = "\(Int(now.timeIntervalSince1970))"
                    }
                }

                if let msg = copyStatusMessage {
                    Text(msg)
                        .font(.caption)
                        .foregroundColor(.green)
                }

                Spacer()

                Button("清除") {
                    inputText = ""
                    outputText = ""
                    copyStatusMessage = nil
                }
            }
        }
        .padding()
    }

    private func convert() {
        outputText = ""

        switch mode {
        case .timestampToDate:
            guard let timestamp = TimeInterval(inputText.trimmingCharacters(in: .whitespacesAndNewlines)) else {
                outputText = "⚠️ 輸入的時間戳無效"
                return
            }

            let date = Date(timeIntervalSince1970: timestamp)
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone.current
            formatter.dateFormat = selectedFormat
            outputText = formatter.string(from: date)

        case .dateToTimestamp:
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone.current
            formatter.dateFormat = "yyyy/MM/dd HH:mm:ss" // 預設輸入格式

            guard let date = formatter.date(from: inputText) else {
                outputText = "⚠️ 請使用格式 yyyy/MM/dd HH:mm:ss"
                return
            }

            outputText = "\(Int(date.timeIntervalSince1970))"
        }
    }
}
