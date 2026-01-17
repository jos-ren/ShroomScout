//
//  SafetyDisclaimerPageView.swift
//  ShroomScout
//
//  Fourth onboarding screen - Safety disclaimer with required checkbox.
//

import SwiftUI

struct SafetyDisclaimerPageView: View {
    @Binding var hasAgreed: Bool
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Content container
            VStack(spacing: 32) {
                // Cautious mascot
                MascotView(expression: .cautious, size: 192)
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                    .opacity(isAnimating ? 1.0 : 0.0)

                // Text content
                VStack(spacing: 12) {
                    Text("Safety First!")
                        .font(.nunito(30, weight: .bold))
                        .foregroundColor(AppColors.textDark)
                        .multilineTextAlignment(.center)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : 20)

                    Text("Never eat wild mushrooms based on app identification. Always consult an expert.")
                        .font(.nunito(18, weight: .regular))
                        .foregroundColor(AppColors.textLight)
                        .multilineTextAlignment(.center)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : 20)
                }

                // Warning banner
                warningCard
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 30)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.4), value: isAnimating)

                // Checkbox agreement
                agreementCheckbox
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 20)
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

    // MARK: - Warning Card

    private var warningCard: some View {
        VStack(spacing: 12) {
            // Warning icon
            Text("\u{26A0}\u{FE0F}")
                .font(.system(size: 36))

            // Warning text
            VStack(spacing: 4) {
                Text("Remember:")
                    .font(.nunito(14, weight: .bold))
                    .foregroundColor(AppColors.textDark)

                Text("This app is for fun and education only. Never consume wild mushrooms without expert verification.")
                    .font(.nunito(14, weight: .regular))
                    .foregroundColor(AppColors.textDark)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 26)
        .padding(.vertical, 26)
        .frame(maxWidth: .infinity)
        .background(AppColors.caution.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(AppColors.caution, lineWidth: 2)
        )
        .cornerRadius(24)
    }

    // MARK: - Agreement Checkbox

    private var agreementCheckbox: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                hasAgreed.toggle()
            }
        } label: {
            HStack(spacing: 12) {
                // Checkbox
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(hasAgreed ? AppColors.primaryGreen : AppColors.textLight, lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if hasAgreed {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(AppColors.primaryGreen)
                            .frame(width: 24, height: 24)

                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .scaleEffect(hasAgreed ? 1.0 : 1.0)

                // Label
                Text("I understand and agree to use this app responsibly")
                    .font(.nunito(14, weight: .medium))
                    .foregroundColor(AppColors.textDark)
                    .multilineTextAlignment(.leading)

                Spacer()
            }
            .padding(16)
            .background(hasAgreed ? AppColors.primaryGreen.opacity(0.1) : AppColors.cream)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(hasAgreed ? AppColors.primaryGreen : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var hasAgreed = false

        var body: some View {
            SafetyDisclaimerPageView(hasAgreed: $hasAgreed)
                .background(AppColors.background)
        }
    }

    return PreviewWrapper()
}
