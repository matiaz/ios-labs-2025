//
//  PDF417Parser.swift
//  visionPassport
//
//  Created by matiaz on 21/9/25.
//

import Foundation

struct PDF417Parser {

    static func parseUSDriversLicense(from barcodeString: String) -> PersonalDocument? {

        let lines = barcodeString.components(separatedBy: .newlines)

        guard lines.count > 0,
              lines[0].hasPrefix("@") else {
            return nil
        }

        var aamvaData: [String: String] = [:]

        for line in lines {
            if line.count >= 3 && line.hasPrefix("D") {
                let elementId = String(line.prefix(3))
                let value = String(line.dropFirst(3))
                aamvaData[elementId] = value
            }
        }

        let fullName = extractFullName(from: aamvaData)
        let dateOfBirth = extractDateOfBirth(from: aamvaData)
        let documentNumber = aamvaData["DAQ"] ?? aamvaData["DCF"]
        let expirationDate = extractExpirationDate(from: aamvaData)
        let issuingAuthority = extractIssuingAuthority(from: aamvaData)
        let gender = extractGender(from: aamvaData)
        let address = extractAddress(from: aamvaData)

        guard fullName != nil || documentNumber != nil else {
            return nil
        }

        return PersonalDocument(
            documentType: .usDLCode,
            fullName: fullName,
            dateOfBirth: dateOfBirth,
            documentNumber: documentNumber,
            expirationDate: expirationDate,
            nationality: "United States",
            issuingAuthority: issuingAuthority,
            gender: gender,
            placeOfBirth: address
        )
    }

    private static func extractFullName(from data: [String: String]) -> String? {
        var nameComponents: [String] = []

        if let firstName = data["DAC"] {
            nameComponents.append(firstName)
        }

        if let middleName = data["DAD"] {
            nameComponents.append(middleName)
        }

        if let lastName = data["DCS"] {
            nameComponents.append(lastName)
        }

        return nameComponents.isEmpty ? nil : nameComponents.joined(separator: " ")
    }

    private static func extractDateOfBirth(from data: [String: String]) -> Date? {
        guard let dobString = data["DBB"] else { return nil }
        return parseAAMVADate(dobString)
    }

    private static func extractExpirationDate(from data: [String: String]) -> Date? {
        guard let expString = data["DBA"] else { return nil }
        return parseAAMVADate(expString)
    }

    private static func extractIssuingAuthority(from data: [String: String]) -> String? {

        if let jurisdiction = data["DCG"] {
            return "Department of Motor Vehicles - \(jurisdiction)"
        }

        if let issuer = data["DCA"] {
            return issuer
        }

        return "Department of Motor Vehicles"
    }

    private static func extractGender(from data: [String: String]) -> String? {
        guard let genderCode = data["DBC"] else { return nil }

        switch genderCode.uppercased() {
        case "1", "M":
            return "Male"
        case "2", "F":
            return "Female"
        default:
            return nil
        }
    }

    private static func extractAddress(from data: [String: String]) -> String? {
        var addressComponents: [String] = []

        if let street = data["DAG"] {
            addressComponents.append(street)
        }

        if let city = data["DAI"] {
            addressComponents.append(city)
        }

        if let state = data["DAJ"] {
            addressComponents.append(state)
        }

        if let zip = data["DAK"] {
            addressComponents.append(zip)
        }

        return addressComponents.isEmpty ? nil : addressComponents.joined(separator: ", ")
    }

    private static func parseAAMVADate(_ dateString: String) -> Date? {

        let formatter = DateFormatter()

        if dateString.count == 8 {
            formatter.dateFormat = "MMddyyyy"
        } else if dateString.count == 6 {
            formatter.dateFormat = "MMddyy"
        } else {
            return nil
        }

        return formatter.date(from: dateString)
    }
}

struct AAMVAElementCodes {

    static let commonElements: [String: String] = [
        "DCA": "Jurisdiction-specific vehicle class",
        "DCB": "Jurisdiction-specific restriction codes",
        "DCD": "Jurisdiction-specific endorsement codes",
        "DBA": "Document expiration date",
        "DCS": "Customer family name",
        "DAC": "Customer first name",
        "DAD": "Customer middle name",
        "DBD": "Document issue date",
        "DBB": "Date of birth",
        "DBC": "Physical description – sex",
        "DAY": "Physical description – eye color",
        "DAU": "Physical description – height",
        "DAG": "Address – street 1",
        "DAI": "Address – city",
        "DAJ": "Address – jurisdiction code",
        "DAK": "Address – postal code",
        "DAQ": "Customer ID number",
        "DCF": "Document discriminator",
        "DCG": "Country identification",
        "DDE": "Family name truncation",
        "DDF": "First name truncation",
        "DDG": "Middle name truncation"
    ]
}

extension PDF417Parser {

    static func extractAllFields(from barcodeString: String) -> [String: String] {
        var result: [String: String] = [:]
        let lines = barcodeString.components(separatedBy: .newlines)

        for line in lines {
            if line.count >= 3 && line.hasPrefix("D") {
                let elementId = String(line.prefix(3))
                let value = String(line.dropFirst(3))
                let description = AAMVAElementCodes.commonElements[elementId] ?? "Unknown field"
                result["\(elementId) (\(description))"] = value
            }
        }

        return result
    }

    static func validateAAMVAFormat(_ barcodeString: String) -> Bool {
        let lines = barcodeString.components(separatedBy: .newlines)

        guard lines.count > 0,
              lines[0].hasPrefix("@") else {
            return false
        }

        let dataElements = lines.filter { $0.count >= 3 && $0.hasPrefix("D") }
        return dataElements.count >= 5
    }
}