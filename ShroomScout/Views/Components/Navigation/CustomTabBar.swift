//
//  CustomTabBar.swift
//  ShroomScout
//
//  Custom tab bar with 5 tabs and raised center hexagonal scan button.
//  Features curved top edge wrapping around the center button.
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

// MARK: - Rounded Hexagon Shape

struct HexagonShape: Shape {
    var cornerRadius: CGFloat = 8

    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        let centerX = rect.midX
        let centerY = rect.midY

        // Pointy-top hexagon with rounded corners
        let radius = min(width, height) / 2
        var points: [CGPoint] = []

        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3 - .pi / 2
            let x = centerX + radius * cos(angle)
            let y = centerY + radius * sin(angle)
            points.append(CGPoint(x: x, y: y))
        }

        var path = Path()

        for i in 0..<6 {
            let current = points[i]
            let next = points[(i + 1) % 6]
            let prev = points[(i + 5) % 6]

            // Vector from current to previous
            let toPrev = CGPoint(x: prev.x - current.x, y: prev.y - current.y)
            let toPrevLen = sqrt(toPrev.x * toPrev.x + toPrev.y * toPrev.y)
            let toPrevNorm = CGPoint(x: toPrev.x / toPrevLen, y: toPrev.y / toPrevLen)

            // Vector from current to next
            let toNext = CGPoint(x: next.x - current.x, y: next.y - current.y)
            let toNextLen = sqrt(toNext.x * toNext.x + toNext.y * toNext.y)
            let toNextNorm = CGPoint(x: toNext.x / toNextLen, y: toNext.y / toNextLen)

            // Start and end points of the rounded corner
            let cornerStart = CGPoint(
                x: current.x + toPrevNorm.x * cornerRadius,
                y: current.y + toPrevNorm.y * cornerRadius
            )
            let cornerEnd = CGPoint(
                x: current.x + toNextNorm.x * cornerRadius,
                y: current.y + toNextNorm.y * cornerRadius
            )

            if i == 0 {
                path.move(to: cornerStart)
            } else {
                path.addLine(to: cornerStart)
            }

            path.addQuadCurve(to: cornerEnd, control: current)
        }

        path.closeSubpath()
        return path
    }
}

// MARK: - Tab Bar Background Shape (with curved notch for hexagon)

struct TabBarBackgroundShape: Shape {
    let notchWidth: CGFloat
    let notchHeight: CGFloat
    let cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let centerX = rect.midX
        let notchRadius = notchWidth / 2

        // Start from top-left with corner radius
        path.move(to: CGPoint(x: 0, y: cornerRadius))
        path.addQuadCurve(
            to: CGPoint(x: cornerRadius, y: 0),
            control: CGPoint(x: 0, y: 0)
        )

        // Top edge to notch start
        let notchStartX = centerX - notchRadius - 10
        path.addLine(to: CGPoint(x: notchStartX, y: 0))

        // Curve up and around the notch (smooth arc going UP)
        path.addQuadCurve(
            to: CGPoint(x: centerX - notchRadius * 0.6, y: -notchHeight * 0.5),
            control: CGPoint(x: centerX - notchRadius, y: 0)
        )

        // Top of notch curve
        path.addQuadCurve(
            to: CGPoint(x: centerX + notchRadius * 0.6, y: -notchHeight * 0.5),
            control: CGPoint(x: centerX, y: -notchHeight)
        )

        // Curve back down
        path.addQuadCurve(
            to: CGPoint(x: centerX + notchRadius + 10, y: 0),
            control: CGPoint(x: centerX + notchRadius, y: 0)
        )

        // Top edge to top-right corner
        path.addLine(to: CGPoint(x: rect.width - cornerRadius, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: rect.width, y: cornerRadius),
            control: CGPoint(x: rect.width, y: 0)
        )

        // Right edge down
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))

        // Bottom edge
        path.addLine(to: CGPoint(x: 0, y: rect.height))

        // Left edge up
        path.closeSubpath()

        return path
    }
}

// MARK: - Tab Bar Constants

private enum TabBarConstants {
    static let contentHeight: CGFloat = 70
    static let scanButtonSize: CGFloat = 64
    static let notchHeight: CGFloat = 28
    static let bottomPadding: CGFloat = 8
    static let tabItemHeight: CGFloat = 70 // Match contentHeight so selected background fills to top
    static let cornerRadius: CGFloat = 12
    static let hexCornerRadius: CGFloat = 10

    // Colors
    static let backgroundColor = Color(hex: "D9664E") // Darker coral
    static let topEdgeColor = Color(hex: "B8503D") // Even darker for 3D top edge
    static let selectedBackground = Color(hex: "E57A62") // Lighter coral for selected
    static let selectedTopLine = Color(hex: "FFB8A8") // Light line at top when selected
    static let scanButtonColor = Color(hex: "FF8A6C") // Coral
    static let scanButtonShadowColor = Color(hex: "D9664E") // Darker coral
}

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    var onScanTapped: () -> Void
    var bottomSafeArea: CGFloat = 0

    private var totalHeight: CGFloat {
        TabBarConstants.contentHeight + bottomSafeArea + TabBarConstants.bottomPadding
    }

    var body: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let tabWidth = (totalWidth - TabBarConstants.scanButtonSize - 20) / 4

            ZStack(alignment: .top) {
                // Background that extends into safe area (behind everything)
                TabBarConstants.backgroundColor
                    .ignoresSafeArea(edges: .bottom)

                VStack(spacing: 0) {
                    ZStack(alignment: .top) {
                        // Main background with notch
                        TabBarBackgroundShape(
                            notchWidth: TabBarConstants.scanButtonSize + 20,
                            notchHeight: TabBarConstants.notchHeight,
                            cornerRadius: TabBarConstants.cornerRadius
                        )
                        .fill(TabBarConstants.backgroundColor)
                        .frame(height: TabBarConstants.contentHeight)

                        // Tab items row
                        HStack(spacing: 0) {
                            tabItem(for: .home, width: tabWidth)
                            tabItem(for: .collection, width: tabWidth)

                            // Spacer for center button
                            Spacer()
                                .frame(width: TabBarConstants.scanButtonSize + 20)

                            tabItem(for: .map, width: tabWidth)
                            tabItem(for: .profile, width: tabWidth)
                        }

                        // Center hexagon scan button
                        scanButton
                            .position(x: totalWidth / 2, y: TabBarConstants.scanButtonSize / 2 - 8)
                    }
                    .frame(height: TabBarConstants.contentHeight)

                    Spacer()
                }
            }
        }
        .frame(height: totalHeight)
    }

    // MARK: - Tab Item

    private func tabItem(for tab: Tab, width: CGFloat) -> some View {
        let isSelected = selectedTab == tab

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 0) {
                // Selected top line indicator
                Rectangle()
                    .fill(isSelected ? TabBarConstants.selectedTopLine : Color.clear)
                    .frame(height: 3)

                // Content area
                VStack(spacing: 4) {
                    Image(systemName: tab.icon)
                        .font(.system(size: 22, weight: .medium))

                    Text(tab.title)
                        .font(.nunito(10, weight: .semibold))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: width, height: TabBarConstants.tabItemHeight)
            .background(isSelected ? TabBarConstants.selectedBackground : Color.clear)
            .foregroundColor(.white)
        }
        .buttonStyle(TabItemButtonStyle())
    }

    // MARK: - Scan Button

    private var scanButton: some View {
        Button {
            onScanTapped()
        } label: {
            ZStack {
                // Shadow layer
                HexagonShape(cornerRadius: TabBarConstants.hexCornerRadius)
                    .fill(TabBarConstants.scanButtonShadowColor)
                    .frame(width: TabBarConstants.scanButtonSize, height: TabBarConstants.scanButtonSize)
                    .offset(y: 5)

                // Main button
                HexagonShape(cornerRadius: TabBarConstants.hexCornerRadius)
                    .fill(TabBarConstants.scanButtonColor)
                    .frame(width: TabBarConstants.scanButtonSize, height: TabBarConstants.scanButtonSize)

                Image(systemName: "camera.fill")
                    .font(.system(size: 26, weight: .semibold))
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
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

private struct ScanButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .offset(y: configuration.isPressed ? 3 : 0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Tab Bar Container

/// Main container view that combines content with custom tab bar
struct TabBarContainer<Content: View>: View {
    @Binding var selectedTab: Tab
    var onScanTapped: () -> Void
    @ViewBuilder let content: () -> Content

    private let tabBarContentHeight: CGFloat = 78 // 70 content + 8 bottom padding

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

    private let buttonSize: CGFloat = 64
    private let hexCornerRadius: CGFloat = 10
    private let shadowColor = Color(hex: "D9664E")
    private let buttonColor = Color(hex: "FF8A6C")

    var body: some View {
        Button {
            onTap()
        } label: {
            ZStack {
                // Pulse ring
                HexagonShape(cornerRadius: hexCornerRadius)
                    .stroke(buttonColor.opacity(0.3), lineWidth: 2)
                    .frame(width: buttonSize + 20, height: buttonSize + 20)
                    .scaleEffect(isPulsing ? 1.3 : 1.0)
                    .opacity(isPulsing ? 0 : 0.5)

                // Shadow layer
                HexagonShape(cornerRadius: hexCornerRadius)
                    .fill(shadowColor)
                    .frame(width: buttonSize, height: buttonSize)
                    .offset(y: 5)

                // Main button
                HexagonShape(cornerRadius: hexCornerRadius)
                    .fill(buttonColor)
                    .frame(width: buttonSize, height: buttonSize)

                Image(systemName: "camera.fill")
                    .font(.system(size: 26, weight: .semibold))
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
