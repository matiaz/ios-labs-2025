//
//  FitnessCoachDemo.swift
//  foundationmodels
//
//  Created by matiaz on 29/8/25.
//

import SwiftUI

struct FitnessCoachDemo: View {
    @State private var fitnessGoal = "Build muscle"
    @State private var workoutTime = 45
    @State private var isGenerating = false
    @State private var workoutPlan: [String] = []
    
    let goals = ["Build muscle", "Lose weight", "Improve endurance", "General fitness"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Fitness Goal:")
                .font(.subheadline)
                .fontWeight(.medium)
            
            Picker("Goal", selection: $fitnessGoal) {
                ForEach(goals, id: \.self) { goal in
                    Text(goal).tag(goal)
                }
            }
            .pickerStyle(.menu)
            
            Text("Workout Time: \(workoutTime) minutes")
                .font(.subheadline)
                .fontWeight(.medium)
            
            Slider(value: .init(get: { Double(workoutTime) }, set: { workoutTime = Int($0) }), in: 15...90, step: 15)
            
            Button(action: generateWorkout) {
                HStack {
                    if isGenerating {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                    Text(isGenerating ? "Generating..." : "Create Workout")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isGenerating)
            
            if !workoutPlan.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Workout Plan:")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    ForEach(Array(workoutPlan.enumerated()), id: \.offset) { index, exercise in
                        HStack {
                            Text("\(index + 1).")
                                .font(.caption)
                                .fontWeight(.medium)
                            Text(exercise)
                                .font(.caption)
                        }
                    }
                }
            }
        }
    }
    
    private func generateWorkout() {
        isGenerating = true
        
        // Simulate AI workout generation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if fitnessGoal == "Build muscle" {
                workoutPlan = [
                    "Push-ups: 3 sets of 12 reps",
                    "Squats: 3 sets of 15 reps",
                    "Lunges: 3 sets of 10 reps each leg",
                    "Plank: 3 sets of 30 seconds",
                    "Burpees: 2 sets of 8 reps"
                ]
            } else {
                workoutPlan = [
                    "Jumping jacks: 3 sets of 30 seconds",
                    "Mountain climbers: 3 sets of 20 reps",
                    "High knees: 3 sets of 30 seconds",
                    "Push-ups: 2 sets of 10 reps",
                    "Cool down stretches: 5 minutes"
                ]
            }
            isGenerating = false
        }
    }
}

#Preview {
    FitnessCoachDemo()
        .padding()
}