//
//  RarityFilters.swift
//  ShroomScout
//
//  Horizontal scrollable filter pills for filtering by rarity using AppBadge.
//

import SwiftUI

struct RarityFilters: View {
    @Binding var selectedRarities: Set<Rarity>
    var showAllOption: Bool = true

    private var allSelected: Bool {
        selectedRarities.isEmpty || selectedRarities.count == Rarity.allCases.count
    }

    var body: some View {
        HStack(spacing: 6) {
            if showAllOption {
                AllFilterBadge(isSelected: allSelected) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedRarities.removeAll()
                    }
                }
            }

            ForEach(Rarity.allCases, id: \.self) { rarity in
                RarityFilterBadge(
                    rarity: rarity,
                    isSelected: selectedRarities.contains(rarity)
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectRarity(rarity)
                    }
                }
            }
        }
        .fixedSize(horizontal: true, vertical: true)
    }

    private func selectRarity(_ rarity: Rarity) {
        if selectedRarities.contains(rarity) {
            // Tapping already selected rarity deselects it (shows all)
            selectedRarities.removeAll()
        } else {
            // Single selection - clear others and select this one
            selectedRarities.removeAll()
            selectedRarities.insert(rarity)
        }
    }
}

// MARK: - All Filter Badge

private struct AllFilterBadge: View {
    let isSelected: Bool
    let action: () -> Void

    private let height: CGFloat = 26
    private let cornerRadius: CGFloat = 8
    private let shadowOffset: CGFloat = 3

    private var backgroundColor: Color {
        isSelected ? AppColors.primaryGreen : .white
    }

    private var shadowColor: Color {
        isSelected ? Color(hex: "3A6247") : Color(hex: "E5E5E5")
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                // Shadow layer
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(shadowColor)
                    .frame(height: height)
                    .offset(y: shadowOffset)

                // Main layer
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
                    .frame(height: height)

                // Content
                HStack(spacing: 4) {
                    Circle()
                        .fill(isSelected ? .white : AppColors.primaryGreen)
                        .frame(width: 6, height: 6)

                    Text("All")
                        .font(.nunito(11, weight: .semibold))
                        .foregroundColor(isSelected ? .white : AppColors.textDark)
                }
                .padding(.horizontal, 10)
            }
            .frame(height: height + shadowOffset)
            .fixedSize(horizontal: true, vertical: false)
        }
        .buttonStyle(FilterBadgeButtonStyle(shadowOffset: shadowOffset))
    }
}

// MARK: - Rarity Filter Badge

private struct RarityFilterBadge: View {
    let rarity: Rarity
    let isSelected: Bool
    let action: () -> Void

    private let height: CGFloat = 26
    private let cornerRadius: CGFloat = 8
    private let shadowOffset: CGFloat = 3

    private var rarityColor: Color {
        AppColors.color(for: rarity)
    }

    private var backgroundColor: Color {
        isSelected ? rarityColor : .white
    }

    private var shadowColor: Color {
        if isSelected {
            switch rarity {
            case .common:
                return Color(hex: "7A8189")
            case .uncommon:
                return Color(hex: "4CB896")
            case .rare:
                return Color(hex: "5BB8E0")
            case .legendary:
                return Color(hex: "D4A82D")
            }
        } else {
            return Color(hex: "E5E5E5")
        }
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                // Shadow layer
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(shadowColor)
                    .frame(height: height)
                    .offset(y: shadowOffset)

                // Main layer
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
                    .frame(height: height)

                // Content
                HStack(spacing: 4) {
                    Circle()
                        .fill(isSelected ? .white : rarityColor)
                        .frame(width: 6, height: 6)

                    Text(rarity.displayName)
                        .font(.nunito(11, weight: .semibold))
                        .foregroundColor(isSelected ? .white : AppColors.textDark)
                }
                .padding(.horizontal, 10)
            }
            .frame(height: height + shadowOffset)
            .fixedSize(horizontal: true, vertical: false)
        }
        .buttonStyle(FilterBadgeButtonStyle(shadowOffset: shadowOffset))
    }
}

// MARK: - Button Style

private struct FilterBadgeButtonStyle: ButtonStyle {
    let shadowOffset: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .offset(y: configuration.isPressed ? shadowOffset * 0.6 : 0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
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
