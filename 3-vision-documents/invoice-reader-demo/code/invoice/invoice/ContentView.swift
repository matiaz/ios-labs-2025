//
//  ContentView.swift
//  invoice
//
//  Created by matiaz on 21/9/25.
//

import SwiftUI
import VisionKit

struct ContentView: View {
    @StateObject private var invoiceProcessor = InvoiceProcessor()
    @State private var scannedImages: [UIImage] = []
    @State private var selectedImage: UIImage?
    @State private var showingCamera = false
    @State private var showingImagePicker = false
    @State private var showingResults = false
    @State private var showingDetailView = false

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                headerSection

                if invoiceProcessor.isProcessing {
                    processingSection
                } else if invoiceProcessor.invoiceData.vendor != nil || !invoiceProcessor.invoiceData.lineItems.isEmpty {
                    resultsPreviewSection
                } else {
                    instructionsSection
                }

                actionButtonsSection

                Spacer()
            }
            .padding()
            .navigationTitle("Invoice Reader")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingCamera) {
            CameraView(scannedImages: $scannedImages)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .sheet(isPresented: $showingResults) {
            ResultsView(invoiceData: invoiceProcessor.invoiceData, rawText: invoiceProcessor.rawText)
        }
        .sheet(isPresented: $showingDetailView) {
            InvoiceDetailView(invoiceData: invoiceProcessor.invoiceData)
        }
        .onChange(of: scannedImages) { _, newImages in
            if let firstImage = newImages.first {
                processImage(firstImage)
            }
        }
        .onChange(of: selectedImage) { _, newImage in
            if let image = newImage {
                processImage(image)
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text.viewfinder")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("Invoice Reader Demo")
                .font(.title2)
                .fontWeight(.bold)

            Text("Scan or select invoice images to extract structured data using Apple's Vision framework")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var processingSection: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Processing invoice...")
                .font(.headline)
                .foregroundColor(.blue)

            Text("Extracting and parsing text data")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 32)
    }

    private var resultsPreviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Results")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                if let vendor = invoiceProcessor.invoiceData.vendor {
                    Label(vendor, systemImage: "building.2")
                        .foregroundColor(.primary)
                }

                HStack {
                    if invoiceProcessor.invoiceData.amount != nil {
                        Label(invoiceProcessor.invoiceData.formattedAmount, systemImage: "dollarsign.circle")
                            .foregroundColor(.green)
                    }

                    if invoiceProcessor.invoiceData.date != nil {
                        Label(invoiceProcessor.invoiceData.formattedDate, systemImage: "calendar")
                            .foregroundColor(.blue)
                    }
                }

                if !invoiceProcessor.invoiceData.lineItems.isEmpty {
                    Label("\(invoiceProcessor.invoiceData.lineItems.count) line items", systemImage: "list.bullet")
                        .foregroundColor(.orange)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)

            HStack(spacing: 12) {
                Button("View Details") {
                    showingDetailView = true
                }
                .buttonStyle(.borderedProminent)

                Button("View JSON") {
                    showingResults = true
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private var instructionsSection: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 40))
                    .foregroundColor(.gray)

                Text("No invoice processed yet")
                    .font(.headline)
                    .foregroundColor(.secondary)

                Text("Scan a new invoice or select from your photo library to get started")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 24)
        }
    }

    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            if VNDocumentCameraViewController.isSupported {
                Button(action: {
                    showingCamera = true
                }) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("Scan Invoice")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }

            Button(action: {
                showingImagePicker = true
            }) {
                HStack {
                    Image(systemName: "photo.fill")
                    Text("Choose from Photos")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
    }

    private func processImage(_ image: UIImage) {
        invoiceProcessor.processInvoice(from: image)
    }
}

#Preview {
    ContentView()
}
