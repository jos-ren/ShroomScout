//
//  OnboardingView.swift
//  ShroomScout
//
//  Main onboarding flow with TabView paging through 5 screens.
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]

    @State private var currentPage = 0
    @State private var hasAgreedToDisclaimer = false

    private let totalPages = 5

    var body: some View {
        ZStack {
            // Background
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Page content
                TabView(selection: $currentPage) {
                    WelcomePageView()
                        .tag(0)

                    HowItWorksPageView()
                        .tag(1)

                    CollectionPreviewPageView()
                        .tag(2)

                    SafetyDisclaimerPageView(hasAgreed: $hasAgreedToDisclaimer)
                        .tag(3)

                    ReadyPageView(onComplete: completeOnboarding)
                        .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentPage)

                // Bottom controls
                bottomControls
            }
        }
    }

    // MARK: - Bottom Controls

    private var bottomControls: some View {
        VStack(spacing: 24) {
            // Progress indicator
            ProgressIndicator(totalSteps: totalPages, currentStep: currentPage)

            // Continue button
            continueButton
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }

    @ViewBuilder
    private var continueButton: some View {
        if currentPage < totalPages - 1 {
            // Normal continue button
            let isDisabled = currentPage == 3 && !hasAgreedToDisclaimer

            AppButton("Continue", style: .secondary) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    currentPage += 1
                }
            }
            .opacity(isDisabled ? 0.5 : 1.0)
            .disabled(isDisabled)
        } else {
            // Empty spacer to maintain layout - Ready page has its own button
            Color.clear
                .frame(height: 56)
        }
    }

    // MARK: - Actions

    private func completeOnboarding() {
        // Get or create user profile
        let profile: UserProfile
        if let existingProfile = userProfiles.first {
            profile = existingProfile
        } else {
            profile = UserProfile()
            modelContext.insert(profile)
        }

        // Update profile
        profile.hasCompletedOnboarding = true
        profile.hasAgreedToDisclaimer = hasAgreedToDisclaimer

        // Save changes
        try? modelContext.save()
    }
}

#Preview {
    OnboardingView()
        .modelContainer(for: UserProfile.self, inMemory: true)
}
