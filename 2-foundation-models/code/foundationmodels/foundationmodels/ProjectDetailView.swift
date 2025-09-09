//
//  ProjectDetailView.swift
//  foundationmodels
//
//  Created by matiaz on 29/8/25.
//

import SwiftUI

struct ProjectDetailView: View {
    let projectIdea: ProjectIdea
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(projectIdea.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(projectIdea.concept)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Complexity")
                        .font(.headline)
                    
                    Text(projectIdea.complexity)
                        .font(.body)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Features")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(projectIdea.features, id: \.self) { feature in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text(feature)
                                    .font(.body)
                            }
                        }
                    }
                    .padding()
                    .background(Color.green.opacity(0.05))
                    .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Key APIs")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(projectIdea.keyAPIs, id: \.self) { api in
                            HStack {
                                Image(systemName: "gear")
                                    .foregroundColor(.orange)
                                Text(api)
                                    .font(.body)
                            }
                        }
                    }
                    .padding()
                    .background(Color.orange.opacity(0.05))
                    .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Demo Interface")
                        .font(.headline)
                    
                    demoView
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private var demoView: some View {
        switch projectIdea.title {
        case "Smart Note Organizer":
            SmartNoteOrganizerDemo()
        case "Email Assistant":
            EmailAssistantDemo()
        case "Recipe Analyzer & Meal Planner":
            RecipeAnalyzerDemo()
        case "Code Documentation Generator":
            CodeDocGeneratorDemo()
        case "Meeting Transcript Analyzer":
            MeetingTranscriptDemo()
        case "Personal Fitness Coach":
            FitnessCoachDemo()
        case "Study Buddy App":
            StudyBuddyDemo()
        case "Social Media Content Planner":
            SocialMediaPlannerDemo()
        case "Travel Itinerary Assistant":
            TravelAssistantDemo()
        case "Home Automation Controller":
            HomeAutomationDemo()
        default:
            Text("Demo coming soon...")
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        ProjectDetailView(projectIdea: ProjectIdea(
            title: "Smart Note Organizer",
            concept: "Automatically categorize, tag, and summarize user notes",
            features: ["Auto-tagging", "Smart search", "Content extraction"],
            complexity: "Beginner to Intermediate",
            keyAPIs: ["@Generable for metadata", "Tool calling for file system access"]
        ))
    }
}
