//
//  CollectionProgress.swift
//  ShroomScout
//
//  Shows collection progress with region, count, and progress bar.
//

import SwiftUI

struct CollectionProgress: View {
    let region: String
    let discoveredCount: Int
    let totalCount: Int

    private var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(discoveredCount) / Double(totalCount)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Region and count row
            HStack {
                Text(region)
                    .font(.nunito(14, weight: .semibold))
                    .foregroundColor(AppColors.textLight)

                Spacer()

                Text("\(discoveredCount)/\(totalCount) discovered")
                    .font(.nunito(14, weight: .bold))
                    .foregroundColor(AppColors.primaryGreen)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 6)
                        .fill(AppColors.primaryGreen.opacity(0.15))
                        .frame(height: 12)

                    // Progress fill
                    RoundedRectangle(cornerRadius: 6)
                        .fill(AppColors.primaryGreen)
                        .frame(width: geometry.size.width * progress, height: 12)
                }
            }
            .frame(height: 12)
        }
        .padding(16)
        .background(AppColors.cream)
        .cornerRadius(16)
    }
}

#Preview {
    VStack(spacing: 16) {
        CollectionProgress(
            region: "Pacific Northwest",
            discoveredCount: 12,
            totalCount: 45
        )

        CollectionProgress(
            region: "California",
            discoveredCount: 5,
            totalCount: 30
        )

        CollectionProgress(
            region: "Northeast",
            discoveredCount: 30,
            totalCount: 30
        )

        CollectionProgress(
            region: "Just Started",
            discoveredCount: 0,
            totalCount: 50
        )
    }
    .padding(24)
    .background(AppColors.background)
}
