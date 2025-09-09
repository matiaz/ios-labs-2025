# Sprint 3: Apple's Vision Framework for Document Understanding

## Goal
Research and implement Apple's new Vision framework capabilities for document understanding introduced at WWDC 2025. This includes leveraging VisionKit + Vision APIs to detect, extract, and process text from scanned documents, receipts, and forms directly on-device.

## Why This Matters
Accurate, on-device document reading is critical for many business applications (e.g., expense management, healthcare, legal, finance). With Apple's enhanced Vision framework, we can now extract structured information (like names, dates, totals) in a secure and performant way, reducing reliance on third-party OCR services.

## Deliverables

### 1. Research Summary
- **File**: `summary.md`
- **Content**: Written summary of WWDC 2025 session "Read documents using the Vision framework" and supporting Apple documentation

### 2. Demo Applications

#### Invoice Reader Demo
- **Location**: `invoice-reader-demo/`
- **Features**:
  - Capture photo of invoice or use existing image
  - Extract structured data (vendor, amount, date, line items)
  - Convert to JSON format
  - Display formatted results in clean UI
  - Handle various invoice formats and layouts

#### ID/Passport Reader Demo  
- **Location**: `id-passport-reader-demo/`
- **Features**:
  - Scan ID cards and passports
  - Extract personal information (name, DOB, ID numbers, etc.)
  - Secure handling of sensitive data
  - Formatted display of extracted details
  - Support for multiple document types

### 3. Implementation Documentation
- API usage examples and code snippets
- Best practices for document processing
- Error handling strategies
- Performance optimization tips
- Real-world use case scenarios

## Technical Stack
- **Primary**: VisionKit + Vision Framework
- **UI**: SwiftUI
- **Image Processing**: Core Image (if needed)
- **Data Format**: JSON for structured output
- **Platform**: iOS 18.0+

## Key APIs to Explore
- `VNRecognizeTextRequest` - Enhanced text recognition
- `VNDetectDocumentSegmentationRequest` - Document boundary detection  
- `VNRecognizeDocumentElementsRequest` - Structured content extraction
- `VisionKit.DocumentCamera` - Document capture interface

## Success Criteria
- [ ] Complete research summary with key WWDC insights
- [ ] Working invoice reader demo with JSON output
- [ ] Working ID/passport reader demo
- [ ] Comprehensive documentation with code examples
- [ ] Published in GitHub repository under `3-vision-documents/`

## Timeline
**Sprint Duration**: 2 weeks
**Start Date**: TBD
**End Date**: TBD

## Notes
- Focus on on-device processing for privacy
- Prioritize accuracy and user experience
- Consider accessibility in UI design
- Plan for localization of document formats