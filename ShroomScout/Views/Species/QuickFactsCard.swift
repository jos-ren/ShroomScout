//
//  QuickFactsCard.swift
//  ShroomScout
//
//  Quick facts card displaying edibility, season, and habitat with icons.
//

import SwiftUI

struct QuickFactsCard: View {
    let edibility: Edibility
    let seasons: [Season]
    let habitat: String

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                Text("Quick Facts")
                    .font(.nunito(18, weight: .bold))
                    .foregroundColor(AppColors.textDark)

                // Facts list
                VStack(spacing: 16) {
                    // Edibility row
                    FactRow(
                        icon: edibilityIcon,
                        label: "Edibility",
                        value: edibility.displayName
                    )

                    // Season row
                    FactRow(
                        icon: "calendar",
                        label: "Season",
                        value: seasonDisplayText
                    )

                    // Habitat row
                    FactRow(
                        icon: "leaf.fill",
                        label: "Habitat",
                        value: habitat
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var edibilityIcon: String {
        switch edibility {
        case .edible:
            return "fork.knife"
        case .inedible:
            return "xmark.circle"
        case .caution:
            return "exclamationmark.triangle"
        case .toxic:
            return "exclamationmark.octagon"
        case .deadly:
            return "skull"
        }
    }

    private var seasonDisplayText: String {
        if seasons.isEmpty {
            return "Unknown"
        }

        if seasons.contains(.yearRound) {
            return "Year Round"
        }

        let sortedSeasons = seasons.sorted { season1, season2 in
            let order: [Season] = [.spring, .summer, .fall, .winter]
            let index1 = order.firstIndex(of: season1) ?? 0
            let index2 = order.firstIndex(of: season2) ?? 0
            return index1 < index2
        }

        if sortedSeasons.count == 1 {
            return sortedSeasons[0].displayName
        } else if sortedSeasons.count == 2 {
            return "\(sortedSeasons[0].displayName) through \(sortedSeasons[1].displayName)"
        } else {
            return sortedSeasons.map { $0.displayName }.joined(separator: ", ")
        }
    }
}

// MARK: - Fact Row

private struct FactRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            // Icon container
            ZStack {
                Circle()
                    .fill(AppColors.cream)
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.primaryGreen)
            }

            // Label and value
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.nunito(14, weight: .semibold))
                    .foregroundColor(AppColors.textDark)

                Text(value)
                    .font(.nunito(14, weight: .regular))
                    .foregroundColor(AppColors.textLight)
            }

            Spacer()
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 24) {
            QuickFactsCard(
                edibility: .edible,
                seasons: [.summer, .fall],
                habitat: "Conifer forests, mossy areas"
            )

            QuickFactsCard(
                edibility: .caution,
                seasons: [.spring],
                habitat: "Hardwood forests, near oak trees"
            )

            QuickFactsCard(
                edibility: .toxic,
                seasons: [.yearRound],
                habitat: "Disturbed soils, lawns, gardens"
            )
        }
        .padding(24)
    }
    .background(AppColors.background)
}
