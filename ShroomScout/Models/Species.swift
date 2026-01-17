//
//  Species.swift
//  ShroomScout
//
//  Created by Joshua Renema on 2026-01-16.
//

import SwiftData
import Foundation

@Model
final class Species {
    @Attribute(.unique) var id: String
    var commonName: String
    var scientificName: String
    var speciesDescription: String
    var rarity: Rarity
    var edibility: Edibility
    var season: [Season]
    var habitat: String
    var identificationTips: String
    var lookalikes: [String]
    var region: String
    var referenceImageName: String

    init(
        id: String,
        commonName: String,
        scientificName: String,
        speciesDescription: String,
        rarity: Rarity,
        edibility: Edibility,
        season: [Season],
        habitat: String,
        identificationTips: String,
        lookalikes: [String] = [],
        region: String,
        referenceImageName: String
    ) {
        self.id = id
        self.commonName = commonName
        self.scientificName = scientificName
        self.speciesDescription = speciesDescription
        self.rarity = rarity
        self.edibility = edibility
        self.season = season
        self.habitat = habitat
        self.identificationTips = identificationTips
        self.lookalikes = lookalikes
        self.region = region
        self.referenceImageName = referenceImageName
    }
}

// MARK: - Rarity Enum
enum Rarity: String, Codable, CaseIterable {
    case common
    case uncommon
    case rare
    case legendary

    var displayName: String {
        rawValue.capitalized
    }
}

// MARK: - Edibility Enum
enum Edibility: String, Codable, CaseIterable {
    case edible
    case inedible
    case caution
    case toxic
    case deadly

    var displayName: String {
        rawValue.capitalized
    }

    var iconName: String {
        switch self {
        case .edible: return "checkmark.circle.fill"
        case .inedible: return "xmark.circle.fill"
        case .caution: return "exclamationmark.triangle.fill"
        case .toxic: return "exclamationmark.octagon.fill"
        case .deadly: return "skull.fill"
        }
    }
}

// MARK: - Season Enum
enum Season: String, Codable, CaseIterable {
    case spring
    case summer
    case fall
    case winter
    case yearRound

    var displayName: String {
        switch self {
        case .yearRound: return "Year Round"
        default: return rawValue.capitalized
        }
    }
}
