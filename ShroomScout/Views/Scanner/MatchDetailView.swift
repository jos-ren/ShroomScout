//
//  MatchDetailView.swift
//  ShroomScout
//
//  Detail view shown when user selects a match from ScanResultsView.
//  Displays the species details with confidence and allows final confirmation.
//

import SwiftUI

struct MatchDetailView: View {
    let match: IdentificationMatch
    let capturedImage: UIImage

    var onConfirm: (() -> Void)?
    var onBack: (() -> Void)?

    @Environment(\.dismiss) private var dismiss

    // Animation states
    @State private var showContent = false
    @State private var checkmarkScale: CGFloat = 0.0

    var body: some View {
        ZStack(alignment: .top) {
            // Background
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header bar
                headerBar

                // Scrollable content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Captured photo with overlay
                        capturedPhotoSection

                        // Confidence indicator
                        confidenceSection

                        // Species info card
                        speciesInfoCard

                        // Key features
                        keyFeaturesSection

                        // Safety disclaimer
                        safetyDisclaimer
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 120) // Space for bottom buttons
                }

                Spacer(minLength: 0)
            }

            // Bottom action buttons
            VStack {
                Spacer()
                bottomButtons
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2)) {
                showContent = true
            }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5).delay(0.4)) {
                checkmarkScale = 1.0
            }
        }
    }

    // MARK: - Header Bar

    private var headerBar: some View {
        HStack {
            // Back button
            Button {
                onBack?()
            } label: {
                ZStack {
                    Circle()
                        .fill(AppColors.cream)
                        .frame(width: 40, height: 40)

                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.textDark)
                }
            }
            .buttonStyle(BounceButtonStyle())

            Spacer()

            Text("Confirm Match")
                .font(.nunito(20, weight: .bold))
                .foregroundColor(AppColors.textDark)

            Spacer()

            // Invisible spacer for centering
            Circle()
                .fill(.clear)
                .frame(width: 40, height: 40)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(.white)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    // MARK: - Captured Photo Section

    private var capturedPhotoSection: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: capturedImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 240)
                .frame(maxWidth: .infinity)
                .clipped()
                .cornerRadius(24)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

            // Checkmark badge
            ZStack {
                Circle()
                    .fill(AppColors.primaryGreen)
                    .frame(width: 48, height: 48)
                    .shadow(color: AppColors.primaryGreen.opacity(0.3), radius: 8, x: 0, y: 4)

                Image(systemName: "checkmark")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            .scaleEffect(checkmarkScale)
            .padding(16)
        }
        .opacity(showContent ? 1.0 : 0.0)
        .offset(y: showContent ? 0 : 20)
    }

    // MARK: - Confidence Section

    private var confidenceSection: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: confidenceIcon)
                    .font(.system(size: 24))
                    .foregroundColor(confidenceColor)

                Text(confidenceMessage)
                    .font(.nunito(22, weight: .bold))
                    .foregroundColor(AppColors.textDark)
            }

            Text("\(Int(match.confidence * 100))% confidence match")
                .font(.nunito(14, weight: .medium))
                .foregroundColor(AppColors.textLight)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .background(confidenceColor.opacity(0.1))
        .cornerRadius(16)
        .opacity(showContent ? 1.0 : 0.0)
        .offset(y: showContent ? 0 : 20)
    }

    private var confidenceIcon: String {
        if match.confidence >= 0.8 {
            return "sparkles"
        } else if match.confidence >= 0.6 {
            return "checkmark.circle.fill"
        } else {
            return "questionmark.circle.fill"
        }
    }

    private var confidenceMessage: String {
        if match.confidence >= 0.8 {
            return "Great match!"
        } else if match.confidence >= 0.6 {
            return "Good match"
        } else {
            return "Possible match"
        }
    }

    private var confidenceColor: Color {
        if match.confidence >= 0.8 {
            return AppColors.primaryGreen
        } else if match.confidence >= 0.6 {
            return AppColors.rarityUncommon
        } else {
            return AppColors.caution
        }
    }

    // MARK: - Species Info Card

    private var speciesInfoCard: some View {
        AppCard {
            HStack(spacing: 16) {
                // Thumbnail
                thumbnailView

                // Info
                VStack(alignment: .leading, spacing: 8) {
                    Text(match.species.commonName)
                        .font(.nunito(22, weight: .bold))
                        .foregroundColor(AppColors.textDark)

                    Text(match.species.scientificName)
                        .font(.nunito(14, weight: .medium))
                        .foregroundColor(AppColors.textLight)
                        .italic()

                    // Badges
                    HStack(spacing: 8) {
                        AppBadge.rarity(match.species.rarity)
                        AppBadge.edibility(match.species.edibility)
                    }
                }

                Spacer()
            }
        }
        .opacity(showContent ? 1.0 : 0.0)
        .offset(y: showContent ? 0 : 20)
    }

    private var thumbnailView: some View {
        ZStack {
            if let uiImage = UIImage(named: match.species.referenceImageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                AppColors.cream
                Text("🍄")
                    .font(.system(size: 32))
            }
        }
        .frame(width: 80, height: 80)
        .background(AppColors.cream)
        .cornerRadius(16)
        .clipped()
    }

    // MARK: - Key Features Section

    private var keyFeaturesSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Key Features")
                    .font(.nunito(18, weight: .bold))
                    .foregroundColor(AppColors.textDark)

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(identificationTips, id: \.self) { tip in
                        HStack(alignment: .top, spacing: 12) {
                            Text("\u{2022}")
                                .font(.nunito(14, weight: .regular))
                                .foregroundColor(AppColors.primaryGreen)
                                .padding(.top, 1)

                            Text(tip)
                                .font(.nunito(14, weight: .regular))
                                .foregroundColor(AppColors.textDark)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .opacity(showContent ? 1.0 : 0.0)
        .offset(y: showContent ? 0 : 20)
    }

    private var identificationTips: [String] {
        let tips = match.species.identificationTips
            .components(separatedBy: CharacterSet.newlines)
            .flatMap { $0.components(separatedBy: ". ") }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .map { $0.trimmingCharacters(in: CharacterSet(charactersIn: ".-")) }
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        return tips.isEmpty ? [match.species.identificationTips] : tips
    }

    // MARK: - Safety Disclaimer

    private var safetyDisclaimer: some View {
        WarningBanner.disclaimer(
            "Never eat wild mushrooms based on app identification alone. Always consult an expert."
        )
        .opacity(showContent ? 1.0 : 0.0)
        .offset(y: showContent ? 0 : 20)
    }

    // MARK: - Bottom Buttons

    private var bottomButtons: some View {
        HStack(spacing: 12) {
            // Go Back button
            Button {
                onBack?()
            } label: {
                Text("Go Back")
                    .font(.nunito(16, weight: .semibold))
                    .foregroundColor(AppColors.primaryGreen)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(AppColors.primaryGreen, lineWidth: 2)
                    )
                    .cornerRadius(28)
            }
            .buttonStyle(BounceButtonStyle())

            // Confirm Discovery button
            Button {
                onConfirm?()
            } label: {
                Text("Confirm Discovery")
                    .font(.nunito(16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(AppColors.coral)
                    .cornerRadius(28)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
            .buttonStyle(BounceButtonStyle())
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(.white)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -4)
    }
}

// MARK: - Preview

#Preview("High Confidence") {
    let sampleImage = UIImage(systemName: "photo.fill")!
        .withTintColor(.systemGray3, renderingMode: .alwaysOriginal)

    return MatchDetailView(
        match: IdentificationResult.mock.matches[0], // 87% confidence
        capturedImage: sampleImage,
        onConfirm: { print("Confirmed!") },
        onBack: { print("Go back") }
    )
}

#Preview("Medium Confidence") {
    let sampleImage = UIImage(systemName: "photo.fill")!
        .withTintColor(.systemGray3, renderingMode: .alwaysOriginal)

    return MatchDetailView(
        match: IdentificationResult.mock.matches[1], // 72% confidence
        capturedImage: sampleImage,
        onConfirm: { print("Confirmed!") },
        onBack: { print("Go back") }
    )
}

#Preview("Low Confidence") {
    let sampleImage = UIImage(systemName: "photo.fill")!
        .withTintColor(.systemGray3, renderingMode: .alwaysOriginal)

    return MatchDetailView(
        match: IdentificationResult.mock.matches[2], // 57% confidence
        capturedImage: sampleImage,
        onConfirm: { print("Confirmed!") },
        onBack: { print("Go back") }
    )
}
