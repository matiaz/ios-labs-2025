//
//  IDParser.swift
//  visionPassport
//
//  Created by matiaz on 21/9/25.
//

import Foundation

struct IDParser {

    static func parseID(from recognizedStrings: [String], documentType: DocumentType) -> PersonalDocument? {
        let text = recognizedStrings.joined(separator: " ")

        var fullName: String?
        var dateOfBirth: Date?
        var documentNumber: String?
        var expirationDate: Date?
        var issuingAuthority: String?
        var gender: String?

        switch documentType {
        case .driversLicense:
            (fullName, dateOfBirth, documentNumber, expirationDate, issuingAuthority, gender) = parseDriversLicense(text: text, strings: recognizedStrings)
        case .nationalID:
            (fullName, dateOfBirth, documentNumber, expirationDate, issuingAuthority, gender) = parseNationalID(text: text, strings: recognizedStrings)
        case .passport:
            return nil
        }

        guard fullName != nil || documentNumber != nil else {
            return nil
        }

        return PersonalDocument(
            documentType: documentType,
            fullName: fullName,
            dateOfBirth: dateOfBirth,
            documentNumber: documentNumber,
            expirationDate: expirationDate,
            nationality: nil,
            issuingAuthority: issuingAuthority,
            gender: gender
        )
    }

    private static func parseDriversLicense(text: String, strings: [String]) -> (String?, Date?, String?, Date?, String?, String?) {
        var fullName: String?
        var dateOfBirth: Date?
        var documentNumber: String?
        var expirationDate: Date?
        var issuingAuthority: String?
        var gender: String?

        fullName = extractName(from: strings)
        dateOfBirth = extractDateOfBirth(from: text)
        documentNumber = extractLicenseNumber(from: text)
        expirationDate = extractExpirationDate(from: text)
        issuingAuthority = extractIssuingAuthority(from: strings, documentType: .driversLicense)
        gender = extractGender(from: text)

        return (fullName, dateOfBirth, documentNumber, expirationDate, issuingAuthority, gender)
    }

    private static func parseNationalID(text: String, strings: [String]) -> (String?, Date?, String?, Date?, String?, String?) {
        var fullName: String?
        var dateOfBirth: Date?
        var documentNumber: String?
        var expirationDate: Date?
        var issuingAuthority: String?
        var gender: String?

        fullName = extractName(from: strings)
        dateOfBirth = extractDateOfBirth(from: text)
        documentNumber = extractIDNumber(from: text)
        expirationDate = extractExpirationDate(from: text)
        issuingAuthority = extractIssuingAuthority(from: strings, documentType: .nationalID)
        gender = extractGender(from: text)

        return (fullName, dateOfBirth, documentNumber, expirationDate, issuingAuthority, gender)
    }

    private static func extractName(from strings: [String]) -> String? {
        let namePatterns = [
            "NAME",
            "NOME",
            "FULL NAME",
            "LASTNAME",
            "FIRST NAME",
            "LN",
            "FN"
        ]

        for string in strings {
            let upperString = string.uppercased()
            for pattern in namePatterns {
                if upperString.contains(pattern) {
                    let components = string.components(separatedBy: .whitespacesAndNewlines)
                    if let index = components.firstIndex(where: { $0.uppercased().contains(pattern) }) {
                        let nameComponents = Array(components[(index + 1)...])
                        let name = nameComponents.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
                        if !name.isEmpty && name.count > 2 {
                            return name
                        }
                    }
                }
            }
        }

        let capitalizationPattern = try? NSRegularExpression(pattern: "[A-Z][a-z]+ [A-Z][a-z]+", options: [])
        for string in strings {
            if let match = capitalizationPattern?.firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.count)) {
                let name = String(string[Range(match.range, in: string)!])
                if name.count > 4 {
                    return name
                }
            }
        }

        return nil
    }

    private static func extractDateOfBirth(from text: String) -> Date? {
        let datePatterns = [
            "DOB[: ]*([0-9]{1,2}[/-][0-9]{1,2}[/-][0-9]{2,4})",
            "BIRTH[: ]*([0-9]{1,2}[/-][0-9]{1,2}[/-][0-9]{2,4})",
            "BORN[: ]*([0-9]{1,2}[/-][0-9]{1,2}[/-][0-9]{2,4})",
            "([0-9]{1,2}[/-][0-9]{1,2}[/-][0-9]{4})"
        ]

        return extractDate(from: text, patterns: datePatterns)
    }

    private static func extractExpirationDate(from text: String) -> Date? {
        let datePatterns = [
            "EXP[: ]*([0-9]{1,2}[/-][0-9]{1,2}[/-][0-9]{2,4})",
            "EXPIRES[: ]*([0-9]{1,2}[/-][0-9]{1,2}[/-][0-9]{2,4})",
            "VALID UNTIL[: ]*([0-9]{1,2}[/-][0-9]{1,2}[/-][0-9]{2,4})"
        ]

        return extractDate(from: text, patterns: datePatterns)
    }

    private static func extractDate(from text: String, patterns: [String]) -> Date? {
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(location: 0, length: text.count)
                if let match = regex.firstMatch(in: text, options: [], range: range) {
                    let matchRange = match.range(at: 1)
                    if matchRange.location != NSNotFound,
                       let dateRange = Range(matchRange, in: text) {
                        let dateString = String(text[dateRange])
                        return parseDate(from: dateString)
                    }
                }
            }
        }
        return nil
    }

    private static func parseDate(from dateString: String) -> Date? {
        let formatters = [
            DateFormatter().apply { $0.dateFormat = "MM/dd/yyyy" },
            DateFormatter().apply { $0.dateFormat = "dd/MM/yyyy" },
            DateFormatter().apply { $0.dateFormat = "MM-dd-yyyy" },
            DateFormatter().apply { $0.dateFormat = "dd-MM-yyyy" },
            DateFormatter().apply { $0.dateFormat = "MM/dd/yy" },
            DateFormatter().apply { $0.dateFormat = "dd/MM/yy" }
        ]

        for formatter in formatters {
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        return nil
    }

    private static func extractLicenseNumber(from text: String) -> String? {
        let patterns = [
            "DL[# ]*([A-Z0-9]{8,20})",
            "LIC[# ]*([A-Z0-9]{8,20})",
            "LICENSE[# ]*([A-Z0-9]{8,20})",
            "([A-Z][0-9]{7,15})",
            "([0-9]{8,15})"
        ]

        return extractPattern(from: text, patterns: patterns)
    }

    private static func extractIDNumber(from text: String) -> String? {
        let patterns = [
            "ID[# ]*([A-Z0-9]{8,20})",
            "NUMBER[# ]*([A-Z0-9]{8,20})",
            "([A-Z0-9]{8,20})"
        ]

        return extractPattern(from: text, patterns: patterns)
    }

    private static func extractGender(from text: String) -> String? {
        let patterns = [
            "SEX[: ]*([MF])",
            "GENDER[: ]*([MF])",
            "([MF])\\b"
        ]

        if let gender = extractPattern(from: text, patterns: patterns) {
            return gender == "M" ? "Male" : "Female"
        }
        return nil
    }

    private static func extractIssuingAuthority(from strings: [String], documentType: DocumentType) -> String? {
        let authorityKeywords = documentType == .driversLicense
            ? ["DMV", "DEPARTMENT", "MOTOR", "VEHICLE", "STATE"]
            : ["GOVERNMENT", "MINISTRY", "DEPARTMENT", "STATE", "FEDERAL"]

        for string in strings {
            let upperString = string.uppercased()
            for keyword in authorityKeywords {
                if upperString.contains(keyword) {
                    return string.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        }
        return nil
    }

    private static func extractPattern(from text: String, patterns: [String]) -> String? {
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(location: 0, length: text.count)
                if let match = regex.firstMatch(in: text, options: [], range: range) {
                    let matchRange = match.numberOfRanges > 1 ? match.range(at: 1) : match.range(at: 0)
                    if matchRange.location != NSNotFound,
                       let resultRange = Range(matchRange, in: text) {
                        return String(text[resultRange])
                    }
                }
            }
        }
        return nil
    }
}

private extension DateFormatter {
    func apply(_ configuration: (DateFormatter) -> Void) -> DateFormatter {
        configuration(self)
        return self
    }
}