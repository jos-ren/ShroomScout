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
    @State private var selectedRegion = "pnw"

    private let totalPages = 6

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

                    RegionSelectionPageView(selectedRegion: $selectedRegion)
                        .tag(2)

                    CollectionPreviewPageView()
                        .tag(3)

                    SafetyDisclaimerPageView(hasAgreed: $hasAgreedToDisclaimer)
                        .tag(4)

                    ReadyPageView()
                        .tag(5)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentPage)
                .onChange(of: currentPage) { oldValue, newValue in
                    // Prevent advancing past safety disclaimer without agreement
                    if newValue == 5 && !hasAgreedToDisclaimer {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            currentPage = 4
                        }
                    }
                }

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
            let isDisabled = currentPage == 4 && !hasAgreedToDisclaimer

            AppButton("Continue", style: .secondary) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    currentPage += 1
                }
            }
            .opacity(isDisabled ? 0.5 : 1.0)
            .disabled(isDisabled)
        } else {
            // Start collecting button on final page
            startCollectingButton
        }
    }

    private var startCollectingButton: some View {
        Button {
            completeOnboarding()
        } label: {
            HStack(spacing: 8) {
                Text("Start Collecting!")
                    .font(.nunito(18, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(AppColors.coral)
            .cornerRadius(28)
            .shadow(
                color: AppColors.coral.opacity(0.4),
                radius: 15,
                x: 0,
                y: 8
            )
        }
        .buttonStyle(BounceButtonStyle())
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
        profile.selectedRegion = selectedRegion

        // Save changes
        try? modelContext.save()
    }
}

#Preview {
    OnboardingView()
        .modelContainer(for: UserProfile.self, inMemory: true)
}
