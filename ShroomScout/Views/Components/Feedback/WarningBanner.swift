//
//  WarningBanner.swift
//  ShroomScout
//
//  Warning banner component with small and large variants.
//

import SwiftUI

struct WarningBanner: View {
    enum Style {
        case small  // Compact disclaimer style (red)
        case large  // Detailed warning with icon and body (amber)
    }

    let style: Style
    let title: String
    var message: String? = nil

    var body: some View {
        switch style {
        case .small:
            SmallBannerContent(text: title)
        case .large:
            LargeBannerContent(title: title, bodyText: message)
        }
    }
}

// MARK: - Small Banner (Disclaimer Style)

private struct SmallBannerContent: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.nunito(12, weight: .bold))
            .foregroundColor(AppColors.textDark)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 17)
            .padding(.vertical, 17)
            .frame(maxWidth: .infinity)
            .background(Color(hex: "EF4444").opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color(hex: "EF4444").opacity(0.3), lineWidth: 1)
            )
            .cornerRadius(24)
    }
}

// MARK: - Large Banner (Detailed Warning)

private struct LargeBannerContent: View {
    let title: String
    let bodyText: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with icon and title
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(AppColors.caution)

                Text(title)
                    .font(.nunito(18, weight: .bold))
                    .foregroundColor(AppColors.textDark)
            }

            // Body text (indented to align with title)
            if let bodyText = bodyText {
                Text(bodyText)
                    .font(.nunito(14, weight: .regular))
                    .foregroundColor(AppColors.textDark)
                    .padding(.leading, 36) // 24 icon + 12 spacing
            }
        }
        .padding(26)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.caution.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(AppColors.caution, lineWidth: 2)
        )
        .cornerRadius(24)
    }
}

// MARK: - Convenience Initializers

extension WarningBanner {
    /// Create a small disclaimer banner
    static func disclaimer(_ text: String) -> WarningBanner {
        WarningBanner(style: .small, title: text)
    }

    /// Create a large warning banner with title and optional message
    static func warning(title: String, message: String? = nil) -> WarningBanner {
        WarningBanner(style: .large, title: title, message: message)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 24) {
            Text("Warning Banners")
                .font(.appTitle)
                .foregroundColor(AppColors.textDark)

            // Small disclaimer
            VStack(alignment: .leading, spacing: 8) {
                Text("Small (Disclaimer)")
                    .font(.appHeadline)
                    .foregroundColor(AppColors.textDark)

                WarningBanner.disclaimer(
                    "Never eat wild mushrooms based on app ID alone. Always consult an expert."
                )
            }

            // Large warning
            VStack(alignment: .leading, spacing: 8) {
                Text("Large (Warning)")
                    .font(.appHeadline)
                    .foregroundColor(AppColors.textDark)

                WarningBanner.warning(
                    title: "Watch out for lookalikes!",
                    message: "False Chanterelle - note the true gills vs. ridges"
                )
            }

            // Large without body
            VStack(alignment: .leading, spacing: 8) {
                Text("Large (Title Only)")
                    .font(.appHeadline)
                    .foregroundColor(AppColors.textDark)

                WarningBanner.warning(title: "This species can be confused with toxic varieties")
            }
        }
        .padding(24)
    }
    .background(AppColors.background)
}
