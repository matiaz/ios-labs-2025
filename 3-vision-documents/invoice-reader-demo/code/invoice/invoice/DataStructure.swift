//
//  DataStructure.swift
//  invoice
//
//  Created by matiaz on 21/9/25.
//

import Foundation

struct LineItem: Codable, Identifiable {
    let id = UUID()
    let description: String
    let quantity: Int?
    let unitPrice: Decimal?
    let amount: Decimal?

    private enum CodingKeys: String, CodingKey {
        case description, quantity, unitPrice, amount
    }
}

struct InvoiceData: Codable {
    let vendor: String?
    let amount: Decimal?
    let date: Date?
    let invoiceNumber: String?
    let lineItems: [LineItem]

    var totalAmount: Decimal {
        lineItems.compactMap { $0.amount }.reduce(0, +)
    }

    var formattedDate: String {
        guard let date = date else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    var formattedAmount: String {
        guard let amount = amount else { return "N/A" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: amount as NSDecimalNumber) ?? "N/A"
    }
}

extension InvoiceData {
    func toJSONString() -> String? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted

        do {
            let data = try encoder.encode(self)
            return String(data: data, encoding: .utf8)
        } catch {
            print("Error encoding invoice data: \(error)")
            return nil
        }
    }

    static func empty() -> InvoiceData {
        return InvoiceData(
            vendor: nil,
            amount: nil,
            date: nil,
            invoiceNumber: nil,
            lineItems: []
        )
    }
}