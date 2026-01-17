//
//  UserProfile.swift
//  ShroomScout
//
//  Created by Joshua Renema on 2026-01-16.
//

import SwiftData
import Foundation

@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID
    var displayName: String
    var selectedRegion: String
    var hasCompletedOnboarding: Bool
    var hasAgreedToDisclaimer: Bool
    var createdAt: Date
    var soundEffectsEnabled: Bool
    var hapticFeedbackEnabled: Bool

    init(
        displayName: String = "Scout",
        selectedRegion: String = "pnw"
    ) {
        self.id = UUID()
        self.displayName = displayName
        self.selectedRegion = selectedRegion
        self.hasCompletedOnboarding = false
        self.hasAgreedToDisclaimer = false
        self.createdAt = Date()
        self.soundEffectsEnabled = true
        self.hapticFeedbackEnabled = true
    }
}
