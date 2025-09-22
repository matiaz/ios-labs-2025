//
//  ContentView.swift
//  visionPassport
//
//  Created by matiaz on 21/9/25.
//

import SwiftUI
import LocalAuthentication

struct ContentView: View {
    @StateObject private var dataManager = SecureDataManager()
    @State private var authenticationError: String?
    @State private var showingError = false

    var body: some View {
        NavigationView {
            Group {
                switch dataManager.appState {
                case .startup:
                    StartupView(dataManager: dataManager)

                case .authenticating:
                    AuthenticationView()

                case .documentTypeSelection:
                    DocumentTypeSelector(dataManager: dataManager)

                case .privacyNotice:
                    SecurityWarningView(dataManager: dataManager)

                case .documentCapture:
                    if dataManager.selectedDocumentType.scanningMethod == .barcodeDetection {
                        BarcodeCameraWrapperView(dataManager: dataManager, documentType: dataManager.selectedDocumentType)
                    } else {
                        DocumentCameraWrapperView(dataManager: dataManager, documentType: dataManager.selectedDocumentType)
                    }

                case .processing:
                    ProcessingView()

                case .displayingResults:
                    PersonalInfoView(dataManager: dataManager)

                case .error(let error):
                    ErrorView(error: error, dataManager: dataManager)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .alert("Authentication Error", isPresented: $showingError) {
            Button("Retry") {
                authenticateUser()
            }
            Button("Cancel", role: .cancel) {
                dataManager.appState = .startup
            }
        } message: {
            if let error = authenticationError {
                Text(error)
            }
        }
        .onAppear {
            if dataManager.appState == .startup {
                authenticateUser()
            }
        }
    }

    private func authenticateUser() {
        let context = LAContext()
        var error: NSError?

        dataManager.appState = .authenticating

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to access document scanning features"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        dataManager.appState = .documentTypeSelection
                    } else {
                        self.authenticationError = authenticationError?.localizedDescription ?? "Authentication failed"
                        showingError = true
                        dataManager.appState = .error(.biometricAuthenticationFailed)
                    }
                }
            }
        } else {
            // Fallback to device passcode
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                let reason = "Authenticate to access document scanning features"

                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                    DispatchQueue.main.async {
                        if success {
                            dataManager.appState = .documentTypeSelection
                        } else {
                            self.authenticationError = authenticationError?.localizedDescription ?? "Authentication failed"
                            showingError = true
                            dataManager.appState = .error(.biometricAuthenticationFailed)
                        }
                    }
                }
            } else {
                // No authentication available
                authenticationError = "Device authentication is not available. Please set up Face ID, Touch ID, or a passcode."
                showingError = true
                dataManager.appState = .error(.biometricAuthenticationFailed)
            }
        }
    }
}

struct StartupView: View {
    @ObservedObject var dataManager: SecureDataManager

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 20) {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)

                Text("ID & Passport Reader")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("Secure document scanning with privacy protection")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 16) {
                FeatureRow(icon: "shield.lefthalf.filled", title: "Privacy First", description: "All processing happens on your device")
                FeatureRow(icon: "eye.slash", title: "No Storage", description: "Information is never saved permanently")
                FeatureRow(icon: "lock.fill", title: "Secure Access", description: "Biometric authentication required")
            }

            Spacer()

            VStack(spacing: 12) {
                Button("Get Started") {
                    // Authentication will be triggered in onAppear
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)

                Text("By continuing, you agree to our privacy practices")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
}

struct AuthenticationView: View {
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 20) {
                Image(systemName: "faceid")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)

                Text("Authentication Required")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Please authenticate to access document scanning features")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            ProgressView()
                .scaleEffect(1.5)

            Spacer()
        }
        .padding()
    }
}

struct ProcessingView: View {
    @State private var progress: Double = 0.0

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 20) {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                    .symbolEffect(.pulse, isActive: true)

                Text("Processing Document")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Analyzing and extracting information...")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 16) {
                ProgressView(value: progress, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle())
                    .scaleEffect(x: 1, y: 2, anchor: .center)

                Text("\(Int(progress * 100))% Complete")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0)) {
                progress = 1.0
            }
        }
    }
}

struct ErrorView: View {
    let error: DocumentProcessingError
    @ObservedObject var dataManager: SecureDataManager

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)

                Text("Error")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(error.localizedDescription)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                Button("Try Again") {
                    dataManager.clearAllData()
                    dataManager.appState = .documentTypeSelection
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)

                Button("Go Back") {
                    dataManager.clearAllData()
                    dataManager.appState = .startup
                }
                .font(.body)
                .foregroundColor(.blue)
                .padding(.vertical, 8)
            }

            Spacer()
        }
        .padding()
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)

                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }
}

#Preview {
    ContentView()
}
