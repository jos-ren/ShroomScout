//
//  ContentView.swift
//  ShroomScout
//
//  Main app view with custom tab navigation.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab: Tab = .home
    @State private var showScanner: Bool = false

    var body: some View {
        TabBarContainer(selectedTab: $selectedTab, onScanTapped: {
            showScanner = true
        }) {
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .collection:
                    CollectionView()
                case .scan:
                    // Scan is handled via modal, show home as fallback
                    HomeView()
                case .map:
                    MapView()
                case .profile:
                    ProfileView()
                }
            }
        }
        .sheet(isPresented: $showScanner) {
            ScannerView(isPresented: $showScanner)
        }
    }
}

// MARK: - Scanner View (Placeholder)

struct ScannerView: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            MascotView(expression: .curious, size: 120)

            Text("Scan a Mushroom")
                .font(.nunito(24, weight: .bold))
                .foregroundColor(AppColors.textDark)

            Text("Point your camera at a mushroom to identify it.")
                .font(.nunito(14, weight: .regular))
                .foregroundColor(AppColors.textLight)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            // Camera placeholder
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.cream)
                .frame(height: 300)
                .overlay(
                    VStack(spacing: 12) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 48))
                            .foregroundColor(AppColors.primaryGreen.opacity(0.3))

                        Text("Camera Preview")
                            .font(.nunito(14, weight: .semibold))
                            .foregroundColor(AppColors.textLight)
                    }
                )
                .padding(.horizontal, 24)

            Spacer()

            AppButton("Close", style: .secondary) {
                isPresented = false
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(AppColors.background)
    }
}

#Preview {
    ContentView()
}
