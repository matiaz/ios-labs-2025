//
//  EmailAssistantDemo.swift
//  foundationmodels
//
//  Created by matiaz on 29/8/25.
//

import SwiftUI

struct EmailAssistantDemo: View {
    @State private var emailTopic = "Follow up on project proposal"
    @State private var tone = "Professional"
    @State private var generatedEmail = ""
    @State private var isGenerating = false
    
    let tones = ["Professional", "Casual", "Friendly", "Formal"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Email Topic:")
                .font(.subheadline)
                .fontWeight(.medium)
            
            TextField("What's the email about?", text: $emailTopic)
                .textFieldStyle(.roundedBorder)
            
            Text("Tone:")
                .font(.subheadline)
                .fontWeight(.medium)
            
            Picker("Tone", selection: $tone) {
                ForEach(tones, id: \.self) { tone in
                    Text(tone).tag(tone)
                }
            }
            .pickerStyle(.segmented)
            
            Button(action: generateEmail) {
                HStack {
                    if isGenerating {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                    Text(isGenerating ? "Generating..." : "Generate Email")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isGenerating)
            
            if !generatedEmail.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Generated Email:")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    ScrollView {
                        Text(generatedEmail)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxHeight: 120)
                    .padding(8)
                    .background(Color.blue.opacity(0.05))
                    .cornerRadius(8)
                }
            }
        }
    }
    
    private func generateEmail() {
        isGenerating = true
        
        // Simulate AI email generation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            generatedEmail = """
            Subject: \(emailTopic)
            
            Hi [Name],
            
            I hope this email finds you well. I wanted to follow up on the project proposal we discussed last week.
            
            I'm excited about the potential collaboration and would love to schedule a time to discuss the next steps. Please let me know your availability for a brief call this week.
            
            Looking forward to hearing from you.
            
            Best regards,
            [Your Name]
            """
            isGenerating = false
        }
    }
}

#Preview {
    EmailAssistantDemo()
        .padding()
}