//
//  StudyBuddyDemo.swift
//  foundationmodels
//
//  Created by matiaz on 29/8/25.
//

import SwiftUI

struct StudyBuddyDemo: View {
    @State private var studyMaterial = "Photosynthesis is the process by which plants convert sunlight into energy using chlorophyll."
    @State private var isGenerating = false
    @State private var quiz: [String] = []
    @State private var flashcards: [String] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Enter study material:")
                .font(.subheadline)
                .fontWeight(.medium)
            
            TextEditor(text: $studyMaterial)
                .frame(minHeight: 60)
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            
            Button(action: generateStudyMaterials) {
                HStack {
                    if isGenerating {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                    Text(isGenerating ? "Generating..." : "Create Study Materials")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isGenerating)
            
            if !quiz.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Generated Quiz:")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    ForEach(Array(quiz.enumerated()), id: \.offset) { index, question in
                        Text("\(index + 1). \(question)")
                            .font(.caption)
                            .padding(6)
                            .background(Color.yellow.opacity(0.1))
                            .cornerRadius(6)
                    }
                }
            }
            
            if !flashcards.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Flashcards:")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    ForEach(flashcards, id: \.self) { card in
                        Text(card)
                            .font(.caption)
                            .padding(6)
                            .background(Color.pink.opacity(0.1))
                            .cornerRadius(6)
                    }
                }
            }
        }
    }
    
    private func generateStudyMaterials() {
        isGenerating = true
        
        // Simulate AI study material generation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            quiz = [
                "What is photosynthesis?",
                "Which pigment is essential for photosynthesis?",
                "What does photosynthesis convert sunlight into?"
            ]
            flashcards = [
                "Front: Photosynthesis | Back: Process converting sunlight to energy",
                "Front: Chlorophyll | Back: Green pigment that captures sunlight",
                "Front: Plant energy | Back: Created through photosynthesis"
            ]
            isGenerating = false
        }
    }
}

#Preview {
    StudyBuddyDemo()
        .padding()
}