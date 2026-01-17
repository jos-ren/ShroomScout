//
//  RarityFilters.swift
//  ShroomScout
//
//  Horizontal scrollable filter pills for filtering by rarity.
//

import SwiftUI

struct RarityFilters: View {
    @Binding var selectedRarities: Set<Rarity>
    var showAllOption: Bool = true

    private var allSelected: Bool {
        selectedRarities.isEmpty || selectedRarities.count == Rarity.allCases.count
    }

    var body: some View {
        HStack(spacing: 4) {
            if showAllOption {
                filterPill(
                    title: "All",
                    color: AppColors.primaryGreen,
                    isSelected: allSelected
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedRarities.removeAll()
                    }
                }
            }

            ForEach(Rarity.allCases, id: \.self) { rarity in
                filterPill(
                    title: rarity.rawValue.capitalized,
                    color: rarityColor(for: rarity),
                    isSelected: selectedRarities.contains(rarity)
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        toggleRarity(rarity)
                    }
                }
            }
        }
        .fixedSize(horizontal: true, vertical: true)
    }

    private func filterPill(
        title: String,
        color: Color,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Circle()
                    .fill(isSelected ? .white : color)
                    .frame(width: 6, height: 6)

                Text(title)
                    .font(.nunito(11, weight: .semibold))
                    .lineLimit(1)
            }
            .foregroundColor(isSelected ? .white : AppColors.textDark)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isSelected ? color : .white)
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(FilterPillButtonStyle())
    }

    private func toggleRarity(_ rarity: Rarity) {
        if selectedRarities.contains(rarity) {
            selectedRarities.remove(rarity)
        } else {
            selectedRarities.insert(rarity)
        }
    }

    private func rarityColor(for rarity: Rarity) -> Color {
        switch rarity {
        case .common:
            return AppColors.rarityCommon
        case .uncommon:
            return AppColors.rarityUncommon
        case .rare:
            return AppColors.rarityRare
        case .legendary:
            return AppColors.rarityLegendary
        }
    }
}

private struct FilterPillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedRarities: Set<Rarity> = []

        var body: some View {
            VStack(spacing: 24) {
                RarityFilters(selectedRarities: $selectedRarities)

                Text("Selected: \(selectedRarities.isEmpty ? "All" : selectedRarities.map { $0.rawValue.capitalized }.joined(separator: ", "))")
                    .font(.nunito(14, weight: .medium))
                    .foregroundColor(AppColors.textDark)

                Spacer()
            }
            .padding(24)
            .background(AppColors.background)
        }
    }

    return PreviewWrapper()
}
