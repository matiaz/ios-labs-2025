//
//  CanvasView.swift
//  accessibility
//
//  Created by matiaz on 17/8/25.
//

import SwiftUI

struct CanvasView: View {
    @EnvironmentObject private var appState: AppState
    @State private var currentPoints: [CGPoint] = []

    var body: some View {
        VStack(spacing: 16) {
            Text("Tap to draw")
                .font(.title2).bold()

            GeometryReader { proxy in
                ZStack {
                    // Existing drawings
                    ForEach(appState.drawings) { drawing in
                        Path { path in
                            for p in drawing.points {
                                path.addEllipse(in: CGRect(x: p.x - 6, y: p.y - 6, width: 12, height: 12))
                            }
                        }
                        .fill(drawing.color.color.opacity(0.9))
                        .accessibilityHidden(true)
                    }

                    // Current in-progress points
                    Path { path in
                        for p in currentPoints {
                            path.addEllipse(in: CGRect(x: p.x - 6, y: p.y - 6, width: 12, height: 12))
                        }
                    }
                    .fill(appState.selectedColor.color.opacity(0.9))
                    .accessibilityHidden(true)
                }
                .contentShape(Rectangle())
                .onTapGesture { location in
                    // Avoid hidden multi-finger gestures—single tap only, visible action
                    let point = CGPoint(x: location.x, y: location.y)
                    currentPoints.append(point)
                }
                .accessibilityLabel(Text("Drawing area"))
            }
            .frame(minHeight: 320)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal)

            HStack(spacing: 12) {
                Button {
                    // Confirm “Save” explicitly (no auto-timeouts)
                    let drawing = Drawing(color: appState.selectedColor, points: currentPoints)
                    appState.drawings.append(drawing)
                    currentPoints.removeAll()
                } label: {
                    Label("Save", systemImage: "square.and.arrow.down")
                }
                .buttonStyle(.borderedProminent)
                .accessibilityHint(Text("Saves current taps to the gallery"))

                Button(role: .destructive) {
                    // Gate destructive action with a confirm alert
                    showDeleteConfirm = true
                } label: {
                    Label("Clear", systemImage: "trash")
                }
                .buttonStyle(.bordered)
                .confirmationDialog("Clear current drawing?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
                    Button("Clear", role: .destructive) { currentPoints.removeAll() }
                    Button("Cancel", role: .cancel) {}
                }
            }
            .font(.title3).bold()
            .padding(.horizontal)

            Spacer()
        }
        .navigationTitle("Canvas")
    }

    @State private var showDeleteConfirm = false
}
