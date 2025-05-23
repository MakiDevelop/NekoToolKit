//
//  QRCodeGeneratorView.swift
//  NekoToolKit
//
//  Created by 千葉牧人 on 2025/5/23.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeGeneratorView: View {
    enum QRType: String, CaseIterable, Identifiable {
        case text = "純文字"
        case url = "網址"
        case contact = "聯絡人"
        case wifi = "Wi-Fi"
        case email = "電子郵件"
        case phone = "電話號碼"
        case sms = "簡訊"
        case location = "地點"
        case mecard = "MECard"
        case json = "JSON"

        var id: String { self.rawValue }
    }

    @State private var selectedType: QRType = .text
    @State private var inputText: String = ""
    @State private var qrImage: Image? = nil
    @State private var qrCGImage: CGImage? = nil
    // Extra fields for various QR types
    @State private var emailAddress = ""
    @State private var phoneNumber = ""
    @State private var smsBody = ""
    @State private var location = ""
    @State private var mecardName = ""
    @State private var mecardPhone = ""
    @State private var mecardEmail = ""
    @State private var wifiSSID = ""
    @State private var wifiPassword = ""
    @State private var wifiEncryption: String = "WPA"
    @State private var wifiHidden = false
    // Contact fields for vCard
    @State private var contactName = ""
    @State private var contactOrg = ""
    @State private var contactTitle = ""
    @State private var contactPhone = ""
    @State private var contactEmail = ""
    @State private var contactURL = ""

    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()

    var body: some View {
        VStack(spacing: 16) {
            Text("QRCode 產生器")
                .font(.headline)

            Picker("資料類型", selection: $selectedType) {
                ForEach(QRType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)

            VStack(alignment: .leading) {
                inputFields()
            }

            Button("產生 QRCode") {
                generateQRCode()
            }

            if let qrImage = qrImage {
                qrImage
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 240, height: 240)
                    .padding(.top)
                Button("下載 QRCode 圖片") {
                    saveQRCodeImage()
                }
            }
        }
        .padding()
    }

    @ViewBuilder
    private func inputFields() -> some View {
        switch selectedType {
        case .text:
            TextField("請輸入文字", text: $inputText)
                .textFieldStyle(.roundedBorder)

        case .url:
            TextField("請輸入網址", text: $inputText)
                .textFieldStyle(.roundedBorder)

        case .contact:
            VStack(alignment: .leading, spacing: 8) {
                TextField("姓名", text: $contactName)
                    .textFieldStyle(.roundedBorder)
                TextField("公司", text: $contactOrg)
                    .textFieldStyle(.roundedBorder)
                TextField("職稱", text: $contactTitle)
                    .textFieldStyle(.roundedBorder)
                TextField("電話", text: $contactPhone)
                    .textFieldStyle(.roundedBorder)
                TextField("電子郵件", text: $contactEmail)
                    .textFieldStyle(.roundedBorder)
                TextField("網址", text: $contactURL)
                    .textFieldStyle(.roundedBorder)
            }

        case .wifi:
            VStack(alignment: .leading, spacing: 8) {
                TextField("網路名稱（SSID）", text: $wifiSSID)
                    .textFieldStyle(.roundedBorder)
                TextField("密碼（如無密碼可留空）", text: $wifiPassword)
                    .textFieldStyle(.roundedBorder)
                Picker("加密方式", selection: $wifiEncryption) {
                    Text("WPA").tag("WPA")
                    Text("WEP").tag("WEP")
                    Text("無加密（nopass）").tag("nopass")
                }
                .pickerStyle(.segmented)
                Toggle("隱藏網路", isOn: $wifiHidden)
            }

        case .email:
            TextField("輸入電子郵件地址", text: $emailAddress)
                .textFieldStyle(.roundedBorder)

        case .phone:
            TextField("輸入電話號碼", text: $phoneNumber)
                .textFieldStyle(.roundedBorder)

        case .sms:
            VStack(alignment: .leading) {
                TextField("電話號碼", text: $phoneNumber)
                    .textFieldStyle(.roundedBorder)
                TextField("簡訊內容", text: $smsBody)
                    .textFieldStyle(.roundedBorder)
            }

        case .location:
            TextField("輸入地點（地址或經緯度）", text: $location)
                .textFieldStyle(.roundedBorder)

        case .mecard:
            VStack(alignment: .leading) {
                TextField("姓名", text: $mecardName)
                    .textFieldStyle(.roundedBorder)
                TextField("電話", text: $mecardPhone)
                    .textFieldStyle(.roundedBorder)
                TextField("電子郵件", text: $mecardEmail)
                    .textFieldStyle(.roundedBorder)
            }

        case .json:
            VStack(alignment: .leading) {
                Text("請輸入 JSON 內容")
                TextEditor(text: $inputText)
                    .frame(height: 100)
                    .border(Color.gray)
            }
        }
    }

    private func generateQRCode() {
        var content: String = ""
        switch selectedType {
        case .text, .url:
            guard !inputText.isEmpty else {
                qrCGImage = nil
                qrImage = nil
                return
            }
            content = inputText
        case .contact:
            guard !contactName.isEmpty || !contactPhone.isEmpty || !contactEmail.isEmpty else {
                qrCGImage = nil
                qrImage = nil
                return
            }
            var lines: [String] = []
            lines.append("BEGIN:VCARD")
            lines.append("VERSION:3.0")
            lines.append("FN:\(contactName)")
            if !contactOrg.isEmpty { lines.append("ORG:\(contactOrg)") }
            if !contactTitle.isEmpty { lines.append("TITLE:\(contactTitle)") }
            if !contactPhone.isEmpty { lines.append("TEL;TYPE=CELL:\(contactPhone)") }
            if !contactEmail.isEmpty { lines.append("EMAIL:\(contactEmail)") }
            if !contactURL.isEmpty { lines.append("URL:\(contactURL)") }
            lines.append("END:VCARD")
            content = lines.joined(separator: "\n")
        case .wifi:
            guard !wifiSSID.isEmpty else {
                qrCGImage = nil
                qrImage = nil
                return
            }
            let hiddenFlag = wifiHidden ? "H:true;" : ""
            let passwordPart = wifiEncryption != "nopass" ? "P:\(wifiPassword);" : ""
            content = "WIFI:T:\(wifiEncryption);S:\(wifiSSID);\(passwordPart)\(hiddenFlag);"
        case .email:
            guard !emailAddress.isEmpty else {
                qrCGImage = nil
                qrImage = nil
                return
            }
            content = "mailto:\(emailAddress)"
        case .phone:
            guard !phoneNumber.isEmpty else {
                qrCGImage = nil
                qrImage = nil
                return
            }
            content = "tel:\(phoneNumber)"
        case .sms:
            guard !phoneNumber.isEmpty else {
                qrCGImage = nil
                qrImage = nil
                return
            }
            let encodedBody = smsBody.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            content = "sms:\(phoneNumber)?body=\(encodedBody)"
        case .location:
            guard !location.isEmpty else {
                qrCGImage = nil
                qrImage = nil
                return
            }
            content = "https://maps.google.com/?q=\(location)"
        case .mecard:
            guard !mecardName.isEmpty || !mecardPhone.isEmpty || !mecardEmail.isEmpty else {
                qrCGImage = nil
                qrImage = nil
                return
            }
            content = "MECARD:N:\(mecardName);TEL:\(mecardPhone);EMAIL:\(mecardEmail);;"
        case .json:
            guard !inputText.isEmpty else {
                qrCGImage = nil
                qrImage = nil
                return
            }
            content = inputText
        }

        let data = Data(content.utf8)
        filter.setValue(data, forKey: "inputMessage")

        if let outputImage = filter.outputImage,
           let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            qrCGImage = cgimg
            qrImage = Image(decorative: cgimg, scale: 1.0)
        } else {
            qrCGImage = nil
            qrImage = nil
        }
    }
    
    private func saveQRCodeImage() {
        guard let cgImage = qrCGImage else { return }

        let panel = NSSavePanel()
        panel.allowedContentTypes = [.png]
        panel.nameFieldStringValue = "qrcode.png"
        panel.canCreateDirectories = true

        panel.begin { response in
            if response == .OK, let url = panel.url {
                let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
                if let pngData = bitmapRep.representation(using: .png, properties: [:]) {
                    try? pngData.write(to: url)
                }
            }
        }
    }
}
