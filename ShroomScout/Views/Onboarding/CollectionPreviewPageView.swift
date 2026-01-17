//
//  CollectionPreviewPageView.swift
//  ShroomScout
//
//  Third onboarding screen - Shows rarity system with badges.
//

import SwiftUI

struct CollectionPreviewPageView: View {
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Content container
            VStack(spacing: 32) {
                // Excited mascot
                AnimatedMascotView(expression: .excited, size: 192)
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                    .opacity(isAnimating ? 1.0 : 0.0)

                // Text content
                VStack(spacing: 12) {
                    Text("Collect them all!")
                        .font(.nunito(30, weight: .bold))
                        .foregroundColor(AppColors.textDark)
                        .multilineTextAlignment(.center)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : 20)

                    Text("Discover common, rare, and legendary species")
                        .font(.nunito(18, weight: .regular))
                        .foregroundColor(AppColors.textLight)
                        .multilineTextAlignment(.center)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : 20)
                }

                // Rarity badges
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        rarityBadge(
                            label: "Common",
                            color: AppColors.rarityCommon,
                            delay: 0.3
                        )

                        rarityBadge(
                            label: "Uncommon",
                            color: AppColors.rarityUncommon,
                            delay: 0.4
                        )

                        rarityBadge(
                            label: "Rare",
                            color: AppColors.rarityRare,
                            delay: 0.5
                        )
                    }

                    rarityBadge(
                        label: "Legendary",
                        color: AppColors.rarityLegendary,
                        delay: 0.6
                    )
                }
                .padding(.top, 16)
            }
            .padding(.horizontal, 24)

            Spacer()
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                isAnimating = true
            }
        }
    }

    // MARK: - Rarity Badge

    private func rarityBadge(label: String, color: Color, delay: Double) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(.white)
                .frame(width: 8, height: 8)

            Text(label)
                .font(.nunito(14, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(color)
        .cornerRadius(100)
        .scaleEffect(isAnimating ? 1.0 : 0.5)
        .opacity(isAnimating ? 1.0 : 0.0)
        .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(delay), value: isAnimating)
    }
}

#Preview {
    CollectionPreviewPageView()
        .background(AppColors.background)
}
