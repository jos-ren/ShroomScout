//
//  HowItWorksPageView.swift
//  ShroomScout
//
//  Second onboarding screen - Shows Scan, Identify, Collect flow.
//

import SwiftUI

struct HowItWorksPageView: View {
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Content container
            VStack(spacing: 32) {
                // Curious mascot
                MascotView(expression: .curious, size: 192)
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                    .opacity(isAnimating ? 1.0 : 0.0)

                // Text content
                VStack(spacing: 12) {
                    Text("Scan & Discover")
                        .font(.nunito(30, weight: .bold))
                        .foregroundColor(AppColors.textDark)
                        .multilineTextAlignment(.center)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : 20)

                    Text("Find mushrooms in the wild and identify them instantly")
                        .font(.nunito(18, weight: .regular))
                        .foregroundColor(AppColors.textLight)
                        .multilineTextAlignment(.center)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : 20)
                }

                // Step icons
                HStack(spacing: 32) {
                    stepItem(
                        icon: "camera.fill",
                        label: "Scan",
                        delay: 0.3
                    )

                    stepItem(
                        icon: "magnifyingglass",
                        label: "Identify",
                        delay: 0.4
                    )

                    stepItem(
                        icon: "square.grid.2x2.fill",
                        label: "Collect",
                        delay: 0.5
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

    // MARK: - Step Item

    private func stepItem(icon: String, label: String, delay: Double) -> some View {
        VStack(spacing: 8) {
            // Icon container
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.cream)
                    .frame(width: 64, height: 64)

                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(AppColors.primaryGreen)
            }
            .scaleEffect(isAnimating ? 1.0 : 0.5)
            .opacity(isAnimating ? 1.0 : 0.0)
            .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(delay), value: isAnimating)

            // Label
            Text(label)
                .font(.nunito(14, weight: .semibold))
                .foregroundColor(AppColors.textDark)
                .opacity(isAnimating ? 1.0 : 0.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(delay + 0.1), value: isAnimating)
        }
    }
}

#Preview {
    HowItWorksPageView()
        .background(AppColors.background)
}
