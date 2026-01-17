//
//  HomeView.swift
//  ShroomScout
//
//  Home tab placeholder view.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                PageHeader(title: "Home")

                // Placeholder content
                VStack(spacing: 16) {
                    MascotView(expression: .happy, size: 120)

                    Text("Welcome to ShroomScout!")
                        .font(.nunito(18, weight: .bold))
                        .foregroundColor(AppColors.textDark)

                    Text("Start exploring and collecting mushrooms in your area.")
                        .font(.nunito(14, weight: .regular))
                        .foregroundColor(AppColors.textLight)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
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
    HomeView()
}
