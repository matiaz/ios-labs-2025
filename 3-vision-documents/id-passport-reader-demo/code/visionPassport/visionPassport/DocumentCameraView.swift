//
//  DocumentCameraView.swift
//  visionPassport
//
//  Created by matiaz on 21/9/25.
//

import SwiftUI
import VisionKit
import UIKit

struct DocumentCameraView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    let documentType: DocumentType
    let onDocumentScanned: (UIImage) -> Void
    let onError: (DocumentProcessingError) -> Void

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scannerViewController = VNDocumentCameraViewController()
        scannerViewController.delegate = context.coordinator
        return scannerViewController
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var parent: DocumentCameraView

        init(_ parent: DocumentCameraView) {
            self.parent = parent
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            guard scan.pageCount > 0 else {
                parent.onError(.documentNotDetected)
                parent.dismiss()
                return
            }

            let scannedImage = scan.imageOfPage(at: 0)

            if !DocumentProcessor.shared.validateImageQuality(scannedImage) {
                parent.onError(.lowImageQuality)
                parent.dismiss()
                return
            }

            if let processedImage = DocumentProcessor.shared.preprocessImage(scannedImage) {
                parent.onDocumentScanned(processedImage)
            } else {
                parent.onDocumentScanned(scannedImage)
            }

            parent.dismiss()
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            parent.onError(.textRecognitionFailed)
            parent.dismiss()
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            parent.dismiss()
        }
    }
}

struct DocumentCameraWrapperView: View {
    @ObservedObject var dataManager: SecureDataManager
    let documentType: DocumentType
    @State private var showingScanner = false
    @State private var isProcessing = false

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                Image(systemName: documentType.icon)
                    .font(.system(size: 60))
                    .foregroundColor(.blue)

                Text("Scan \(documentType.rawValue)")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Position your \(documentType.rawValue.lowercased()) within the camera frame")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            VStack(spacing: 16) {
                scanningTips

                Button(action: {
                    showingScanner = true
                }) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("Start Scanning")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .disabled(isProcessing)
            }
            .padding(.horizontal)

            if isProcessing {
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Processing document...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
            }

            Spacer()
        }
        .padding()
        .sheet(isPresented: $showingScanner) {
            DocumentCameraView(
                documentType: documentType,
                onDocumentScanned: { image in
                    processDocument(image: image)
                },
                onError: { error in
                    dataManager.appState = .error(error)
                }
            )
        }
    }

    private var scanningTips: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Scanning Tips:")
                .font(.headline)
                .foregroundColor(.primary)

            VStack(alignment: .leading, spacing: 6) {
                tipRow(icon: "lightbulb.fill", text: "Ensure good lighting")
                tipRow(icon: "camera.fill", text: "Hold device steady")
                tipRow(icon: "doc.text.fill", text: "Capture the entire document")
                if documentType == .passport {
                    tipRow(icon: "textformat", text: "Include the MRZ (bottom lines)")
                }
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
    }

    private func tipRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
            Spacer()
        }
    }

    private func processDocument(image: UIImage) {
        isProcessing = true
        dataManager.appState = .processing

        DocumentProcessor.shared.processDocument(image: image, documentType: documentType) { result in
            DispatchQueue.main.async {
                isProcessing = false
                dataManager.processingResult = result

                if result.isSuccessful {
                    dataManager.setDocument(result.document)
                    dataManager.appState = .displayingResults
                } else {
                    let error = result.errors.first ?? .textRecognitionFailed
                    dataManager.appState = .error(error)
                }
            }
        }
    }
}

#Preview {
    DocumentCameraWrapperView(
        dataManager: SecureDataManager(),
        documentType: .passport
    )
}