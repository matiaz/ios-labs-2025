//
//  DocumentTypeSelector.swift
//  visionPassport
//
//  Created by matiaz on 21/9/25.
//

import SwiftUI

struct DocumentTypeSelector: View {
    @ObservedObject var dataManager: SecureDataManager
    @State private var selectedDocumentType: DocumentType?

    var body: some View {
        VStack(spacing: 24) {
            headerSection

            documentTypeGrid

            if selectedDocumentType != nil {
                continueButton
            }

            Spacer()
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("Select Document Type")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Choose the type of document you want to scan")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var documentTypeGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(DocumentType.allCases, id: \.self) { documentType in
                DocumentTypeCard(
                    documentType: documentType,
                    isSelected: selectedDocumentType == documentType,
                    onTap: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedDocumentType = documentType
                        }
                    }
                )
            }
        }
    }

    private var continueButton: some View {
        VStack(spacing: 16) {
            Button(action: {
                if let selectedType = selectedDocumentType {
                    dataManager.selectedDocumentType = selectedType
                    dataManager.appState = .privacyNotice
                }
            }) {
                HStack {
                    Text("Continue")
                    Image(systemName: "arrow.right")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }

            if let selectedType = selectedDocumentType {
                documentInfo(for: selectedType)
            }
        }
    }

    private func documentInfo(for documentType: DocumentType) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("What we'll extract:")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 4) {
                ForEach(extractableFields(for: documentType), id: \.self) { field in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text(field)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(8)
    }

    private func extractableFields(for documentType: DocumentType) -> [String] {
        switch documentType {
        case .driversLicense:
            return [
                "Full Name",
                "License Number",
                "Date of Birth",
                "Expiration Date",
                "Issuing Authority"
            ]
        case .nationalID:
            return [
                "Full Name",
                "ID Number",
                "Date of Birth",
                "Expiration Date",
                "Issuing Authority"
            ]
        case .passport:
            return [
                "Full Name",
                "Passport Number",
                "Date of Birth",
                "Expiration Date",
                "Nationality",
                "Issuing Country"
            ]
        case .usDLCode:
            return [
                "Full Name",
                "License Number",
                "Date of Birth",
                "Expiration Date",
                "Address",
                "Gender",
                "Issuing State"
            ]
        }
    }
}

struct DocumentTypeCard: View {
    let documentType: DocumentType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                Image(systemName: documentType.icon)
                    .font(.system(size: 40))
                    .foregroundColor(isSelected ? .white : .blue)

                Text(documentType.rawValue)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)

                Text(supportedText(for: documentType))
                    .font(.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .padding()
            .background(isSelected ? Color.blue : Color(.systemGroupedBackground))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    private func supportedText(for documentType: DocumentType) -> String {
        switch documentType {
        case .driversLicense:
            return "US Driver's Licenses"
        case .nationalID:
            return "Government ID Cards"
        case .passport:
            return "International Passports"
        case .usDLCode:
            return "PDF417 Barcode"
        }
    }
}

#Preview {
    NavigationView {
        DocumentTypeSelector(dataManager: SecureDataManager())
    }
}