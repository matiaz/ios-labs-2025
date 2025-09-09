//
//  MeetingTranscriptDemo.swift
//  foundationmodels
//
//  Created by matiaz on 29/8/25.
//

import SwiftUI

struct MeetingTranscriptDemo: View {
    @State private var transcript = "John: We need to finalize the budget by Friday. Sarah: I'll review the Q2 numbers. Mike: Can we schedule a follow-up for Monday?"
    @State private var isProcessing = false
    @State private var actionItems: [String] = []
    @State private var summary = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Enter meeting transcript:")
                .font(.subheadline)
                .fontWeight(.medium)
            
            TextEditor(text: $transcript)
                .frame(minHeight: 80)
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            
            Button(action: processTranscript) {
                HStack {
                    if isProcessing {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                    Text(isProcessing ? "Processing..." : "Analyze Meeting")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isProcessing)
            
            if !actionItems.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Action Items:")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    ForEach(actionItems, id: \.self) { item in
                        HStack {
                            Image(systemName: "checkmark.square")
                                .foregroundColor(.blue)
                                .font(.caption)
                            Text(item)
                                .font(.caption)
                        }
                    }
                }
            }
            
            if !summary.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Meeting Summary:")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Text(summary)
                        .font(.caption)
                        .padding(8)
                        .background(Color.indigo.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
    }
    
    private func processTranscript() {
        isProcessing = true
        
        // Simulate AI transcript analysis
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            actionItems = [
                "John: Finalize budget by Friday",
                "Sarah: Review Q2 numbers",
                "Mike: Schedule follow-up for Monday"
            ]
            summary = "Team discussed budget finalization with a Friday deadline. Sarah will handle Q2 number review, and Mike will coordinate the Monday follow-up meeting."
            isProcessing = false
        }
    }
}

#Preview {
    MeetingTranscriptDemo()
        .padding()
}