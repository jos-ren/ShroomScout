//
//  SpeciesDetailView.swift
//  ShroomScout
//
//  Detail view for a mushroom species showing all information,
//  user sightings, and safety warnings.
//

import SwiftUI
import SwiftData

struct SpeciesDetailView: View {
    let species: Species
    let userSightings: [Sighting]
    var onNavigateToLocation: ((Double, Double) -> Void)?

    @Environment(\.dismiss) private var dismiss

    // Hero image height
    private let heroImageHeight: CGFloat = 320
    private let overlayCardOffset: CGFloat = -48

    var body: some View {
        ZStack(alignment: .top) {
            // Background
            AppColors.background
                .ignoresSafeArea()

            // Scrollable content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Hero image section
                    heroImageSection

                    // Content cards
                    VStack(spacing: 24) {
                        // Title section (overlapping hero)
                        titleSection
                            .offset(y: overlayCardOffset)

                        // Safety disclaimer (right below title)
                        safetyDisclaimer
                            .offset(y: overlayCardOffset)

                        // Main content with negative margin to account for title offset
                        VStack(spacing: 24) {
                            // User sightings (only if user has found this species)
                            if !userSightings.isEmpty {
                                SightingsRow(
                                    sightings: userSightings,
                                    speciesName: species.commonName,
                                    onNavigateToLocation: { lat, lon in
                                        dismiss()
                                        onNavigateToLocation?(lat, lon)
                                    }
                                )
                            }

                            // Quick facts
                            QuickFactsCard(
                                edibility: species.edibility,
                                seasons: species.season,
                                habitat: species.habitat
                            )

                            // About section
                            aboutSection

                            // How to identify section
                            identificationSection

                            // Lookalikes warning (only if species has lookalikes)
                            if !species.lookalikes.isEmpty {
                                LookalikesCard(lookalikes: species.lookalikes)
                            }
                        }
                        .offset(y: overlayCardOffset)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            .ignoresSafeArea(edges: .top)

            // Floating navigation buttons
            floatingButtons
        }
        .navigationBarHidden(true)
    }

    // MARK: - Hero Image Section

    private var heroImageSection: some View {
        ZStack(alignment: .bottom) {
            // Background image
            GeometryReader { geometry in
                ZStack {
                    // Reference image or placeholder
                    if let image = UIImage(named: species.referenceImageName) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: heroImageHeight)
                            .clipped()
                    } else {
                        // Placeholder
                        Rectangle()
                            .fill(AppColors.cream)
                            .frame(width: geometry.size.width, height: heroImageHeight)
                            .overlay(
                                VStack(spacing: 12) {
                                    Image(systemName: "photo")
                                        .font(.system(size: 48))
                                        .foregroundColor(AppColors.textLight)
                                    Text(species.commonName)
                                        .font(.nunito(16, weight: .medium))
                                        .foregroundColor(AppColors.textLight)
                                }
                            )
                    }

                    // Gradient overlay
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.6),
                            Color.black.opacity(0),
                            Color.black.opacity(0)
                        ]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                }
            }
            .frame(height: heroImageHeight)
        }
    }

    // MARK: - Title Section

    private var titleSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 8) {
                // Common name
                Text(species.commonName)
                    .font(.nunito(30, weight: .bold))
                    .foregroundColor(AppColors.textDark)

                // Scientific name
                Text(species.scientificName)
                    .font(.nunito(18, weight: .regular))
                    .foregroundColor(AppColors.textLight)
                    .italic()

                // Badges
                HStack(spacing: 12) {
                    AppBadge.rarity(species.rarity)
                    AppBadge.edibility(species.edibility)
                }
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("About")
                    .font(.nunito(18, weight: .bold))
                    .foregroundColor(AppColors.textDark)

                Text(species.speciesDescription)
                    .font(.nunito(16, weight: .regular))
                    .foregroundColor(AppColors.textDark)
                    .lineSpacing(6)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Identification Section

    private var identificationSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("How to Identify")
                    .font(.nunito(18, weight: .bold))
                    .foregroundColor(AppColors.textDark)

                // Parse identification tips into bullet points
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(identificationTips, id: \.self) { tip in
                        IdentificationTipRow(tip: tip)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var identificationTips: [String] {
        // Split tips by newlines or common delimiters
        let tips = species.identificationTips
            .components(separatedBy: CharacterSet.newlines)
            .flatMap { $0.components(separatedBy: ". ") }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .map { $0.trimmingCharacters(in: CharacterSet(charactersIn: ".-")) }
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        return tips.isEmpty ? [species.identificationTips] : tips
    }

    // MARK: - Safety Disclaimer

    private var safetyDisclaimer: some View {
        WarningBanner.disclaimer(
            "Never eat wild mushrooms based on app identification alone. Always consult an expert mycologist."
        )
    }

    // MARK: - Floating Buttons

    private var floatingButtons: some View {
        HStack {
            // Back button
            FloatingButton(systemImage: "chevron.left") {
                dismiss()
            }

            Spacer()

            // Share button
            FloatingButton(systemImage: "square.and.arrow.up") {
                shareSpecies()
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }

    // MARK: - Actions

    private func shareSpecies() {
        let text = "Check out the \(species.commonName) (\(species.scientificName)) on ShroomScout!"
        let activityController = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            rootViewController.present(activityController, animated: true)
        }
    }
}

// MARK: - Identification Tip Row

private struct IdentificationTipRow: View {
    let tip: String

    var body: some View {
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

// MARK: - Floating Button

private struct FloatingButton: View {
    let systemImage: String
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.black.opacity(0.4))
                    .frame(width: 40, height: 40)

                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(BounceButtonStyle())
    }
}

// MARK: - Preview

#Preview("With Sightings") {
    let species = Species(
        id: "chanterelle",
        commonName: "Golden Chanterelle",
        scientificName: "Cantharellus cibarius",
        speciesDescription: "The golden chanterelle is a highly prized edible mushroom. Its vibrant golden-yellow color and distinctive trumpet shape make it easy to spot. Known for its fruity aroma reminiscent of apricots and peppery taste.",
        rarity: .uncommon,
        edibility: .edible,
        season: [.summer, .fall],
        habitat: "Conifer forests, mossy areas",
        identificationTips: "Bright golden-yellow color. Ridges instead of true gills. Forked, blunt-edged ridges running down the stem. Fruity apricot smell. Solid white flesh inside.",
        lookalikes: ["false-chanterelle", "jack-o-lantern"],
        region: "pnw",
        referenceImageName: "chanterelle_ref"
    )

    let sightings = [
        Sighting(
            speciesID: "chanterelle",
            photoFileName: "photo1.jpg",
            latitude: 47.6062,
            longitude: -122.3321
        ),
        Sighting(
            speciesID: "chanterelle",
            photoFileName: "photo2.jpg",
            latitude: 47.6062,
            longitude: -122.3321
        )
    ]

    return SpeciesDetailView(species: species, userSightings: sightings)
}

#Preview("Without Sightings") {
    let species = Species(
        id: "morel",
        commonName: "Yellow Morel",
        scientificName: "Morchella esculenta",
        speciesDescription: "The yellow morel is one of the most sought-after wild mushrooms. Its distinctive honeycomb appearance and earthy, nutty flavor make it a culinary treasure. They emerge in spring, often near dead or dying trees.",
        rarity: .rare,
        edibility: .edible,
        season: [.spring],
        habitat: "Disturbed areas, burned forests, near elm and ash trees",
        identificationTips: "Honeycomb-like cap with ridges and pits. Cap is attached to the stem at the base. Completely hollow inside from tip to bottom. Light brown to yellowish color.",
        lookalikes: ["false-morel"],
        region: "pnw",
        referenceImageName: "morel_ref"
    )

    return SpeciesDetailView(species: species, userSightings: [])
}

#Preview("No Lookalikes") {
    let species = Species(
        id: "chicken-of-woods",
        commonName: "Chicken of the Woods",
        scientificName: "Laetiporus sulphureus",
        speciesDescription: "This striking bracket fungus gets its name from its texture when cooked, which resembles chicken. The bright orange and yellow colors make it unmistakable in the forest.",
        rarity: .uncommon,
        edibility: .edible,
        season: [.summer, .fall],
        habitat: "On dead or dying hardwood trees, especially oak",
        identificationTips: "Bright orange and yellow shelf-like brackets. No gills - pore surface underneath. Grows in overlapping clusters. Soft and moist when young.",
        lookalikes: [],
        region: "pnw",
        referenceImageName: "chicken_ref"
    )

    return SpeciesDetailView(species: species, userSightings: [])
}
