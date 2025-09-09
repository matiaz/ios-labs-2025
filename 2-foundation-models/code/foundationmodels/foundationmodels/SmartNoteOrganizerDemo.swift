//
//  SmartNoteOrganizerDemo.swift
//  foundationmodels
//
//  Created by matiaz on 29/8/25.
//

import SwiftUI

struct SmartNoteOrganizerDemo: View {
    @State private var noteText = "Meeting with client tomorrow at 3pm. Need to prepare quarterly report and discuss budget for Q2."
    @State private var isProcessing = false
    @State private var tags: [String] = []
    @State private var summary = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Enter a note to organize:")
                .font(.subheadline)
                .fontWeight(.medium)
            
            TextEditor(text: $noteText)
                .frame(minHeight: 80)
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            
            Button(action: processNote) {
                HStack {
                    if isProcessing {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                    Text(isProcessing ? "Processing..." : "Analyze Note")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isProcessing)
            
            if !tags.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Generated Tags:")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            if !summary.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("AI Summary:")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Text(summary)
                        .font(.caption)
                        .padding(8)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
    }
    
    private func processNote() {
        isProcessing = true
        
        // Simulate AI processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            tags = ["meeting", "client", "quarterly-report", "budget", "Q2"]
            summary = "Upcoming client meeting scheduled for 3pm tomorrow. Action items include preparing quarterly report and discussing Q2 budget allocation."
            isProcessing = false
        }
    }
}

#Preview {
    SmartNoteOrganizerDemo()
        .padding()
}