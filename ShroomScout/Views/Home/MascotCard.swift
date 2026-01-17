//
//  MascotCard.swift
//  ShroomScout
//
//  Home screen mascot card with speech bubble message.
//  Uses the existing AppCard and MascotView components.
//

import SwiftUI

struct MascotCard: View {
    /// The message displayed in the speech bubble
    let message: String

    /// The mascot expression to display
    var expression: MascotView.Expression = .happy

    /// Size of the mascot
    var mascotSize: CGFloat = 128

    var body: some View {
        ZStack {
            // Background card with cream color
            RoundedRectangle(cornerRadius: 24)
                .fill(AppColors.cream)
                .shadow(
                    color: .black.opacity(0.1),
                    radius: 7.5,
                    x: 0,
                    y: 5
                )

            // Decorative coral blur accent
            Circle()
                .fill(AppColors.coral.opacity(0.1))
                .blur(radius: 60)
                .frame(width: 128, height: 128)
                .offset(x: 100, y: -20)

            // Content
            HStack(spacing: 0) {
                // Mascot on the left
                MascotView(expression: expression, size: mascotSize)
                    .padding(.leading, 24)

                Spacer()

                // Speech bubble on the right
                SpeechBubble(message: message)
                    .padding(.trailing, 24)
                    .padding(.vertical, 24)
            }
        }
        .frame(height: 176)
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
                .shadow(
                    color: .black.opacity(0.1),
                    radius: 3,
                    x: 0,
                    y: 1
                )
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

#Preview {
    VStack(spacing: 24) {
        MascotCard(
            message: "Let's find something new today!",
            expression: .happy
        )

        MascotCard(
            message: "You found 3 new species this week!",
            expression: .excited
        )

        MascotCard(
            message: "Ready to explore the forest?",
            expression: .curious
        )
    }
    .padding(24)
    .background(AppColors.background)
}
