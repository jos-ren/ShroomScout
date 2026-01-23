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

    enum Size {
        case regular
        case small
    }

    let type: BadgeType
    var size: Size = .regular

    var body: some View {
        switch type {
        case .rarity(let rarity):
            RarityBadgeContent(rarity: rarity, size: size)
        case .edibility(let edibility):
            EdibilityBadgeContent(edibility: edibility, size: size)
        }
    }
}

// MARK: - Badge Constants

private enum BadgeConstants {
    static func height(for size: AppBadge.Size) -> CGFloat {
        switch size {
        case .regular: return 36
        case .small: return 26
        }
    }

    static func cornerRadius(for size: AppBadge.Size) -> CGFloat {
        switch size {
        case .regular: return 12
        case .small: return 8
        }
    }

    static func shadowOffset(for size: AppBadge.Size) -> CGFloat {
        switch size {
        case .regular: return 4
        case .small: return 3
        }
    }

    static func fontSize(for size: AppBadge.Size) -> CGFloat {
        switch size {
        case .regular: return 14
        case .small: return 11
        }
    }

    static func horizontalPadding(for size: AppBadge.Size) -> CGFloat {
        switch size {
        case .regular: return 16
        case .small: return 10
        }
    }

    static func dotSize(for size: AppBadge.Size) -> CGFloat {
        switch size {
        case .regular: return 8
        case .small: return 6
        }
    }

    static func spacing(for size: AppBadge.Size) -> CGFloat {
        switch size {
        case .regular: return 8
        case .small: return 4
        }
    }
}

// MARK: - Rarity Badge

private struct RarityBadgeContent: View {
    let rarity: Rarity
    let size: AppBadge.Size

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

    private var shadowColor: Color {
        switch rarity {
        case .common:
            return Color(hex: "7A8189") // Darker gray
        case .uncommon:
            return Color(hex: "4CB896") // Darker green
        case .rare:
            return Color(hex: "5BB8E0") // Darker blue
        case .legendary:
            return Color(hex: "D4A82D") // Darker gold
        }
    }

    private var height: CGFloat { BadgeConstants.height(for: size) }
    private var cornerRadius: CGFloat { BadgeConstants.cornerRadius(for: size) }
    private var shadowOffset: CGFloat { BadgeConstants.shadowOffset(for: size) }
    private var fontSize: CGFloat { BadgeConstants.fontSize(for: size) }
    private var horizontalPadding: CGFloat { BadgeConstants.horizontalPadding(for: size) }
    private var dotSize: CGFloat { BadgeConstants.dotSize(for: size) }
    private var spacing: CGFloat { BadgeConstants.spacing(for: size) }

    var body: some View {
        ZStack {
            // Shadow layer
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(shadowColor)
                .frame(height: height)
                .offset(y: shadowOffset)

            // Main badge layer
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(backgroundColor)
                .frame(height: height)

            // Content
            HStack(spacing: spacing) {
                Circle()
                    .fill(.white)
                    .frame(width: dotSize, height: dotSize)

                Text(rarity.displayName)
                    .font(.nunito(fontSize, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, horizontalPadding)
        }
        .frame(height: height + shadowOffset)
        .fixedSize(horizontal: true, vertical: false)
    }
}

// MARK: - Edibility Badge

private struct EdibilityBadgeContent: View {
    let edibility: Edibility
    let size: AppBadge.Size

    private var backgroundColor: Color {
        switch edibility {
        case .edible:
            return AppColors.cream
        case .inedible:
            return AppColors.cream
        case .caution:
            return Color(hex: "FEEBC8") // Light orange/amber
        case .toxic:
            return Color(hex: "9B59B6") // Purple
        case .deadly:
            return Color(hex: "2D2D2D") // Near black
        }
    }

    private var shadowColor: Color {
        switch edibility {
        case .edible, .inedible:
            return Color(hex: "E0D8C7") // Darker cream
        case .caution:
            return Color(hex: "E8C896") // Darker light orange
        case .toxic:
            return Color(hex: "7D3C98") // Darker purple
        case .deadly:
            return Color(hex: "1A1A1A") // Darker black
        }
    }

    private var textColor: Color {
        switch edibility {
        case .edible, .inedible:
            return AppColors.textDark
        case .caution:
            return AppColors.caution
        case .toxic, .deadly:
            return .white
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

    private var height: CGFloat { BadgeConstants.height(for: size) }
    private var cornerRadius: CGFloat { BadgeConstants.cornerRadius(for: size) }
    private var shadowOffset: CGFloat { BadgeConstants.shadowOffset(for: size) }
    private var fontSize: CGFloat { BadgeConstants.fontSize(for: size) }
    private var horizontalPadding: CGFloat { BadgeConstants.horizontalPadding(for: size) }
    private var spacing: CGFloat { BadgeConstants.spacing(for: size) }

    var body: some View {
        ZStack {
            // Shadow layer
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(shadowColor)
                .frame(height: height)
                .offset(y: shadowOffset)

            // Main badge layer
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(backgroundColor)
                .frame(height: height)

            // Content
            HStack(spacing: spacing) {
                Text(icon)
                    .font(.nunito(fontSize, weight: .semibold))

                Text(edibility.displayName)
                    .font(.nunito(fontSize, weight: .semibold))
                    .foregroundColor(textColor)
            }
            .padding(.horizontal, horizontalPadding)
        }
        .frame(height: height + shadowOffset)
        .fixedSize(horizontal: true, vertical: false)
    }
}

// MARK: - Convenience Initializers

extension AppBadge {
    /// Create a rarity badge
    static func rarity(_ rarity: Rarity, size: Size = .regular) -> AppBadge {
        AppBadge(type: .rarity(rarity), size: size)
    }

    /// Create an edibility badge
    static func edibility(_ edibility: Edibility, size: Size = .regular) -> AppBadge {
        AppBadge(type: .edibility(edibility), size: size)
    }
}

#Preview {
    VStack(spacing: 24) {
        // Regular size rarity badges
        VStack(alignment: .leading, spacing: 12) {
            Text("Rarity Badges (Regular)")
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

        // Small size rarity badges
        VStack(alignment: .leading, spacing: 12) {
            Text("Rarity Badges (Small)")
                .font(.appHeadline)
                .foregroundColor(AppColors.textDark)

            HStack(spacing: 8) {
                AppBadge.rarity(.common, size: .small)
                AppBadge.rarity(.uncommon, size: .small)
                AppBadge.rarity(.rare, size: .small)
                AppBadge.rarity(.legendary, size: .small)
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
