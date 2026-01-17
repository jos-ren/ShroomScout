//
//  ProgressIndicator.swift
//  ShroomScout
//
//  Step indicator for onboarding flow with animated transitions.
//

import SwiftUI

struct ProgressIndicator: View {
    let totalSteps: Int
    let currentStep: Int

    private let dotSize: CGFloat = 8
    private let activeDotWidth: CGFloat = 32
    private let spacing: CGFloat = 8

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<totalSteps, id: \.self) { step in
                Capsule()
                    .fill(step == currentStep ? AppColors.primaryGreen : AppColors.primaryGreen.opacity(0.2))
                    .frame(
                        width: step == currentStep ? activeDotWidth : dotSize,
                        height: dotSize
                    )
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentStep)
            }
        }
    }
}

// MARK: - Interactive Demo View

/// Demo view showing the ProgressIndicator with a button to advance steps
struct ProgressIndicatorDemo: View {
    let totalSteps: Int
    @State private var currentStep: Int = 0

    var body: some View {
        VStack(spacing: 24) {
            ProgressIndicator(totalSteps: totalSteps, currentStep: currentStep)

            AppButton(buttonText, style: .secondary) {
                withAnimation {
                    if currentStep < totalSteps - 1 {
                        currentStep += 1
                    } else {
                        currentStep = 0
                    }
                }
            }
        }
    }

    private var buttonText: String {
        if currentStep < totalSteps - 1 {
            return "Continue"
        } else {
            return "Start Over"
        }
    }
}

#Preview {
    VStack(spacing: 48) {
        // Static examples
        VStack(alignment: .leading, spacing: 16) {
            Text("Static Examples")
                .font(.appHeadline)
                .foregroundColor(AppColors.textDark)

            VStack(spacing: 12) {
                HStack {
                    Text("Step 1 of 4")
                        .font(.appCaption)
                        .foregroundColor(AppColors.textLight)
                    Spacer()
                }
                ProgressIndicator(totalSteps: 4, currentStep: 0)
            }

            VStack(spacing: 12) {
                HStack {
                    Text("Step 3 of 4")
                        .font(.appCaption)
                        .foregroundColor(AppColors.textLight)
                    Spacer()
                }
                ProgressIndicator(totalSteps: 4, currentStep: 2)
            }

            VStack(spacing: 12) {
                HStack {
                    Text("Step 4 of 4")
                        .font(.appCaption)
                        .foregroundColor(AppColors.textLight)
                    Spacer()
                }
                ProgressIndicator(totalSteps: 4, currentStep: 3)
            }
        }

        Divider()

        // Interactive demo
        VStack(alignment: .leading, spacing: 16) {
            Text("Interactive Demo")
                .font(.appHeadline)
                .foregroundColor(AppColors.textDark)

            Text("Tap the button to see the animation")
                .font(.appCaption)
                .foregroundColor(AppColors.textLight)

            ProgressIndicatorDemo(totalSteps: 4)
        }
    }
    .padding(24)
    .background(AppColors.background)
}
