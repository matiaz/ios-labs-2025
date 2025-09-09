# ID & Passport Reader Demo

## Overview
A secure iOS app demonstrating Apple's Vision framework capabilities for extracting personal information from identity documents (ID cards and passports) with privacy-focused design and secure data handling.

## Features
- 📱 Document camera for ID/passport scanning
- 🔒 Secure processing of sensitive personal data
- 👤 Personal information extraction and validation
- 🛡️ Privacy-first approach with on-device processing
- 📋 Formatted display of extracted details
- 🗑️ Automatic data cleanup for security

## Key Components

### Vision Processing
- `DocumentProcessor.swift` - Main Vision framework integration
- `IDParser.swift` - ID card specific parsing logic
- `PassportParser.swift` - Passport specific parsing logic
- `PersonalDataModels.swift` - Secure data structures

### UI Components
- `DocumentCameraView.swift` - Document capture interface
- `PersonalInfoView.swift` - Secure data display
- `DocumentTypeSelector.swift` - ID vs Passport selection
- `SecurityWarningView.swift` - Privacy notices

### Security Features
- Data encryption in memory
- Automatic cleanup after display
- No persistent storage of sensitive data
- Biometric authentication for access

### Data Models
```swift
struct PersonalDocument {
    let documentType: DocumentType
    let fullName: String?
    let dateOfBirth: Date?
    let documentNumber: String?
    let expirationDate: Date?
    let nationality: String?
    let issuingAuthority: String?
}

enum DocumentType {
    case driversLicense
    case nationalID
    case passport
}
```

## Implementation Status
- [ ] Project setup with security frameworks
- [ ] Document camera integration
- [ ] ID card text recognition and parsing
- [ ] Passport MRZ (Machine Readable Zone) reading
- [ ] Secure data handling implementation
- [ ] Privacy-focused UI design
- [ ] Security testing and validation

## Sample Usage
1. Launch app and authenticate (biometric)
2. Select document type (ID or Passport)
3. Review privacy notice
4. Scan document using camera
5. View extracted information
6. Data automatically cleared after use

## Security Considerations
- All processing happens on-device
- No network requests with personal data
- Automatic memory cleanup
- Biometric authentication required
- Clear privacy disclosures

## Technical Requirements
- iOS 18.0+
- Xcode 16.0+
- Vision framework
- VisionKit framework
- LocalAuthentication framework
- SwiftUI

## Privacy Compliance
- Follows Apple's privacy guidelines
- Minimal data retention
- User consent for camera access
- Clear data usage explanations