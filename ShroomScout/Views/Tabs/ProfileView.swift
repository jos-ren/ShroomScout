//
//  ProfileView.swift
//  ShroomScout
//
//  Profile tab with user stats, achievements, and settings access.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ProfileViewModel()
    @State private var showSettings = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero Header Section
                ProfileHeaderSection(
                    viewModel: viewModel,
                    onSettingsTapped: { showSettings = true }
                )

                // Content Section
                VStack(spacing: 24) {
                    // Stats Grid
                    StatsGridCard(stats: viewModel.stats)

                    // Rarity Breakdown
                    RarityBreakdownCard(stats: viewModel.stats)

                    // Achievements
                    AchievementsCard(
                        achievements: viewModel.achievements,
                        earnedCount: viewModel.earnedAchievementsCount,
                        totalCount: viewModel.totalAchievementsCount
                    )

                    // Streak Banner
                    StreakBannerCard(dayStreak: viewModel.stats.dayStreak)

                    Spacer(minLength: 120)
                }
                .padding(.horizontal, 24)
                .padding(.top, -60) // Overlap with header
            }
        }
        .background(AppColors.background)
        .ignoresSafeArea(edges: .top)
        .onAppear {
            viewModel.loadData(modelContext: modelContext)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(viewModel: viewModel)
        }
    }
}

// MARK: - Profile Header Section

private struct ProfileHeaderSection: View {
    let viewModel: ProfileViewModel
    let onSettingsTapped: () -> Void

    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                colors: [
                    AppColors.primaryGreen,
                    AppColors.primaryGreen.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Decorative circles
            Circle()
                .fill(.white.opacity(0.1))
                .frame(width: 256, height: 256)
                .blur(radius: 128)
                .offset(x: 80, y: -80)

            Circle()
                .fill(.white.opacity(0.05))
                .frame(width: 192, height: 192)
                .blur(radius: 80)
                .offset(x: -100, y: 160)

            // Content
            VStack(spacing: 24) {
                // Top bar with title and settings
                HStack {
                    Text("Profile")
                        .font(.nunito(24, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    Button(action: onSettingsTapped) {
                        Circle()
                            .fill(.white.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                            )
                    }
                    .buttonStyle(BounceButtonStyle())
                }

                // Profile Info
                VStack(spacing: 8) {
                    // Mascot Avatar
                    MascotView(expression: .happy, size: 192)
                        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)

                    // User Name / Rank
                    Text(viewModel.displayName)
                        .font(.nunito(24, weight: .bold))
                        .foregroundColor(.white)

                    // Member Since
                    Text(viewModel.memberSinceText)
                        .font(.nunito(14, weight: .regular))
                        .foregroundColor(.white.opacity(0.8))

                    // Region Badge
                    RegionBadge(
                        emoji: viewModel.regionEmoji,
                        name: viewModel.regionDisplayName
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 60)
            .padding(.bottom, 80)
        }
        .frame(height: 508)
    }
}

// MARK: - Region Badge

private struct RegionBadge: View {
    let emoji: String
    let name: String

    var body: some View {
        HStack(spacing: 8) {
            Text(emoji)
                .font(.nunito(18, weight: .regular))

            Text(name)
                .font(.nunito(14, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
        .background(.white.opacity(0.2))
        .cornerRadius(100)
    }
}

// MARK: - Stats Grid Card

private struct StatsGridCard: View {
    let stats: ProfileStats

    var body: some View {
        AppCard {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ],
                spacing: 16
            ) {
                StatCell(
                    value: "\(stats.speciesFound)",
                    label: "Species Found",
                    valueColor: AppColors.primaryGreen
                )

                StatCell(
                    value: "\(stats.totalSightings)",
                    label: "Total Sightings",
                    valueColor: AppColors.primaryGreen
                )

                StatCell(
                    value: "\(stats.dayStreak)",
                    label: "Day Streak",
                    valueColor: AppColors.coral,
                    icon: "flame.fill"
                )

                StatCell(
                    value: "\(stats.rareFinds)",
                    label: "Rare Finds",
                    valueColor: AppColors.rarityRare,
                    icon: "sparkles"
                )
            }
        }
    }
}

// MARK: - Stat Cell

private struct StatCell: View {
    let value: String
    let label: String
    var valueColor: Color = AppColors.primaryGreen
    var icon: String? = nil

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.nunito(30, weight: .bold))
                .foregroundColor(valueColor)

            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textLight)
                }

                Text(label)
                    .font(.nunito(14, weight: .regular))
                    .foregroundColor(AppColors.textLight)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(AppColors.cream)
        .cornerRadius(16)
    }
}

// MARK: - Rarity Breakdown Card

private struct RarityBreakdownCard: View {
    let stats: ProfileStats

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Collection by Rarity")
                    .font(.nunito(18, weight: .bold))
                    .foregroundColor(AppColors.textDark)

                // Rarity Rows
                VStack(spacing: 12) {
                    ForEach(stats.rarityCounts) { rarityCount in
                        RarityRow(
                            rarity: rarityCount.rarity,
                            count: rarityCount.count,
                            total: stats.totalRarityCount
                        )
                    }
                }

                // Combined Progress Bar
                RarityCombinedBar(rarityCounts: stats.rarityCounts)
            }
        }
    }
}

// MARK: - Rarity Row

private struct RarityRow: View {
    let rarity: Rarity
    let count: Int
    let total: Int

    private var barWidth: CGFloat {
        guard total > 0 else { return 0 }
        return CGFloat(count) / CGFloat(total)
    }

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(rarity.displayName)
                    .font(.nunito(14, weight: .semibold))
                    .foregroundColor(AppColors.textDark)

                Spacer()

                Text("\(count)")
                    .font(.nunito(14, weight: .regular))
                    .foregroundColor(AppColors.textLight)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Capsule()
                        .fill(AppColors.cream)
                        .frame(height: 8)

                    // Progress
                    Capsule()
                        .fill(AppColors.color(for: rarity))
                        .frame(width: max(0, geometry.size.width * barWidth), height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Rarity Combined Bar

private struct RarityCombinedBar: View {
    let rarityCounts: [RarityCount]

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                ForEach(rarityCounts) { rarityCount in
                    let total = rarityCounts.reduce(0) { $0 + $1.count }
                    let fraction = total > 0 ? CGFloat(rarityCount.count) / CGFloat(total) : 0
                    let width = max(0, geometry.size.width * fraction)

                    if width > 0 {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(rarityCount.color)
                            .frame(width: width, height: 12)
                    }
                }
            }
        }
        .frame(height: 12)
        .clipShape(Capsule())
    }
}

// MARK: - Achievements Card

private struct AchievementsCard: View {
    let achievements: [Achievement]
    let earnedCount: Int
    let totalCount: Int

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    Text("Badges")
                        .font(.nunito(18, weight: .bold))
                        .foregroundColor(AppColors.textDark)

                    Spacer()

                    Text("\(earnedCount) / \(totalCount) earned")
                        .font(.nunito(14, weight: .regular))
                        .foregroundColor(AppColors.textLight)
                }

                // Achievements Grid
                LazyVGrid(
                    columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ],
                    spacing: 16
                ) {
                    ForEach(achievements) { achievement in
                        AchievementBadge(achievement: achievement)
                    }
                }
            }
        }
    }
}

// MARK: - Achievement Badge

private struct AchievementBadge: View {
    let achievement: Achievement

    var body: some View {
        VStack(spacing: 8) {
            // Badge Icon
            ZStack {
                if achievement.isEarned {
                    // Earned badge - gradient background
                    LinearGradient(
                        colors: [AppColors.coral, AppColors.primaryGreen],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(width: 64, height: 64)
                    .cornerRadius(16)
                    .shadow(
                        color: .black.opacity(0.1),
                        radius: 4,
                        x: 0,
                        y: 2
                    )
                } else {
                    // Locked badge - gray background
                    Color(hex: "E5E7EB")
                        .opacity(0.4)
                        .frame(width: 64, height: 64)
                        .cornerRadius(16)
                }

                Text(achievement.emoji)
                    .font(.system(size: 30))
            }

            // Badge Name
            Text(achievement.name)
                .font(.nunito(12, weight: .semibold))
                .foregroundColor(achievement.isEarned ? AppColors.textDark : AppColors.textLight)
                .multilineTextAlignment(.center)
                .lineLimit(1)

            // Description for locked badges
            if !achievement.isEarned {
                Text(achievement.description)
                    .font(.nunito(12, weight: .regular))
                    .foregroundColor(AppColors.textLight)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Streak Banner Card

private struct StreakBannerCard: View {
    let dayStreak: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                // Flame Icon
                Circle()
                    .fill(.white)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "flame.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.primaryGreen)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text("You're on fire!")
                        .font(.nunito(18, weight: .bold))
                        .foregroundColor(AppColors.textDark)

                    Text("\(dayStreak)-day streak going strong")
                        .font(.nunito(14, weight: .regular))
                        .foregroundColor(AppColors.textLight)
                }
            }

            Text("Keep it up! Find one more species to reach your weekly goal.")
                .font(.nunito(14, weight: .regular))
                .foregroundColor(AppColors.textDark)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    AppColors.rarityUncommon.opacity(0.2),
                    AppColors.rarityRare.opacity(0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(AppColors.rarityUncommon.opacity(0.3), lineWidth: 2)
        )
        .cornerRadius(24)
    }
}

#Preview {
    ProfileView()
        .modelContainer(for: [UserProfile.self, Species.self, Sighting.self], inMemory: true)
}
