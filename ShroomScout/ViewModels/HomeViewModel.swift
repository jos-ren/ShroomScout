//
//  HomeViewModel.swift
//  ShroomScout
//
//  View model for the Home screen, managing user data and recent discoveries.
//

import SwiftUI
import SwiftData
import Combine

@MainActor
@Observable
final class HomeViewModel {
    // MARK: - Published Properties

    /// User's display name for greeting
    var userName: String = "Scout"

    /// Current region name for badge display
    var regionName: String = "Pacific Northwest"

    /// Region emoji/icon
    var regionIcon: String = "🌲"

    /// Mascot speech bubble message
    var mascotMessage: String = "Let's find something new today!"

    /// Number of species discovered
    var discoveredCount: Int = 6

    /// Total number of species in the region
    var totalSpeciesCount: Int = 156

    /// Recent discoveries for horizontal scroll
    var recentDiscoveries: [RecentDiscovery] = []

    /// Rarity breakdown for stats display
    var rarityBreakdown: RarityBreakdown = RarityBreakdown()

    // MARK: - Computed Properties

    /// Progress percentage for collection
    var collectionProgress: Double {
        guard totalSpeciesCount > 0 else { return 0 }
        return Double(discoveredCount) / Double(totalSpeciesCount)
    }

    /// Formatted greeting message
    var greetingMessage: String {
        "Hey, \(userName)!"
    }

    // MARK: - Initialization

    init() {
        loadSampleData()
    }

    // MARK: - Data Loading

    /// Load sample data for previews and development
    private func loadSampleData() {
        // Set up recent discoveries from sample data
        recentDiscoveries = [
            RecentDiscovery(
                id: SampleData.goldenChanterelle.id,
                name: SampleData.goldenChanterelle.commonName,
                imageName: SampleData.goldenChanterelle.imageName,
                rarity: SampleData.goldenChanterelle.rarity
            ),
            RecentDiscovery(
                id: "black-morel",
                name: "Black Morel",
                imageName: "black-morel",
                rarity: .rare
            ),
            RecentDiscovery(
                id: SampleData.chickenOfTheWoods.id,
                name: "Oyster Mushroom",
                imageName: "oyster-mushroom",
                rarity: .common
            ),
            RecentDiscovery(
                id: "shiitake",
                name: "Shiitake",
                imageName: "shiitake",
                rarity: .uncommon
            )
        ]

        // Set up rarity breakdown
        rarityBreakdown = RarityBreakdown(
            common: 2,
            uncommon: 3,
            rare: 1,
            legendary: 0
        )
    }

    /// Refresh data from SwiftData (for future implementation)
    func refreshData() async {
        // TODO: Load real data from SwiftData
        // For now, keep sample data
    }

    /// Update mascot message based on time of day or events
    func updateMascotMessage() {
        let hour = Calendar.current.component(.hour, from: Date())

        switch hour {
        case 5..<12:
            mascotMessage = "Good morning! Ready to explore?"
        case 12..<17:
            mascotMessage = "Perfect weather for mushroom hunting!"
        case 17..<21:
            mascotMessage = "Evening forays can be magical!"
        default:
            mascotMessage = "Let's find something new today!"
        }
    }
}

// MARK: - Supporting Types

/// Represents a recently discovered mushroom for the carousel
struct RecentDiscovery: Identifiable {
    let id: String
    let name: String
    let imageName: String
    let rarity: Rarity
}

/// Breakdown of discovered species by rarity
struct RarityBreakdown {
    var common: Int = 0
    var uncommon: Int = 0
    var rare: Int = 0
    var legendary: Int = 0

    var total: Int {
        common + uncommon + rare + legendary
    }
}

// MARK: - Preview Helper

extension HomeViewModel {
    /// Create a view model with sample data for previews
    static var preview: HomeViewModel {
        let viewModel = HomeViewModel()
        return viewModel
    }
}
