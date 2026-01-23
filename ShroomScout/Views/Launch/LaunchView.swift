//
//  LaunchView.swift
//  ShroomScout
//
//  Splash screen shown when the app opens.
//  Displays a coral "S" logo on a cream background.
//

import SwiftUI

struct LaunchView: View {
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            // Cream background
            AppColors.cream
                .ignoresSafeArea()

            // Coral "S" logo
            Text("S")
                .font(.custom("Nunito-Black", size: 120))
                .foregroundStyle(AppColors.coral)
                .scaleEffect(scale)
                .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

#Preview {
    LaunchView()
}
