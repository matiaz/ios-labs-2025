//
//  SocialMediaPlannerDemo.swift
//  foundationmodels
//
//  Created by matiaz on 29/8/25.
//

import SwiftUI

struct SocialMediaPlannerDemo: View {
    @State private var contentTopic = "Product launch announcement"
    @State private var platform = "Instagram"
    @State private var isGenerating = false
    @State private var generatedContent = ""
    @State private var hashtags: [String] = []
    
    let platforms = ["Instagram", "Twitter", "LinkedIn", "Facebook"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Content Topic:")
                .font(.subheadline)
                .fontWeight(.medium)
            
            TextField("What's your post about?", text: $contentTopic)
                .textFieldStyle(.roundedBorder)
            
            Text("Platform:")
                .font(.subheadline)
                .fontWeight(.medium)
            
            Picker("Platform", selection: $platform) {
                ForEach(platforms, id: \.self) { platform in
                    Text(platform).tag(platform)
                }
            }
            .pickerStyle(.segmented)
            
            Button(action: generateContent) {
                HStack {
                    if isGenerating {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                    Text(isGenerating ? "Generating..." : "Generate Content")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isGenerating)
            
            if !generatedContent.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Generated Post:")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Text(generatedContent)
                        .font(.caption)
                        .padding(8)
                        .background(Color.cyan.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            if !hashtags.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Suggested Hashtags:")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(hashtags, id: \.self) { hashtag in
                                Text(hashtag)
                                    .font(.caption)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.cyan)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
    
    private func generateContent() {
        isGenerating = true
        
        // Simulate AI content generation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            generatedContent = "🎉 We're thrilled to announce our latest product launch! After months of hard work and innovation, we're ready to share something amazing with you. Stay tuned for more details! 🚀"
            hashtags = ["#ProductLaunch", "#Innovation", "#NewProduct", "#Exciting", "#ComingSoon"]
            isGenerating = false
        }
    }
}

#Preview {
    SocialMediaPlannerDemo()
        .padding()
}