//
//  PersonalDataModels.swift
//  visionPassport
//
//  Created by matiaz on 21/9/25.
//

import Foundation
import Combine

enum DocumentType: String, CaseIterable {
    case driversLicense = "Driver's License"
    case nationalID = "National ID"
    case passport = "Passport"
    case usDLCode = "US DL Code"

    var icon: String {
        switch self {
        case .driversLicense:
            return "car.fill"
        case .nationalID:
            return "person.text.rectangle.fill"
        case .passport:
            return "book.fill"
        case .usDLCode:
            return "barcode.viewfinder"
        }
    }

    var scanningMethod: ScanningMethod {
        switch self {
        case .driversLicense, .nationalID, .passport:
            return .textRecognition
        case .usDLCode:
            return .barcodeDetection
        }
    }
}

enum ScanningMethod {
    case textRecognition
    case barcodeDetection
}

struct PersonalDocument {
    let documentType: DocumentType
    let fullName: String?
    let dateOfBirth: Date?
    let documentNumber: String?
    let expirationDate: Date?
    let nationality: String?
    let issuingAuthority: String?
    let gender: String?
    let placeOfBirth: String?

    private let timestamp: Date = Date()

    init(documentType: DocumentType,
         fullName: String? = nil,
         dateOfBirth: Date? = nil,
         documentNumber: String? = nil,
         expirationDate: Date? = nil,
         nationality: String? = nil,
         issuingAuthority: String? = nil,
         gender: String? = nil,
         placeOfBirth: String? = nil) {
        self.documentType = documentType
        self.fullName = fullName
        self.dateOfBirth = dateOfBirth
        self.documentNumber = documentNumber
        self.expirationDate = expirationDate
        self.nationality = nationality
        self.issuingAuthority = issuingAuthority
        self.gender = gender
        self.placeOfBirth = placeOfBirth
    }

    var isExpired: Bool {
        guard let expirationDate = expirationDate else { return false }
        return expirationDate < Date()
    }

    var ageFromCreation: TimeInterval {
        Date().timeIntervalSince(timestamp)
    }

    func secureCleanup() {

    }
}

struct DocumentProcessingResult {
    let document: PersonalDocument?
    let confidence: Float
    let processingTime: TimeInterval
    let errors: [DocumentProcessingError]

    var isSuccessful: Bool {
        return document != nil && confidence > 0.7 && errors.isEmpty
    }
}

enum DocumentProcessingError: Error, LocalizedError, Equatable {
    case cameraAccessDenied
    case documentNotDetected
    case textRecognitionFailed
    case invalidDocumentFormat
    case lowImageQuality
    case unsupportedDocumentType
    case biometricAuthenticationFailed

    var errorDescription: String? {
        switch self {
        case .cameraAccessDenied:
            return "Camera access is required to scan documents"
        case .documentNotDetected:
            return "No document detected in the image"
        case .textRecognitionFailed:
            return "Unable to recognize text from the document"
        case .invalidDocumentFormat:
            return "Document format is not supported"
        case .lowImageQuality:
            return "Image quality is too low for processing"
        case .unsupportedDocumentType:
            return "This document type is not supported"
        case .biometricAuthenticationFailed:
            return "Biometric authentication failed"
        }
    }
}

enum AppState: Equatable {
    case startup
    case authenticating
    case documentTypeSelection
    case privacyNotice
    case documentCapture
    case processing
    case displayingResults
    case error(DocumentProcessingError)
}

class SecureDataManager: ObservableObject {
    @Published var currentDocument: PersonalDocument?
    @Published var appState: AppState = .startup
    @Published var processingResult: DocumentProcessingResult?
    @Published var selectedDocumentType: DocumentType = .passport

    private var dataCleanupTimer: Timer?
    private let maxDataRetentionTime: TimeInterval = 300 // 5 minutes

    func setDocument(_ document: PersonalDocument?) {
        currentDocument = document
        scheduleDataCleanup()
    }

    func clearAllData() {
        currentDocument?.secureCleanup()
        currentDocument = nil
        processingResult = nil
        dataCleanupTimer?.invalidate()
        dataCleanupTimer = nil
    }

    private func scheduleDataCleanup() {
        dataCleanupTimer?.invalidate()
        dataCleanupTimer = Timer.scheduledTimer(withTimeInterval: maxDataRetentionTime, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.clearAllData()
            }
        }
    }

    deinit {
        clearAllData()
    }
}