//
//  PassportParser.swift
//  visionPassport
//
//  Created by matiaz on 21/9/25.
//

import Foundation

struct PassportParser {

    static func parsePassport(from recognizedStrings: [String]) -> PersonalDocument? {

        if let mrzData = parseMRZ(from: recognizedStrings) {
            return PersonalDocument(
                documentType: .passport,
                fullName: mrzData.fullName,
                dateOfBirth: mrzData.dateOfBirth,
                documentNumber: mrzData.passportNumber,
                expirationDate: mrzData.expirationDate,
                nationality: mrzData.nationality,
                issuingAuthority: mrzData.issuingCountry,
                gender: mrzData.gender
            )
        }

        return parsePassportText(from: recognizedStrings)
    }

    private static func parseMRZ(from strings: [String]) -> MRZData? {

        let cleanedStrings = strings.map { string in
            string.replacingOccurrences(of: " ", with: "")
                  .replacingOccurrences(of: "O", with: "0")
                  .uppercased()
        }

        let mrzLines = cleanedStrings.filter { line in
            line.count >= 40 && line.allSatisfy { char in
                char.isLetter || char.isNumber || char == "<"
            }
        }

        guard mrzLines.count >= 2 else { return nil }

        let line1 = mrzLines[0]
        let line2 = mrzLines[1]

        guard line1.count >= 44 && line2.count >= 44 else { return nil }

        guard line1.hasPrefix("P<") else { return nil }

        return MRZData(
            passportNumber: extractPassportNumber(from: line2),
            fullName: extractFullName(from: line1),
            nationality: extractNationality(from: line1),
            dateOfBirth: extractDateOfBirth(from: line2),
            gender: extractGender(from: line2),
            expirationDate: extractExpirationDate(from: line2),
            issuingCountry: extractIssuingCountry(from: line1)
        )
    }

    private static func extractPassportNumber(from line: String) -> String? {
        guard line.count >= 9 else { return nil }
        let passportNumber = String(line.prefix(9)).replacingOccurrences(of: "<", with: "")
        return passportNumber.isEmpty ? nil : passportNumber
    }

    private static func extractFullName(from line: String) -> String? {
        guard line.count >= 44 else { return nil }
        let nameSection = String(line.dropFirst(5))
        let components = nameSection.components(separatedBy: "<<")
        guard components.count >= 2 else { return nil }

        let lastName = components[0].replacingOccurrences(of: "<", with: " ").trimmingCharacters(in: .whitespaces)
        let firstName = components[1].replacingOccurrences(of: "<", with: " ").trimmingCharacters(in: .whitespaces)

        return "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
    }

    private static func extractNationality(from line: String) -> String? {
        guard line.count >= 5 else { return nil }
        let nationality = String(line.dropFirst(2).prefix(3))
        return nationality == "<<<" ? nil : nationality
    }

    private static func extractDateOfBirth(from line: String) -> Date? {
        guard line.count >= 19 else { return nil }
        let dobString = String(line.dropFirst(13).prefix(6))
        return parseMRZDate(dobString)
    }

    private static func extractGender(from line: String) -> String? {
        guard line.count >= 21 else { return nil }
        let genderChar = line[line.index(line.startIndex, offsetBy: 20)]
        switch genderChar {
        case "M": return "Male"
        case "F": return "Female"
        default: return nil
        }
    }

    private static func extractExpirationDate(from line: String) -> Date? {
        guard line.count >= 27 else { return nil }
        let expString = String(line.dropFirst(21).prefix(6))
        return parseMRZDate(expString)
    }

    private static func extractIssuingCountry(from line: String) -> String? {
        guard line.count >= 5 else { return nil }
        let country = String(line.dropFirst(2).prefix(3))
        return country == "<<<" ? nil : country
    }

    private static func parseMRZDate(_ dateString: String) -> Date? {
        guard dateString.count == 6 else { return nil }

        let year = String(dateString.prefix(2))
        let month = String(dateString.dropFirst(2).prefix(2))
        let day = String(dateString.suffix(2))

        guard let yearInt = Int(year),
              let monthInt = Int(month),
              let dayInt = Int(day) else { return nil }

        let fullYear = yearInt < 30 ? 2000 + yearInt : 1900 + yearInt

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: "\(fullYear)-\(month)-\(day)")
    }

    private static func parsePassportText(from strings: [String]) -> PersonalDocument? {
        let text = strings.joined(separator: " ")

        let fullName = extractNameFromText(from: strings)
        let dateOfBirth = extractDateFromText(from: text, patterns: [
            "DATE OF BIRTH[: ]*([0-9]{1,2}[/-][0-9]{1,2}[/-][0-9]{2,4})",
            "DOB[: ]*([0-9]{1,2}[/-][0-9]{1,2}[/-][0-9]{2,4})",
            "BIRTH[: ]*([0-9]{1,2}[/-][0-9]{1,2}[/-][0-9]{2,4})"
        ])
        let documentNumber = extractPassportNumberFromText(from: text)
        let expirationDate = extractDateFromText(from: text, patterns: [
            "DATE OF EXPIRY[: ]*([0-9]{1,2}[/-][0-9]{1,2}[/-][0-9]{2,4})",
            "EXPIRY[: ]*([0-9]{1,2}[/-][0-9]{1,2}[/-][0-9]{2,4})",
            "EXPIRES[: ]*([0-9]{1,2}[/-][0-9]{1,2}[/-][0-9]{2,4})"
        ])
        let nationality = extractNationalityFromText(from: strings)
        let issuingAuthority = extractIssuingAuthorityFromText(from: strings)

        guard fullName != nil || documentNumber != nil else { return nil }

        return PersonalDocument(
            documentType: .passport,
            fullName: fullName,
            dateOfBirth: dateOfBirth,
            documentNumber: documentNumber,
            expirationDate: expirationDate,
            nationality: nationality,
            issuingAuthority: issuingAuthority
        )
    }

    private static func extractNameFromText(from strings: [String]) -> String? {
        let nameKeywords = ["NAME", "SURNAME", "GIVEN NAME", "HOLDER"]

        for string in strings {
            let upperString = string.uppercased()
            for keyword in nameKeywords {
                if upperString.contains(keyword) {
                    let components = string.components(separatedBy: .whitespacesAndNewlines)
                    if let index = components.firstIndex(where: { $0.uppercased().contains(keyword) }) {
                        let nameComponents = Array(components[(index + 1)...])
                        let name = nameComponents.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
                        if !name.isEmpty && name.count > 2 {
                            return name
                        }
                    }
                }
            }
        }
        return nil
    }

    private static func extractPassportNumberFromText(from text: String) -> String? {
        let patterns = [
            "PASSPORT[# ]*([A-Z0-9]{6,12})",
            "NO[.: ]*([A-Z0-9]{6,12})",
            "NUMBER[.: ]*([A-Z0-9]{6,12})",
            "([A-Z][0-9]{8})",
            "([0-9]{8,9})"
        ]

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

    private static func extractDateFromText(from text: String, patterns: [String]) -> Date? {
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(location: 0, length: text.count)
                if let match = regex.firstMatch(in: text, options: [], range: range) {
                    let matchRange = match.range(at: 1)
                    if matchRange.location != NSNotFound,
                       let dateRange = Range(matchRange, in: text) {
                        let dateString = String(text[dateRange])
                        return parseTextDate(from: dateString)
                    }
                }
            }
        }
        return nil
    }

    private static func parseTextDate(from dateString: String) -> Date? {
        let formatters = [
            DateFormatter().apply { $0.dateFormat = "dd/MM/yyyy" },
            DateFormatter().apply { $0.dateFormat = "MM/dd/yyyy" },
            DateFormatter().apply { $0.dateFormat = "dd-MM-yyyy" },
            DateFormatter().apply { $0.dateFormat = "MM-dd-yyyy" },
            DateFormatter().apply { $0.dateFormat = "yyyy-MM-dd" }
        ]

        for formatter in formatters {
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        return nil
    }

    private static func extractNationalityFromText(from strings: [String]) -> String? {
        let nationalityKeywords = ["NATIONALITY", "CITIZEN", "COUNTRY OF BIRTH"]

        for string in strings {
            let upperString = string.uppercased()
            for keyword in nationalityKeywords {
                if upperString.contains(keyword) {
                    let components = string.components(separatedBy: .whitespacesAndNewlines)
                    if let index = components.firstIndex(where: { $0.uppercased().contains(keyword) }) {
                        let nationalityComponents = Array(components[(index + 1)...])
                        let nationality = nationalityComponents.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
                        if !nationality.isEmpty {
                            return nationality
                        }
                    }
                }
            }
        }
        return nil
    }

    private static func extractIssuingAuthorityFromText(from strings: [String]) -> String? {
        let authorityKeywords = ["AUTHORITY", "ISSUING", "GOVERNMENT", "REPUBLIC", "KINGDOM", "STATE"]

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
}

private struct MRZData {
    let passportNumber: String?
    let fullName: String?
    let nationality: String?
    let dateOfBirth: Date?
    let gender: String?
    let expirationDate: Date?
    let issuingCountry: String?
}

private extension DateFormatter {
    func apply(_ configuration: (DateFormatter) -> Void) -> DateFormatter {
        configuration(self)
        return self
    }
}