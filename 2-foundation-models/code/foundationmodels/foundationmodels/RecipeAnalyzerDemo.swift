//
//  RecipeAnalyzerDemo.swift
//  foundationmodels
//
//  Created by matiaz on 29/8/25.
//

import SwiftUI

struct RecipeAnalyzerDemo: View {
    @State private var recipeText = "2 cups flour, 1 cup sugar, 3 eggs, 1/2 cup butter, 1 tsp vanilla"
    @State private var isAnalyzing = false
    @State private var ingredients: [String] = []
    @State private var nutritionInfo = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Enter recipe ingredients:")
                .font(.subheadline)
                .fontWeight(.medium)
            
            TextEditor(text: $recipeText)
                .frame(minHeight: 60)
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            
            Button(action: analyzeRecipe) {
                HStack {
                    if isAnalyzing {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                    Text(isAnalyzing ? "Analyzing..." : "Analyze Recipe")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isAnalyzing)
            
            if !ingredients.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Extracted Ingredients:")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    ForEach(ingredients, id: \.self) { ingredient in
                        HStack {
                            Image(systemName: "leaf.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                            Text(ingredient)
                                .font(.caption)
                        }
                    }
                }
            }
            
            if !nutritionInfo.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nutrition Analysis:")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Text(nutritionInfo)
                        .font(.caption)
                        .padding(8)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
    }
    
    private func analyzeRecipe() {
        isAnalyzing = true
        
        // Simulate AI recipe analysis
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            ingredients = ["2 cups all-purpose flour", "1 cup granulated sugar", "3 large eggs", "1/2 cup unsalted butter", "1 tsp vanilla extract"]
            nutritionInfo = "Estimated nutrition per serving (8 servings): 285 calories, 8g fat, 48g carbs, 5g protein"
            isAnalyzing = false
        }
    }
}

#Preview {
    RecipeAnalyzerDemo()
        .padding()
}