//
//  ModernControlsGallery.swift
//  swiftui-wwdc
//
//  Created by matiaz on 24/8/25.
//

import SwiftUI

struct ModernControlsGallery: View {
    @State private var sliderValue: Double = 50
    @State private var toggleValue = false
    @State private var selectedOption = "Option 1"
    @State private var stepperValue = 5
    @State private var segmentedSelection = 0
    @State private var dateValue = Date()
    
    let options = ["Option 1", "Option 2", "Option 3", "Option 4"]
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(alignment: .leading, spacing: 16) {
                Text("Modern Controls Gallery")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Updated controls with capsule shapes, tick marks, and consistent iconography")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Button Styles
            ModernButtonShowcase()
            
            // Sliders with Tick Marks
            ModernSliderShowcase(value: $sliderValue)
            
            // Enhanced Toggles
            ModernToggleShowcase(isOn: $toggleValue)
            
            // Menu Controls
            ModernMenuShowcase(selectedOption: $selectedOption, options: options)
            
            // Steppers and Segments
            VStack(alignment: .leading, spacing: 16) {
                Text("Steppers & Segments")
                    .font(.headline)
                
                VStack(spacing: 16) {
                    // Modern Stepper
                    HStack {
                        Text("Stepper Value")
                        Spacer()
                        Stepper("\(stepperValue)", value: $stepperValue, in: 0...10)
                            // .stepperStyle(.modern) // Would be available in iOS 26
                    }
                    .padding()
                    .glassEffect()
                    
                    // Modern Segmented Control
                    Picker("Selection", selection: $segmentedSelection) {
                        Text("First").tag(0)
                        Text("Second").tag(1)
                        Text("Third").tag(2)
                    }
                    .pickerStyle(.segmented)
                    // .segmentedControlStyle(.modern) // Would be available in iOS 26
                }
            }
            
            // Date and Time Pickers
            ModernDatePickerShowcase(date: $dateValue)
            
            // Progress Indicators
            ModernProgressShowcase()
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
        .backgroundExtensionEffect()
    }
}

struct ModernButtonShowcase: View {
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Modern Buttons")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                // Prominent Button (Capsule by default)
                Button("Prominent") {
                    // Action
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
                
                // Bordered Button
                Button("Bordered") {
                    // Action
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)
                
                // Plain Button with Badge
                Button {
                    // Action
                } label: {
                    HStack {
                        Text("With Badge")
                        Badge(count: 3)
                    }
                }
                .buttonStyle(.plain)
                .padding()
                .glassEffect()
                
                // Icon Button with Tinting
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isPressed.toggle()
                    }
                } label: {
                    Image(systemName: isPressed ? "heart.fill" : "heart")
                        .foregroundStyle(isPressed ? .red : .primary)
                        .font(.title2)
                }
                .buttonStyle(.borderless)
                .padding()
                .background(.thinMaterial, in: Circle())
                .scaleEffect(isPressed ? 1.1 : 1.0)
            }
        }
    }
}

struct ModernSliderShowcase: View {
    @Binding var value: Double
    @State private var discreteValue: Double = 3
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Enhanced Sliders")
                .font(.headline)
            
            VStack(spacing: 20) {
                // Standard Slider with new styling
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Standard Slider")
                        Spacer()
                        Text("\(Int(value))")
                            .font(.subheadline)
                            .monospacedDigit()
                    }
                    
                    Slider(value: $value, in: 0...100) {
                        Text("Value")
                    }
                    .tint(.blue)
                    // .sliderStyle(.modern) // Would be available in iOS 26
                }
                .padding()
                .glassEffect()
                
                // Slider with Tick Marks
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("With Tick Marks")
                        Spacer()
                        Text("\(Int(discreteValue))")
                            .font(.subheadline)
                            .monospacedDigit()
                    }
                    
                    Slider(value: $discreteValue, in: 0...5, step: 1) {
                        Text("Discrete Value")
                    }
                    // .sliderStyle(.tickMarks(count: 6)) // Would be available in iOS 26
                    .tint(.green)
                }
                .padding()
                .glassEffect()
            }
        }
    }
}

struct ModernToggleShowcase: View {
    @Binding var isOn: Bool
    @State private var toggleStates = [false, true, false]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Modern Toggles")
                .font(.headline)
            
            VStack(spacing: 12) {
                // Standard Toggle
                HStack {
                    Text("Main Toggle")
                    Spacer()
                    Toggle("", isOn: $isOn)
                        .toggleStyle(.switch)
                        .tint(.blue)
                }
                .padding()
                .glassEffect()
                
                // Multiple Toggles with Icons
                ForEach(0..<3, id: \.self) { index in
                    HStack {
                        Image(systemName: ["wifi", "bluetooth", "location"][index])
                            .foregroundStyle(.tint)
                            .frame(width: 24)
                        
                        Text(["Wi-Fi", "Bluetooth", "Location"][index])
                        
                        Spacer()
                        
                        Toggle("", isOn: $toggleStates[index])
                            .toggleStyle(.switch)
                            .tint([Color.blue, Color.blue, Color.green][index])
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }
}

struct ModernMenuShowcase: View {
    @Binding var selectedOption: String
    let options: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Enhanced Menus")
                .font(.headline)
            
            VStack(spacing: 16) {
                // Standard Menu
                Menu {
                    ForEach(options, id: \.self) { option in
                        Button(option) {
                            selectedOption = option
                        }
                    }
                } label: {
                    HStack {
                        Text("Selected: \(selectedOption)")
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .glassEffect()
                }
                
                // Menu with Icons
                Menu {
                    Button {
                        // Action
                    } label: {
                        Label("New Document", systemImage: "doc.badge.plus")
                    }
                    
                    Button {
                        // Action
                    } label: {
                        Label("Open File", systemImage: "folder")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive) {
                        // Action
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    HStack {
                        Image(systemName: "ellipsis.circle")
                        Text("Actions")
                    }
                    .padding()
                    .glassEffect()
                }
            }
        }
    }
}

struct ModernDatePickerShowcase: View {
    @Binding var date: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Date & Time Pickers")
                .font(.headline)
            
            VStack(spacing: 16) {
                DatePicker("Select Date", selection: $date, displayedComponents: [.date])
                    .datePickerStyle(.compact)
                    .padding()
                    .glassEffect()
                
                DatePicker("Select Time", selection: $date, displayedComponents: [.hourAndMinute])
                    .datePickerStyle(.wheel)
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .frame(height: 120)
                    .clipped()
            }
        }
    }
}

struct ModernProgressShowcase: View {
    @State private var progress: Double = 0.7
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Progress Indicators")
                .font(.headline)
            
            VStack(spacing: 20) {
                // Linear Progress
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Linear Progress")
                        Spacer()
                        Text("\(Int(progress * 100))%")
                            .font(.subheadline)
                            .monospacedDigit()
                    }
                    
                    ProgressView(value: progress)
                        .progressViewStyle(.linear)
                        .tint(.blue)
                        .scaleEffect(y: 2)
                }
                .padding()
                .glassEffect()
                
                // Circular Progress
                HStack {
                    ProgressView(value: progress) {
                        Text("Circular")
                    }
                    .progressViewStyle(.circular)
                    .scaleEffect(1.5)
                    .tint(.green)
                    
                    Spacer()
                    
                    // Indeterminate Progress
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(1.2)
                        .opacity(isAnimating ? 1 : 0)
                }
                .padding()
                .glassEffect()
                
                Button("Animate Progress") {
                    withAnimation(.easeInOut(duration: 1)) {
                        progress = Double.random(in: 0.1...1.0)
                        isAnimating.toggle()
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            isAnimating = false
                        }
                    }
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

struct Badge: View {
    let count: Int
    
    var body: some View {
        Text("\(count)")
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(.red, in: Capsule())
    }
}

// Note: Custom styles would be available in actual iOS 26 SDK

#Preview {
    ScrollView {
        ModernControlsGallery()
    }
}