//
//  AppCard.swift
//  ShroomScout
//
//  Reusable card wrapper with white background, rounded corners, and shadow.
//

import SwiftUI

struct AppCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(24)
            .background(.white)
            .cornerRadius(24)
            .shadow(
                color: .black.opacity(0.1),
                radius: 7.5,
                x: 0,
                y: 5
            )
    }
}

#Preview {
    VStack(spacing: 24) {
        // Simple text content
        AppCard {
            Text("Simple Card")
                .font(.appHeadline)
                .foregroundColor(AppColors.textDark)
        }

        // Species card example
        AppCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Golden Chanterelle")
                    .font(.nunito(30, weight: .bold))
                    .foregroundColor(AppColors.textDark)

                Text("Cantharellus cibarius")
                    .font(.nunito(18, weight: .regular))
                    .foregroundColor(AppColors.textLight)

                HStack(spacing: 12) {
                    // Rarity badge placeholder
                    HStack(spacing: 8) {
                        Circle()
                            .fill(AppColors.rarityUncommon)
                            .frame(width: 8, height: 8)
                        Text("Uncommon")
                            .font(.nunito(14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AppColors.rarityUncommon)
                    .cornerRadius(100)

                    // Edibility badge placeholder
                    HStack(spacing: 8) {
                        Text("🍽️")
                            .font(.nunito(14, weight: .semibold))
                        Text("Edible")
                            .font(.nunito(14, weight: .semibold))
                            .foregroundColor(AppColors.textDark)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AppColors.cream)
                    .cornerRadius(100)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }

        // Quick facts card example
        AppCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Quick Facts")
                    .font(.nunito(18, weight: .bold))
                    .foregroundColor(AppColors.textDark)

                VStack(spacing: 16) {
                    factRow(icon: "🍽️", label: "Edibility", value: "Edible")
                    factRow(icon: "📅", label: "Season", value: "Summer through Fall")
                    factRow(icon: "🌲", label: "Habitat", value: "Conifer forests, mossy areas")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    .padding(24)
    .background(AppColors.background)
}

// Helper for preview
@ViewBuilder
private func factRow(icon: String, label: String, value: String) -> some View {
    HStack(spacing: 12) {
        Text(icon)
            .font(.nunito(20, weight: .regular))
            .frame(width: 40, height: 40)
            .background(AppColors.cream)
            .cornerRadius(100)

        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.nunito(14, weight: .semibold))
                .foregroundColor(AppColors.textDark)
            Text(value)
                .font(.nunito(14, weight: .regular))
                .foregroundColor(AppColors.textLight)
        }
    }
}
