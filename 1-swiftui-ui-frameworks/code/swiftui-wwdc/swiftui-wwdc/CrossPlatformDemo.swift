//
//  CrossPlatformDemo.swift
//  swiftui-wwdc
//
//  Created by matiaz on 24/8/25.
//

import SwiftUI

struct CrossPlatformDemo: View {
    @State private var webURL = "https://developer.apple.com"
    @State private var richText = AttributedString("Welcome to SwiftUI!")
    @State private var selectedPlatform: PlatformType = .iOS
    @State private var showWebView = false
    @State private var showRichTextEditor = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(alignment: .leading, spacing: 16) {
                Text("Cross-Platform Integration")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Scene bridging, WebView, RichText editing, and platform-specific features")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Platform Selector
            PlatformSelector(selectedPlatform: $selectedPlatform)
            
            // WebView Integration
            WebViewIntegrationDemo(
                webURL: $webURL,
                showWebView: $showWebView
            )
            
            // Rich Text Editing
            RichTextEditingDemo(
                richText: $richText,
                showRichTextEditor: $showRichTextEditor
            )
            
            // Scene Bridging Demo
            SceneBridgingDemo(platform: selectedPlatform)
            
            // Level of Detail Demo
            LevelOfDetailDemo()
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
        .backgroundExtensionEffect()
        .sheet(isPresented: $showWebView) {
            WebViewSheet(url: webURL)
        }
        .sheet(isPresented: $showRichTextEditor) {
            RichTextEditorSheet(text: $richText)
        }
    }
}

enum PlatformType: String, CaseIterable {
    case iOS = "iOS"
    case macOS = "macOS"
    case visionOS = "visionOS"
    case watchOS = "watchOS"
    
    var icon: String {
        switch self {
        case .iOS: return "iphone"
        case .macOS: return "laptopcomputer"
        case .visionOS: return "visionpro"
        case .watchOS: return "applewatch"
        }
    }
    
    var color: Color {
        switch self {
        case .iOS: return .blue
        case .macOS: return .gray
        case .visionOS: return .purple
        case .watchOS: return .red
        }
    }
}

struct PlatformSelector: View {
    @Binding var selectedPlatform: PlatformType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Platform-Specific Features")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(PlatformType.allCases, id: \.self) { platform in
                    PlatformCard(
                        platform: platform,
                        isSelected: platform == selectedPlatform
                    ) {
                        selectedPlatform = platform
                    }
                }
            }
        }
    }
}

struct PlatformCard: View {
    let platform: PlatformType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: platform.icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? .white : platform.color)
                
                Text(platform.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(isSelected ? .white : .primary)
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(
                isSelected ? platform.color : platform.color.opacity(0.1),
                in: RoundedRectangle(cornerRadius: 12)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(platform.color, lineWidth: isSelected ? 0 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct WebViewIntegrationDemo: View {
    @Binding var webURL: String
    @Binding var showWebView: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("WebView Integration")
                .font(.headline)
            
            Text("New WebView with WebPage support for seamless web content")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            VStack(spacing: 12) {
                HStack {
                    TextField("Enter URL", text: $webURL)
                        .textFieldStyle(.roundedBorder)
                    
                    Button("Load") {
                        showWebView = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                // Web Content Preview
                WebContentPreview(url: webURL)
            }
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct WebContentPreview: View {
    let url: String
    
    var body: some View {
        VStack(spacing: 12) {
            // Simulated browser chrome
            HStack {
                Image(systemName: "safari")
                    .foregroundStyle(.blue)
                
                Text(url)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                Spacer()
                
                Button {} label: {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.borderless)
                .controlSize(.mini)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.background, in: RoundedRectangle(cornerRadius: 6))
            
            // Simulated web content
            VStack(spacing: 8) {
                HStack {
                    Rectangle()
                        .fill(.blue)
                        .frame(width: 40, height: 40)
                    
                    VStack(alignment: .leading) {
                        Rectangle()
                            .fill(.primary)
                            .frame(height: 8)
                        Rectangle()
                            .fill(.secondary)
                            .frame(height: 6)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Spacer()
                }
                
                Rectangle()
                    .fill(.tertiary)
                    .frame(height: 40)
            }
            .padding(8)
            .background(.background, in: RoundedRectangle(cornerRadius: 8))
        }
        .frame(height: 120)
    }
}

struct RichTextEditingDemo: View {
    @Binding var richText: AttributedString
    @Binding var showRichTextEditor: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Rich Text Editing")
                .font(.headline)
            
            Text("Enhanced AttributedString support with formatting controls")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            VStack(spacing: 12) {
                // Rich Text Preview
                ScrollView {
                    Text(richText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(.background, in: RoundedRectangle(cornerRadius: 8))
                        .frame(height: 80)
                }
                
                HStack {
                    Button("Edit Rich Text") {
                        showRichTextEditor = true
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Add Bold") {
                        addFormatting(.bold)
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Add Italic") {
                        addFormatting(.italic)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private func addFormatting(_ style: AttributedString.FormattingStyle) {
        var newText = richText
        // Simulate adding formatting
        switch style {
        case .bold:
            newText = AttributedString("Bold text added! ") + richText
        case .italic:
            newText = AttributedString("Italic text added! ") + richText
        }
        richText = newText
    }
}

extension AttributedString {
    enum FormattingStyle {
        case bold, italic
    }
}

struct SceneBridgingDemo: View {
    let platform: PlatformType
    @State private var isUIKitIntegrated = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Scene Bridging")
                .font(.headline)
            
            Text("Seamless integration between SwiftUI and \(platform == .macOS ? "AppKit" : "UIKit")")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            VStack(spacing: 16) {
                // Integration Toggle
                HStack {
                    Text("Enable \(platform == .macOS ? "AppKit" : "UIKit") Integration")
                    Spacer()
                    Toggle("", isOn: $isUIKitIntegrated)
                }
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
                
                // Bridge Visualization
                HStack(spacing: 20) {
                    // SwiftUI Side
                    VStack(spacing: 8) {
                        Text("SwiftUI")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.blue.gradient)
                            .frame(width: 80, height: 60)
                            .overlay(
                                Text("SwiftUI\nView")
                                    .font(.caption2)
                                    .foregroundStyle(.white)
                                    .multilineTextAlignment(.center)
                            )
                    }
                    
                    // Bridge
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.left.and.right")
                            .foregroundStyle(isUIKitIntegrated ? .green : .secondary)
                        Text("Bridge")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    
                    // UIKit/AppKit Side
                    VStack(spacing: 8) {
                        Text(platform == .macOS ? "AppKit" : "UIKit")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isUIKitIntegrated ? Color.green.gradient : Color.gray.gradient)
                            .frame(width: 80, height: 60)
                            .overlay(
                                Text("\(platform == .macOS ? "AppKit" : "UIKit")\nView")
                                    .font(.caption2)
                                    .foregroundStyle(.white)
                                    .multilineTextAlignment(.center)
                            )
                    }
                }
                .frame(maxWidth: .infinity)
                
                // Platform-specific features
                PlatformSpecificFeatures(platform: platform, isEnabled: isUIKitIntegrated)
            }
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct PlatformSpecificFeatures: View {
    let platform: PlatformType
    let isEnabled: Bool
    
    var features: [String] {
        switch platform {
        case .iOS:
            return ["UITableView Integration", "Core Location", "Camera Access", "Push Notifications"]
        case .macOS:
            return ["NSTableView Integration", "Menu Bar Items", "File System Access", "Dock Integration"]
        case .visionOS:
            return ["RealityKit Integration", "Hand Tracking", "Eye Tracking", "Spatial Audio"]
        case .watchOS:
            return ["Digital Crown", "Haptic Feedback", "Workout APIs", "Complications"]
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Available Features:")
                .font(.caption)
                .fontWeight(.medium)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(features, id: \.self) { feature in
                    HStack {
                        Image(systemName: isEnabled ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(isEnabled ? .green : .secondary)
                            .font(.caption)
                        
                        Text(feature)
                            .font(.caption2)
                            .foregroundStyle(isEnabled ? .primary : .secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}

struct LevelOfDetailDemo: View {
    @State private var detailLevel: DetailLevel = .full
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Level of Detail")
                .font(.headline)
            
            Text("Adaptive UI based on available space and system resources")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Picker("Detail Level", selection: $detailLevel) {
                ForEach(DetailLevel.allCases, id: \.self) { level in
                    Text(level.rawValue)
                        .tag(level)
                }
            }
            .pickerStyle(.segmented)
            
            // Adaptive Content
            AdaptiveContentView(detailLevel: detailLevel)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .levelOfDetail(detailLevel)
    }
}

enum DetailLevel: String, CaseIterable {
    case minimal = "Minimal"
    case standard = "Standard"
    case full = "Full"
}

struct AdaptiveContentView: View {
    let detailLevel: DetailLevel
    
    var body: some View {
        VStack(spacing: 12) {
            switch detailLevel {
            case .minimal:
                HStack {
                    Image(systemName: "star")
                    Text("Item")
                    Spacer()
                }
            case .standard:
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    VStack(alignment: .leading) {
                        Text("Item Title")
                            .fontWeight(.medium)
                        Text("Subtitle")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
            case .full:
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .font(.title3)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Full Item Title")
                            .fontWeight(.medium)
                        Text("Detailed subtitle with more information")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        HStack {
                            Text("Tags")
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(.blue.opacity(0.1), in: Capsule())
                        }
                    }
                    Spacer()
                    Button("Action") {}
                        .buttonStyle(.bordered)
                        .controlSize(.mini)
                }
            }
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 8))
        .animation(.easeInOut(duration: 0.3), value: detailLevel)
    }
}

struct WebViewSheet: View {
    let url: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                // Simulated WebView
                WebView(url: url)
            }
            .navigationTitle("Web Content")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct WebView: View {
    let url: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Web Page Content")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("This is a simulated WebView showing content from:")
                    .font(.subheadline)
                
                Text(url)
                    .font(.caption)
                    .foregroundStyle(.blue)
                    .padding()
                    .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(0..<5) { index in
                        VStack(alignment: .leading, spacing: 8) {
                            Rectangle()
                                .fill(.primary)
                                .frame(height: 20)
                                .frame(width: CGFloat.random(in: 200...300))
                            
                            Rectangle()
                                .fill(.secondary)
                                .frame(height: 12)
                                .frame(width: CGFloat.random(in: 150...350))
                            
                            Rectangle()
                                .fill(.tertiary)
                                .frame(height: 8)
                                .frame(width: CGFloat.random(in: 100...250))
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .background(.background)
    }
}

struct RichTextEditorSheet: View {
    @Binding var text: AttributedString
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                // Simulated rich text editor
                RichTextEditor(text: $text)
            }
            .navigationTitle("Rich Text Editor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct RichTextEditor: View {
    @Binding var text: AttributedString
    @State private var plainText: String = ""
    
    var body: some View {
        VStack(spacing: 16) {
            // Formatting toolbar
            HStack {
                Button("B") { /* Bold */ }
                    .fontWeight(.bold)
                    .frame(width: 30, height: 30)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 6))
                
                Button("I") { /* Italic */ }
                    .italic()
                    .frame(width: 30, height: 30)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 6))
                
                Button("U") { /* Underline */ }
                    .underline()
                    .frame(width: 30, height: 30)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 6))
                
                Spacer()
            }
            .padding()
            .background(.background, in: RoundedRectangle(cornerRadius: 8))
            
            // Text editor
            TextEditor(text: $plainText)
                .padding()
                .background(.background, in: RoundedRectangle(cornerRadius: 8))
                .onAppear {
                    plainText = String(text.characters)
                }
                .onChange(of: plainText) { _, newValue in
                    text = AttributedString(newValue)
                }
        }
        .padding()
    }
}

// Extensions and types are defined in LiquidGlassExtensions.swift

#Preview {
    ScrollView {
        CrossPlatformDemo()
    }
}