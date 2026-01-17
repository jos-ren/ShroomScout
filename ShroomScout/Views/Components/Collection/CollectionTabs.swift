//
//  CollectionTabs.swift
//  ShroomScout
//
//  Segmented toggle for collection view modes (All Species / My Finds).
//

import SwiftUI

enum CollectionViewMode: String, CaseIterable {
    case allSpecies = "All Species"
    case myFinds = "My Finds"
}

struct CollectionTabs: View {
    @Binding var selectedMode: CollectionViewMode

    var body: some View {
        HStack(spacing: 4) {
            ForEach(CollectionViewMode.allCases, id: \.self) { mode in
                tabButton(for: mode)
            }
        }
        .padding(4)
        .background(
            Capsule()
                .fill(AppColors.cream)
        )
    }

    private func tabButton(for mode: CollectionViewMode) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedMode = mode
            }
        } label: {
            Text(mode.rawValue)
                .font(.nunito(14, weight: .semibold))
                .foregroundColor(selectedMode == mode ? .white : AppColors.textLight)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Group {
                        if selectedMode == mode {
                            Capsule()
                                .fill(AppColors.primaryGreen)
                        } else {
                            Color.clear
                        }
                    }
                )
        }
        .buttonStyle(TabButtonStyle())
    }
}

private struct TabButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedMode: CollectionViewMode = .allSpecies

        var body: some View {
            VStack(spacing: 24) {
                CollectionTabs(selectedMode: $selectedMode)

                Text("Selected: \(selectedMode.rawValue)")
                    .font(.nunito(16, weight: .medium))
                    .foregroundColor(AppColors.textDark)
            }
            .padding(24)
            .background(AppColors.background)
        }
    }

    return PreviewWrapper()
}
