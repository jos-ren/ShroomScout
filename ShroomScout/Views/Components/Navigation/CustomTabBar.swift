//
//  CustomTabBar.swift
//  ShroomScout
//
//  Custom tab bar with 5 tabs and raised center scan button.
//  Scan button opens camera modally, not as a tab.
//

import SwiftUI

enum Tab: Int, CaseIterable {
    case home
    case collection
    case scan
    case map
    case profile

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .collection: return "square.grid.2x2.fill"
        case .scan: return "camera.fill"
        case .map: return "map.fill"
        case .profile: return "person.fill"
        }
    }

    var title: String {
        switch self {
        case .home: return "Home"
        case .collection: return "Collection"
        case .scan: return "Scan"
        case .map: return "Map"
        case .profile: return "Profile"
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    var onScanTapped: () -> Void
    var bottomSafeArea: CGFloat = 0

    // Figma specs
    private let contentHeight: CGFloat = 64
    private let scanButtonSize: CGFloat = 80
    private let scanButtonOffset: CGFloat = -26
    private let bottomPadding: CGFloat = 20

    // Consistent tab bar background color
    private let tabBarBackground = Color(red: 250/255, green: 250/255, blue: 247/255)

    var body: some View {
        VStack(spacing: 0) {
            // Top border
            Rectangle()
                .fill(AppColors.primaryGreen.opacity(0.1))
                .frame(height: 1)

            ZStack(alignment: .top) {
                // Tab items - 5 equal width sections
                HStack(spacing: 0) {
                    tabItem(for: .home)
                        .frame(maxWidth: .infinity)
                        .padding(.leading, 12)

                    tabItem(for: .collection)
                        .frame(maxWidth: .infinity)
                        .offset(x: -4)

                    // Center placeholder (same width as other tabs)
                    Color.clear
                        .frame(maxWidth: .infinity)

                    tabItem(for: .map)
                        .frame(maxWidth: .infinity)
                        .offset(x: 4)

                    tabItem(for: .profile)
                        .frame(maxWidth: .infinity)
                        .padding(.trailing, 12)
                }
                .padding(.top, 6)

                // Raised scan button (centered)
                scanButton
                    .offset(y: scanButtonOffset)
            }
            .frame(height: contentHeight)

            // Extra bottom padding
            Spacer()
                .frame(height: bottomPadding)

            // Bottom safe area fill
            Spacer()
                .frame(height: bottomSafeArea)
        }
        .background(tabBarBackground)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: -2)
    }

    // MARK: - Tab Item

    private func tabItem(for tab: Tab) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 22))
                    .frame(width: 28, height: 28)

                Text(tab.title)
                    .font(.nunito(10, weight: .semibold))
            }
            .foregroundColor(selectedTab == tab ? AppColors.primaryGreen : Color(hex: "A8B5A8"))
        }
        .buttonStyle(TabItemButtonStyle())
    }

    // MARK: - Scan Button

    private var scanButton: some View {
        Button {
            onScanTapped()
        } label: {
            ZStack {
                Circle()
                    .fill(AppColors.coral)
                    .frame(width: scanButtonSize, height: scanButtonSize)
                    .shadow(color: AppColors.coral.opacity(0.5), radius: 24, x: 0, y: 8)

                Image(systemName: "camera.fill")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(ScanButtonStyle())
    }
}

// MARK: - Button Styles

private struct TabItemButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

private struct ScanButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Tab Bar Container

/// Main container view that combines content with custom tab bar
struct TabBarContainer<Content: View>: View {
    @Binding var selectedTab: Tab
    var onScanTapped: () -> Void
    @ViewBuilder let content: () -> Content

    private let tabBarContentHeight: CGFloat = 85 // 64 content + 1 border + 20 bottom padding

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Main content with bottom padding for tab bar
                content()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.bottom, tabBarContentHeight)

                // Tab bar at the bottom
                CustomTabBar(
                    selectedTab: $selectedTab,
                    onScanTapped: onScanTapped,
                    bottomSafeArea: geometry.safeAreaInsets.bottom
                )
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Animated Scan Button (with pulse)

struct AnimatedScanButton: View {
    let onTap: () -> Void

    @State private var isPulsing = false

    private let buttonSize: CGFloat = 80

    var body: some View {
        Button {
            onTap()
        } label: {
            ZStack {
                Circle()
                    .stroke(AppColors.coral.opacity(0.3), lineWidth: 2)
                    .frame(width: buttonSize + 20, height: buttonSize + 20)
                    .scaleEffect(isPulsing ? 1.3 : 1.0)
                    .opacity(isPulsing ? 0 : 0.5)

                Circle()
                    .fill(AppColors.coral)
                    .frame(width: buttonSize, height: buttonSize)
                    .shadow(color: AppColors.coral.opacity(0.5), radius: 24, x: 0, y: 8)

                Image(systemName: "camera.fill")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(ScanButtonStyle())
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.5)
                .repeatForever(autoreverses: false)
            ) {
                isPulsing = true
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedTab: Tab = .home
        @State private var showScanner = false

        var body: some View {
            TabBarContainer(selectedTab: $selectedTab, onScanTapped: {
                showScanner = true
            }) {
                ZStack {
                    AppColors.background

                    VStack(spacing: 16) {
                        Spacer()

                        Text("Selected Tab")
                            .font(.appHeadline)
                            .foregroundColor(AppColors.textDark)

                        Text(selectedTab.title)
                            .font(.appLargeTitle)
                            .foregroundColor(AppColors.primaryGreen)

                        if selectedTab == .home {
                            MascotView(expression: .happy, size: 100)
                        } else if selectedTab == .collection {
                            MascotView(expression: .curious, size: 100)
                        } else if selectedTab == .map {
                            MascotView(expression: .encouraging, size: 100)
                        } else if selectedTab == .profile {
                            MascotView(expression: .excited, size: 100)
                        }

                        Spacer()
                    }
                }
            }
            .sheet(isPresented: $showScanner) {
                VStack(spacing: 24) {
                    Text("Scanner")
                        .font(.appLargeTitle)
                        .foregroundColor(AppColors.textDark)

                    MascotView(expression: .curious, size: 120)

                    Text("Camera view would appear here")
                        .font(.appBody)
                        .foregroundColor(AppColors.textLight)

                    AppButton("Close", style: .secondary) {
                        showScanner = false
                    }
                }
                .padding(24)
            }
        }
    }

    return PreviewWrapper()
}
