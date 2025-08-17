//
//  LargeActionButton.swift
//  accessibility
//
//  Created by matiaz on 17/8/25.
//

import SwiftUI

struct LargeActionButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 40, weight: .semibold))
                    .accessibilityHidden(true) // icon is decorative; text conveys the label
                Text(title)
                    .font(.title2).bold()
            }
            .frame(maxWidth: .infinity, minHeight: 100)
        }
        .buttonStyle(.borderedProminent)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityLabel(Text(title))
        .padding(.horizontal)
    }
}
