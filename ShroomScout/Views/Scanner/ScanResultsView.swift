//
//  ScanResultsView.swift
//  ShroomScout
//
//  Displays AI identification results with multiple possible matches.
//  User selects the correct match before adding to collection.
//

import SwiftUI

/// A single identification match result
struct IdentificationMatch: Identifiable, Equatable {
    let id = UUID()
    let species: Species
    let confidence: Double

    var confidenceText: String {
        "\(Int(confidence * 100))%"
    }

    static func == (lhs: IdentificationMatch, rhs: IdentificationMatch) -> Bool {
        lhs.id == rhs.id
    }
}

/// Container for all identification results
struct IdentificationResult: Identifiable {
    let id = UUID()
    let matches: [IdentificationMatch]

    /// Mock data for previews and testing (9 matches total)
    static var mock: IdentificationResult {
        IdentificationResult(matches: [
            // First 3 (highest confidence)
            IdentificationMatch(
                species: Species(
                    id: "golden-chanterelle",
                    commonName: "Golden Chanterelle",
                    scientificName: "Cantharellus cibarius",
                    speciesDescription: "A highly prized edible mushroom with a golden-yellow color.",
                    rarity: .uncommon,
                    edibility: .edible,
                    season: [.summer, .fall],
                    habitat: "Conifer and hardwood forests",
                    identificationTips: "Golden-yellow color. Forked ridges instead of true gills.",
                    lookalikes: ["false-chanterelle"],
                    region: "pnw",
                    referenceImageName: "golden-chanterelle"
                ),
                confidence: 0.87
            ),
            IdentificationMatch(
                species: Species(
                    id: "black-morel",
                    commonName: "Black Morel",
                    scientificName: "Morchella elata",
                    speciesDescription: "A highly sought-after edible mushroom with a honeycomb cap.",
                    rarity: .rare,
                    edibility: .edible,
                    season: [.spring],
                    habitat: "Burned areas, disturbed soil, near dying trees",
                    identificationTips: "Honeycomb-like cap. Hollow inside from top to bottom.",
                    lookalikes: ["false-morel"],
                    region: "pnw",
                    referenceImageName: "black-morel"
                ),
                confidence: 0.72
            ),
            IdentificationMatch(
                species: Species(
                    id: "oyster-mushroom",
                    commonName: "Oyster Mushroom",
                    scientificName: "Pleurotus ostreatus",
                    speciesDescription: "A common edible mushroom that grows on dead or dying trees.",
                    rarity: .common,
                    edibility: .edible,
                    season: [.fall, .winter],
                    habitat: "Dead or dying hardwood trees",
                    identificationTips: "Fan or oyster-shaped cap. White to cream colored. Grows in clusters.",
                    lookalikes: [],
                    region: "pnw",
                    referenceImageName: "oyster-mushroom"
                ),
                confidence: 0.57
            ),
            // Second 3 (medium confidence)
            IdentificationMatch(
                species: Species(
                    id: "lions-mane",
                    commonName: "Lion's Mane",
                    scientificName: "Hericium erinaceus",
                    speciesDescription: "A distinctive white mushroom with cascading icicle-like spines.",
                    rarity: .rare,
                    edibility: .edible,
                    season: [.fall],
                    habitat: "Dead or dying hardwood trees",
                    identificationTips: "White, shaggy appearance. No cap - just hanging spines. Grows on hardwoods.",
                    lookalikes: [],
                    region: "pnw",
                    referenceImageName: "lions-mane"
                ),
                confidence: 0.45
            ),
            IdentificationMatch(
                species: Species(
                    id: "chicken-of-woods",
                    commonName: "Chicken of the Woods",
                    scientificName: "Laetiporus sulphureus",
                    speciesDescription: "A bright orange and yellow bracket fungus with a meaty texture.",
                    rarity: .uncommon,
                    edibility: .edible,
                    season: [.summer, .fall],
                    habitat: "Dead or dying oak and other hardwoods",
                    identificationTips: "Bright orange-yellow color. Shelf-like growth. No gills.",
                    lookalikes: [],
                    region: "pnw",
                    referenceImageName: "chicken-of-woods"
                ),
                confidence: 0.38
            ),
            IdentificationMatch(
                species: Species(
                    id: "king-bolete",
                    commonName: "King Bolete",
                    scientificName: "Boletus edulis",
                    speciesDescription: "A prized edible mushroom with a brown cap and thick white stem.",
                    rarity: .rare,
                    edibility: .edible,
                    season: [.fall],
                    habitat: "Conifer and hardwood forests",
                    identificationTips: "Brown cap. White pores underneath. Thick bulbous stem.",
                    lookalikes: [],
                    region: "pnw",
                    referenceImageName: "king-bolete"
                ),
                confidence: 0.31
            ),
            // Third 3 (lower confidence)
            IdentificationMatch(
                species: Species(
                    id: "matsutake",
                    commonName: "Matsutake",
                    scientificName: "Tricholoma matsutake",
                    speciesDescription: "A highly valued mushroom with a distinctive spicy-aromatic odor.",
                    rarity: .legendary,
                    edibility: .edible,
                    season: [.fall],
                    habitat: "Under pine and fir trees in sandy soil",
                    identificationTips: "White to brown cap. Strong cinnamon-like smell. Partial veil.",
                    lookalikes: [],
                    region: "pnw",
                    referenceImageName: "matsutake"
                ),
                confidence: 0.24
            ),
            IdentificationMatch(
                species: Species(
                    id: "shaggy-mane",
                    commonName: "Shaggy Mane",
                    scientificName: "Coprinus comatus",
                    speciesDescription: "A distinctive mushroom that dissolves into black ink as it matures.",
                    rarity: .common,
                    edibility: .edible,
                    season: [.fall],
                    habitat: "Lawns, meadows, disturbed areas",
                    identificationTips: "Tall cylindrical cap with shaggy scales. Turns to ink when mature.",
                    lookalikes: [],
                    region: "pnw",
                    referenceImageName: "shaggy-mane"
                ),
                confidence: 0.18
            ),
            IdentificationMatch(
                species: Species(
                    id: "hedgehog-mushroom",
                    commonName: "Hedgehog Mushroom",
                    scientificName: "Hydnum repandum",
                    speciesDescription: "An edible mushroom with tooth-like spines instead of gills.",
                    rarity: .uncommon,
                    edibility: .edible,
                    season: [.fall, .winter],
                    habitat: "Conifer and hardwood forests",
                    identificationTips: "Pale orange cap. Spines underneath instead of gills. Brittle texture.",
                    lookalikes: [],
                    region: "pnw",
                    referenceImageName: "hedgehog-mushroom"
                ),
                confidence: 0.12
            )
        ])
    }
}

struct ScanResultsView: View {
    // MARK: - Properties

    let capturedImage: UIImage
    let identificationResult: IdentificationResult

    var onConfirmDiscovery: ((IdentificationMatch) -> Void)?
    var onTryAgain: (() -> Void)?

    @Environment(\.dismiss) private var dismiss
    @State private var visibleMatchCount: Int = 3

    private let maxMatches = 9
    private let batchSize = 3

    /// The matches currently visible to the user
    private var visibleMatches: [IdentificationMatch] {
        Array(identificationResult.matches.prefix(visibleMatchCount))
    }

    /// Whether there are more matches to show
    private var hasMoreMatches: Bool {
        visibleMatchCount < min(identificationResult.matches.count, maxMatches)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Background
                AppColors.background
                    .ignoresSafeArea()

                // Scrollable content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Captured photo
                        capturedPhotoSection

                        // Warning banner
                        warningBanner

                        // Possible matches section
                        matchesSection

                        // None of these button
                        noneOfTheseButton
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 100) // Space for bottom button
                }

                // Bottom action button
                bottomButton
            }
            .navigationTitle("Scan Results")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.textDark)
                    }
                }
            }
        }
    }

    // MARK: - Captured Photo Section

    private var capturedPhotoSection: some View {
        Image(uiImage: capturedImage)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 192)
            .frame(maxWidth: .infinity)
            .clipped()
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }

    // MARK: - Warning Banner

    private var warningBanner: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 16))
                .foregroundColor(AppColors.caution)
                .padding(.top, 2)

            Text("Accuracy depends on photo quality. Better lighting and angles give more reliable results.")
                .font(.nunito(13, weight: .medium))
                .foregroundColor(AppColors.textDark)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.caution.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.caution.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(16)
    }

    // MARK: - Matches Section

    private var matchesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Possible Matches")
                .font(.nunito(18, weight: .bold))
                .foregroundColor(AppColors.textDark)

            VStack(spacing: 12) {
                ForEach(visibleMatches) { match in
                    MatchCard(
                        match: match,
                        onTap: {
                            // Navigate directly to match detail
                            onConfirmDiscovery?(match)
                        }
                    )
                }
            }
        }
    }

    // MARK: - None of These Button

    @ViewBuilder
    private var noneOfTheseButton: some View {
        if hasMoreMatches {
            // Show more matches button
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    visibleMatchCount = min(visibleMatchCount + batchSize, maxMatches)
                }
            } label: {
                Text("None of these look right. Show more")
                    .font(.nunito(14, weight: .semibold))
                    .foregroundColor(AppColors.primaryGreen)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
        } else {
            // No more matches to show
            Text("No more suggestions available")
                .font(.nunito(14, weight: .medium))
                .foregroundColor(AppColors.textLight)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
    }

    // MARK: - Bottom Button

    private var bottomButton: some View {
        Button {
            onTryAgain?()
        } label: {
            Text("Retake Photo")
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
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(.white)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -4)
    }
}

// MARK: - Match Card

struct MatchCard: View {
    let match: IdentificationMatch
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Thumbnail
                thumbnailView

                // Info
                VStack(alignment: .leading, spacing: 8) {
                    // Top row: name and confidence
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(match.species.commonName)
                                .font(.nunito(18, weight: .bold))
                                .foregroundColor(AppColors.textDark)
                                .lineLimit(1)

                            Text(match.species.scientificName)
                                .font(.nunito(14, weight: .semibold))
                                .foregroundColor(AppColors.textLight)
                                .italic()
                                .lineLimit(1)
                        }

                        Spacer()

                        // Confidence and chevron
                        HStack(spacing: 12) {
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(match.confidenceText)
                                    .font(.nunito(18, weight: .bold))
                                    .foregroundColor(AppColors.primaryGreen)

                                Text("match")
                                    .font(.nunito(12, weight: .semibold))
                                    .foregroundColor(AppColors.textLight)
                            }

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppColors.textLight)
                        }
                    }

                    // Badges
                    HStack(spacing: 8) {
                        AppBadge.rarity(match.species.rarity)
                        AppBadge.edibility(match.species.edibility)
                    }
                }
            }
            .padding(16)
            .background(.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(BounceButtonStyle())
    }

    private var thumbnailView: some View {
        ZStack {
            // Try to load image from assets
            if let uiImage = UIImage(named: match.species.referenceImageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                // Placeholder
                AppColors.cream
                Text("🍄")
                    .font(.system(size: 32))
            }
        }
        .frame(width: 80, height: 80)
        .background(AppColors.cream)
        .cornerRadius(20)
        .clipped()
    }
}

// MARK: - Preview

#Preview("Scan Results") {
    let sampleImage = UIImage(systemName: "photo.fill")!
        .withTintColor(.systemGray3, renderingMode: .alwaysOriginal)

    return ScanResultsView(
        capturedImage: sampleImage,
        identificationResult: .mock,
        onConfirmDiscovery: { match in
            print("Confirmed: \(match.species.commonName)")
        },
        onTryAgain: {
            print("Try again")
        }
    )
}

#Preview("With Selection") {
    let sampleImage = UIImage(systemName: "photo.fill")!
        .withTintColor(.systemGray3, renderingMode: .alwaysOriginal)

    return ScanResultsView(
        capturedImage: sampleImage,
        identificationResult: .mock,
        onConfirmDiscovery: { match in
            print("Confirmed: \(match.species.commonName)")
        },
        onTryAgain: {
            print("Try again")
        }
    )
}
