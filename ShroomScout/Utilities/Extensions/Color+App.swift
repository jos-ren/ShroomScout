//
//  Color+App.swift
//  ShroomScout
//
//  Created by Joshua Renema on 2026-01-16.
//

import SwiftUI

// MARK: - App Colors
struct AppColors {
    // Primary
    static let primaryGreen = Color(hex: "4A7C59")
    static let cream = Color(hex: "FFF8E7")
    static let coral = Color(hex: "FF8A6C")
    static let background = Color(hex: "FFFDF7")

    // Text
    static let textDark = Color(hex: "2D3B2D")
    static let textLight = Color(hex: "6B7B6B")

    // Rarity
    static let rarityCommon = Color(hex: "9CA3AF")
    static let rarityUncommon = Color(hex: "6EE7B7")
    static let rarityRare = Color(hex: "7DD3FC")
    static let rarityLegendary = Color(hex: "FCD34D")

    // Status
    static let caution = Color(hex: "F59E0B")
    static let danger = Color(hex: "EF4444")

    // Convenience method to get rarity color
    static func color(for rarity: Rarity) -> Color {
        switch rarity {
        case .common: return rarityCommon
        case .uncommon: return rarityUncommon
        case .rare: return rarityRare
        case .legendary: return rarityLegendary
        }
    }

    // Convenience method to get edibility color
    static func color(for edibility: Edibility) -> Color {
        switch edibility {
        case .edible: return primaryGreen
        case .inedible: return textLight
        case .caution: return caution
        case .toxic, .deadly: return danger
        }
    }
}

// MARK: - App Dimensions
struct AppDimensions {
    static let cornerRadiusSmall: CGFloat = 12
    static let cornerRadiusMedium: CGFloat = 16
    static let cornerRadiusLarge: CGFloat = 20
    static let cornerRadiusPill: CGFloat = 100

    static let paddingSmall: CGFloat = 8
    static let paddingMedium: CGFloat = 16
    static let paddingLarge: CGFloat = 24
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
