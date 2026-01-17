//
//  SampleData.swift
//  ShroomScout
//
//  Sample mushroom data for development and previews.
//  These 5 species are used throughout the app until real data is available.
//
//  To add images: In Assets.xcassets, create image sets named:
//  - golden-chanterelle
//  - fly-agaric
//  - chicken-of-the-woods
//  - destroying-angel
//  - lions-mane
//

import SwiftUI

// MARK: - Sample Species Data

/// Lightweight species struct for previews and sample data (non-persistent)
struct SampleSpecies: Identifiable {
    let id: String
    let commonName: String
    let scientificName: String
    let description: String
    let rarity: Rarity
    let edibility: Edibility
    let season: [Season]
    let habitat: String
    let keyFeatures: [String]
    let funFact: String
    let imageName: String  // Asset name in Assets.xcassets

    /// Whether user has "discovered" this species (for preview purposes)
    var isDiscovered: Bool = false

    /// SwiftUI Image from asset catalog
    var image: Image {
        Image(imageName)
    }
}

// MARK: - Sample Data

struct SampleData {

    // MARK: - The 5 Example Mushrooms

    static let goldenChanterelle = SampleSpecies(
        id: "golden-chanterelle",
        commonName: "Golden Chanterelle",
        scientificName: "Cantharellus cibarius",
        description: "One of the most prized culinary mushrooms, with a peppery taste and firm texture that holds up well in cooking.",
        rarity: .uncommon,
        edibility: .edible,
        season: [.summer, .fall],
        habitat: "Deciduous and coniferous forests, often near oak, beech, or pine trees",
        keyFeatures: [
            "Bright golden-yellow to orange color",
            "Funnel or vase-shaped cap",
            "False gills (ridges) running down the stem",
            "Fruity apricot-like aroma",
            "Typically 2-10 cm in diameter"
        ],
        funFact: "One of the most prized culinary mushrooms, with a peppery taste and firm texture that holds up well in cooking.",
        imageName: "golden-chanterelle"
    )

    static let flyAgaric = SampleSpecies(
        id: "fly-agaric",
        commonName: "Fly Agaric",
        scientificName: "Amanita muscaria",
        description: "The classic \"fairy tale\" mushroom often depicted in storybooks and video games. While toxic, it has been used ceremonially in some cultures.",
        rarity: .common,
        edibility: .toxic,
        season: [.summer, .fall],
        habitat: "Birch and conifer forests, forms mycorrhizal relationships",
        keyFeatures: [
            "Iconic red cap with white spots (warts)",
            "White gills and stem",
            "White ring (skirt) on stem",
            "Cap 8-20 cm in diameter",
            "White volva (cup) at base"
        ],
        funFact: "The classic \"fairy tale\" mushroom often depicted in storybooks and video games. While toxic, it has been used ceremonially in some cultures.",
        imageName: "fly-agaric"
    )

    static let chickenOfTheWoods = SampleSpecies(
        id: "chicken-of-the-woods",
        commonName: "Chicken of the Woods",
        scientificName: "Laetiporus sulphureus",
        description: "Named for its chicken-like texture and flavor when cooked. It's a favorite among foragers and vegetarians as a meat substitute.",
        rarity: .uncommon,
        edibility: .edible,
        season: [.spring, .summer, .fall],
        habitat: "Dead or dying hardwood trees (oak, cherry, willow)",
        keyFeatures: [
            "Bright orange to yellow bracket-shaped shelves",
            "Grows in overlapping clusters",
            "Velvety or suede-like texture when young",
            "No gills or pores visible from below",
            "Can grow very large (10-60 cm wide)"
        ],
        funFact: "Named for its chicken-like texture and flavor when cooked. It's a favorite among foragers and vegetarians as a meat substitute.",
        imageName: "chicken-of-the-woods"
    )

    static let destroyingAngel = SampleSpecies(
        id: "destroying-angel",
        commonName: "Destroying Angel",
        scientificName: "Amanita bisporigera",
        description: "One of the most deadly mushrooms in North America. Contains amatoxins that destroy the liver and kidneys.",
        rarity: .rare,
        edibility: .deadly,
        season: [.summer, .fall],
        habitat: "Mixed hardwood and conifer forests",
        keyFeatures: [
            "Pure white throughout (cap, gills, stem)",
            "Smooth cap, 5-15 cm in diameter",
            "White ring on stem",
            "Large white volva (sac) at base",
            "Delicate, innocent appearance"
        ],
        funFact: "One of the most deadly mushrooms in North America. Contains amatoxins that destroy the liver and kidneys. Symptoms may not appear until 6-24 hours after ingestion.",
        imageName: "destroying-angel"
    )

    static let lionsMane = SampleSpecies(
        id: "lions-mane",
        commonName: "Lion's Mane",
        scientificName: "Hericium erinaceus",
        description: "Not only is it delicious with a seafood-like flavor, but it's also studied for potential cognitive and neurological health benefits.",
        rarity: .rare,
        edibility: .edible,
        season: [.summer, .fall],
        habitat: "Dead or dying hardwood trees, especially oak and beech",
        keyFeatures: [
            "White, shaggy appearance with cascading spines",
            "Looks like a white pom-pom or lion's mane",
            "Spines 1-5 cm long",
            "Grows in a single clump",
            "Can reach 10-40 cm in diameter"
        ],
        funFact: "Not only is it delicious with a seafood-like flavor, but it's also studied for potential cognitive and neurological health benefits. Known as \"the smart mushroom\" in traditional medicine.",
        imageName: "lions-mane"
    )

    // MARK: - All Species Array

    static let allSpecies: [SampleSpecies] = [
        goldenChanterelle,
        flyAgaric,
        chickenOfTheWoods,
        destroyingAngel,
        lionsMane
    ]

    // MARK: - Filtered Arrays

    static var edibleSpecies: [SampleSpecies] {
        allSpecies.filter { $0.edibility == .edible }
    }

    static var toxicSpecies: [SampleSpecies] {
        allSpecies.filter { $0.edibility == .toxic || $0.edibility == .deadly }
    }

    static var rareSpecies: [SampleSpecies] {
        allSpecies.filter { $0.rarity == .rare || $0.rarity == .legendary }
    }

    // MARK: - Preview Helpers

    /// Get species with mixed discovered states for previews
    static var mixedDiscoveryStates: [SampleSpecies] {
        var species = allSpecies
        species[0].isDiscovered = true  // Golden Chanterelle - discovered
        species[1].isDiscovered = false // Fly Agaric - not discovered
        species[2].isDiscovered = true  // Chicken of the Woods - discovered
        species[3].isDiscovered = false // Destroying Angel - not discovered
        species[4].isDiscovered = true  // Lion's Mane - discovered
        return species
    }

    /// Get all species as discovered (for collection previews)
    static var allDiscovered: [SampleSpecies] {
        allSpecies.map { species in
            var copy = species
            copy.isDiscovered = true
            return copy
        }
    }

    /// Get all species as undiscovered (for empty state previews)
    static var noneDiscovered: [SampleSpecies] {
        allSpecies.map { species in
            var copy = species
            copy.isDiscovered = false
            return copy
        }
    }
}

