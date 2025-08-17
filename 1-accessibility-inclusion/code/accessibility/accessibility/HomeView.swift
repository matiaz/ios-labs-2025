//
//  HomeView.swift
//  accessibility
//
//  Created by matiaz on 17/8/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appState: AppState
    @State private var navPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navPath) {
            VStack(spacing: 24) {
                Spacer(minLength: 16)

                // Keep choices to essentials
                LargeActionButton(title: "Draw", systemImage: "pencil.and.scribble") {
                    navPath.append(Route.colorChooser)
                }

                LargeActionButton(title: "Gallery", systemImage: "photo.on.rectangle") {
                    navPath.append(Route.gallery)
                }

                Spacer()
            }
            .navigationTitle("Choose an action")
            .toolbar {
                // Avoid hidden gestures; persistent, visible controls only
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .colorChooser:
                    ColorChooserView(onContinue: { navPath.append(Route.canvas) })
                case .canvas:
                    CanvasView()
                case .gallery:
                    GalleryView()
                }
            }
        }
    }
}

enum Route: Hashable {
    case colorChooser
    case canvas
    case gallery
}

#Preview {
    HomeView()
        .environmentObject(AppState())
}
