//
//  LiquidGlassShowcase.swift
//  swiftui-wwdc
//
//  Created by matiaz on 24/8/25.
//

import SwiftUI

struct LiquidGlassShowcase: View {
    @State private var isInteracting = false
    @State private var selectedGlassType: GlassType = .regular
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(alignment: .leading, spacing: 16) {
                Text("Liquid Glass Design System")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Dynamic material that adapts to content and environment")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Glass Type Selector
            Picker("Glass Type", selection: $selectedGlassType) {
                ForEach(GlassType.allCases, id: \.self) { type in
                    Text(type.rawValue)
                        .tag(type)
                }
            }
            .pickerStyle(.segmented)
            
            // Interactive Glass Examples
            VStack(spacing: 20) {
                // Regular Glass Example
                GlassEffectContainer {
                    VStack(spacing: 16) {
                        Text("Regular Liquid Glass")
                            .font(.headline)
                        
                        Text("Adapts automatically to underlying content and provides optimal legibility")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                        
                        Button("Interact") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isInteracting.toggle()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .scaleEffect(isInteracting ? 1.1 : 1.0)
                    }
                    .padding()
                }
                .glassEffect(selectedGlassType == .regular ? .regular : .clear)
                .glassEffectID("mainGlass")
                
                // Interactive Glass Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    ForEach(0..<4, id: \.self) { index in
                        GlassCard(
                            title: "Feature \(index + 1)",
                            icon: ["star.fill", "heart.fill", "bolt.fill", "leaf.fill"][index],
                            isActive: isInteracting
                        )
                    }
                }
            }
            
            // Adaptive Glass with Different Backgrounds
            VStack(alignment: .leading, spacing: 16) {
                Text("Adaptive Behavior")
                    .font(.headline)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(BackgroundType.allCases, id: \.self) { background in
                            AdaptiveGlassExample(background: background)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            // Glass Transition Demo
            VStack(alignment: .leading, spacing: 16) {
                Text("Smooth Transitions")
                    .font(.headline)
                
                HStack(spacing: 20) {
                    GlassTransitionButton(
                        title: "From",
                        isActive: !isInteracting,
                        glassID: "transition1"
                    )
                    
                    Image(systemName: "arrow.right")
                        .foregroundStyle(.secondary)
                    
                    GlassTransitionButton(
                        title: "To",
                        isActive: isInteracting,
                        glassID: "transition2"
                    )
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
        .backgroundExtensionEffect()
    }
}

enum GlassType: String, CaseIterable {
    case regular = "Regular"
    case clear = "Clear"
}

enum BackgroundType: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    case colorful = "Colorful"
    case media = "Media"
    
    var background: some View {
        Group {
            switch self {
            case .light:
                Color.white
            case .dark:
                Color.black
            case .colorful:
                LinearGradient(colors: [.blue, .purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
            case .media:
                Image(systemName: "photo.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.blue.opacity(0.3))
            }
        }
    }
}

struct GlassCard: View {
    let title: String
    let icon: String
    let isActive: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.tint)
                .scaleEffect(isActive ? 1.2 : 1.0)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .frame(height: 80)
        .frame(maxWidth: .infinity)
        .glassEffect()
        .animation(.easeInOut(duration: 0.3), value: isActive)
    }
}

struct AdaptiveGlassExample: View {
    let background: BackgroundType
    
    var body: some View {
        ZStack {
            background.background
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(spacing: 8) {
                Text(background.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text("Glass adapts")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .glassEffect()
        }
    }
}

struct GlassTransitionButton: View {
    let title: String
    let isActive: Bool
    let glassID: String
    
    var body: some View {
        Text(title)
            .font(.subheadline)
            .fontWeight(.medium)
            .padding()
            .frame(minWidth: 80)
            .glassEffect(isActive ? .regular : .clear)
            .glassEffectID(glassID)
            .animation(.easeInOut(duration: 0.5), value: isActive)
    }
}

#Preview {
    ScrollView {
        LiquidGlassShowcase()
    }
}