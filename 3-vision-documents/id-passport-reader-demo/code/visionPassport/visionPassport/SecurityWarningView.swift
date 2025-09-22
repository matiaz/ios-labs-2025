//
//  SecurityWarningView.swift
//  visionPassport
//
//  Created by matiaz on 21/9/25.
//

import SwiftUI

struct SecurityWarningView: View {
    @ObservedObject var dataManager: SecureDataManager
    @State private var hasAgreedToTerms = false
    @State private var showingFullPrivacyPolicy = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection

                privacyHighlights

                securityFeatures

                dataHandlingInfo

                agreementSection

                actionButtons
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Privacy & Security")
        .sheet(isPresented: $showingFullPrivacyPolicy) {
            FullPrivacyPolicyView()
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "shield.checkered")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("Your Privacy is Protected")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            Text("Before we scan your document, please review our privacy and security practices.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var privacyHighlights: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Key Privacy Features")
                .font(.headline)
                .foregroundColor(.primary)

            VStack(spacing: 12) {
                privacyFeatureRow(
                    icon: "iphone",
                    title: "On-Device Processing",
                    description: "All document analysis happens locally on your device"
                )

                privacyFeatureRow(
                    icon: "wifi.slash",
                    title: "No Network Access",
                    description: "No personal data is sent to external servers"
                )

                privacyFeatureRow(
                    icon: "clock",
                    title: "Temporary Storage",
                    description: "Data is automatically deleted after 5 minutes"
                )

                privacyFeatureRow(
                    icon: "lock.fill",
                    title: "Secure Memory",
                    description: "Information is encrypted in device memory"
                )
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
    }

    private var securityFeatures: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Security Measures")
                .font(.headline)
                .foregroundColor(.primary)

            VStack(spacing: 12) {
                securityFeatureRow(
                    icon: "faceid",
                    title: "Biometric Authentication",
                    description: "Access requires Face ID or Touch ID verification"
                )

                securityFeatureRow(
                    icon: "eye.slash.fill",
                    title: "No Screenshots",
                    description: "Personal data cannot be captured via screenshots"
                )

                securityFeatureRow(
                    icon: "trash.fill",
                    title: "Automatic Cleanup",
                    description: "All data is securely wiped from memory after use"
                )
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
    }

    private var dataHandlingInfo: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What We Process")
                .font(.headline)
                .foregroundColor(.primary)

            Text("This app extracts and displays text from your documents including:")
                .font(.body)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 6) {
                dataPointRow("Full Name")
                dataPointRow("Document Numbers")
                dataPointRow("Dates (Birth, Expiration)")
                dataPointRow("Nationality/Issuing Authority")
            }

            Text("This information is never stored permanently and is automatically deleted.")
                .font(.caption)
                .foregroundColor(.orange)
                .padding(.top, 8)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
    }

    private var agreementSection: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                Button(action: {
                    hasAgreedToTerms.toggle()
                }) {
                    Image(systemName: hasAgreedToTerms ? "checkmark.square.fill" : "square")
                        .font(.title3)
                        .foregroundColor(hasAgreedToTerms ? .blue : .secondary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("I understand and agree to the privacy practices outlined above.")
                        .font(.body)
                        .foregroundColor(.primary)

                    Button("View Full Privacy Policy") {
                        showingFullPrivacyPolicy = true
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }

                Spacer()
            }
        }
        .padding()
        .background(hasAgreedToTerms ? Color.blue.opacity(0.1) : Color(.systemGroupedBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(hasAgreedToTerms ? Color.blue : Color.clear, lineWidth: 1)
        )
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: {
                dataManager.appState = .documentCapture
            }) {
                Text("Continue to Scanning")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(hasAgreedToTerms ? Color.blue : Color.gray)
                    .cornerRadius(12)
            }
            .disabled(!hasAgreedToTerms)

            Button("Go Back") {
                dataManager.appState = .documentTypeSelection
            }
            .font(.body)
            .foregroundColor(.blue)
            .padding(.vertical, 8)
        }
    }

    private func privacyFeatureRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }

    private func securityFeatureRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.green)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }

    private func dataPointRow(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "doc.text")
                .font(.caption)
                .foregroundColor(.blue)
                .frame(width: 16)

            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()
        }
    }
}

struct FullPrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Privacy Policy")
                        .font(.title)
                        .fontWeight(.bold)

                    Group {
                        privacySection(
                            title: "Data Collection",
                            content: "This application processes personal information from identity documents solely for the purpose of displaying extracted text to the user. No personal data is collected, stored, or transmitted outside of the device."
                        )

                        privacySection(
                            title: "Data Processing",
                            content: "All document analysis is performed locally using Apple's Vision framework. The app extracts text from documents including names, dates, document numbers, and issuing authorities for display purposes only."
                        )

                        privacySection(
                            title: "Data Storage",
                            content: "No personal information is permanently stored on the device or transmitted to external servers. All extracted data is held in device memory temporarily and is automatically deleted within 5 minutes or when the app is closed."
                        )

                        privacySection(
                            title: "Security",
                            content: "The app implements biometric authentication, memory encryption, and automatic data cleanup. Screenshots are disabled when personal information is displayed to prevent unauthorized capture."
                        )

                        privacySection(
                            title: "Third Parties",
                            content: "No personal data is shared with third parties. The app operates entirely offline and does not communicate with external services when processing personal documents."
                        )

                        privacySection(
                            title: "User Rights",
                            content: "Users can exit the app at any time to immediately trigger data cleanup. The biometric authentication requirement ensures only authorized users can access the scanning functionality."
                        )
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func privacySection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
                .lineSpacing(2)
        }
    }
}

#Preview {
    NavigationView {
        SecurityWarningView(dataManager: SecureDataManager())
    }
}