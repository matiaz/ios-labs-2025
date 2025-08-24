//
//  ContentView.swift
//  swiftui-wwdc
//
//  Created by matiaz on 24/8/25.
//

import SwiftUI

// Demo sections for the ModernUI Explorer
enum DemoSection: String, CaseIterable, Identifiable {
    case liquidGlass = "Liquid Glass"
    case performance = "Performance"
    case spatial3D = "3D & Spatial"
    case controls = "Modern Controls"
    case search = "Search Experiences"
    case crossPlatform = "Cross-Platform"
    case charts3D = "3D Charts"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .liquidGlass: return "drop.triangle"
        case .performance: return "speedometer"
        case .spatial3D: return "cube.transparent"
        case .controls: return "slider.horizontal.3"
        case .search: return "magnifyingglass"
        case .crossPlatform: return "arrow.triangle.branch"
        case .charts3D: return "chart.bar.fill"
        }
    }
}

struct ContentView: View {
    @State private var selectedSection: DemoSection? = .liquidGlass
    @State private var searchText = ""
    
    var body: some View {
        NavigationSplitView {
            // Sidebar with Liquid Glass effect
            List(DemoSection.allCases, selection: $selectedSection) { section in
                NavigationLink(value: section) {
                    HStack {
                        Image(systemName: section.icon)
                            .foregroundStyle(.tint)
                        Text(section.rawValue)
                    }
                }
            }
            .navigationTitle("ModernUI Explorer")
        } detail: {
            // Detail view based on selected section
            Group {
                if let section = selectedSection {
                    DemoDetailView(section: section)
                } else {
                    WelcomeView()
                }
            }
            .glassEffect()
        }
        .searchable(text: $searchText, prompt: "Search features...")
        // .searchToolbarBehavior(.floating) // Would be available in iOS 26
    }
}

struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "sparkles")
                .font(.system(size: 80))
                .foregroundStyle(.tint)
            
            Text("ModernUI Explorer")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Explore the latest SwiftUI features from WWDC 2025")
                .font(.headline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Features:")
                    .font(.headline)
                
                FeatureRow(icon: "drop.triangle", title: "Liquid Glass Design System")
                FeatureRow(icon: "speedometer", title: "6x Performance Improvements")
                FeatureRow(icon: "cube.transparent", title: "3D Layout & Spatial Computing")
                FeatureRow(icon: "slider.horizontal.3", title: "Modern Controls")
            }
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .padding()
        .navigationTitle("Welcome")
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.tint)
                .frame(width: 24)
            Text(title)
        }
    }
}

struct DemoDetailView: View {
    let section: DemoSection
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                switch section {
                case .liquidGlass:
                    LiquidGlassShowcase()
                case .performance:
                    PerformanceDemo()
                case .spatial3D:
                    Spatial3DDemo()
                case .controls:
                    ModernControlsGallery()
                case .search:
                    SearchExperiencesDemo()
                case .crossPlatform:
                    CrossPlatformDemo()
                case .charts3D:
                    Charts3DDemo()
                }
            }
            .padding()
        }
        .navigationTitle(section.rawValue)
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    ContentView()
}
