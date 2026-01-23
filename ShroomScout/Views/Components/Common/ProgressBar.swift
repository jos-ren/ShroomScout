//
//  ProgressBar.swift
//  ShroomScout
//
//  Reusable progress bar component with customizable colors.
//

import SwiftUI

struct ProgressBar: View {
    let progress: Double
    var fillColor: Color = AppColors.primaryGreen
    var trackColor: Color? = nil
    var height: CGFloat = 12
    var cornerRadius: CGFloat = 6

    private var effectiveTrackColor: Color {
        trackColor ?? fillColor.opacity(0.15)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(effectiveTrackColor)
                    .frame(height: height)

                // Progress fill
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(fillColor)
                    .frame(width: geometry.size.width * min(max(progress, 0), 1), height: height)
            }
        }
        .frame(height: height)
    }
}

#Preview {
    VStack(spacing: 24) {
        VStack(alignment: .leading, spacing: 8) {
            Text("Default (Green)")
                .font(.nunito(14, weight: .semibold))
                .foregroundColor(AppColors.textDark)

            ProgressBar(progress: 0.6)
        }

        VStack(alignment: .leading, spacing: 8) {
            Text("Various Progress")
                .font(.nunito(14, weight: .semibold))
                .foregroundColor(AppColors.textDark)

            ProgressBar(progress: 0.0)
            ProgressBar(progress: 0.25)
            ProgressBar(progress: 0.5)
            ProgressBar(progress: 0.75)
            ProgressBar(progress: 1.0)
        }

        VStack(alignment: .leading, spacing: 8) {
            Text("Custom Colors")
                .font(.nunito(14, weight: .semibold))
                .foregroundColor(AppColors.textDark)

            ProgressBar(progress: 0.7, fillColor: AppColors.coral)
            ProgressBar(progress: 0.5, fillColor: AppColors.rarityLegendary)
            ProgressBar(progress: 0.3, fillColor: AppColors.rarityRare)
        }

        VStack(alignment: .leading, spacing: 8) {
            Text("Custom Height")
                .font(.nunito(14, weight: .semibold))
                .foregroundColor(AppColors.textDark)

            ProgressBar(progress: 0.6, height: 8)
            ProgressBar(progress: 0.6, height: 16)
            ProgressBar(progress: 0.6, height: 24)
        }
    }
    .padding(24)
    .background(AppColors.background)
}
