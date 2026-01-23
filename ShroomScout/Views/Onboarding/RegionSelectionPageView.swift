//
//  RegionSelectionPageView.swift
//  ShroomScout
//
//  Onboarding screen for selecting your foraging region.
//

import SwiftUI

struct RegionSelectionPageView: View {
    @Binding var selectedRegion: String
    @State private var isAnimating = false

    private var activeRegions: [Region] {
        Region.active
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Content container
            VStack(spacing: 24) {
                // Mascot
                MascotView(expression: .happy, size: 120)
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                    .opacity(isAnimating ? 1.0 : 0.0)

                // Text content
                VStack(spacing: 8) {
                    Text("Where do you forage?")
                        .font(.nunito(30, weight: .bold))
                        .foregroundColor(AppColors.textDark)
                        .multilineTextAlignment(.center)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : 20)

                    Text("We'll show you mushrooms found in your area")
                        .font(.nunito(16, weight: .regular))
                        .foregroundColor(AppColors.textLight)
                        .multilineTextAlignment(.center)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : 20)
                }

                // Region options
                VStack(spacing: 12) {
                    ForEach(activeRegions) { region in
                        regionButton(for: region)
                            .opacity(isAnimating ? 1.0 : 0.0)
                            .offset(y: isAnimating ? 0 : 20)
                            .animation(
                                .spring(response: 0.6, dampingFraction: 0.7)
                                    .delay(0.3 + Double(activeRegions.firstIndex(of: region) ?? 0) * 0.1),
                                value: isAnimating
                            )
                    }
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 24)

            Spacer()
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                isAnimating = true
            }
        }
    }

    // MARK: - Region Button

    private func regionButton(for region: Region) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                selectedRegion = region.id
            }
        } label: {
            HStack(spacing: 16) {
                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(
                            selectedRegion == region.id ? AppColors.primaryGreen : AppColors.textLight.opacity(0.3),
                            lineWidth: 2
                        )
                        .frame(width: 24, height: 24)

                    if selectedRegion == region.id {
                        Circle()
                            .fill(AppColors.primaryGreen)
                            .frame(width: 14, height: 14)
                    }
                }

                // Region info
                VStack(alignment: .leading, spacing: 2) {
                    Text(region.name)
                        .font(.nunito(16, weight: .semibold))
                        .foregroundColor(AppColors.textDark)

                    Text(region.description)
                        .font(.nunito(13, weight: .regular))
                        .foregroundColor(AppColors.textLight)
                }

                Spacer()
            }
            .padding(16)
            .background(
                selectedRegion == region.id
                    ? AppColors.primaryGreen.opacity(0.1)
                    : AppColors.cream
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        selectedRegion == region.id ? AppColors.primaryGreen : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedRegion = "pnw"

        var body: some View {
            RegionSelectionPageView(selectedRegion: $selectedRegion)
                .background(AppColors.background)
        }
    }

    return PreviewWrapper()
}
