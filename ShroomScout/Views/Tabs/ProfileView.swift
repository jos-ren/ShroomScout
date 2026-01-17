//
//  ProfileView.swift
//  ShroomScout
//
//  Profile tab placeholder view.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                PageHeader(title: "Profile")

                // Placeholder content
                VStack(spacing: 16) {
                    // Avatar placeholder
                    Circle()
                        .fill(AppColors.cream)
                        .frame(width: 100, height: 100)
                        .overlay(
                            MascotView(expression: .excited, size: 60)
                        )

                    Text("Mushroom Hunter")
                        .font(.nunito(20, weight: .bold))
                        .foregroundColor(AppColors.textDark)

                    Text("Level 5 Forager")
                        .font(.nunito(14, weight: .semibold))
                        .foregroundColor(AppColors.primaryGreen)

                    // Stats row
                    HStack(spacing: 32) {
                        statItem(value: "12", label: "Discoveries")
                        statItem(value: "5", label: "Regions")
                        statItem(value: "28", label: "Days Active")
                    }
                    .padding(.top, 16)
                }
                .padding(.top, 40)

                // Settings placeholder
                VStack(spacing: 12) {
                    settingsRow(icon: "gearshape.fill", title: "Settings")
                    settingsRow(icon: "bell.fill", title: "Notifications")
                    settingsRow(icon: "questionmark.circle.fill", title: "Help & Support")
                    settingsRow(icon: "info.circle.fill", title: "About")
                }
                .padding(.top, 24)

                Spacer(minLength: 100)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
        .background(AppColors.background)
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.nunito(24, weight: .bold))
                .foregroundColor(AppColors.primaryGreen)

            Text(label)
                .font(.nunito(12, weight: .medium))
                .foregroundColor(AppColors.textLight)
        }
    }

    private func settingsRow(icon: String, title: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AppColors.primaryGreen)
                .frame(width: 28)

            Text(title)
                .font(.nunito(16, weight: .medium))
                .foregroundColor(AppColors.textDark)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColors.textLight)
        }
        .padding(16)
        .background(.white)
        .cornerRadius(12)
    }
}

#Preview {
    ProfileView()
}
