//
//  HomeView.swift
//  ShroomScout
//
//  Main home screen with greeting, mascot card, collection stats, and recent discoveries.
//

import SwiftUI

struct HomeView: View {
    /// Callback when a species is tapped to navigate to detail
    var onSpeciesTapped: ((String) -> Void)?

    /// Callback when "View All" is tapped to navigate to collection tab
    var onViewCollection: (() -> Void)?

    @State private var viewModel = HomeViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with greeting and region badge
                HomeHeader(
                    greeting: viewModel.greetingMessage,
                    regionName: viewModel.regionName,
                    regionIcon: viewModel.regionIcon
                )

                // Mascot card with speech bubble
                AppCard(backgroundColor: AppColors.cream) {
                    HStack(spacing: 0) {
                        MascotView(expression: .happy, size: 80)

                        Spacer()

                        SpeechBubble(message: viewModel.mascotMessage)
                    }
                }

                // Collection stats card
                StatsCard(
                    discoveredCount: viewModel.discoveredCount,
                    totalCount: viewModel.totalSpeciesCount,
                    rarityBreakdown: viewModel.rarityBreakdown
                ) {
                    onViewCollection?()
                }

                // Recent discoveries section
                if !viewModel.recentDiscoveries.isEmpty {
                    RecentFindsRow(
                        title: "Recent Discoveries",
                        discoveries: viewModel.recentDiscoveries
                    ) { discovery in
                        onSpeciesTapped?(discovery.id)
                    }
                    .padding(.horizontal, -24) // Extend to edges for scroll
                }

                Spacer(minLength: 100)
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
        }
        .background(AppColors.background)
        .onAppear {
            viewModel.updateMascotMessage()
        }
    }
}

// MARK: - Home Header

private struct HomeHeader: View {
    let greeting: String
    let regionName: String
    let regionIcon: String

    var body: some View {
        HStack {
            // Greeting text
            Text(greeting)
                .font(.nunito(24, weight: .bold))
                .foregroundColor(AppColors.textDark)

            Spacer()

            // Region badge pill
            RegionBadge(name: regionName, icon: regionIcon)
        }
    }
}

// MARK: - Region Badge

private struct RegionBadge: View {
    let name: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Text(icon)
                .font(.nunito(18, weight: .regular))

            Text(name)
                .font(.nunito(14, weight: .semibold))
                .foregroundColor(AppColors.primaryGreen)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(AppColors.primaryGreen.opacity(0.1))
        .cornerRadius(100)
    }
}

// MARK: - Speech Bubble

private struct SpeechBubble: View {
    let message: String

    var body: some View {
        HStack(spacing: 0) {
            // Triangle pointer
            Triangle()
                .fill(.white)
                .frame(width: 12, height: 16)
                .rotationEffect(.degrees(-90))
                .offset(x: 6)

            // Bubble content
            Text(message)
                .font(.nunito(16, weight: .semibold))
                .foregroundColor(AppColors.textDark)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.white)
                .cornerRadius(16)
        }
        .frame(maxWidth: 190)
    }
}

// MARK: - Triangle Shape

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Preview

#Preview("Home Screen") {
    HomeView()
}

#Preview("Home Header") {
    VStack {
        HomeHeader(
            greeting: "Hey, Scout!",
            regionName: "Pacific Northwest",
            regionIcon: "🌲"
        )
        .padding(24)
    }
    .background(AppColors.background)
}

#Preview("Region Badge") {
    HStack(spacing: 16) {
        RegionBadge(name: "Pacific Northwest", icon: "🌲")
        RegionBadge(name: "California", icon: "☀️")
        RegionBadge(name: "Northeast", icon: "🍂")
    }
    .padding(24)
    .background(AppColors.background)
}
