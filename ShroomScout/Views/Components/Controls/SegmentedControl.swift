//
//  SegmentedControl.swift
//  ShroomScout
//
//  Reusable segmented control with 3D raised button style.
//  Works with any CaseIterable enum that has String raw values.
//

import SwiftUI

struct SegmentedControl<Option: RawRepresentable & CaseIterable & Hashable>: View where Option.RawValue == String, Option.AllCases: RandomAccessCollection {
    @Binding var selected: Option

    private let height: CGFloat = 36
    private let cornerRadius: CGFloat = 12
    private let shadowOffset: CGFloat = 4

    var body: some View {
        HStack(spacing: 6) {
            ForEach(Array(Option.allCases), id: \.self) { option in
                SegmentButton(
                    title: option.rawValue,
                    isSelected: selected == option,
                    height: height,
                    cornerRadius: cornerRadius,
                    shadowOffset: shadowOffset
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selected = option
                    }
                }
            }
        }
    }
}

// MARK: - Segment Button

private struct SegmentButton: View {
    let title: String
    let isSelected: Bool
    let height: CGFloat
    let cornerRadius: CGFloat
    let shadowOffset: CGFloat
    let action: () -> Void

    private var backgroundColor: Color {
        isSelected ? AppColors.primaryGreen : .white
    }

    private var shadowColor: Color {
        isSelected ? Color(hex: "3A6247") : Color(hex: "E5E5E5")
    }

    private var textColor: Color {
        isSelected ? .white : AppColors.textDark
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                // Shadow layer
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(shadowColor)
                    .frame(height: height)
                    .offset(y: shadowOffset)

                // Main layer
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
                    .frame(height: height)

                // Text
                Text(title)
                    .font(.nunito(14, weight: .semibold))
                    .foregroundColor(textColor)
            }
            .frame(maxWidth: .infinity)
            .frame(height: height + shadowOffset)
        }
        .buttonStyle(SegmentButtonStyle(shadowOffset: shadowOffset))
    }
}

// MARK: - Button Style

private struct SegmentButtonStyle: ButtonStyle {
    let shadowOffset: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .offset(y: configuration.isPressed ? shadowOffset * 0.6 : 0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Preview

private enum PreviewOption: String, CaseIterable {
    case optionA = "Option A"
    case optionB = "Option B"
}

private enum ThreeOptions: String, CaseIterable {
    case first = "First"
    case second = "Second"
    case third = "Third"
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selected: PreviewOption = .optionA
        @State private var threeSelected: ThreeOptions = .first

        var body: some View {
            VStack(spacing: 32) {
                VStack(spacing: 12) {
                    Text("Two Options")
                        .font(.nunito(16, weight: .bold))
                        .foregroundColor(AppColors.textDark)

                    SegmentedControl(selected: $selected)

                    Text("Selected: \(selected.rawValue)")
                        .font(.nunito(14, weight: .regular))
                        .foregroundColor(AppColors.textLight)
                }

                VStack(spacing: 12) {
                    Text("Three Options")
                        .font(.nunito(16, weight: .bold))
                        .foregroundColor(AppColors.textDark)

                    SegmentedControl(selected: $threeSelected)

                    Text("Selected: \(threeSelected.rawValue)")
                        .font(.nunito(14, weight: .regular))
                        .foregroundColor(AppColors.textLight)
                }
            }
            .padding(24)
            .background(AppColors.background)
        }
    }

    return PreviewWrapper()
}
