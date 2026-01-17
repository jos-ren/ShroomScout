//
//  Font+App.swift
//  ShroomScout
//
//  Created by Joshua Renema on 2026-01-16.
//

import SwiftUI

extension Font {
    /// Creates a Nunito font with the specified size and weight
    /// - Parameters:
    ///   - size: The font size in points
    ///   - weight: The font weight (default: .regular)
    /// - Returns: A Nunito font with the specified parameters
    static func nunito(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch weight {
        case .black:
            return .custom("Nunito-Black", size: size)
        case .bold:
            return .custom("Nunito-Bold", size: size)
        case .semibold:
            return .custom("Nunito-SemiBold", size: size)
        case .medium:
            return .custom("Nunito-Medium", size: size)
        case .light:
            return .custom("Nunito-Light", size: size)
        case .ultraLight:
            return .custom("Nunito-ExtraLight", size: size)
        default:
            return .custom("Nunito-Regular", size: size)
        }
    }

    // MARK: - App Font Presets

    /// Large title - 32pt Bold (e.g., "Welcome back!")
    static let appLargeTitle = nunito(32, weight: .bold)

    /// Title - 24pt Bold (e.g., screen titles)
    static let appTitle = nunito(24, weight: .bold)

    /// Headline - 20pt SemiBold (e.g., section headers)
    static let appHeadline = nunito(20, weight: .semibold)

    /// Subheadline - 17pt SemiBold (e.g., card titles)
    static let appSubheadline = nunito(17, weight: .semibold)

    /// Body - 16pt Regular (e.g., main content)
    static let appBody = nunito(16, weight: .regular)

    /// Callout - 15pt Medium (e.g., emphasized content)
    static let appCallout = nunito(15, weight: .medium)

    /// Caption - 13pt Regular (e.g., secondary text)
    static let appCaption = nunito(13, weight: .regular)

    /// Small - 11pt Light (e.g., fine print)
    static let appSmall = nunito(11, weight: .light)

    /// Button - 17pt SemiBold (e.g., button labels)
    static let appButton = nunito(17, weight: .semibold)
}
