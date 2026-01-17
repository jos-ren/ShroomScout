//
//  ProfileViewModel.swift
//  ShroomScout
//
//  ViewModel for Profile screen managing user stats and settings.
//

import SwiftUI
import SwiftData

// MARK: - Achievement Model

struct Achievement: Identifiable {
    let id: String
    let name: String
    let description: String
    let emoji: String
    let isEarned: Bool

    static let allAchievements: [Achievement] = [
        Achievement(id: "first_find", name: "First Find", description: "Find your first mushroom", emoji: "🌟", isEarned: true),
        Achievement(id: "fungi_fanatic", name: "Fungi Fanatic", description: "Find 50 species", emoji: "🍄", isEarned: false),
        Achievement(id: "rare_hunter", name: "Rare Hunter", description: "Find 5 rare species", emoji: "💎", isEarned: true),
        Achievement(id: "legendary", name: "Legendary!", description: "Find a legendary", emoji: "👑", isEarned: false),
        Achievement(id: "week_streak", name: "Week Streak", description: "7 days in a row", emoji: "🔥", isEarned: true),
        Achievement(id: "explorer", name: "Explorer", description: "Visit 20 locations", emoji: "🗺️", isEarned: false),
    ]
}

// MARK: - Rarity Count Model

struct RarityCount: Identifiable {
    let id = UUID()
    let rarity: Rarity
    let count: Int

    var color: Color {
        AppColors.color(for: rarity)
    }
}

// MARK: - Profile Stats

struct ProfileStats {
    var speciesFound: Int = 6
    var totalSightings: Int = 4
    var dayStreak: Int = 12
    var rareFinds: Int = 2

    var rarityCounts: [RarityCount] = [
        RarityCount(rarity: .common, count: 1),
        RarityCount(rarity: .uncommon, count: 3),
        RarityCount(rarity: .rare, count: 2),
        RarityCount(rarity: .legendary, count: 0)
    ]

    var totalRarityCount: Int {
        rarityCounts.reduce(0) { $0 + $1.count }
    }
}

// MARK: - ProfileViewModel

@Observable
final class ProfileViewModel {
    var userProfile: UserProfile?
    var stats = ProfileStats()
    var achievements: [Achievement] = Achievement.allAchievements

    var earnedAchievementsCount: Int {
        achievements.filter { $0.isEarned }.count
    }

    var totalAchievementsCount: Int {
        achievements.count
    }

    var memberSinceText: String {
        guard let profile = userProfile else {
            return "Member since May 2025"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return "Member since \(formatter.string(from: profile.createdAt))"
    }

    var displayName: String {
        userProfile?.displayName ?? "Scout"
    }

    var regionDisplayName: String {
        switch userProfile?.selectedRegion ?? "pnw" {
        case "pnw":
            return "Pacific Northwest"
        case "ne":
            return "Northeast"
        case "se":
            return "Southeast"
        case "mw":
            return "Midwest"
        case "sw":
            return "Southwest"
        default:
            return "Unknown Region"
        }
    }

    var regionEmoji: String {
        switch userProfile?.selectedRegion ?? "pnw" {
        case "pnw":
            return "🌲"
        case "ne":
            return "🍂"
        case "se":
            return "🌴"
        case "mw":
            return "🌾"
        case "sw":
            return "🌵"
        default:
            return "🗺️"
        }
    }

    var soundEffectsEnabled: Bool {
        get { userProfile?.soundEffectsEnabled ?? true }
        set { userProfile?.soundEffectsEnabled = newValue }
    }

    var hapticFeedbackEnabled: Bool {
        get { userProfile?.hapticFeedbackEnabled ?? true }
        set { userProfile?.hapticFeedbackEnabled = newValue }
    }

    // MARK: - Data Loading

    func loadData(modelContext: ModelContext) {
        // Fetch or create user profile
        let descriptor = FetchDescriptor<UserProfile>()
        if let profiles = try? modelContext.fetch(descriptor), let profile = profiles.first {
            userProfile = profile
        } else {
            // Create default profile if none exists
            let newProfile = UserProfile()
            modelContext.insert(newProfile)
            userProfile = newProfile
        }

        // Load stats from sightings
        loadStats(modelContext: modelContext)
    }

    private func loadStats(modelContext: ModelContext) {
        // Fetch all sightings
        let sightingsDescriptor = FetchDescriptor<Sighting>()
        let sightings = (try? modelContext.fetch(sightingsDescriptor)) ?? []

        // Fetch all species
        let speciesDescriptor = FetchDescriptor<Species>()
        let allSpecies = (try? modelContext.fetch(speciesDescriptor)) ?? []

        // Get unique species IDs from sightings
        let foundSpeciesIDs = Set(sightings.map { $0.speciesID })

        // Count by rarity
        var commonCount = 0
        var uncommonCount = 0
        var rareCount = 0
        var legendaryCount = 0

        for speciesID in foundSpeciesIDs {
            if let species = allSpecies.first(where: { $0.id == speciesID }) {
                switch species.rarity {
                case .common:
                    commonCount += 1
                case .uncommon:
                    uncommonCount += 1
                case .rare:
                    rareCount += 1
                case .legendary:
                    legendaryCount += 1
                }
            }
        }

        // Update stats if we have real data
        if !sightings.isEmpty {
            stats.speciesFound = foundSpeciesIDs.count
            stats.totalSightings = sightings.count
            stats.rareFinds = rareCount + legendaryCount
            stats.rarityCounts = [
                RarityCount(rarity: .common, count: commonCount),
                RarityCount(rarity: .uncommon, count: uncommonCount),
                RarityCount(rarity: .rare, count: rareCount),
                RarityCount(rarity: .legendary, count: legendaryCount)
            ]
        }
        // Day streak would require more complex date tracking - using placeholder for MVP
    }

    // MARK: - Settings Actions

    func updateDisplayName(_ name: String) {
        userProfile?.displayName = name
    }

    func updateRegion(_ region: String) {
        userProfile?.selectedRegion = region
    }
}
