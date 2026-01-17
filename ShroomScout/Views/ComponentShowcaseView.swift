//
//  ComponentShowcaseView.swift
//  ShroomScout
//
//  Test page to preview all UI components.
//

import SwiftUI

struct ComponentShowcaseView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Buttons") {
                    NavigationLink("AppButton") {
                        ButtonShowcase()
                    }
                }

                Section("Cards") {
                    NavigationLink("AppCard") {
                        CardShowcase()
                    }
                    NavigationLink("CollectionCard") {
                        CollectionCardShowcase()
                    }
                }

                Section("Navigation") {
                    NavigationLink("CustomTabBar") {
                        TabBarShowcase()
                    }
                }

                Section("Badges") {
                    NavigationLink("AppBadge") {
                        BadgeShowcase()
                    }
                }

                Section("Mascot") {
                    NavigationLink("MascotView") {
                        MascotShowcase()
                    }
                }

                Section("Feedback") {
                    NavigationLink("LoadingOverlay") {
                        ComingSoonView(name: "LoadingOverlay")
                    }
                    NavigationLink("WarningBanner") {
                        WarningBannerShowcase()
                    }
                    NavigationLink("EmptyStateView") {
                        ComingSoonView(name: "EmptyStateView")
                    }
                }

                Section("Collection") {
                    NavigationLink("CollectionProgress") {
                        CollectionProgressShowcase()
                    }
                    NavigationLink("CollectionTabs") {
                        CollectionTabsShowcase()
                    }
                    NavigationLink("RarityFilters") {
                        RarityFiltersShowcase()
                    }
                }

                Section("Common") {
                    NavigationLink("PageHeader") {
                        PageHeaderShowcase()
                    }
                    NavigationLink("ProgressIndicator") {
                        ProgressIndicatorShowcase()
                    }
                    NavigationLink("ProgressBar") {
                        ComingSoonView(name: "ProgressBar")
                    }
                }
            }
            .navigationTitle("Components")
            .font(.nunito(16, weight: .regular))
        }
    }
}

// MARK: - Button Showcase

struct ButtonShowcase: View {
    @State private var tapCount = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Primary Button
                VStack(alignment: .leading, spacing: 12) {
                    Text("Primary Button")
                        .font(.appHeadline)
                        .foregroundColor(AppColors.textDark)

                    AppButton("Scan Mushroom", style: .primary) {
                        tapCount += 1
                    }

                    Text("Coral background, white text, 60pt height")
                        .font(.appCaption)
                        .foregroundColor(AppColors.textLight)
                }

                // Secondary Button
                VStack(alignment: .leading, spacing: 12) {
                    Text("Secondary Button")
                        .font(.appHeadline)
                        .foregroundColor(AppColors.textDark)

                    AppButton("View Collection", style: .secondary) {
                        tapCount += 1
                    }

                    Text("Green background, white text, 56pt height")
                        .font(.appCaption)
                        .foregroundColor(AppColors.textLight)
                }

                // Tap counter
                Text("Tap count: \(tapCount)")
                    .font(.appBody)
                    .foregroundColor(AppColors.textLight)

                Spacer()
            }
            .padding(24)
        }
        .background(AppColors.background)
        .navigationTitle("Buttons")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Card Showcase

struct CardShowcase: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Simple card
                VStack(alignment: .leading, spacing: 12) {
                    Text("Simple Card")
                        .font(.appHeadline)
                        .foregroundColor(AppColors.textDark)

                    AppCard {
                        Text("Any content goes here")
                            .font(.appBody)
                            .foregroundColor(AppColors.textDark)
                    }

                    Text("White background, 24px radius, shadow, 24px padding")
                        .font(.appCaption)
                        .foregroundColor(AppColors.textLight)
                }

                // Species card example
                VStack(alignment: .leading, spacing: 12) {
                    Text("Species Card Example")
                        .font(.appHeadline)
                        .foregroundColor(AppColors.textDark)

                    AppCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Golden Chanterelle")
                                .font(.nunito(30, weight: .bold))
                                .foregroundColor(AppColors.textDark)

                            Text("Cantharellus cibarius")
                                .font(.nunito(18, weight: .regular))
                                .foregroundColor(AppColors.textLight)

                            HStack(spacing: 12) {
                                // Rarity badge
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(AppColors.rarityUncommon)
                                        .frame(width: 8, height: 8)
                                    Text("Uncommon")
                                        .font(.nunito(14, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(AppColors.rarityUncommon)
                                .cornerRadius(100)

                                // Edibility badge
                                HStack(spacing: 8) {
                                    Text("🍽️")
                                    Text("Edible")
                                        .font(.nunito(14, weight: .semibold))
                                        .foregroundColor(AppColors.textDark)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(AppColors.cream)
                                .cornerRadius(100)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                // Quick facts card
                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick Facts Example")
                        .font(.appHeadline)
                        .foregroundColor(AppColors.textDark)

                    AppCard {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Quick Facts")
                                .font(.nunito(18, weight: .bold))
                                .foregroundColor(AppColors.textDark)

                            VStack(spacing: 16) {
                                factRow(icon: "🍽️", label: "Edibility", value: "Edible")
                                factRow(icon: "📅", label: "Season", value: "Summer through Fall")
                                factRow(icon: "🌲", label: "Habitat", value: "Conifer forests")
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                Spacer()
            }
            .padding(24)
        }
        .background(AppColors.background)
        .navigationTitle("Cards")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func factRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.nunito(20, weight: .regular))
                .frame(width: 40, height: 40)
                .background(AppColors.cream)
                .cornerRadius(100)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.nunito(14, weight: .semibold))
                    .foregroundColor(AppColors.textDark)
                Text(value)
                    .font(.nunito(14, weight: .regular))
                    .foregroundColor(AppColors.textLight)
            }
        }
    }
}

// MARK: - Collection Card Showcase

struct CollectionCardShowcase: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Discovered vs undiscovered
                VStack(alignment: .leading, spacing: 12) {
                    Text("Discovered vs Undiscovered")
                        .font(.appHeadline)
                        .foregroundColor(AppColors.textDark)

                    CollectionGrid {
                        CollectionCard(name: "Chanterelle", rarity: .uncommon, isDiscovered: true)
                        CollectionCard(name: "Fly Agaric", rarity: .legendary, isDiscovered: false)
                        CollectionCard(name: "Oyster", rarity: .common, isDiscovered: true)
                    }

                    Text("140px height, rarity dot in top-right corner")
                        .font(.appCaption)
                        .foregroundColor(AppColors.textLight)
                }

                // All rarities discovered
                VStack(alignment: .leading, spacing: 12) {
                    Text("Rarity Colors (Discovered)")
                        .font(.appHeadline)
                        .foregroundColor(AppColors.textDark)

                    CollectionGrid {
                        CollectionCard(name: "Common", rarity: .common, isDiscovered: true)
                        CollectionCard(name: "Uncommon", rarity: .uncommon, isDiscovered: true)
                        CollectionCard(name: "Rare", rarity: .rare, isDiscovered: true)
                        CollectionCard(name: "Legendary", rarity: .legendary, isDiscovered: true)
                    }
                }

                // All rarities undiscovered
                VStack(alignment: .leading, spacing: 12) {
                    Text("Rarity Colors (Undiscovered)")
                        .font(.appHeadline)
                        .foregroundColor(AppColors.textDark)

                    CollectionGrid {
                        CollectionCard(name: "Common", rarity: .common, isDiscovered: false)
                        CollectionCard(name: "Uncommon", rarity: .uncommon, isDiscovered: false)
                        CollectionCard(name: "Rare", rarity: .rare, isDiscovered: false)
                        CollectionCard(name: "Legendary", rarity: .legendary, isDiscovered: false)
                    }

                    Text("Faded colors still distinguishable")
                        .font(.appCaption)
                        .foregroundColor(AppColors.textLight)
                }

                Spacer()
            }
            .padding(24)
        }
        .background(AppColors.background)
        .navigationTitle("Collection Card")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Badge Showcase

struct BadgeShowcase: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Rarity badges
                VStack(alignment: .leading, spacing: 12) {
                    Text("Rarity Badges")
                        .font(.appHeadline)
                        .foregroundColor(AppColors.textDark)

                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            AppBadge.rarity(.common)
                            AppBadge.rarity(.uncommon)
                        }
                        HStack(spacing: 12) {
                            AppBadge.rarity(.rare)
                            AppBadge.rarity(.legendary)
                        }
                    }

                    Text("Colored background with white dot and text")
                        .font(.appCaption)
                        .foregroundColor(AppColors.textLight)
                }

                // Edibility badges
                VStack(alignment: .leading, spacing: 12) {
                    Text("Edibility Badges")
                        .font(.appHeadline)
                        .foregroundColor(AppColors.textDark)

                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            AppBadge.edibility(.edible)
                            AppBadge.edibility(.inedible)
                        }
                        HStack(spacing: 12) {
                            AppBadge.edibility(.caution)
                            AppBadge.edibility(.toxic)
                        }
                        HStack(spacing: 12) {
                            AppBadge.edibility(.deadly)
                        }
                    }

                    Text("Emoji icon with status text")
                        .font(.appCaption)
                        .foregroundColor(AppColors.textLight)
                }

                // Usage example
                VStack(alignment: .leading, spacing: 12) {
                    Text("Usage in Cards")
                        .font(.appHeadline)
                        .foregroundColor(AppColors.textDark)

                    AppCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Golden Chanterelle")
                                .font(.nunito(24, weight: .bold))
                                .foregroundColor(AppColors.textDark)

                            HStack(spacing: 12) {
                                AppBadge.rarity(.uncommon)
                                AppBadge.edibility(.edible)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                Spacer()
            }
            .padding(24)
        }
        .background(AppColors.background)
        .navigationTitle("Badges")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Mascot Showcase

struct MascotShowcase: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // All expressions
                VStack(alignment: .leading, spacing: 16) {
                    Text("Expressions")
                        .font(.appHeadline)
                        .foregroundColor(AppColors.textDark)

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20) {
                        ForEach(MascotView.Expression.allCases, id: \.self) { expression in
                            VStack(spacing: 8) {
                                MascotView(expression: expression, size: 80)

                                Text(expression.rawValue.capitalized)
                                    .font(.appCaption)
                                    .foregroundColor(AppColors.textLight)
                            }
                        }
                    }

                    Text("Placeholder artwork - will be replaced with commissioned art")
                        .font(.appCaption)
                        .foregroundColor(AppColors.textLight)
                }

                // Animated version
                VStack(alignment: .leading, spacing: 16) {
                    Text("Animated")
                        .font(.appHeadline)
                        .foregroundColor(AppColors.textDark)

                    HStack(spacing: 24) {
                        AnimatedMascotView(expression: .happy, size: 80)
                        AnimatedMascotView(expression: .excited, size: 80)
                    }
                    .frame(maxWidth: .infinity)

                    Text("Bouncy animation for attention")
                        .font(.appCaption)
                        .foregroundColor(AppColors.textLight)
                }

                // Size variations
                VStack(alignment: .leading, spacing: 16) {
                    Text("Sizes")
                        .font(.appHeadline)
                        .foregroundColor(AppColors.textDark)

                    HStack(spacing: 16) {
                        MascotView(expression: .happy, size: 40)
                        MascotView(expression: .happy, size: 60)
                        MascotView(expression: .happy, size: 80)
                        MascotView(expression: .happy, size: 100)
                    }

                    Text("Scales cleanly at any size")
                        .font(.appCaption)
                        .foregroundColor(AppColors.textLight)
                }

                Spacer()
            }
            .padding(24)
        }
        .background(AppColors.background)
        .navigationTitle("Mascot")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Warning Banner Showcase

struct WarningBannerShowcase: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Small disclaimer
                VStack(alignment: .leading, spacing: 12) {
                    Text("Small (Disclaimer)")
                        .font(.appHeadline)
                        .foregroundColor(AppColors.textDark)

                    WarningBanner.disclaimer(
                        "Never eat wild mushrooms based on app ID alone. Always consult an expert."
                    )

                    Text("Red tint, 1px border, centered bold text")
                        .font(.appCaption)
                        .foregroundColor(AppColors.textLight)
                }

                // Large warning with message
                VStack(alignment: .leading, spacing: 12) {
                    Text("Large (With Message)")
                        .font(.appHeadline)
                        .foregroundColor(AppColors.textDark)

                    WarningBanner.warning(
                        title: "Watch out for lookalikes!",
                        message: "False Chanterelle - note the true gills vs. ridges"
                    )

                    Text("Amber tint, 2px border, icon + title + body")
                        .font(.appCaption)
                        .foregroundColor(AppColors.textLight)
                }

                // Large warning without message
                VStack(alignment: .leading, spacing: 12) {
                    Text("Large (Title Only)")
                        .font(.appHeadline)
                        .foregroundColor(AppColors.textDark)

                    WarningBanner.warning(
                        title: "This species can be confused with toxic varieties"
                    )

                    Text("Message is optional")
                        .font(.appCaption)
                        .foregroundColor(AppColors.textLight)
                }

                Spacer()
            }
            .padding(24)
        }
        .background(AppColors.background)
        .navigationTitle("Warning Banner")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Progress Indicator Showcase

struct ProgressIndicatorShowcase: View {
    @State private var currentStep = 0
    let totalSteps = 4

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Static examples
                VStack(alignment: .leading, spacing: 16) {
                    Text("Step Positions")
                        .font(.appHeadline)
                        .foregroundColor(AppColors.textDark)

                    VStack(spacing: 16) {
                        ForEach(0..<4) { step in
                            HStack {
                                Text("Step \(step + 1) of 4")
                                    .font(.appCaption)
                                    .foregroundColor(AppColors.textLight)
                                    .frame(width: 80, alignment: .leading)

                                ProgressIndicator(totalSteps: 4, currentStep: step)
                            }
                        }
                    }

                    Text("Active step is elongated, inactive are small dots")
                        .font(.appCaption)
                        .foregroundColor(AppColors.textLight)
                }

                // Interactive demo
                VStack(alignment: .leading, spacing: 16) {
                    Text("Interactive Demo")
                        .font(.appHeadline)
                        .foregroundColor(AppColors.textDark)

                    VStack(spacing: 24) {
                        ProgressIndicator(totalSteps: totalSteps, currentStep: currentStep)

                        AppButton(currentStep < totalSteps - 1 ? "Continue" : "Start Over", style: .secondary) {
                            withAnimation {
                                if currentStep < totalSteps - 1 {
                                    currentStep += 1
                                } else {
                                    currentStep = 0
                                }
                            }
                        }
                    }

                    Text("Tap button to see smooth animation")
                        .font(.appCaption)
                        .foregroundColor(AppColors.textLight)
                }

                Spacer()
            }
            .padding(24)
        }
        .background(AppColors.background)
        .navigationTitle("Progress Indicator")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Tab Bar Showcase

struct TabBarShowcase: View {
    @State private var selectedTab: Tab = .home

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    // Description
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Custom Tab Bar")
                            .font(.appHeadline)
                            .foregroundColor(AppColors.textDark)

                        Text("5 tabs with raised center scan button. Scan opens camera modally instead of switching tabs.")
                            .font(.appBody)
                            .foregroundColor(AppColors.textLight)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Current selection
                    AppCard {
                        VStack(spacing: 8) {
                            Text("Selected Tab")
                                .font(.appCaption)
                                .foregroundColor(AppColors.textLight)

                            Text(selectedTab.title)
                                .font(.nunito(24, weight: .bold))
                                .foregroundColor(AppColors.primaryGreen)
                        }
                        .frame(maxWidth: .infinity)
                    }

                    // Specs
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Specs")
                            .font(.appHeadline)
                            .foregroundColor(AppColors.textDark)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("• Content height: 64px")
                            Text("• Scan button: 80px diameter")
                            Text("• Scan button offset: -26px")
                            Text("• Bottom padding: 20px")
                            Text("• Unselected color: #A8B5A8")
                        }
                        .font(.appCaption)
                        .foregroundColor(AppColors.textLight)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer(minLength: 120)
                }
                .padding(24)
            }

            // Actual tab bar
            CustomTabBar(
                selectedTab: $selectedTab,
                onScanTapped: {
                    // Show alert in showcase
                },
                bottomSafeArea: 0
            )
        }
        .background(AppColors.background)
        .navigationTitle("Tab Bar")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Page Header Showcase

struct PageHeaderShowcase: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Default (Left Aligned)")
                        .font(.appHeadline)
                        .foregroundColor(AppColors.textDark)

                    PageHeader(title: "My Collection")

                    Text("Nunito Bold 24px, left aligned")
                        .font(.appCaption)
                        .foregroundColor(AppColors.textLight)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Center Aligned")
                        .font(.appHeadline)
                        .foregroundColor(AppColors.textDark)

                    PageHeader(title: "Settings", alignment: .center)

                    Text("Optional center alignment")
                        .font(.appCaption)
                        .foregroundColor(AppColors.textLight)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Various Titles")
                        .font(.appHeadline)
                        .foregroundColor(AppColors.textDark)

                    VStack(spacing: 16) {
                        PageHeader(title: "Home")
                        PageHeader(title: "Profile")
                        PageHeader(title: "Explore Map")
                    }
                }

                Spacer()
            }
            .padding(24)
        }
        .background(AppColors.background)
        .navigationTitle("Page Header")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Collection Progress Showcase

struct CollectionProgressShowcase: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Standard Progress")
                        .font(.appHeadline)
                        .foregroundColor(AppColors.textDark)

                    CollectionProgress(
                        region: "Pacific Northwest",
                        discoveredCount: 12,
                        totalCount: 45
                    )

                    Text("Shows region, count, and progress bar")
                        .font(.appCaption)
                        .foregroundColor(AppColors.textLight)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Various States")
                        .font(.appHeadline)
                        .foregroundColor(AppColors.textDark)

                    CollectionProgress(
                        region: "Just Started",
                        discoveredCount: 2,
                        totalCount: 50
                    )

                    CollectionProgress(
                        region: "Halfway There",
                        discoveredCount: 25,
                        totalCount: 50
                    )

                    CollectionProgress(
                        region: "Almost Complete!",
                        discoveredCount: 48,
                        totalCount: 50
                    )

                    CollectionProgress(
                        region: "Complete!",
                        discoveredCount: 30,
                        totalCount: 30
                    )
                }

                Spacer()
            }
            .padding(24)
        }
        .background(AppColors.background)
        .navigationTitle("Collection Progress")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Collection Tabs Showcase

struct CollectionTabsShowcase: View {
    @State private var selectedMode: CollectionViewMode = .allSpecies

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Segmented Toggle")
                        .font(.appHeadline)
                        .foregroundColor(AppColors.textDark)

                    CollectionTabs(selectedMode: $selectedMode)

                    Text("Selected: \(selectedMode.rawValue)")
                        .font(.appCaption)
                        .foregroundColor(AppColors.textLight)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Specs")
                        .font(.appHeadline)
                        .foregroundColor(AppColors.textDark)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("• Cream background")
                        Text("• Green fill on selected")
                        Text("• Nunito Semibold 14px")
                        Text("• Spring animation on tap")
                    }
                    .font(.appCaption)
                    .foregroundColor(AppColors.textLight)
                }

                Spacer()
            }
            .padding(24)
        }
        .background(AppColors.background)
        .navigationTitle("Collection Tabs")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Rarity Filters Showcase

struct RarityFiltersShowcase: View {
    @State private var selectedRarities: Set<Rarity> = []

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Filter Pills")
                        .font(.appHeadline)
                        .foregroundColor(AppColors.textDark)

                    RarityFilters(selectedRarities: $selectedRarities)

                    Text("Selected: \(selectedRarities.isEmpty ? "All" : selectedRarities.map { $0.rawValue.capitalized }.joined(separator: ", "))")
                        .font(.appCaption)
                        .foregroundColor(AppColors.textLight)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Features")
                        .font(.appHeadline)
                        .foregroundColor(AppColors.textDark)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("• Compact pills fit on one line")
                        Text("• Multi-select enabled")
                        Text("• \"All\" resets selection")
                        Text("• Rarity color dots (white when selected)")
                        Text("• Capsule shape pills")
                    }
                    .font(.appCaption)
                    .foregroundColor(AppColors.textLight)
                }

                Spacer()
            }
            .padding(24)
        }
        .background(AppColors.background)
        .navigationTitle("Rarity Filters")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Coming Soon Placeholder

struct ComingSoonView: View {
    let name: String

    var body: some View {
        VStack(spacing: 16) {
            Text("🚧")
                .font(.system(size: 64))

            Text("\(name)")
                .font(.appHeadline)
                .foregroundColor(AppColors.textDark)

            Text("Component not yet created")
                .font(.appBody)
                .foregroundColor(AppColors.textLight)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
        .navigationTitle(name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ComponentShowcaseView()
}
