//
//  InvoiceProcessor.swift
//  invoice
//
//  Created by matiaz on 21/9/25.
//

import Vision
import UIKit
import Foundation
import Combine

class InvoiceProcessor: ObservableObject {
    @Published var invoiceData: InvoiceData = .empty()
    @Published var isProcessing = false
    @Published var rawText = ""

    private let textExtractor = TextExtractor()

    func processInvoice(from image: UIImage) {
        isProcessing = true

        textExtractor.extractText(from: image) { [weak self] extractedText in
            self?.rawText = extractedText
            self?.parseInvoiceData(from: extractedText)
            self?.isProcessing = false
        }
    }

    private func parseInvoiceData(from text: String) {
        let lines = text.components(separatedBy: .newlines)

        var vendor: String?
        var amount: Decimal?
        var date: Date?
        var invoiceNumber: String?
        var lineItems: [LineItem] = []

        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)

            if vendor == nil && isLikelyVendorName(trimmedLine) {
                vendor = trimmedLine
            }

            if let extractedAmount = extractAmount(from: trimmedLine) {
                amount = extractedAmount
            }

            if let extractedDate = extractDate(from: trimmedLine) {
                date = extractedDate
            }

            if let extractedInvoiceNumber = extractInvoiceNumber(from: trimmedLine) {
                invoiceNumber = extractedInvoiceNumber
            }

            if let lineItem = extractLineItem(from: trimmedLine) {
                lineItems.append(lineItem)
            }
        }

        self.invoiceData = InvoiceData(
            vendor: vendor,
            amount: amount,
            date: date,
            invoiceNumber: invoiceNumber,
            lineItems: lineItems
        )
    }

    private func isLikelyVendorName(_ text: String) -> Bool {
        let vendorKeywords = ["company", "corp", "corporation", "inc", "llc", "ltd", "limited"]
        let lowercased = text.lowercased()

        return text.count > 3 &&
               text.count < 100 &&
               (vendorKeywords.contains { lowercased.contains($0) } ||
                text.range(of: #"^[A-Z][a-zA-Z\s&]+$"#, options: .regularExpression) != nil)
    }

    private func extractAmount(from text: String) -> Decimal? {
        let patterns = [
            #"\$[\d,]+\.?\d*"#,
            #"total:?\s*\$?[\d,]+\.?\d*"#,
            #"amount:?\s*\$?[\d,]+\.?\d*"#
        ]

        for pattern in patterns {
            if let range = text.range(of: pattern, options: [.regularExpression, .caseInsensitive]) {
                let match = String(text[range])
                let numberString = match.replacingOccurrences(of: #"[^\d\.]"#, with: "", options: .regularExpression)
                return Decimal(string: numberString)
            }
        }

        return nil
    }

    private func extractDate(from text: String) -> Date? {
        let patterns = [
            #"\d{1,2}/\d{1,2}/\d{2,4}"#,
            #"\d{1,2}-\d{1,2}-\d{2,4}"#,
            #"\d{4}-\d{2}-\d{2}"#
        ]

        for pattern in patterns {
            if let range = text.range(of: pattern, options: .regularExpression) {
                let dateString = String(text[range])

                let formatters = [
                    "MM/dd/yyyy", "MM/dd/yy", "M/d/yyyy", "M/d/yy",
                    "MM-dd-yyyy", "MM-dd-yy", "M-d-yyyy", "M-d-yy",
                    "yyyy-MM-dd"
                ]

                for format in formatters {
                    let formatter = DateFormatter()
                    formatter.dateFormat = format
                    if let date = formatter.date(from: dateString) {
                        return date
                    }
                }
            }
        }

        return nil
    }

    private func extractInvoiceNumber(from text: String) -> String? {
        let patterns = [
            #"invoice\s*#?:?\s*([A-Z0-9\-]+)"#,
            #"inv\s*#?:?\s*([A-Z0-9\-]+)"#,
            #"#([A-Z0-9\-]{3,})"#
        ]

        for pattern in patterns {
            if let range = text.range(of: pattern, options: [.regularExpression, .caseInsensitive]) {
                let match = String(text[range])
                let numberPattern = #"[A-Z0-9\-]{3,}"#
                if let numberRange = match.range(of: numberPattern, options: .regularExpression) {
                    return String(match[numberRange])
                }
            }
        }

        return nil
    }

    private func extractLineItem(from text: String) -> LineItem? {
        let pattern = #"^(.+?)\s+(\d+)\s+\$?([\d,]+\.?\d*)\s+\$?([\d,]+\.?\d*)$"#

        if let range = text.range(of: pattern, options: .regularExpression) {
            let match = String(text[range])
            let components = match.components(separatedBy: .whitespaces).filter { !$0.isEmpty }

            if components.count >= 4 {
                let description = components.dropLast(3).joined(separator: " ")
                let quantity = Int(components[components.count - 3])
                let unitPrice = Decimal(string: components[components.count - 2].replacingOccurrences(of: "$", with: ""))
                let amount = Decimal(string: components.last!.replacingOccurrences(of: "$", with: ""))

                if !description.isEmpty {
                    return LineItem(
                        description: description,
                        quantity: quantity,
                        unitPrice: unitPrice,
                        amount: amount
                    )
                }
            }
        }

        return nil
    }
}