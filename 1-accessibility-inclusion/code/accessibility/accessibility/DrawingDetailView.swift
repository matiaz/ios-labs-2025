//
//  DrawingDetailView.swift
//  accessibility
//
//  Created by matiaz on 17/8/25.
//

import SwiftUI

struct DrawingDetailView: View {
    let drawing: Drawing

    var body: some View {
        VStack(spacing: 16) {
            Text("Your \(drawing.color.label.lowercased()) drawing")
                .font(.title2).bold()
                .padding(.top)

            GeometryReader { proxy in
                ZStack {
                    Path { path in
                        for point in drawing.points {
                            path.addEllipse(in: CGRect(x: point.x - 6, y: point.y - 6, width: 12, height: 12))
                        }
                    }
                    .fill(drawing.color.color.opacity(0.9))
                    .accessibilityLabel(Text("Drawing with \(drawing.points.count) dots in \(drawing.color.label.lowercased())"))
                }
            }
            .frame(minHeight: 320)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal)

            Spacer()
        }
        .navigationTitle("Drawing")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        DrawingDetailView(drawing: Drawing(
            color: .blue,
            points: [
                CGPoint(x: 100, y: 100),
                CGPoint(x: 120, y: 120),
                CGPoint(x: 140, y: 100)
            ]
        ))
    }
}