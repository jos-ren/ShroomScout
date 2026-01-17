//
//  UndiscoveredSpeciesDetailView.swift
//  ShroomScout
//
//  Detail view for undiscovered mushroom species with limited info.
//  Shows where to find it and encourages scanning to discover.
//

import SwiftUI

struct UndiscoveredSpeciesDetailView: View {
    let species: SampleSpecies
    var onStartScanning: (() -> Void)?

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .top) {
            // Background
            AppColors.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Hero section with mystery vibe
                    heroSection

                    // Content
                    VStack(spacing: 24) {
                        // Title card
                        titleCard
                            .offset(y: -48)

                        // Main content
                        VStack(spacing: 24) {
                            // Ready to discover prompt
                            discoverPromptCard

                            // Where to find
                            whereToFindCard

                            // About (locked)
                            aboutLockedCard

                            // Start scanning button
                            AppButton("Start Scanning", style: .primary) {
                                onStartScanning?()
                                dismiss()
                            }
                        }
                        .offset(y: -48)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            .ignoresSafeArea(edges: .top)

            // Back button
            floatingBackButton
        }
        .navigationBarHidden(true)
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    AppColors.primaryGreen.opacity(0.2),
                    AppColors.cream,
                    AppColors.primaryGreen.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 320)

            // Large faded mushroom emoji
            Text("🍄")
                .font(.system(size: 128))
                .opacity(0.1)

            // Sparkles
            VStack {
                HStack {
                    Spacer()
                    Text("✨")
                        .font(.system(size: 36))
                        .opacity(0.4)
                        .offset(x: -40, y: 40)
                }

                Spacer()

                HStack {
                    Text("✨")
                        .font(.system(size: 30))
                        .opacity(0.35)
                        .offset(x: 40, y: -20)
                    Spacer()
                }
            }
            .frame(height: 320)

            // Not Discovered badge
            VStack {
                HStack {
                    Spacer()

                    HStack(spacing: 8) {
                        Text("Not Discovered")
                            .font(.nunito(14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.4))
                    .cornerRadius(100)
                    .padding(.trailing, 16)
                    .padding(.top, 16)
                }

                Spacer()
            }
            .frame(height: 320)
        }
    }

    // MARK: - Title Card

    private var titleCard: some View {
        AppCard {
            HStack(spacing: 16) {
                // Mascot
                MascotView(expression: .curious, size: 128)

                // Info
                VStack(alignment: .leading, spacing: 8) {
                    Text(species.commonName)
                        .font(.nunito(30, weight: .bold))
                        .foregroundColor(AppColors.textDark)

                    Text("Unknown species")
                        .font(.nunito(18, weight: .regular))
                        .foregroundColor(AppColors.textLight)

                    // Rarity badge
                    AppBadge.rarity(species.rarity)
                        .padding(.top, 8)
                }

                Spacer()
            }
        }
    }

    // MARK: - Discover Prompt Card

    private var discoverPromptCard: some View {
        VStack(spacing: 12) {
            Text("Ready to discover?")
                .font(.nunito(14, weight: .bold))
                .foregroundColor(AppColors.textDark)

            Text("Head to the locations below and use the camera to scan and identify this mushroom!")
                .font(.nunito(14, weight: .regular))
                .foregroundColor(AppColors.textDark)
                .multilineTextAlignment(.center)
        }
        .padding(21)
        .frame(maxWidth: .infinity)
        .background(AppColors.primaryGreen.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(AppColors.primaryGreen.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(24)
    }

    // MARK: - Where to Find Card

    private var whereToFindCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack(spacing: 8) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.primaryGreen)

                    Text("Where to Find")
                        .font(.nunito(18, weight: .bold))
                        .foregroundColor(AppColors.textDark)
                }

                // Habitat
                infoRow(icon: "leaf.fill", title: "Habitat", value: species.habitat)

                // Season
                infoRow(
                    icon: "calendar",
                    title: "Best Season",
                    value: species.season.map { $0.displayName }.joined(separator: ", ")
                )
            }
        }
    }

    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            // Icon circle
            ZStack {
                Circle()
                    .fill(AppColors.cream)
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.primaryGreen)
            }

            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.nunito(14, weight: .semibold))
                    .foregroundColor(AppColors.textDark)

                Text(value)
                    .font(.nunito(14, weight: .regular))
                    .foregroundColor(AppColors.textLight)
            }

            Spacer()
        }
    }

    // MARK: - About Locked Card

    private var aboutLockedCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("About")
                    .font(.nunito(18, weight: .bold))
                    .foregroundColor(AppColors.textDark)

                Text("This species has not been discovered yet.")
                    .font(.nunito(16, weight: .regular))
                    .foregroundColor(AppColors.textDark)

                // Divider
                Rectangle()
                    .fill(AppColors.cream)
                    .frame(height: 1)
                    .padding(.top, 4)

                // Unlock message
                Text("Discover this mushroom to unlock full details, identification tips, and more! 🔓")
                    .font(.nunito(14, weight: .regular))
                    .foregroundColor(AppColors.textLight)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Floating Back Button

    private var floatingBackButton: some View {
        HStack {
            Button(action: { dismiss() }) {
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.4))
                        .frame(width: 40, height: 40)

                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(BounceButtonStyle())
            .padding(.leading, 16)
            .padding(.top, 16)

            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    UndiscoveredSpeciesDetailView(
        species: SampleData.flyAgaric
    )
}
