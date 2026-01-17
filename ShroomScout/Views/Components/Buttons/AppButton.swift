//
//  AppButton.swift
//  ShroomScout
//
//  Reusable button component with primary and secondary variants.
//

import SwiftUI

struct AppButton: View {
    enum Style {
        case primary
        case secondary
    }

    let title: String
    let style: Style
    let action: () -> Void

    init(_ title: String, style: Style = .primary, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.action = action
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:
            return AppColors.coral
        case .secondary:
            return AppColors.primaryGreen
        }
    }

    private var fontSize: CGFloat {
        switch style {
        case .primary:
            return 18
        case .secondary:
            return 16
        }
    }

    private var buttonHeight: CGFloat {
        switch style {
        case .primary:
            return 60
        case .secondary:
            return 56
        }
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.nunito(fontSize, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: buttonHeight)
                .background(backgroundColor)
                .cornerRadius(buttonHeight / 2)
                .shadow(
                    color: .black.opacity(0.1),
                    radius: 7.5,
                    x: 0,
                    y: 5
                )
        }
        .buttonStyle(BounceButtonStyle())
    }
}

/// Reusable bouncy button style for press animations
struct BounceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: 20) {
        AppButton("Scan Mushroom", style: .primary) {
            print("Primary tapped!")
        }

        AppButton("View Collection", style: .secondary) {
            print("Secondary tapped!")
        }
    }
    .padding(.horizontal, 24)
    .padding(.vertical, 40)
    .background(AppColors.background)
}
