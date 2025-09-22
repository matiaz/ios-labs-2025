//
//  PersonalInfoView.swift
//  visionPassport
//
//  Created by matiaz on 21/9/25.
//

import SwiftUI

struct PersonalInfoView: View {
    @ObservedObject var dataManager: SecureDataManager
    @State private var timeRemaining: TimeInterval = 300
    @State private var timer: Timer?
    @State private var showingSecurityAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection

                if let document = dataManager.currentDocument {
                    documentInfoSection(document)
                    processingInfoSection
                }

                securityNoticeSection

                actionButtons
            }
            .padding()
        }
        .navigationBarHidden(true)
        .onAppear {
            startSecurityTimer()
        }
        .onDisappear {
            stopSecurityTimer()
        }
        .alert("Security Notice", isPresented: $showingSecurityAlert) {
            Button("Continue Viewing") { }
            Button("Clear Data Now", role: .destructive) {
                dataManager.clearAllData()
                dataManager.appState = .startup
            }
        } message: {
            Text("For your security, this information will be automatically cleared in \(Int(timeRemaining)) seconds.")
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "checkmark.shield.fill")
                    .font(.title)
                    .foregroundColor(.green)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Document Processed")
                        .font(.headline)
                        .fontWeight(.semibold)

                    Text("Information extracted successfully")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                timeRemainingView
            }

            if let document = dataManager.currentDocument, document.isExpired {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("This document has expired")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }

    private var timeRemainingView: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text("Auto-clear in")
                .font(.caption2)
                .foregroundColor(.secondary)

            Text(formatTime(timeRemaining))
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(timeRemaining < 60 ? .red : .secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.systemGroupedBackground))
        .cornerRadius(6)
    }

    private func documentInfoSection(_ document: PersonalDocument) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: document.documentType.icon)
                    .font(.title2)
                    .foregroundColor(.blue)

                Text(document.documentType.rawValue)
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()
            }

            LazyVGrid(columns: [
                GridItem(.flexible(), alignment: .leading),
                GridItem(.flexible(), alignment: .leading)
            ], spacing: 16) {
                if let fullName = document.fullName {
                    InfoField(label: "Full Name", value: fullName, icon: "person.fill")
                }

                if let documentNumber = document.documentNumber {
                    InfoField(label: "Document Number", value: documentNumber, icon: "number")
                }

                if let dateOfBirth = document.dateOfBirth {
                    InfoField(label: "Date of Birth", value: formatDate(dateOfBirth), icon: "calendar")
                }

                if let expirationDate = document.expirationDate {
                    InfoField(
                        label: "Expiration Date",
                        value: formatDate(expirationDate),
                        icon: "calendar.badge.exclamationmark",
                        isExpired: document.isExpired
                    )
                }

                if let nationality = document.nationality {
                    InfoField(label: "Nationality", value: nationality, icon: "flag.fill")
                }

                if let issuingAuthority = document.issuingAuthority {
                    InfoField(label: "Issuing Authority", value: issuingAuthority, icon: "building.columns.fill")
                }

                if let gender = document.gender {
                    InfoField(label: "Gender", value: gender, icon: "person.2.fill")
                }

                if let placeOfBirth = document.placeOfBirth {
                    InfoField(label: "Place of Birth", value: placeOfBirth, icon: "location.fill")
                }
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
    }

    private var processingInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Processing Details")
                .font(.headline)
                .foregroundColor(.primary)

            if let result = dataManager.processingResult {
                VStack(spacing: 8) {
                    ProcessingDetailRow(
                        label: "Confidence",
                        value: "\(Int(result.confidence * 100))%",
                        icon: "gauge.medium"
                    )

                    ProcessingDetailRow(
                        label: "Processing Time",
                        value: String(format: "%.2fs", result.processingTime),
                        icon: "clock"
                    )

                    ProcessingDetailRow(
                        label: "Status",
                        value: result.isSuccessful ? "Successful" : "Partial",
                        icon: result.isSuccessful ? "checkmark.circle" : "exclamationmark.triangle"
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
    }

    private var securityNoticeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "shield.lefthalf.filled")
                    .foregroundColor(.blue)
                Text("Security Active")
                    .font(.headline)
                    .fontWeight(.medium)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 6) {
                SecurityFeatureRow(
                    icon: "eye.slash",
                    text: "Screenshots disabled",
                    isActive: true
                )

                SecurityFeatureRow(
                    icon: "memories",
                    text: "Memory encrypted",
                    isActive: true
                )

                SecurityFeatureRow(
                    icon: "wifi.slash",
                    text: "No network access",
                    isActive: true
                )

                SecurityFeatureRow(
                    icon: "trash",
                    text: "Auto-cleanup enabled",
                    isActive: true
                )
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: {
                dataManager.clearAllData()
                dataManager.appState = .documentTypeSelection
            }) {
                HStack {
                    Image(systemName: "doc.text.magnifyingglass")
                    Text("Scan Another Document")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }

            Button(action: {
                dataManager.clearAllData()
                dataManager.appState = .startup
            }) {
                HStack {
                    Image(systemName: "trash.fill")
                    Text("Clear Data & Exit")
                }
                .font(.body)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }

    private func startSecurityTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            timeRemaining -= 1

            if timeRemaining <= 60 && timeRemaining > 0 && Int(timeRemaining) % 15 == 0 {
                showingSecurityAlert = true
            }

            if timeRemaining <= 0 {
                dataManager.clearAllData()
                dataManager.appState = .startup
            }
        }
    }

    private func stopSecurityTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct InfoField: View {
    let label: String
    let value: String
    let icon: String
    var isExpired: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(isExpired ? .red : .blue)

                Text(label)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                if isExpired {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption2)
                        .foregroundColor(.red)
                }

                Spacer()
            }

            Text(value)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(isExpired ? .red : .primary)
                .lineLimit(3)
        }
        .padding()
        .background(isExpired ? Color.red.opacity(0.1) : Color(.systemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isExpired ? Color.red.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}

struct ProcessingDetailRow: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.blue)
                .frame(width: 16)

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
}

struct SecurityFeatureRow: View {
    let icon: String
    let text: String
    let isActive: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(isActive ? .green : .secondary)
                .frame(width: 16)

            Text(text)
                .font(.caption)
                .foregroundColor(isActive ? .primary : .secondary)

            Spacer()

            Image(systemName: isActive ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.caption)
                .foregroundColor(isActive ? .green : .red)
        }
    }
}

#Preview {
    let dataManager = SecureDataManager()
    dataManager.currentDocument = PersonalDocument(
        documentType: .passport,
        fullName: "John Doe",
        dateOfBirth: Calendar.current.date(byAdding: .year, value: -30, to: Date()),
        documentNumber: "P123456789",
        expirationDate: Calendar.current.date(byAdding: .year, value: 5, to: Date()),
        nationality: "United States",
        issuingAuthority: "US Department of State"
    )

    return PersonalInfoView(dataManager: dataManager)
}