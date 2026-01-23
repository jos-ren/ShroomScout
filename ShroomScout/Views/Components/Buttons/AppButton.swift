//
//  AppButton.swift
//  ShroomScout
//
//  Reusable button component with primary and secondary variants.
//  Features a 3D raised effect with darker bottom edge.
//

import SwiftUI

struct AppButton: View {
    enum Style {
        case primary
        case secondary
    }

    let title: String
    let style: Style
    let icon: String?
    let action: () -> Void

    init(_ title: String, style: Style = .primary, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.icon = icon
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

    private var shadowColor: Color {
        switch style {
        case .primary:
            return Color(hex: "D9664E") // Darker coral
        case .secondary:
            return Color(hex: "3A6247") // Darker green
        }
    }

    private var fontSize: CGFloat {
        return 16
    }

    private var buttonHeight: CGFloat {
        return 56
    }

    private var shadowOffset: CGFloat {
        return 6
    }

    private var cornerRadius: CGFloat {
        return 16
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                // Bottom shadow layer (darker color offset down)
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(shadowColor)
                    .frame(height: buttonHeight)
                    .offset(y: shadowOffset)

                // Main button layer
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
                    .frame(height: buttonHeight)

                // Button content (icon + text)
                HStack(spacing: 8) {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: fontSize, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Text(title)
                        .font(.nunito(fontSize, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: buttonHeight + shadowOffset)
            .contentShape(Rectangle())
        }
        .buttonStyle(BounceButtonStyle3D(shadowOffset: shadowOffset))
    }
}

/// Bouncy button style with 3D press effect
struct BounceButtonStyle3D: ButtonStyle {
    let shadowOffset: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .offset(y: configuration.isPressed ? shadowOffset * 0.6 : 0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
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
        
        AppButton("View Species Details", style: .primary, icon: "leaf.fill") {
            print("With icon tapped!")
        }
    }
    .padding(.horizontal, 24)
    .padding(.vertical, 40)
    .background(AppColors.background)
}
