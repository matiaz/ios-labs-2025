# Invoice Reader Demo

## Overview
A minimal iOS app demonstrating Apple's Vision framework capabilities for extracting structured data from invoice images and displaying it in a formatted JSON structure.

## Features
- 📸 Document camera integration for capturing invoice photos
- 🖼️ Support for existing images from photo library
- 🔍 Text recognition and extraction using Vision framework
- 📊 Structured data parsing (vendor, amount, date, line items)
- 📱 Clean SwiftUI interface for displaying results
- 💾 JSON export functionality

## Key Components

### Vision Processing
- `InvoiceProcessor.swift` - Main Vision framework integration
- `TextExtractor.swift` - Text recognition and parsing logic
- `DataStructure.swift` - Invoice data models

### UI Components
- `CameraView.swift` - Document camera interface
- `ResultsView.swift` - Formatted JSON display
- `InvoiceDetailView.swift` - Structured data presentation

### Data Models
```swift
struct InvoiceData {
    let vendor: String?
    let amount: Decimal?
    let date: Date?
    let invoiceNumber: String?
    let lineItems: [LineItem]
}
```

## Implementation Status
- [ ] Project setup with Vision framework
- [ ] Document camera integration
- [ ] Basic text recognition
- [ ] Invoice-specific data extraction
- [ ] JSON formatting and display
- [ ] UI polish and error handling

## Sample Usage
1. Launch app
2. Tap "Scan Invoice" to open camera
3. Position invoice in camera frame
4. Capture image
5. Review extracted JSON data
6. Export or share results

## Technical Requirements
- iOS 18.0+
- Xcode 16.0+
- Vision framework
- VisionKit framework
- SwiftUI