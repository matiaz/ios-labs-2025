//
//  CodeDocGeneratorDemo.swift
//  foundationmodels
//
//  Created by matiaz on 29/8/25.
//

import SwiftUI

struct CodeDocGeneratorDemo: View {
    @State private var codeInput = """
    func calculateDistance(from point1: CGPoint, to point2: CGPoint) -> Double {
        let dx = point2.x - point1.x
        let dy = point2.y - point1.y
        return sqrt(dx * dx + dy * dy)
    }
    """
    @State private var isGenerating = false
    @State private var documentation = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Enter Swift code:")
                .font(.subheadline)
                .fontWeight(.medium)
            
            TextEditor(text: $codeInput)
                .font(.system(.caption, design: .monospaced))
                .frame(minHeight: 80)
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            
            Button(action: generateDocumentation) {
                HStack {
                    if isGenerating {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                    Text(isGenerating ? "Generating..." : "Generate Docs")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isGenerating)
            
            if !documentation.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Generated Documentation:")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    ScrollView {
                        Text(documentation)
                            .font(.system(.caption, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxHeight: 120)
                    .padding(8)
                    .background(Color.purple.opacity(0.05))
                    .cornerRadius(8)
                }
            }
        }
    }
    
    private func generateDocumentation() {
        isGenerating = true
        
        // Simulate AI documentation generation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            documentation = """
            /// Calculates the Euclidean distance between two points in 2D space
            /// 
            /// This function uses the Pythagorean theorem to determine the straight-line
            /// distance between two CGPoint objects.
            /// 
            /// - Parameters:
            ///   - point1: The starting point
            ///   - point2: The ending point
            /// - Returns: The distance between the points as a Double
            /// 
            /// Example:
            /// ```swift
            /// let p1 = CGPoint(x: 0, y: 0)
            /// let p2 = CGPoint(x: 3, y: 4)
            /// let distance = calculateDistance(from: p1, to: p2) // Returns 5.0
            /// ```
            """
            isGenerating = false
        }
    }
}

#Preview {
    CodeDocGeneratorDemo()
        .padding()
}