//
//  ColorChooserView.swift
//  accessibility
//
//  Created by matiaz on 17/8/25.
//

import SwiftUI

struct ColorChooserView: View {
    @EnvironmentObject private var appState: AppState
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("Pick a color")
                .font(.largeTitle).bold()
                .padding(.top)

            // Keep options small and clear (2–4 is ideal)
            VStack(spacing: 12) {
                ForEach(ColorOption.allCases) { option in
                    Button {
                        appState.selectedColor = option
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: option.symbolName)
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(option.color)
                                .font(.system(size: 28, weight: .semibold))
                                .accessibilityHidden(true)

                            Text(option.label)
                                .font(.title3).bold()

                            Spacer()

                            if appState.selectedColor == option {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                    .accessibilityLabel(Text("Selected"))
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text(option.label))
                    .padding(.horizontal)
                }
            }

            Button("Continue") { onContinue() }
                .buttonStyle(.borderedProminent)
                .font(.title3).bold()
                .padding(.horizontal)

            Spacer()
        }
        .navigationTitle("Color")
        .toolbar {
            // No destructive items here; keep it simple
        }
    }
}

#Preview {
    ColorChooserView(onContinue: {})
        .environmentObject(AppState())
}
