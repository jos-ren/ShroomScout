//
//  ReadyPageView.swift
//  ShroomScout
//
//  Fifth onboarding screen - Ready to start with completion button.
//

import SwiftUI

struct ReadyPageView: View {
    let onComplete: () -> Void

    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Content container
            VStack(spacing: 32) {
                // Excited mascot with sparkles
                ZStack {
                    // Background glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    AppColors.rarityLegendary.opacity(0.3),
                                    AppColors.rarityLegendary.opacity(0.0)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 150
                            )
                        )
                        .frame(width: 300, height: 300)
                        .scaleEffect(isAnimating ? 1.0 : 0.5)
                        .opacity(isAnimating ? 1.0 : 0.0)

                    AnimatedMascotView(expression: .excited, size: 192)
                        .scaleEffect(isAnimating ? 1.0 : 0.8)
                        .opacity(isAnimating ? 1.0 : 0.0)
                }

                // Text content
                VStack(spacing: 12) {
                    Text("Ready to explore?")
                        .font(.nunito(30, weight: .bold))
                        .foregroundColor(AppColors.textDark)
                        .multilineTextAlignment(.center)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : 20)

                    Text("Your mushroom hunting adventure awaits!")
                        .font(.nunito(18, weight: .regular))
                        .foregroundColor(AppColors.textLight)
                        .multilineTextAlignment(.center)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : 20)
                }

                // Start button
                startButton
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 30)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.5), value: isAnimating)
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

    // MARK: - Start Button

    private var startButton: some View {
        Button {
            onComplete()
        } label: {
            HStack(spacing: 8) {
                Text("Start Collecting!")
                    .font(.nunito(18, weight: .bold))
                    .foregroundColor(.white)

                Text("\u{1F344}")
                    .font(.system(size: 20))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(AppColors.coral)
            .cornerRadius(30)
            .shadow(
                color: AppColors.coral.opacity(0.4),
                radius: 15,
                x: 0,
                y: 8
            )
        }
        .buttonStyle(BounceButtonStyle())
    }
}

#Preview {
    ReadyPageView {
        print("Onboarding completed!")
    }
    .background(AppColors.background)
}
