//
//  Charts3DDemo.swift
//  swiftui-wwdc
//
//  Created by matiaz on 24/8/25.
//

import SwiftUI

struct Charts3DDemo: View {
    @State private var chartData: [ChartDataPoint] = []
    @State private var selectedChartType: Chart3DType = .bar
    @State private var animateChart = false
    @State private var rotationX: Double = 0
    @State private var rotationY: Double = 0
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(alignment: .leading, spacing: 16) {
                Text("3D Charts & Visualization")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("New Chart3D capabilities for immersive data visualization")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Chart Type Selector
            Chart3DTypeSelector(selectedType: $selectedChartType)
            
            // 3D Chart Display
            Chart3DView(
                data: chartData,
                type: selectedChartType,
                animated: animateChart,
                rotationX: rotationX,
                rotationY: rotationY
            )
            
            // Chart Controls
            Chart3DControls(
                animateChart: $animateChart,
                rotationX: $rotationX,
                rotationY: $rotationY,
                onGenerateData: generateChartData
            )
            
            // Chart Customization
            Chart3DCustomization(selectedType: selectedChartType)
            
            // Interactive Features
            InteractiveChart3DFeatures()
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
        .backgroundExtensionEffect()
        .onAppear {
            generateChartData()
        }
    }
    
    private func generateChartData() {
        chartData = (1...12).map { month in
            ChartDataPoint(
                id: UUID(),
                x: month,
                y: Double.random(in: 20...100),
                z: Double.random(in: 10...80),
                category: ["Sales", "Marketing", "Development", "Support"].randomElement() ?? "Sales",
                month: DateFormatter().monthSymbols[month - 1]
            )
        }
    }
}

struct ChartDataPoint: Identifiable {
    let id: UUID
    let x: Int
    let y: Double
    let z: Double
    let category: String
    let month: String
}

enum Chart3DType: String, CaseIterable {
    case bar = "3D Bar"
    case surface = "Surface"
    case scatter = "Scatter"
    case line = "3D Line"
    
    var icon: String {
        switch self {
        case .bar: return "chart.bar.fill"
        case .surface: return "square.grid.3x3.fill"
        case .scatter: return "circle.grid.3x3.fill"
        case .line: return "chart.line.uptrend.xyaxis"
        }
    }
}

struct Chart3DTypeSelector: View {
    @Binding var selectedType: Chart3DType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Chart Type")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(Chart3DType.allCases, id: \.self) { type in
                    Chart3DTypeButton(
                        type: type,
                        isSelected: type == selectedType
                    ) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedType = type
                        }
                    }
                }
            }
        }
    }
}

struct Chart3DTypeButton: View {
    let type: Chart3DType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: type.icon)
                    .font(.title3)
                
                Text(type.rawValue)
                    .fontWeight(.medium)
            }
            .foregroundStyle(isSelected ? .white : .primary)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                isSelected ? Color.accentColor : Color.accentColor.opacity(0.1),
                in: RoundedRectangle(cornerRadius: 12)
            )
        }
        .buttonStyle(.plain)
    }
}

struct Chart3DView: View {
    let data: [ChartDataPoint]
    let type: Chart3DType
    let animated: Bool
    let rotationX: Double
    let rotationY: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Interactive 3D Chart")
                .font(.headline)
            
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 16)
                    .fill(.black.opacity(0.05))
                    .frame(height: 300)
                
                // Chart content based on type
                Group {
                    switch type {
                    case .bar:
                        Chart3DBarView(data: data, animated: animated)
                    case .surface:
                        Chart3DSurfaceView(data: data, animated: animated)
                    case .scatter:
                        Chart3DScatterView(data: data, animated: animated)
                    case .line:
                        Chart3DLineView(data: data, animated: animated)
                    }
                }
                .rotation3DEffect(
                    .degrees(rotationX),
                    axis: (x: 1, y: 0, z: 0)
                )
                .rotation3DEffect(
                    .degrees(rotationY),
                    axis: (x: 0, y: 1, z: 0)
                )
                
                // Chart axes
                Chart3DAxes()
            }
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }
}

struct Chart3DBarView: View {
    let data: [ChartDataPoint]
    let animated: Bool
    
    var body: some View {
        ZStack {
            // 3D Bars
            ForEach(Array(data.enumerated()), id: \.element.id) { index, point in
                Chart3DBar(
                    height: point.y,
                    color: colorForCategory(point.category),
                    position: CGPoint(
                        x: Double(index - data.count / 2) * 20,
                        y: 0
                    ),
                    animated: animated,
                    delay: Double(index) * 0.1
                )
            }
        }
    }
    
    private func colorForCategory(_ category: String) -> Color {
        switch category {
        case "Sales": return .blue
        case "Marketing": return .green
        case "Development": return .orange
        case "Support": return .red
        default: return .gray
        }
    }
}

struct Chart3DBar: View {
    let height: Double
    let color: Color
    let position: CGPoint
    let animated: Bool
    let delay: Double
    
    @State private var animatedHeight: Double = 0
    
    var body: some View {
        VStack {
            Spacer()
            
            Rectangle()
                .fill(color.gradient)
                .frame(
                    width: 15,
                    height: CGFloat(animated ? animatedHeight : height) * 2
                )
                .shadow(color: color.opacity(0.3), radius: 3, x: 2, y: 2)
        }
        .position(x: 150 + position.x, y: 150 + position.y)
        .onAppear {
            if animated {
                withAnimation(.easeOut(duration: 0.8).delay(delay)) {
                    animatedHeight = height
                }
            }
        }
        .onChange(of: animated) { _, newValue in
            if newValue {
                animatedHeight = 0
                withAnimation(.easeOut(duration: 0.8).delay(delay)) {
                    animatedHeight = height
                }
            } else {
                animatedHeight = height
            }
        }
    }
}

struct Chart3DSurfaceView: View {
    let data: [ChartDataPoint]
    let animated: Bool
    
    var body: some View {
        ZStack {
            // Surface mesh
            ForEach(0..<4, id: \.self) { row in
                ForEach(0..<4, id: \.self) { col in
                    SurfacePoint(
                        x: Double(col - 2) * 30,
                        y: Double(row - 2) * 30,
                        z: Double.random(in: 0...30),
                        animated: animated,
                        delay: Double(row * 4 + col) * 0.05
                    )
                }
            }
        }
    }
}

struct SurfacePoint: View {
    let x: Double
    let y: Double
    let z: Double
    let animated: Bool
    let delay: Double
    
    @State private var animatedZ: Double = 0
    
    var body: some View {
        Circle()
            .fill(.blue.gradient)
            .frame(width: 8, height: 8)
            .position(
                x: 150 + x,
                y: 150 + y - (animated ? animatedZ : z) * 0.5
            )
            .onAppear {
                if animated {
                    withAnimation(.easeOut(duration: 1.0).delay(delay)) {
                        animatedZ = z
                    }
                }
            }
            .onChange(of: animated) { _, newValue in
                if newValue {
                    animatedZ = 0
                    withAnimation(.easeOut(duration: 1.0).delay(delay)) {
                        animatedZ = z
                    }
                } else {
                    animatedZ = z
                }
            }
    }
}

struct Chart3DScatterView: View {
    let data: [ChartDataPoint]
    let animated: Bool
    
    var body: some View {
        ZStack {
            ForEach(Array(data.enumerated()), id: \.element.id) { index, point in
                ScatterPoint(
                    point: point,
                    position: CGPoint(
                        x: point.y - 50,
                        y: point.z - 40
                    ),
                    animated: animated,
                    delay: Double(index) * 0.08
                )
            }
        }
    }
}

struct ScatterPoint: View {
    let point: ChartDataPoint
    let position: CGPoint
    let animated: Bool
    let delay: Double
    
    @State private var scale: CGFloat = 0
    
    var body: some View {
        Circle()
            .fill(colorForCategory(point.category).gradient)
            .frame(width: 12, height: 12)
            .scaleEffect(animated ? scale : 1.0)
            .position(x: 150 + position.x, y: 150 + position.y)
            .onAppear {
                if animated {
                    withAnimation(.easeOut(duration: 0.6).delay(delay)) {
                        scale = 1.0
                    }
                }
            }
            .onChange(of: animated) { _, newValue in
                if newValue {
                    scale = 0
                    withAnimation(.easeOut(duration: 0.6).delay(delay)) {
                        scale = 1.0
                    }
                } else {
                    scale = 1.0
                }
            }
    }
    
    private func colorForCategory(_ category: String) -> Color {
        switch category {
        case "Sales": return .blue
        case "Marketing": return .green
        case "Development": return .orange
        case "Support": return .red
        default: return .gray
        }
    }
}

struct Chart3DLineView: View {
    let data: [ChartDataPoint]
    let animated: Bool
    
    var body: some View {
        ZStack {
            // Line segments
            ForEach(0..<data.count - 1, id: \.self) { index in
                LineSegment3D(
                    from: data[index],
                    to: data[index + 1],
                    index: index,
                    animated: animated
                )
            }
            
            // Data points
            ForEach(Array(data.enumerated()), id: \.element.id) { index, point in
                LinePoint3D(
                    point: point,
                    index: index,
                    animated: animated
                )
            }
        }
    }
}

struct LineSegment3D: View {
    let from: ChartDataPoint
    let to: ChartDataPoint
    let index: Int
    let animated: Bool
    
    @State private var progress: CGFloat = 0
    
    var body: some View {
        Path { path in
            let fromPos = CGPoint(
                x: 50 + Double(from.x) * 20,
                y: 150 - from.y
            )
            let toPos = CGPoint(
                x: 50 + Double(to.x) * 20,
                y: 150 - to.y
            )
            
            path.move(to: fromPos)
            path.addLine(to: CGPoint(
                x: fromPos.x + (toPos.x - fromPos.x) * progress,
                y: fromPos.y + (toPos.y - fromPos.y) * progress
            ))
        }
        .stroke(.blue, lineWidth: 3)
        .onAppear {
            if animated {
                withAnimation(.easeInOut(duration: 0.5).delay(Double(index) * 0.1)) {
                    progress = 1.0
                }
            }
        }
        .onChange(of: animated) { _, newValue in
            if newValue {
                progress = 0
                withAnimation(.easeInOut(duration: 0.5).delay(Double(index) * 0.1)) {
                    progress = 1.0
                }
            } else {
                progress = 1.0
            }
        }
    }
}

struct LinePoint3D: View {
    let point: ChartDataPoint
    let index: Int
    let animated: Bool
    
    @State private var scale: CGFloat = 0
    
    var body: some View {
        Circle()
            .fill(.blue.gradient)
            .frame(width: 8, height: 8)
            .scaleEffect(animated ? scale : 1.0)
            .position(
                x: 50 + Double(point.x) * 20,
                y: 150 - point.y
            )
            .onAppear {
                if animated {
                    withAnimation(.easeOut(duration: 0.3).delay(Double(index) * 0.1 + 0.2)) {
                        scale = 1.0
                    }
                }
            }
            .onChange(of: animated) { _, newValue in
                if newValue {
                    scale = 0
                    withAnimation(.easeOut(duration: 0.3).delay(Double(index) * 0.1 + 0.2)) {
                        scale = 1.0
                    }
                } else {
                    scale = 1.0
                }
            }
    }
}

struct Chart3DAxes: View {
    var body: some View {
        ZStack {
            // X axis
            Path { path in
                path.move(to: CGPoint(x: 50, y: 250))
                path.addLine(to: CGPoint(x: 250, y: 250))
            }
            .stroke(.secondary, lineWidth: 1)
            
            // Y axis
            Path { path in
                path.move(to: CGPoint(x: 50, y: 250))
                path.addLine(to: CGPoint(x: 50, y: 50))
            }
            .stroke(.secondary, lineWidth: 1)
            
            // Z axis (simulated perspective)
            Path { path in
                path.move(to: CGPoint(x: 50, y: 250))
                path.addLine(to: CGPoint(x: 100, y: 200))
            }
            .stroke(.secondary, lineWidth: 1)
        }
    }
}

struct Chart3DControls: View {
    @Binding var animateChart: Bool
    @Binding var rotationX: Double
    @Binding var rotationY: Double
    let onGenerateData: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Chart Controls")
                .font(.headline)
            
            VStack(spacing: 16) {
                // Animation Control
                HStack {
                    Text("Animate Chart")
                    Spacer()
                    Button(animateChart ? "Stop" : "Animate") {
                        withAnimation {
                            animateChart.toggle()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                // Data Generation
                HStack {
                    Text("Chart Data")
                    Spacer()
                    Button("Generate New Data") {
                        onGenerateData()
                        if animateChart {
                            withAnimation {
                                animateChart = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation {
                                    animateChart = true
                                }
                            }
                        }
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
            
            // 3D Rotation Controls
            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("X Rotation: \(Int(rotationX))°")
                        .font(.subheadline)
                    
                    Slider(value: $rotationX, in: -45...45) {
                        Text("X Rotation")
                    }
                    .tint(.blue)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Y Rotation: \(Int(rotationY))°")
                        .font(.subheadline)
                    
                    Slider(value: $rotationY, in: -45...45) {
                        Text("Y Rotation")
                    }
                    .tint(.green)
                }
                
                Button("Reset View") {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        rotationX = 0
                        rotationY = 0
                    }
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct Chart3DCustomization: View {
    let selectedType: Chart3DType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Customization Options")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                CustomizationOption(
                    title: "Color Scheme",
                    icon: "paintpalette",
                    description: "Gradient colors"
                )
                
                CustomizationOption(
                    title: "Lighting",
                    icon: "sun.max",
                    description: "Ambient lighting"
                )
                
                CustomizationOption(
                    title: "Shadows",
                    icon: "circle.dotted",
                    description: "Drop shadows"
                )
                
                CustomizationOption(
                    title: "Transparency",
                    icon: "circle.dashed",
                    description: "Alpha blending"
                )
            }
        }
    }
}

struct CustomizationOption: View {
    let title: String
    let icon: String
    let description: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.tint)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct InteractiveChart3DFeatures: View {
    @State private var selectedFeature: InteractiveFeature = .zoom
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Interactive Features")
                .font(.headline)
            
            Picker("Feature", selection: $selectedFeature) {
                ForEach(InteractiveFeature.allCases, id: \.self) { feature in
                    Text(feature.rawValue)
                        .tag(feature)
                }
            }
            .pickerStyle(.segmented)
            
            InteractiveFeatureDemo(feature: selectedFeature)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

enum InteractiveFeature: String, CaseIterable {
    case zoom = "Zoom"
    case pan = "Pan"
    case select = "Select"
    case filter = "Filter"
}

struct InteractiveFeatureDemo: View {
    let feature: InteractiveFeature
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(feature.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            HStack {
                Image(systemName: feature.icon)
                    .foregroundStyle(.tint)
                
                Text(feature.instruction)
                    .font(.caption)
                
                Spacer()
            }
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 8))
    }
}

extension InteractiveFeature {
    var description: String {
        switch self {
        case .zoom: return "Pinch to zoom in and out of the chart"
        case .pan: return "Drag to move the chart around"
        case .select: return "Tap data points to see details"
        case .filter: return "Filter data by category or range"
        }
    }
    
    var icon: String {
        switch self {
        case .zoom: return "plus.magnifyingglass"
        case .pan: return "hand.draw"
        case .select: return "hand.tap"
        case .filter: return "line.horizontal.3.decrease"
        }
    }
    
    var instruction: String {
        switch self {
        case .zoom: return "Use pinch gestures on the chart"
        case .pan: return "Drag gestures move the view"
        case .select: return "Tap to select data points"
        case .filter: return "Use controls to filter data"
        }
    }
}

#Preview {
    ScrollView {
        Charts3DDemo()
    }
}