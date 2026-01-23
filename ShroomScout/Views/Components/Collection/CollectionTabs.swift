//
//  CollectionTabs.swift
//  ShroomScout
//
//  Collection view mode enum and convenience wrapper for SegmentedControl.
//

import SwiftUI

enum CollectionViewMode: String, CaseIterable {
    case allSpecies = "All Species"
    case myFinds = "My Finds"
}

/// Convenience wrapper that uses SegmentedControl with CollectionViewMode
struct CollectionTabs: View {
    @Binding var selectedMode: CollectionViewMode

    var body: some View {
        SegmentedControl(selected: $selectedMode)
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
