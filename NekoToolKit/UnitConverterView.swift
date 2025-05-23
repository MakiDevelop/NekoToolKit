//
//  UnitConverterView.swift
//  NekoToolKit
//
//  Created by 千葉牧人 on 2025/5/23.
//


import SwiftUI

struct UnitConverterView: View {
    enum UnitCategory: String, CaseIterable, Identifiable {
        case length = "長度"
        case weight = "重量"
        case temperature = "溫度"
        case time = "時間"
        
        var id: String { self.rawValue }
    }

    struct UnitPair: Identifiable, Equatable, Hashable {
        let id = UUID()
        let from: String
        let to: String
        let convert: (Double) -> Double

        static func == (lhs: UnitPair, rhs: UnitPair) -> Bool {
            lhs.from == rhs.from && lhs.to == rhs.to
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(from)
            hasher.combine(to)
        }
    }

    @State private var category: UnitCategory = .length
    @State private var value: String = ""
    @State private var selectedPair: UnitPair?
    @State private var result: String = ""

    let lengthUnits: [UnitPair] = [
        UnitPair(from: "公尺", to: "英尺", convert: { $0 * 3.28084 }),
        UnitPair(from: "英尺", to: "公尺", convert: { $0 / 3.28084 })
    ]
    
    let weightUnits: [UnitPair] = [
        UnitPair(from: "公斤", to: "磅", convert: { $0 * 2.20462 }),
        UnitPair(from: "磅", to: "公斤", convert: { $0 / 2.20462 })
    ]
    
    let temperatureUnits: [UnitPair] = [
        UnitPair(from: "攝氏", to: "華氏", convert: { $0 * 9 / 5 + 32 }),
        UnitPair(from: "華氏", to: "攝氏", convert: { ($0 - 32) * 5 / 9 }),
        UnitPair(from: "攝氏", to: "開爾文", convert: { $0 + 273.15 }),
        UnitPair(from: "開爾文", to: "攝氏", convert: { $0 - 273.15 }),
        UnitPair(from: "華氏", to: "開爾文", convert: { ($0 - 32) * 5 / 9 + 273.15 }),
        UnitPair(from: "開爾文", to: "華氏", convert: { ($0 - 273.15) * 9 / 5 + 32 })
    ]
    
    let timeUnits: [UnitPair] = [
        UnitPair(from: "秒", to: "分", convert: { $0 / 60 }),
        UnitPair(from: "分", to: "秒", convert: { $0 * 60 }),
        UnitPair(from: "分", to: "時", convert: { $0 / 60 }),
        UnitPair(from: "時", to: "分", convert: { $0 * 60 }),
        UnitPair(from: "時", to: "天", convert: { $0 / 24 }),
        UnitPair(from: "天", to: "時", convert: { $0 * 24 })
    ]

    var currentUnitPairs: [UnitPair] {
        switch category {
        case .length: return lengthUnits
        case .weight: return weightUnits
        case .temperature: return temperatureUnits
        case .time: return timeUnits
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("單位轉換工具")
                .font(.headline)

            Picker("類別", selection: $category) {
                ForEach(UnitCategory.allCases) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(.segmented)

            HStack {
                TextField("輸入數值", text: $value)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 120)
                // .keyboardType(.decimalPad) // Not available on macOS

                Picker("轉換方向", selection: $selectedPair) {
                    ForEach(currentUnitPairs) { pair in
                        Text("\(pair.from) → \(pair.to)").tag(pair as UnitPair?)
                    }
                }
                .frame(width: 200)

                Button("轉換") {
                    convertValue()
                }
            }

            Text("結果：\(result)")
                .font(.title2)
                .padding(.top)
        }
        .padding()
        .onChange(of: category) { _ in
            selectedPair = currentUnitPairs.first
        }
        .onAppear {
            selectedPair = currentUnitPairs.first
        }
    }

    private func convertValue() {
        guard let input = Double(value),
              let pair = selectedPair else {
            result = "⚠️ 請輸入有效數值並選擇單位"
            return
        }
        let converted = pair.convert(input)
        result = String(format: "%.4f \(pair.to)", converted)
    }
}
