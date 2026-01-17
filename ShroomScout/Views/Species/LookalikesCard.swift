//
//  LookalikesCard.swift
//  ShroomScout
//
//  Warning card displaying dangerous lookalike species.
//

import SwiftUI

struct LookalikesCard: View {
    let lookalikes: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with icon and title
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(AppColors.caution)

                Text("Watch out for lookalikes!")
                    .font(.nunito(18, weight: .bold))
                    .foregroundColor(AppColors.textDark)
            }

            // Lookalikes list
            VStack(alignment: .leading, spacing: 8) {
                ForEach(lookalikes, id: \.self) { lookalike in
                    LookalikeRow(name: formatLookalikeName(lookalike))
                }
            }
            .padding(.leading, 36) // Align with title (24 icon + 12 spacing)
        }
        .padding(26)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.caution.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(AppColors.caution, lineWidth: 2)
        )
        .cornerRadius(24)
    }

    private func formatLookalikeName(_ name: String) -> String {
        // Convert kebab-case or snake_case to Title Case
        name.replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "_", with: " ")
            .split(separator: " ")
            .map { $0.capitalized }
            .joined(separator: " ")
    }
}

// MARK: - Lookalike Row

private struct LookalikeRow: View {
    let name: String

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(AppColors.caution)
                .frame(width: 6, height: 6)

            Text(name)
                .font(.nunito(14, weight: .regular))
                .foregroundColor(AppColors.textDark)
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        LookalikesCard(lookalikes: [
            "false-chanterelle",
            "jack-o-lantern"
        ])

        LookalikesCard(lookalikes: [
            "destroying-angel",
            "death-cap",
            "false-parasol"
        ])
    }
    .padding(24)
    .background(AppColors.background)
}
