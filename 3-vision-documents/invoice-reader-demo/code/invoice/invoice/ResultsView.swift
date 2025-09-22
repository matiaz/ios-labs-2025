//
//  ResultsView.swift
//  invoice
//
//  Created by matiaz on 21/9/25.
//

import SwiftUI

struct ResultsView: View {
    let invoiceData: InvoiceData
    let rawText: String
    @State private var showingRawText = false
    @State private var showingShareSheet = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    jsonDisplaySection
                }
                .padding()
            }
            .navigationTitle("Invoice Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("View Raw Text") {
                            showingRawText = true
                        }
                        Button("Share JSON") {
                            showingShareSheet = true
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showingRawText) {
            RawTextView(text: rawText)
        }
        .sheet(isPresented: $showingShareSheet) {
            if let jsonString = invoiceData.toJSONString() {
                ShareSheet(items: [jsonString])
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Extracted Invoice Data")
                .font(.title2)
                .fontWeight(.bold)

            if let vendor = invoiceData.vendor {
                Label(vendor, systemImage: "building.2")
                    .foregroundColor(.primary)
            }

            HStack {
                if invoiceData.amount != nil {
                    Label(invoiceData.formattedAmount, systemImage: "dollarsign.circle")
                        .foregroundColor(.green)
                }

                if invoiceData.date != nil {
                    Label(invoiceData.formattedDate, systemImage: "calendar")
                        .foregroundColor(.blue)
                }
            }

            if let invoiceNumber = invoiceData.invoiceNumber {
                Label("Invoice: \(invoiceNumber)", systemImage: "number")
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private var jsonDisplaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("JSON Output")
                .font(.headline)

            ScrollView {
                Text(invoiceData.toJSONString() ?? "Unable to generate JSON")
                    .font(.system(.caption, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            .frame(maxHeight: 300)
        }
    }
}

struct RawTextView: View {
    let text: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                Text(text.isEmpty ? "No text extracted" : text)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle("Raw Text")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ResultsView(
        invoiceData: InvoiceData(
            vendor: "Sample Company Inc.",
            amount: Decimal(string: "125.50"),
            date: Date(),
            invoiceNumber: "INV-2024-001",
            lineItems: [
                LineItem(description: "Consulting Services", quantity: 2, unitPrice: Decimal(string: "50.00"), amount: Decimal(string: "100.00")),
                LineItem(description: "Software License", quantity: 1, unitPrice: Decimal(string: "25.50"), amount: Decimal(string: "25.50"))
            ]
        ),
        rawText: "Sample extracted text from invoice..."
    )
}