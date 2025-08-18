//
//  GalleryView.swift
//  accessibility
//
//  Created by matiaz on 17/8/25.
//

import SwiftUI

struct GalleryView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        List {
            if appState.drawings.isEmpty {
                Section {
                    Text("No drawings yet")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .accessibilityLabel(Text("No drawings yet"))
                }
            } else {
                ForEach(appState.drawings) { drawing in
                    NavigationLink(destination: DrawingDetailView(drawing: drawing)) {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(drawing.color.color)
                                .frame(width: 24, height: 24)
                                .accessibilityHidden(true)

                            Text("\(drawing.color.label) drawing")
                                .font(.body)
                        }
                        .padding(.vertical, 4)
                    }
                    .accessibilityLabel(Text("View \(drawing.color.label.lowercased()) drawing"))
                    .accessibilityHint(Text("Shows your saved drawing"))
                }
            }
        }
        .navigationTitle("Gallery")
    }
}
