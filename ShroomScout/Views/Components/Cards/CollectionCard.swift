//
//  CollectionCard.swift
//  ShroomScout
//
//  Collection grid card showing discovered/undiscovered mushroom species.
//  Designed for 3-wide grid layout.
//

import SwiftUI

struct CollectionCard: View {
    let name: String
    let rarity: Rarity
    let isDiscovered: Bool
    var imageName: String? = nil  // Asset catalog image name
    var imageURL: URL? = nil      // Remote image URL
    var onTap: (() -> Void)? = nil

    // Card dimensions for 3-wide grid
    private let cardHeight: CGFloat = 140
    private let imageHeight: CGFloat = 100

    var body: some View {
        Button(action: { onTap?() }) {
            VStack(spacing: 0) {
                // Image/Placeholder area
                imageArea
                    .frame(height: imageHeight)

                // Info area - just the name
                infoArea
            }
            .frame(height: cardHeight)
            .background(.white)
            .cornerRadius(20)
            .shadow(
                color: .black.opacity(0.1),
                radius: 3,
                x: 0,
                y: 2
            )
        }
        .buttonStyle(CollectionCardButtonStyle())
    }

    /// Convenience initializer using SampleSpecies
    init(species: SampleSpecies, onTap: (() -> Void)? = nil) {
        self.name = species.commonName
        self.rarity = species.rarity
        self.isDiscovered = species.isDiscovered
        self.imageName = species.imageName
        self.imageURL = nil
        self.onTap = onTap
    }

    /// Standard initializer
    init(
        name: String,
        rarity: Rarity,
        isDiscovered: Bool,
        imageName: String? = nil,
        imageURL: URL? = nil,
        onTap: (() -> Void)? = nil
    ) {
        self.name = name
        self.rarity = rarity
        self.isDiscovered = isDiscovered
        self.imageName = imageName
        self.imageURL = imageURL
        self.onTap = onTap
    }

    // MARK: - Image Area

    @ViewBuilder
    private var imageArea: some View {
        if isDiscovered {
            // Discovered: Show image with rarity badge
            GeometryReader { geometry in
                ZStack {
                    // Image from asset, URL, or placeholder
                    if let imageName = imageName {
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                    } else if let imageURL = imageURL {
                        AsyncImage(url: imageURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                        } placeholder: {
                            discoveredPlaceholder
                        }
                        .clipped()
                    } else {
                        discoveredPlaceholder
                    }

                    // Rarity badge overlay
                    rarityBadgeOverlay
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .background(AppColors.cream)
        } else {
            // Undiscovered: Gradient with faded emoji and ?
            ZStack {
                // Gradient background
                LinearGradient(
                    colors: [AppColors.cream, Color(hex: "F3F4F6")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // Faded mushroom emoji
                Text("🍄")
                    .font(.system(size: imageHeight * 0.5))
                    .opacity(0.1)

                // Question mark overlay
                Text("?")
                    .font(.nunito(28, weight: .bold))
                    .foregroundColor(AppColors.textLight.opacity(0.5))

                // Rarity badge overlay
                rarityBadgeOverlay
            }
        }
    }

    private var rarityBadgeOverlay: some View {
        VStack {
            HStack {
                Spacer()
                rarityBadge
            }
            Spacer()
        }
        .padding(8)
    }

    private var discoveredPlaceholder: some View {
        ZStack {
            AppColors.cream
            Text("🍄")
                .font(.system(size: imageHeight * 0.45))
        }
    }

    private var rarityBadge: some View {
        Circle()
            .fill(rarityColor)
            .frame(width: 14, height: 14)
            .overlay(
                Circle()
                    .stroke(.white, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
    }

    // MARK: - Info Area

    private var infoArea: some View {
        Text(name)
            .font(.nunito(13, weight: .bold))
            .foregroundColor(isDiscovered ? AppColors.textDark : AppColors.textLight)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    // MARK: - Rarity Color

    private var rarityColor: Color {
        let baseColor: Color = {
            switch rarity {
            case .common:
                return AppColors.rarityCommon
            case .uncommon:
                return AppColors.rarityUncommon
            case .rare:
                return AppColors.rarityRare
            case .legendary:
                return AppColors.rarityLegendary
            }
        }()

        if isDiscovered {
            return baseColor
        } else {
            return baseColor.opacity(0.4)
        }
    }
}

// MARK: - Button Style

private struct CollectionCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Collection Grid Helper

struct CollectionGrid<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            content
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 24) {
            Text("Collection Cards")
                .font(.appTitle)
                .foregroundColor(AppColors.textDark)

            // Debug: Test if asset images load
            VStack(alignment: .leading, spacing: 12) {
                Text("Asset Test")
                    .font(.appHeadline)
                    .foregroundColor(AppColors.textDark)

                HStack(spacing: 8) {
                    ForEach(SampleData.allSpecies) { species in
                        Image(species.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }

            // Mixed discovered/undiscovered with real mushrooms
            VStack(alignment: .leading, spacing: 12) {
                Text("Sample Mushrooms")
                    .font(.appHeadline)
                    .foregroundColor(AppColors.textDark)

                CollectionGrid {
                    ForEach(SampleData.mixedDiscoveryStates) { species in
                        CollectionCard(species: species)
                    }
                }

                Text("Mixed discovered/undiscovered states")
                    .font(.appCaption)
                    .foregroundColor(AppColors.textLight)
            }

            // All discovered
            VStack(alignment: .leading, spacing: 12) {
                Text("All Discovered")
                    .font(.appHeadline)
                    .foregroundColor(AppColors.textDark)

                CollectionGrid {
                    ForEach(SampleData.allDiscovered) { species in
                        CollectionCard(species: species)
                    }
                }
            }

            // All undiscovered
            VStack(alignment: .leading, spacing: 12) {
                Text("All Undiscovered")
                    .font(.appHeadline)
                    .foregroundColor(AppColors.textDark)

                CollectionGrid {
                    ForEach(SampleData.noneDiscovered) { species in
                        CollectionCard(species: species)
                    }
                }
            }
        }
        .padding(24)
    }
    .background(AppColors.background)
}
