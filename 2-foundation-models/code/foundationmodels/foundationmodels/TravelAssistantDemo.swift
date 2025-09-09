//
//  TravelAssistantDemo.swift
//  foundationmodels
//
//  Created by matiaz on 29/8/25.
//

import SwiftUI

struct TravelAssistantDemo: View {
    @State private var destination = "Paris"
    @State private var days = 3
    @State private var budget = 1000
    @State private var isGenerating = false
    @State private var itinerary: [String] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Destination:")
                .font(.subheadline)
                .fontWeight(.medium)
            
            TextField("Where are you traveling?", text: $destination)
                .textFieldStyle(.roundedBorder)
            
            Text("Duration: \(days) days")
                .font(.subheadline)
                .fontWeight(.medium)
            
            Slider(value: .init(get: { Double(days) }, set: { days = Int($0) }), in: 1...14, step: 1)
            
            Text("Budget: $\(budget)")
                .font(.subheadline)
                .fontWeight(.medium)
            
            Slider(value: .init(get: { Double(budget) }, set: { budget = Int($0) }), in: 500...5000, step: 100)
            
            Button(action: generateItinerary) {
                HStack {
                    if isGenerating {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                    Text(isGenerating ? "Generating..." : "Plan Trip")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isGenerating)
            
            if !itinerary.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Itinerary:")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    ForEach(Array(itinerary.enumerated()), id: \.offset) { index, activity in
                        HStack {
                            Text("Day \(index + 1):")
                                .font(.caption)
                                .fontWeight(.medium)
                            Text(activity)
                                .font(.caption)
                        }
                    }
                }
            }
        }
    }
    
    private func generateItinerary() {
        isGenerating = true
        
        // Simulate AI itinerary generation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            itinerary = [
                "Visit the Eiffel Tower and Seine River cruise",
                "Explore Louvre Museum and Champs-Élysées",
                "Day trip to Versailles Palace and Gardens"
            ]
            isGenerating = false
        }
    }
}

#Preview {
    TravelAssistantDemo()
        .padding()
}