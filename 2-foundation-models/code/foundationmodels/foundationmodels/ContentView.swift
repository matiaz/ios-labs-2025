//
//  ContentView.swift
//  foundationmodels
//
//  Created by matiaz on 29/8/25.
//

import SwiftUI

struct ProjectIdea {
    let id = UUID()
    let title: String
    let concept: String
    let features: [String]
    let complexity: String
    let keyAPIs: [String]
}

struct ContentView: View {
    let projectIdeas: [ProjectIdea] = [
        ProjectIdea(
            title: "Smart Note Organizer",
            concept: "Automatically categorize, tag, and summarize user notes",
            features: ["Auto-tagging", "Smart search", "Content extraction"],
            complexity: "Beginner to Intermediate",
            keyAPIs: ["@Generable for metadata", "Tool calling for file system access"]
        ),
        ProjectIdea(
            title: "Email Assistant",
            concept: "Intelligent email composition and response suggestion",
            features: ["Draft generation", "Tone adjustment", "Reply suggestions"],
            complexity: "Intermediate",
            keyAPIs: ["Structured generation", "Streaming for real-time composition"]
        ),
        ProjectIdea(
            title: "Recipe Analyzer & Meal Planner",
            concept: "Analyze recipes and create personalized meal plans",
            features: ["Ingredient extraction", "Nutrition analysis", "Meal planning"],
            complexity: "Intermediate to Advanced",
            keyAPIs: ["Dynamic schemas", "Tool calling for nutrition databases"]
        ),
        ProjectIdea(
            title: "Code Documentation Generator",
            concept: "Automatically generate Swift documentation from code",
            features: ["Function descriptions", "Parameter documentation", "Usage examples"],
            complexity: "Advanced",
            keyAPIs: ["Custom tools for code parsing", "Structured output generation"]
        ),
        ProjectIdea(
            title: "Meeting Transcript Analyzer",
            concept: "Process meeting transcripts to extract action items and summaries",
            features: ["Speaker identification", "Task extraction", "Summary generation"],
            complexity: "Intermediate",
            keyAPIs: ["@Generable for structured outputs", "Content classification"]
        ),
        ProjectIdea(
            title: "Personal Fitness Coach",
            concept: "AI-powered workout planning and progress tracking",
            features: ["Workout generation", "Progress analysis", "Personalized recommendations"],
            complexity: "Advanced",
            keyAPIs: ["Tool calling for HealthKit integration", "Stateful sessions"]
        ),
        ProjectIdea(
            title: "Study Buddy App",
            concept: "Generate quizzes and study materials from textbooks or notes",
            features: ["Question generation", "Flashcards", "Study schedule optimization"],
            complexity: "Intermediate",
            keyAPIs: ["Content extraction", "Dynamic schema generation"]
        ),
        ProjectIdea(
            title: "Social Media Content Planner",
            concept: "Generate and schedule social media posts across platforms",
            features: ["Content generation", "Hashtag suggestions", "Posting schedules"],
            complexity: "Intermediate to Advanced",
            keyAPIs: ["Structured generation", "Tool calling for calendar integration"]
        ),
        ProjectIdea(
            title: "Travel Itinerary Assistant",
            concept: "Create personalized travel plans based on preferences and constraints",
            features: ["Activity recommendations", "Schedule optimization", "Budget tracking"],
            complexity: "Advanced",
            keyAPIs: ["Tool calling for MapKit integration", "Complex structured generation"]
        ),
        ProjectIdea(
            title: "Home Automation Controller",
            concept: "Natural language interface for smart home control",
            features: ["Voice commands", "Scene creation", "Automated routines"],
            complexity: "Advanced",
            keyAPIs: ["Tool calling for HomeKit", "Stateful conversation management"]
        )
    ]
    
    var body: some View {
        NavigationStack {
            List(projectIdeas, id: \.id) { idea in
                NavigationLink(destination: ProjectDetailView(projectIdea: idea)) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(idea.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(idea.concept)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                        
                        HStack {
                            Text(idea.complexity)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                            
                            Spacer()
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Foundation Models Demo")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    ContentView()
}
