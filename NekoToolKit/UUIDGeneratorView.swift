
//
//  UUIDGeneratorView.swift
//  NekoToolKit
//
//  Created by 千葉牧人 on 2025/5/23.
//

import SwiftUI

struct UUIDGeneratorView: View {
    @State private var uuidCount: Int = 5
    @State private var includeDash: Bool = true
    @State private var uppercase: Bool = false
    @State private var generatedUUIDs: [String] = []
    @State private var copyStatus: String?

    var body: some View {
        VStack(spacing: 16) {
            Text("UUID 生成器")
                .font(.headline)

            HStack {
                Stepper("產生數量：\(uuidCount)", value: $uuidCount, in: 1...50)
                Toggle("包含 dash", isOn: $includeDash)
                Toggle("大寫格式", isOn: $uppercase)
            }

            Button("產生 UUID") {
                generateUUIDs()
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(generatedUUIDs, id: \.self) { uuid in
                        HStack {
                            Text(uuid)
                                .font(.system(.body, design: .monospaced))
                                .lineLimit(1)
                            Spacer()
                            Button("複製") {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(uuid, forType: .string)
                                copyStatus = "✅ 已複製 UUID"
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    copyStatus = nil
                                }
                            }
                        }
                        .padding(.vertical, 4)
                        Divider()
                    }
                }
            }
            .frame(minHeight: 240)
            .border(Color.gray)

            if let msg = copyStatus {
                Text(msg)
                    .font(.caption)
                    .foregroundColor(.green)
            }

            Button("清除") {
                generatedUUIDs = []
                copyStatus = nil
            }
        }
        .padding()
    }

    private func generateUUIDs() {
        generatedUUIDs = (0..<uuidCount).map { _ in
            var uuid = UUID().uuidString
            if !includeDash {
                uuid = uuid.replacingOccurrences(of: "-", with: "")
            }
            return uppercase ? uuid.uppercased() : uuid.lowercased()
        }
    }
}

