//
//  SearchExperiencesDemo.swift
//  swiftui-wwdc
//
//  Created by matiaz on 24/8/25.
//

import SwiftUI

struct SearchExperiencesDemo: View {
    @State private var searchText = ""
    @State private var selectedSearchType: SearchType = .toolbar
    @State private var searchResults: [SearchResult] = []
    @State private var isSearching = false
    @State private var showDedicatedSearch = false
    
    let sampleItems = [
        SearchResult(title: "Liquid Glass Design", category: "UI", description: "New adaptive material system"),
        SearchResult(title: "Performance Improvements", category: "Performance", description: "6x faster lists and scrolling"),
        SearchResult(title: "3D Layout System", category: "Layout", description: "Alignment3D and spatial computing"),
        SearchResult(title: "Modern Controls", category: "Controls", description: "Capsule buttons and enhanced sliders"),
        SearchResult(title: "SwiftUI Charts", category: "Visualization", description: "3D chart rendering capabilities"),
        SearchResult(title: "Cross-Platform APIs", category: "Integration", description: "WebView and scene bridging"),
        SearchResult(title: "Search Experiences", category: "UI", description: "Toolbar and dedicated search patterns"),
        SearchResult(title: "Spatial Computing", category: "3D", description: "visionOS and ARKit integration")
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(alignment: .leading, spacing: 16) {
                Text("Search Experiences")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Two primary patterns: toolbar search and dedicated search pages")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Search Type Selector
            Picker("Search Type", selection: $selectedSearchType) {
                ForEach(SearchType.allCases, id: \.self) { type in
                    Text(type.rawValue)
                        .tag(type)
                }
            }
            .pickerStyle(.segmented)
            
            // Search Implementation Demo
            Group {
                switch selectedSearchType {
                case .toolbar:
                    ToolbarSearchDemo(
                        searchText: $searchText,
                        searchResults: $searchResults,
                        isSearching: $isSearching,
                        sampleItems: sampleItems
                    )
                case .dedicated:
                    DedicatedSearchDemo(
                        searchText: $searchText,
                        searchResults: $searchResults,
                        isSearching: $isSearching,
                        sampleItems: sampleItems,
                        showDedicatedSearch: $showDedicatedSearch
                    )
                }
            }
            
            // Search Behavior Options
            SearchBehaviorDemo()
            
            // Search Results Display
            SearchResultsView(results: searchResults, isSearching: isSearching)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
        .backgroundExtensionEffect()
        .onChange(of: searchText) { _, newValue in
            performSearch(query: newValue)
        }
        .sheet(isPresented: $showDedicatedSearch) {
            DedicatedSearchPage(
                searchText: $searchText,
                searchResults: $searchResults,
                sampleItems: sampleItems
            )
        }
    }
    
    private func performSearch(query: String) {
        isSearching = true
        
        // Simulate search delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if query.isEmpty {
                searchResults = []
            } else {
                searchResults = sampleItems.filter { item in
                    item.title.localizedCaseInsensitiveContains(query) ||
                    item.category.localizedCaseInsensitiveContains(query) ||
                    item.description.localizedCaseInsensitiveContains(query)
                }
            }
            isSearching = false
        }
    }
}

enum SearchType: String, CaseIterable {
    case toolbar = "Toolbar Search"
    case dedicated = "Dedicated Page"
}

struct SearchResult: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let category: String
    let description: String
}

struct ToolbarSearchDemo: View {
    @Binding var searchText: String
    @Binding var searchResults: [SearchResult]
    @Binding var isSearching: Bool
    let sampleItems: [SearchResult]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Toolbar Search Pattern")
                .font(.headline)
            
            Text("Bottom-aligned on iPhone, top-trailing on iPad/Mac")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            // Simulated Navigation View with Search
            VStack(spacing: 0) {
                // Navigation Bar
                HStack {
                    Text("SwiftUI Features")
                        .font(.headline)
                    
                    Spacer()
                    
                    // Search field (simulating toolbar search)
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        
                        TextField("Search features...", text: $searchText)
                            .textFieldStyle(.roundedBorder)
                    }
                    .frame(maxWidth: 200)
                }
                .padding()
                .background(.thinMaterial)
                // .searchToolbarBehavior(.floating) // Would be available in iOS 26
                
                Divider()
                
                // Content area
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(searchText.isEmpty ? sampleItems : searchResults) { item in
                            SearchItemRow(item: item)
                        }
                    }
                    .padding()
                }
                .frame(height: 200)
            }
            .background(.background, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.separator, lineWidth: 1)
            )
        }
    }
}

struct DedicatedSearchDemo: View {
    @Binding var searchText: String
    @Binding var searchResults: [SearchResult]
    @Binding var isSearching: Bool
    let sampleItems: [SearchResult]
    @Binding var showDedicatedSearch: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Dedicated Search Page Pattern")
                .font(.headline)
            
            Text("Full-screen search experience for multi-tab apps")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            // Tab View Simulation
            VStack(spacing: 0) {
                // Tab content area
                VStack(spacing: 20) {
                    Text("Main App Content")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Button("Open Dedicated Search") {
                        showDedicatedSearch = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(height: 150)
                .frame(maxWidth: .infinity)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                
                // Tab Bar
                HStack {
                    TabBarItem(title: "Home", icon: "house", isActive: true)
                    TabBarItem(title: "Search", icon: "magnifyingglass", isActive: false) {
                        showDedicatedSearch = true
                    }
                    TabBarItem(title: "Settings", icon: "gear", isActive: false)
                }
                .padding()
                .background(.thinMaterial)
                // .tabBarMinimizeBehavior(.automatic) // Would be available in iOS 26
            }
            .background(.background, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.separator, lineWidth: 1)
            )
        }
    }
}

struct SearchBehaviorDemo: View {
    @State private var selectedBehavior: SearchBehavior = .floating
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Search Toolbar Behavior")
                .font(.headline)
            
            Picker("Behavior", selection: $selectedBehavior) {
                ForEach(SearchBehavior.allCases, id: \.self) { behavior in
                    Text(behavior.rawValue)
                        .tag(behavior)
                }
            }
            .pickerStyle(.menu)
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
            
            Text("Selected: \(selectedBehavior.description)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

enum SearchBehavior: String, CaseIterable {
    case floating = "Floating"
    case inline = "Inline"
    case automatic = "Automatic"
    
    var description: String {
        switch self {
        case .floating: return "Search bar floats above content"
        case .inline: return "Search bar integrated with navigation"
        case .automatic: return "System chooses best behavior"
        }
    }
}

struct SearchResultsView: View {
    let results: [SearchResult]
    let isSearching: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Search Results")
                    .font(.headline)
                
                if isSearching {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(0.8)
                }
                
                Spacer()
                
                if !results.isEmpty {
                    Text("\(results.count) results")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            if results.isEmpty && !isSearching {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    
                    Text("No results found")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(results) { result in
                        SearchResultRow(result: result)
                    }
                }
            }
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct SearchItemRow: View {
    let item: SearchResult
    
    var body: some View {
        HStack(spacing: 12) {
            CategoryIcon(category: item.category)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(item.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Text(item.category)
                .font(.caption2)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.tint.opacity(0.1), in: Capsule())
                .foregroundStyle(.tint)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.background, in: RoundedRectangle(cornerRadius: 8))
    }
}

struct SearchResultRow: View {
    let result: SearchResult
    
    var body: some View {
        HStack(spacing: 12) {
            CategoryIcon(category: result.category)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(result.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(result.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 8))
    }
}

struct CategoryIcon: View {
    let category: String
    
    var icon: String {
        switch category {
        case "UI": return "paintbrush"
        case "Performance": return "speedometer"
        case "Layout": return "square.grid.3x3"
        case "Controls": return "slider.horizontal.3"
        case "Visualization": return "chart.bar"
        case "Integration": return "arrow.triangle.branch"
        case "3D": return "cube.transparent"
        default: return "circle"
        }
    }
    
    var color: Color {
        switch category {
        case "UI": return .blue
        case "Performance": return .green
        case "Layout": return .orange
        case "Controls": return .purple
        case "Visualization": return .red
        case "Integration": return .cyan
        case "3D": return .pink
        default: return .gray
        }
    }
    
    var body: some View {
        Image(systemName: icon)
            .foregroundStyle(color)
            .frame(width: 32, height: 32)
            .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
    }
}

struct TabBarItem: View {
    let title: String
    let icon: String
    let isActive: Bool
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button {
            action?()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                
                Text(title)
                    .font(.caption2)
            }
            .foregroundStyle(isActive ? Color.accentColor : Color.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct DedicatedSearchPage: View {
    @Binding var searchText: String
    @Binding var searchResults: [SearchResult]
    let sampleItems: [SearchResult]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        
                        TextField("Search everything...", text: $searchText)
                        
                        if !searchText.isEmpty {
                            Button("Clear") {
                                searchText = ""
                            }
                            .font(.caption)
                        }
                    }
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    
                    Button("Cancel") {
                        dismiss()
                    }
                }
                .padding()
                
                // Results
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(searchText.isEmpty ? sampleItems : searchResults) { item in
                            SearchItemRow(item: item)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// Extensions and types are defined in LiquidGlassExtensions.swift

#Preview {
    ScrollView {
        SearchExperiencesDemo()
    }
}