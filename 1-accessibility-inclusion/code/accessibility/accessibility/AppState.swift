//
//  AppState.swift
//  accessibility
//
//  Created by matiaz on 17/8/25.
//

import SwiftUI

final class AppState: ObservableObject {
    @Published var selectedColor: ColorOption = .blue
    @Published var drawings: [Drawing] = []  // very simple: arrays of points per color
}

struct Drawing: Identifiable {
    let id = UUID()
    var color: ColorOption
    var points: [CGPoint]
}

enum ColorOption: String, CaseIterable, Identifiable {
    case red, green, blue, yellow

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .red:    return .red
        case .green:  return .green
        case .blue:   return .blue
        case .yellow: return .yellow
        }
    }

    var symbolName: String {
        switch self {
        case .red:    return "circle.fill"
        case .green:  return "circle.fill"
        case .blue:   return "circle.fill"
        case .yellow: return "circle.fill"
        }
    }

    var label: String {
        switch self {
        case .red:    return "Red"
        case .green:  return "Green"
        case .blue:   return "Blue"
        case .yellow: return "Yellow"
        }
    }
}
