//
//  accessibilityApp.swift
//  accessibility
//
//  Created by matiaz on 17/8/25.
//

import SwiftUI

@main
struct accessibilityApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(appState)
        }
    }
}
