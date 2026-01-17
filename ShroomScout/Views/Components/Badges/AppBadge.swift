//
//  AppBadge.swift
//  ShroomScout
//
//  Reusable badge component with rarity and edibility subtypes.
//

import SwiftUI

struct AppBadge: View {
    enum BadgeType {
        case rarity(Rarity)
        case edibility(Edibility)
    }

    let type: BadgeType

    var body: some View {
        switch type {
        case .rarity(let rarity):
            RarityBadgeContent(rarity: rarity)
        case .edibility(let edibility):
            EdibilityBadgeContent(edibility: edibility)
        }
    }
}

// MARK: - Rarity Badge

private struct RarityBadgeContent: View {
    let rarity: Rarity

    private var backgroundColor: Color {
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

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(.white)
                .frame(width: 8, height: 8)

            Text(rarity.displayName)
                .font(.nunito(14, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.leading, 16)
        .padding(.trailing, 16)
        .frame(height: 36)
        .background(backgroundColor)
        .cornerRadius(100)
    }
}

// MARK: - Edibility Badge

private struct EdibilityBadgeContent: View {
    let edibility: Edibility

    private var backgroundColor: Color {
        switch edibility {
        case .edible:
            return AppColors.cream
        case .inedible:
            return AppColors.cream
        case .caution:
            return AppColors.caution.opacity(0.2)
        case .toxic:
            return Color(hex: "FF3B30").opacity(0.2)
        case .deadly:
            return Color(hex: "FF3B30").opacity(0.3)
        }
    }

    private var textColor: Color {
        switch edibility {
        case .edible, .inedible:
            return AppColors.textDark
        case .caution:
            return AppColors.caution
        case .toxic, .deadly:
            return AppColors.danger
        }
    }

    private var icon: String {
        switch edibility {
        case .edible:
            return "🍽️"
        case .inedible:
            return "🚫"
        case .caution:
            return "⚠️"
        case .toxic:
            return "☠️"
        case .deadly:
            return "💀"
        }
    }

    var body: some View {
        HStack(spacing: 8) {
            Text(icon)
                .font(.nunito(14, weight: .semibold))

            Text(edibility.displayName)
                .font(.nunito(14, weight: .semibold))
                .foregroundColor(textColor)
        }
        .padding(.horizontal, 16)
        .frame(height: 36)
        .background(backgroundColor)
        .cornerRadius(100)
    }
}

// MARK: - Convenience Initializers

extension AppBadge {
    /// Create a rarity badge
    static func rarity(_ rarity: Rarity) -> AppBadge {
        AppBadge(type: .rarity(rarity))
    }

    /// Create an edibility badge
    static func edibility(_ edibility: Edibility) -> AppBadge {
        AppBadge(type: .edibility(edibility))
    }
}

#Preview {
    VStack(spacing: 24) {
        // Rarity badges
        VStack(alignment: .leading, spacing: 12) {
            Text("Rarity Badges")
                .font(.appHeadline)
                .foregroundColor(AppColors.textDark)

            HStack(spacing: 12) {
                AppBadge.rarity(.common)
                AppBadge.rarity(.uncommon)
            }
            HStack(spacing: 12) {
                AppBadge.rarity(.rare)
                AppBadge.rarity(.legendary)
            }
        }

        Divider()

        // Edibility badges
        VStack(alignment: .leading, spacing: 12) {
            Text("Edibility Badges")
                .font(.appHeadline)
                .foregroundColor(AppColors.textDark)

            HStack(spacing: 12) {
                AppBadge.edibility(.edible)
                AppBadge.edibility(.inedible)
            }
            HStack(spacing: 12) {
                AppBadge.edibility(.caution)
                AppBadge.edibility(.toxic)
            }
            HStack(spacing: 12) {
                AppBadge.edibility(.deadly)
            }
        }
    }
    .padding(24)
    .background(AppColors.background)
}
