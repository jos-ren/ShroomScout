//
//  ConfirmationView.swift
//  ShroomScout
//
//  Celebration screen shown after a user confirms a mushroom discovery.
//  Displays celebratory animations, the species discovered, XP earned,
//  and collection stats.
//

import SwiftUI

// MARK: - Discovery Stats

/// Stats to display on the confirmation screen
struct DiscoveryStats {
    let totalSpeciesFound: Int
    let totalSightings: Int
    let xpEarned: Int

    /// Base XP values for different rarities
    static func xpForRarity(_ rarity: Rarity) -> Int {
        switch rarity {
        case .common: return 10
        case .uncommon: return 25
        case .rare: return 50
        case .legendary: return 100
        }
    }

    /// Bonus XP for discovering a new species
    static let newSpeciesBonus: Int = 50
}

// MARK: - Confirmation View

struct ConfirmationView: View {
    let species: SampleSpecies
    let isNewSpecies: Bool
    let stats: DiscoveryStats

    var onViewCollection: () -> Void
    var onKeepExploring: () -> Void

    // Animation states
    @State private var showContent = false
    @State private var showConfetti = false
    @State private var mascotBounce = false
    @State private var xpCounterValue = 0
    @State private var statsScale: CGFloat = 0.5

    // Confetti particles
    @State private var confettiParticles: [ConfettiParticle] = []

    var body: some View {
        ZStack {
            // Background
            AppColors.background
                .ignoresSafeArea()

            // Main content - no scroll, everything fits
            VStack(spacing: 16) {
                Spacer()

                // Mascot with celebration
                mascotSection

                // Title message
                titleSection

                // Species card
                speciesCard

                // XP and stats in a row
                xpAndStatsSection

                Spacer()

                // Action buttons at bottom
                buttonsSection
                    .padding(.bottom, 24)
            }
            .padding(.horizontal, 24)

            // Confetti layer - in front of everything
            confettiLayer
        }
        .onAppear {
            startAnimations()
        }
    }

    // MARK: - Mascot Section

    private var mascotSection: some View {
        AnimatedMascotView(expression: .excited, size: 100)
            .scaleEffect(showContent ? 1.0 : 0.3)
            .opacity(showContent ? 1.0 : 0.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.2), value: showContent)
    }

    // MARK: - Title Section

    private var titleSection: some View {
        VStack(spacing: 8) {
            Text(isNewSpecies ? "New Species Found!" : "Discovery Added!")
                .font(.appLargeTitle)
                .foregroundColor(AppColors.textDark)
                .multilineTextAlignment(.center)

            if isNewSpecies {
                Text("First time spotting this one!")
                    .font(.appBody)
                    .foregroundColor(AppColors.textLight)
            } else {
                Text("Another sighting recorded")
                    .font(.appBody)
                    .foregroundColor(AppColors.textLight)
            }
        }
        .scaleEffect(showContent ? 1.0 : 0.8)
        .opacity(showContent ? 1.0 : 0.0)
        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.3), value: showContent)
    }

    // MARK: - Species Card

    private var speciesCard: some View {
        AppCard {
            HStack(spacing: 16) {
                // Species image
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppColors.cream)
                        .frame(width: 80, height: 80)

                    Image(species.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .overlay(
                    // Rarity glow for rare/legendary
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(rarityGlowColor, lineWidth: shouldShowRarityGlow ? 3 : 0)
                        .shadow(color: rarityGlowColor.opacity(0.5), radius: shouldShowRarityGlow ? 8 : 0)
                )

                // Species info
                VStack(alignment: .leading, spacing: 6) {
                    Text(species.commonName)
                        .font(.appHeadline)
                        .foregroundColor(AppColors.textDark)

                    Text(species.scientificName)
                        .font(.appCaption)
                        .foregroundColor(AppColors.textLight)
                        .italic()

                    // Rarity badge
                    AppBadge.rarity(species.rarity)
                }

                Spacer()
            }
        }
        .scaleEffect(showContent ? 1.0 : 0.9)
        .opacity(showContent ? 1.0 : 0.0)
        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.4), value: showContent)
    }

    private var shouldShowRarityGlow: Bool {
        species.rarity == .rare || species.rarity == .legendary
    }

    private var rarityGlowColor: Color {
        AppColors.color(for: species.rarity)
    }

    // MARK: - XP and Stats Section (Combined)

    private var xpAndStatsSection: some View {
        HStack(spacing: 12) {
            // XP earned
            VStack(spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 18))
                        .foregroundColor(AppColors.rarityLegendary)

                    Text("+\(xpCounterValue)")
                        .font(.nunito(24, weight: .bold))
                        .foregroundColor(AppColors.textDark)
                }

                Text("XP Earned")
                    .font(.appCaption)
                    .foregroundColor(AppColors.textLight)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.rarityLegendary.opacity(0.15))
            )

            // Species found
            VStack(spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.primaryGreen)

                    Text("\(stats.totalSpeciesFound)")
                        .font(.nunito(24, weight: .bold))
                        .foregroundColor(AppColors.textDark)
                }

                Text("Species")
                    .font(.appCaption)
                    .foregroundColor(AppColors.textLight)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.cream)
            )

            // Total sightings
            VStack(spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.primaryGreen)

                    Text("\(stats.totalSightings)")
                        .font(.nunito(24, weight: .bold))
                        .foregroundColor(AppColors.textDark)
                }

                Text("Sightings")
                    .font(.appCaption)
                    .foregroundColor(AppColors.textLight)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.cream)
            )
        }
        .scaleEffect(statsScale)
        .opacity(showContent ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.5).delay(0.5), value: showContent)
    }

    // MARK: - Buttons Section

    private var buttonsSection: some View {
        VStack(spacing: 12) {
            AppButton("View in Collection", style: .primary) {
                onViewCollection()
            }

            AppButton("Keep Exploring", style: .secondary) {
                onKeepExploring()
            }
        }
        .opacity(showContent ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.3).delay(0.7), value: showContent)
    }

    // MARK: - Confetti Layer

    private var confettiLayer: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(confettiParticles) { particle in
                    ConfettiPiece(particle: particle)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onAppear {
                generateConfetti(in: geometry.size)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    // MARK: - Animations

    private func startAnimations() {
        // Show content with staggered animations
        withAnimation {
            showContent = true
        }

        // Animate XP counter
        let targetXP = stats.xpEarned
        let duration: Double = 1.0
        let steps = 20
        let stepDuration = duration / Double(steps)

        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * stepDuration + 0.5) {
                withAnimation(.linear(duration: stepDuration)) {
                    xpCounterValue = Int(Double(targetXP) * (Double(i) / Double(steps)))
                }
            }
        }

        // Stats pop animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
                statsScale = 1.0
            }
        }

        // Trigger confetti
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showConfetti = true
        }
    }

    private func generateConfetti(in size: CGSize) {
        let colors: [Color] = [
            AppColors.coral,
            AppColors.primaryGreen,
            AppColors.rarityLegendary,
            AppColors.rarityUncommon,
            AppColors.rarityRare
        ]

        var particles: [ConfettiParticle] = []

        for i in 0..<50 {
            let particle = ConfettiParticle(
                id: i,
                x: CGFloat.random(in: 0...size.width),
                y: -20,
                color: colors.randomElement() ?? AppColors.coral,
                rotation: Double.random(in: 0...360),
                scale: CGFloat.random(in: 0.5...1.0),
                delay: Double.random(in: 0...0.5)
            )
            particles.append(particle)
        }

        confettiParticles = particles
    }
}

// MARK: - Confetti Particle

struct ConfettiParticle: Identifiable {
    let id: Int
    let x: CGFloat
    let y: CGFloat
    let color: Color
    let rotation: Double
    let scale: CGFloat
    let delay: Double
}

// MARK: - Confetti Piece View

struct ConfettiPiece: View {
    let particle: ConfettiParticle

    @State private var offsetY: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1.0

    var body: some View {
        confettiShape
            .rotationEffect(.degrees(rotation))
            .position(x: particle.x, y: particle.y + offsetY)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    .easeOut(duration: 3.0)
                    .delay(particle.delay)
                ) {
                    offsetY = 800
                    rotation = particle.rotation + Double.random(in: 360...720)
                }

                withAnimation(
                    .easeIn(duration: 1.0)
                    .delay(particle.delay + 2.0)
                ) {
                    opacity = 0
                }
            }
    }

    @ViewBuilder
    private var confettiShape: some View {
        let size = 10 * particle.scale

        // Alternate between different shapes
        switch particle.id % 3 {
        case 0:
            Circle()
                .fill(particle.color)
                .frame(width: size, height: size)
        case 1:
            Rectangle()
                .fill(particle.color)
                .frame(width: size, height: size)
        default:
            Capsule()
                .fill(particle.color)
                .frame(width: size, height: size * 1.5)
        }
    }
}

// MARK: - Preview

#Preview("New Species - Uncommon") {
    ConfirmationView(
        species: SampleData.goldenChanterelle,
        isNewSpecies: true,
        stats: DiscoveryStats(
            totalSpeciesFound: 5,
            totalSightings: 12,
            xpEarned: 75
        ),
        onViewCollection: {
            print("View Collection tapped")
        },
        onKeepExploring: {
            print("Keep Exploring tapped")
        }
    )
}

#Preview("Repeat Sighting") {
    var species = SampleData.flyAgaric
    species.isDiscovered = true

    return ConfirmationView(
        species: species,
        isNewSpecies: false,
        stats: DiscoveryStats(
            totalSpeciesFound: 3,
            totalSightings: 8,
            xpEarned: 10
        ),
        onViewCollection: {
            print("View Collection tapped")
        },
        onKeepExploring: {
            print("Keep Exploring tapped")
        }
    )
}

#Preview("Rare Discovery") {
    ConfirmationView(
        species: SampleData.lionsMane,
        isNewSpecies: true,
        stats: DiscoveryStats(
            totalSpeciesFound: 10,
            totalSightings: 25,
            xpEarned: 100
        ),
        onViewCollection: {
            print("View Collection tapped")
        },
        onKeepExploring: {
            print("Keep Exploring tapped")
        }
    )
}

#Preview("Legendary Discovery") {
    let legendary = SampleSpecies(
        id: "matsutake",
        commonName: "Matsutake",
        scientificName: "Tricholoma matsutake",
        description: "One of the rarest and most prized mushrooms in the world.",
        rarity: .legendary,
        edibility: .edible,
        season: [.fall],
        habitat: "Pine forests",
        keyFeatures: ["Spicy aroma", "White to brown cap"],
        funFact: "Can sell for over $1000 per pound in Japan",
        imageName: "matsutake"
    )

    return ConfirmationView(
        species: legendary,
        isNewSpecies: true,
        stats: DiscoveryStats(
            totalSpeciesFound: 15,
            totalSightings: 42,
            xpEarned: 150
        ),
        onViewCollection: {
            print("View Collection tapped")
        },
        onKeepExploring: {
            print("Keep Exploring tapped")
        }
    )
}
