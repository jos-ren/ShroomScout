//
//  MapView.swift
//  ShroomScout
//
//  Map tab placeholder view.
//

import SwiftUI

struct MapView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                PageHeader(title: "Map")

                // Placeholder content
                VStack(spacing: 16) {
                    MascotView(expression: .encouraging, size: 120)

                    Text("Explore Nearby")
                        .font(.nunito(18, weight: .bold))
                        .foregroundColor(AppColors.textDark)

                    Text("Discover mushroom hotspots and sightings in your area.")
                        .font(.nunito(14, weight: .regular))
                        .foregroundColor(AppColors.textLight)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    // Placeholder map area
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppColors.cream)
                        .frame(height: 300)
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: "map.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(AppColors.primaryGreen.opacity(0.3))

                                Text("Map Coming Soon")
                                    .font(.nunito(14, weight: .semibold))
                                    .foregroundColor(AppColors.textLight)
                            }
                        )
                }
                .padding(.top, 40)

                Spacer(minLength: 100)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
        .background(AppColors.background)
    }
}

#Preview {
    MapView()
}
