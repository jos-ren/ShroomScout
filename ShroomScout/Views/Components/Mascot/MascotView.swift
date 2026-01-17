//
//  MascotView.swift
//  ShroomScout
//
//  Placeholder mascot component - will be replaced with commissioned artwork.
//  Supports multiple expressions for different app states.
//

import SwiftUI

struct MascotView: View {
    enum Expression: String, CaseIterable {
        case happy       // Default, general positive state
        case curious     // Searching, scanning, exploring
        case excited     // Found something, celebration
        case cautious    // Warning, toxic mushroom
        case encouraging // Empty states, motivating user
    }

    let expression: Expression
    var size: CGFloat = 80

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(backgroundColor)
                .frame(width: size, height: size)

            // Mascot face
            VStack(spacing: size * 0.02) {
                // Cap (top of mushroom)
                ZStack {
                    // Mushroom cap shape
                    Capsule()
                        .fill(capColor)
                        .frame(width: size * 0.6, height: size * 0.35)
                        .offset(y: -size * 0.08)

                    // Spots on cap
                    HStack(spacing: size * 0.08) {
                        Circle()
                            .fill(.white.opacity(0.6))
                            .frame(width: size * 0.08, height: size * 0.08)
                        Circle()
                            .fill(.white.opacity(0.6))
                            .frame(width: size * 0.06, height: size * 0.06)
                            .offset(y: -size * 0.04)
                    }
                    .offset(y: -size * 0.1)
                }

                // Face
                VStack(spacing: size * 0.04) {
                    // Eyes
                    HStack(spacing: size * 0.12) {
                        EyeView(expression: expression, size: size * 0.12)
                        EyeView(expression: expression, size: size * 0.12)
                    }

                    // Mouth
                    MouthView(expression: expression, size: size * 0.15)
                }
                .offset(y: -size * 0.02)
            }

            // Expression accents
            expressionAccents
        }
        .frame(width: size, height: size)
    }

    // MARK: - Colors

    private var backgroundColor: Color {
        switch expression {
        case .happy:
            return AppColors.cream
        case .curious:
            return AppColors.cream
        case .excited:
            return AppColors.rarityLegendary.opacity(0.3)
        case .cautious:
            return AppColors.caution.opacity(0.2)
        case .encouraging:
            return AppColors.primaryGreen.opacity(0.15)
        }
    }

    private var capColor: Color {
        switch expression {
        case .happy, .curious, .encouraging:
            return AppColors.coral
        case .excited:
            return AppColors.rarityLegendary
        case .cautious:
            return AppColors.caution
        }
    }

    // MARK: - Expression Accents

    @ViewBuilder
    private var expressionAccents: some View {
        switch expression {
        case .happy:
            EmptyView()

        case .curious:
            // Question mark
            Text("?")
                .font(.nunito(size * 0.25, weight: .bold))
                .foregroundColor(AppColors.primaryGreen)
                .offset(x: size * 0.4, y: -size * 0.35)

        case .excited:
            // Sparkles
            Group {
                sparkle
                    .offset(x: -size * 0.45, y: -size * 0.3)
                sparkle
                    .offset(x: size * 0.45, y: -size * 0.25)
                    .scaleEffect(0.7)
                sparkle
                    .offset(x: size * 0.35, y: size * 0.35)
                    .scaleEffect(0.5)
            }

        case .cautious:
            // Warning triangle
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: size * 0.2))
                .foregroundColor(AppColors.caution)
                .offset(x: size * 0.4, y: -size * 0.35)

        case .encouraging:
            // Thumbs up / sparkle
            Text("✨")
                .font(.system(size: size * 0.2))
                .offset(x: size * 0.4, y: -size * 0.3)
        }
    }

    private var sparkle: some View {
        Image(systemName: "sparkle")
            .font(.system(size: size * 0.15, weight: .bold))
            .foregroundColor(AppColors.rarityLegendary)
    }
}

// MARK: - Eye View

private struct EyeView: View {
    let expression: MascotView.Expression
    let size: CGFloat

    var body: some View {
        ZStack {
            // Eye white
            Circle()
                .fill(.white)
                .frame(width: size, height: size)

            // Pupil
            Circle()
                .fill(AppColors.textDark)
                .frame(width: size * pupilScale, height: size * pupilScale)
                .offset(x: pupilOffset.x, y: pupilOffset.y)
        }
    }

    private var pupilScale: CGFloat {
        switch expression {
        case .happy, .encouraging:
            return 0.5
        case .curious:
            return 0.6
        case .excited:
            return 0.7
        case .cautious:
            return 0.4
        }
    }

    private var pupilOffset: CGPoint {
        switch expression {
        case .happy, .excited, .encouraging:
            return .zero
        case .curious:
            return CGPoint(x: size * 0.1, y: -size * 0.1)
        case .cautious:
            return CGPoint(x: 0, y: size * 0.1)
        }
    }
}

// MARK: - Mouth View

private struct MouthView: View {
    let expression: MascotView.Expression
    let size: CGFloat

    var body: some View {
        switch expression {
        case .happy, .encouraging:
            // Smile
            Arc(startAngle: .degrees(0), endAngle: .degrees(180))
                .stroke(AppColors.textDark, lineWidth: size * 0.15)
                .frame(width: size, height: size * 0.5)

        case .curious:
            // Small "o" mouth
            Circle()
                .stroke(AppColors.textDark, lineWidth: size * 0.12)
                .frame(width: size * 0.4, height: size * 0.4)

        case .excited:
            // Big open smile
            ZStack {
                Arc(startAngle: .degrees(0), endAngle: .degrees(180))
                    .fill(AppColors.textDark)
                    .frame(width: size * 1.2, height: size * 0.7)

                // Tongue
                Capsule()
                    .fill(AppColors.coral)
                    .frame(width: size * 0.4, height: size * 0.25)
                    .offset(y: size * 0.15)
            }

        case .cautious:
            // Worried squiggle
            Rectangle()
                .fill(AppColors.textDark)
                .frame(width: size * 0.8, height: size * 0.12)
                .cornerRadius(size * 0.06)
        }
    }
}

// MARK: - Arc Shape

private struct Arc: Shape {
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.minY),
            radius: rect.width / 2,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        return path
    }
}

// MARK: - Animated Mascot

struct AnimatedMascotView: View {
    let expression: MascotView.Expression
    var size: CGFloat = 80

    @State private var bounce = false

    var body: some View {
        MascotView(expression: expression, size: size)
            .scaleEffect(bounce ? 1.05 : 1.0)
            .animation(
                .spring(response: 0.6, dampingFraction: 0.5)
                    .repeatForever(autoreverses: true),
                value: bounce
            )
            .onAppear {
                bounce = true
            }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 32) {
            Text("Mascot Expressions")
                .font(.appTitle)
                .foregroundColor(AppColors.textDark)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 24) {
                ForEach(MascotView.Expression.allCases, id: \.self) { expression in
                    VStack(spacing: 12) {
                        MascotView(expression: expression, size: 100)

                        Text(expression.rawValue.capitalized)
                            .font(.appCallout)
                            .foregroundColor(AppColors.textDark)
                    }
                }
            }

            Divider()
                .padding(.vertical)

            Text("Animated Version")
                .font(.appHeadline)
                .foregroundColor(AppColors.textDark)

            AnimatedMascotView(expression: .excited, size: 120)

            Divider()
                .padding(.vertical)

            Text("Size Variations")
                .font(.appHeadline)
                .foregroundColor(AppColors.textDark)

            HStack(spacing: 24) {
                MascotView(expression: .happy, size: 40)
                MascotView(expression: .happy, size: 60)
                MascotView(expression: .happy, size: 80)
                MascotView(expression: .happy, size: 100)
            }
        }
        .padding(24)
    }
    .background(AppColors.background)
}
