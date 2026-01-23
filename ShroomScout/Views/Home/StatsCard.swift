//
//  StatsCard.swift
//  ShroomScout
//
//  Home screen stats card showing collection progress and rarity breakdown.
//  Uses the existing AppCard component.
//

import SwiftUI

struct StatsCard: View {
    /// Number of species discovered
    let discoveredCount: Int

    /// Total species in the region
    let totalCount: Int

    /// Breakdown by rarity
    let rarityBreakdown: RarityBreakdown

    /// Action when "View All" is tapped
    var onViewAll: (() -> Void)?

    private var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(discoveredCount) / Double(totalCount)
    }

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 16) {
                // Header row
                HStack {
                    Text("Your Collection")
                        .font(.nunito(20, weight: .bold))
                        .foregroundColor(AppColors.textDark)

                    Spacer()

                    Button {
                        onViewAll?()
                    } label: {
                        Text("View All")
                            .font(.nunito(14, weight: .semibold))
                            .foregroundColor(AppColors.primaryGreen)
                    }
                }

                // Count display
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(discoveredCount)")
                        .font(.nunito(36, weight: .bold))
                        .foregroundColor(AppColors.primaryGreen)

                    Text("/ \(totalCount)")
                        .font(.nunito(24, weight: .regular))
                        .foregroundColor(AppColors.textLight)
                }

                // Progress bar
                ProgressBarView(progress: progress)

                // Rarity breakdown
                RarityBreakdownRow(breakdown: rarityBreakdown)
            }
        }
    }
}

// MARK: - Progress Bar

private struct ProgressBarView: View {
    let progress: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 6)
                    .fill(AppColors.cream)
                    .frame(height: 12)

                // Progress fill
                RoundedRectangle(cornerRadius: 6)
                    .fill(AppColors.primaryGreen)
                    .frame(width: max(0, geometry.size.width * progress), height: 12)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: progress)
            }
        }
        .frame(height: 12)
    }
}

// MARK: - Rarity Breakdown Row

private struct RarityBreakdownRow: View {
    let breakdown: RarityBreakdown

    var body: some View {
        HStack(spacing: 12) {
            RarityCountItem(color: AppColors.rarityCommon, count: breakdown.common)
            RarityCountItem(color: AppColors.rarityUncommon, count: breakdown.uncommon)
            RarityCountItem(color: AppColors.rarityRare, count: breakdown.rare)
            RarityCountItem(color: AppColors.rarityLegendary, count: breakdown.legendary)
        }
        .padding(.top, 4)
    }
}

// MARK: - Rarity Count Item

private struct RarityCountItem: View {
    let color: Color
    let count: Int

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)

            Text("\(count)")
                .font(.nunito(12, weight: .regular))
                .foregroundColor(AppColors.textLight)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 24) {
        StatsCard(
            discoveredCount: 6,
            totalCount: 156,
            rarityBreakdown: RarityBreakdown(
                common: 2,
                uncommon: 3,
                rare: 1,
                legendary: 0
            )
        ) {
            print("View All tapped")
        }

        StatsCard(
            discoveredCount: 45,
            totalCount: 156,
            rarityBreakdown: RarityBreakdown(
                common: 20,
                uncommon: 15,
                rare: 8,
                legendary: 2
            )
        )

        StatsCard(
            discoveredCount: 0,
            totalCount: 156,
            rarityBreakdown: RarityBreakdown()
        )
    }
    .padding(24)
    .background(AppColors.background)
}
