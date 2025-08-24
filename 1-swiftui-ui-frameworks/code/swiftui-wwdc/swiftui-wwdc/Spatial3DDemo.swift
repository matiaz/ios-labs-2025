//
//  Spatial3DDemo.swift
//  swiftui-wwdc
//
//  Created by matiaz on 24/8/25.
//

import SwiftUI

struct Spatial3DDemo: View {
    @State private var rotation3D: Double = 0
    @State private var isManipulating = false
    @State private var selectedAlignment: Alignment3DType = .center
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(alignment: .leading, spacing: 16) {
                Text("3D Layout & Spatial Computing")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("New Alignment3D system and manipulable objects for visionOS")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // 3D Alignment Demo
            VStack(alignment: .leading, spacing: 16) {
                Text("Alignment3D System")
                    .font(.headline)
                
                Picker("3D Alignment", selection: $selectedAlignment) {
                    ForEach(Alignment3DType.allCases, id: \.self) { alignment in
                        Text(alignment.rawValue)
                            .tag(alignment)
                    }
                }
                .pickerStyle(.segmented)
                
                // 3D Layout Container
                ZStack {
                    // Background container
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.thinMaterial)
                        .frame(height: 200)
                    
                    // 3D positioned elements
                    ForEach(0..<3, id: \.self) { index in
                        Spatial3DElement(
                            index: index,
                            alignment: selectedAlignment,
                            isActive: isManipulating
                        )
                    }
                }
            }
            
            // Manipulable Objects Demo
            VStack(alignment: .leading, spacing: 16) {
                Text("Manipulable Objects")
                    .font(.headline)
                
                Text("Interactive 3D objects with gesture support")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 20) {
                    ForEach(0..<3, id: \.self) { index in
                        ManipulableObject(
                            title: "Object \(index + 1)",
                            color: [Color.blue, Color.green, Color.orange][index],
                            rotation: rotation3D
                        )
                    }
                }
            }
            
            // Spatial Overlay Demo
            SpatialOverlayDemo()
            
            // Control Panel
            VStack(spacing: 16) {
                Button("Toggle Manipulation") {
                    withAnimation(Animation.easeInOut(duration: 0.5)) {
                        isManipulating.toggle()
                    }
                }
                .buttonStyle(.borderedProminent)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("3D Rotation: \(Int(rotation3D))°")
                        .font(.subheadline)
                    
                    Slider(value: $rotation3D, in: 0...360) {
                        Text("Rotation")
                    }
                    .tint(.blue)
                }
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
        .backgroundExtensionEffect()
    }
}

enum Alignment3DType: String, CaseIterable {
    case center = "Center"
    case leading = "Leading"
    case trailing = "Trailing"
    case top = "Top"
    case bottom = "Bottom"
    
    var alignment3D: Alignment3D {
        switch self {
        case .center: return .center
        case .leading: return .leading
        case .trailing: return .trailing  
        case .top: return .top
        case .bottom: return .bottom
        }
    }
}

struct Spatial3DElement: View {
    let index: Int
    let alignment: Alignment3DType
    let isActive: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(colors[index].gradient)
            .frame(width: 60, height: 60)
            .overlay(
                Text("\(index + 1)")
                    .font(.headline)
                    .foregroundStyle(.white)
            )
            .rotation3DEffect(
                .degrees(isActive ? Double(index * 30) : 0),
                axis: (x: 1, y: 1, z: 0)
            )
            .scaleEffect(isActive ? 1.2 : 1.0)
            .position3D(alignment: alignment.alignment3D, offset: CGPoint(
                x: Double(index - 1) * 80,
                y: Double(index) * 20
            ))
            .animation(.easeInOut(duration: 0.5), value: alignment)
            .animation(.easeInOut(duration: 0.3), value: isActive)
    }
    
    private var colors: [Color] {
        [.blue, .green, .orange]
    }
}

struct ManipulableObject: View {
    let title: String
    let color: Color
    let rotation: Double
    
    @State private var dragOffset: CGSize = .zero
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(color.gradient)
                .frame(width: 80, height: 80)
                .rotation3DEffect(
                    .degrees(rotation),
                    axis: (x: 0, y: 1, z: 0)
                )
                .scaleEffect(scale)
                .offset(dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation
                            let magnitude = sqrt(pow(value.translation.width, 2) + pow(value.translation.height, 2))
                            scale = 1.0 + magnitude / 200
                        }
                        .onEnded { _ in
                            withAnimation(.spring()) {
                                dragOffset = .zero
                                scale = 1.0
                            }
                        }
                )
                .shadow(color: color.opacity(0.3), radius: 10, x: 0, y: 5)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

struct SpatialOverlayDemo: View {
    @State private var showOverlay = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Spatial Overlays")
                .font(.headline)
            
            ZStack {
                // Base content
                RoundedRectangle(cornerRadius: 16)
                    .fill(.blue.gradient)
                    .frame(height: 120)
                    .overlay(
                        Text("Base Content")
                            .font(.headline)
                            .foregroundStyle(.white)
                    )
                
                // Spatial overlay
                if showOverlay {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.white.opacity(0.9))
                        .frame(width: 200, height: 80)
                        .overlay(
                            VStack(spacing: 4) {
                                Text("Spatial Overlay")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                Text("Positioned in 3D space")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        )
                        .spatialOverlay(
                            alignment: .center,
                            distance: 50
                        )
                        .transition(.scale.combined(with: .opacity))
                }
            }
            
            Button("Toggle Spatial Overlay") {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showOverlay.toggle()
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// Extensions and types are defined in LiquidGlassExtensions.swift

#Preview {
    ScrollView {
        Spatial3DDemo()
    }
}