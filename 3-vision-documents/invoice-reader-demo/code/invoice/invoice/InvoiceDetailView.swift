//
//  InvoiceDetailView.swift
//  invoice
//
//  Created by matiaz on 21/9/25.
//

import SwiftUI

struct InvoiceDetailView: View {
    let invoiceData: InvoiceData
    @State private var showingShareSheet = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    invoiceHeaderSection
                    lineItemsSection
                    totalSection
                }
                .padding()
            }
            .navigationTitle("Invoice Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Share") {
                        showingShareSheet = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let jsonString = invoiceData.toJSONString() {
                ShareSheet(items: [jsonString])
            }
        }
    }

    private var invoiceHeaderSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Invoice Information")
                .font(.title2)
                .fontWeight(.bold)

            LazyVGrid(columns: [
                GridItem(.flexible(), alignment: .leading),
                GridItem(.flexible(), alignment: .leading)
            ], spacing: 16) {
                DetailCard(
                    title: "Vendor",
                    value: invoiceData.vendor ?? "Not detected",
                    icon: "building.2",
                    color: .blue
                )

                DetailCard(
                    title: "Invoice Number",
                    value: invoiceData.invoiceNumber ?? "Not detected",
                    icon: "number",
                    color: .orange
                )

                DetailCard(
                    title: "Date",
                    value: invoiceData.formattedDate,
                    icon: "calendar",
                    color: .purple
                )

                DetailCard(
                    title: "Amount",
                    value: invoiceData.formattedAmount,
                    icon: "dollarsign.circle",
                    color: .green
                )
            }
        }
    }

    private var lineItemsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Line Items")
                .font(.title2)
                .fontWeight(.bold)

            if invoiceData.lineItems.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "list.bullet.clipboard")
                        .font(.title)
                        .foregroundColor(.gray)
                    Text("No line items detected")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(invoiceData.lineItems) { item in
                        LineItemRow(item: item)
                    }
                }
            }
        }
    }

    private var totalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Summary")
                .font(.title2)
                .fontWeight(.bold)

            HStack {
                Text("Total from line items:")
                    .font(.headline)
                Spacer()
                Text(formatDecimal(invoiceData.totalAmount))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)

            if let detectedAmount = invoiceData.amount,
               detectedAmount != invoiceData.totalAmount {
                HStack {
                    Text("Detected total:")
                        .font(.subheadline)
                    Spacer()
                    Text(invoiceData.formattedAmount)
                        .font(.subheadline)
                        .foregroundColor(.orange)
                }
                .padding(.horizontal)
            }
        }
    }

    private func formatDecimal(_ decimal: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: decimal as NSDecimalNumber) ?? "$0.00"
    }
}

struct DetailCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct LineItemRow: View {
    let item: LineItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.description)
                .font(.subheadline)
                .fontWeight(.medium)

            HStack {
                if let quantity = item.quantity {
                    Label("\(quantity)", systemImage: "number")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if let unitPrice = item.unitPrice {
                    Label(formatDecimal(unitPrice), systemImage: "tag")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if let amount = item.amount {
                    Text(formatDecimal(amount))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }

    private func formatDecimal(_ decimal: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: decimal as NSDecimalNumber) ?? "$0.00"
    }
}

#Preview {
    InvoiceDetailView(
        invoiceData: InvoiceData(
            vendor: "Tech Solutions Inc.",
            amount: Decimal(string: "1250.75"),
            date: Date(),
            invoiceNumber: "INV-2024-12345",
            lineItems: [
                LineItem(description: "Web Development Services", quantity: 40, unitPrice: Decimal(string: "25.00"), amount: Decimal(string: "1000.00")),
                LineItem(description: "Domain Registration", quantity: 1, unitPrice: Decimal(string: "15.99"), amount: Decimal(string: "15.99")),
                LineItem(description: "SSL Certificate", quantity: 1, unitPrice: Decimal(string: "49.99"), amount: Decimal(string: "49.99"))
            ]
        )
    )
}