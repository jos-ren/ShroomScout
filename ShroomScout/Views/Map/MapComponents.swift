//
//  MapComponents.swift
//  ShroomScout
//
//  Reusable map-related UI components.
//

import SwiftUI
import MapKit

// MARK: - Sighting Callout View

/// Callout view displayed when a map pin is tapped
struct SightingCalloutView: View {
    let sighting: MapSightingItem
    let onViewDetails: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Close button
            HStack {
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.textLight)
                        .frame(width: 28, height: 28)
                        .background(AppColors.cream)
                        .clipShape(Circle())
                }
            }
            .padding(.bottom, 8)

            HStack(spacing: 16) {
                // Photo thumbnail
                photoThumbnail

                // Info
                VStack(alignment: .leading, spacing: 6) {
                    // Species name
                    Text(sighting.speciesName)
                        .font(.nunito(18, weight: .bold))
                        .foregroundColor(AppColors.textDark)
                        .lineLimit(1)

                    // Rarity badge
                    HStack(spacing: 6) {
                        Circle()
                            .fill(AppColors.color(for: sighting.rarity))
                            .frame(width: 8, height: 8)

                        Text(sighting.rarity.displayName)
                            .font(.nunito(12, weight: .semibold))
                            .foregroundColor(AppColors.textLight)
                    }

                    // Date
                    Text(sighting.dateSighted.formatted(date: .abbreviated, time: .omitted))
                        .font(.nunito(12, weight: .medium))
                        .foregroundColor(AppColors.textLight)
                }

                Spacer()
            }

            // View button
            Button(action: onViewDetails) {
                HStack(spacing: 8) {
                    Text("View Details")
                        .font(.nunito(14, weight: .semibold))
                        .foregroundColor(.white)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(AppColors.primaryGreen)
                .cornerRadius(12)
            }
            .buttonStyle(BounceButtonStyle())
            .padding(.top, 16)
        }
        .padding(16)
        .background(.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
    }

    private var photoThumbnail: some View {
        ZStack {
            // Try to load image from asset catalog
            Image(sighting.photoFileName)
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
        .frame(width: 72, height: 72)
        .background(AppColors.cream)
        .cornerRadius(16)
        .clipped()
    }
}

// MARK: - Map Filter Pills

/// Filter pills for filtering map sightings by rarity
struct MapFilterPills: View {
    @Binding var selectedRarity: Rarity?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // All filter
                FilterPillButton(
                    title: "All",
                    isSelected: selectedRarity == nil,
                    color: AppColors.primaryGreen
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        selectedRarity = nil
                    }
                }

                // Rarity filters
                ForEach(Rarity.allCases, id: \.self) { rarity in
                    FilterPillButton(
                        title: rarity.displayName,
                        isSelected: selectedRarity == rarity,
                        color: AppColors.color(for: rarity)
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            selectedRarity = selectedRarity == rarity ? nil : rarity
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Filter Pill Button

private struct FilterPillButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Circle()
                    .fill(isSelected ? .white : color)
                    .frame(width: 8, height: 8)

                Text(title)
                    .font(.nunito(13, weight: .semibold))
                    .foregroundColor(isSelected ? .white : AppColors.textDark)
            }
            .padding(.horizontal, 14)
            .frame(height: 36)
            .background(isSelected ? color : .white)
            .cornerRadius(100)
            .overlay(
                RoundedRectangle(cornerRadius: 100)
                    .stroke(color.opacity(0.3), lineWidth: isSelected ? 0 : 1)
            )
            .shadow(color: isSelected ? color.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
        }
        .buttonStyle(BounceButtonStyle())
    }
}

// MARK: - My Location Button

/// Floating button to center the map on user's location
struct MyLocationButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "location.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppColors.primaryGreen)
                .frame(width: 48, height: 48)
                .background(.white)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(BounceButtonStyle())
    }
}

// MARK: - Empty Map State

/// View displayed when there are no sightings to show on the map
struct EmptyMapState: View {
    var body: some View {
        VStack(spacing: 16) {
            MascotView(expression: .encouraging, size: 80)

            Text("No Discoveries Yet")
                .font(.nunito(18, weight: .bold))
                .foregroundColor(AppColors.textDark)

            Text("Start scanning mushrooms to see your discoveries on the map!")
                .font(.nunito(14, weight: .regular))
                .foregroundColor(AppColors.textLight)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(32)
        .background(.white)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.1), radius: 16, x: 0, y: 8)
    }
}

// MARK: - Map Loading Overlay

/// Loading overlay for the map
struct MapLoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.2)

            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(AppColors.primaryGreen)

                Text("Loading discoveries...")
                    .font(.nunito(14, weight: .medium))
                    .foregroundColor(AppColors.textDark)
            }
            .padding(32)
            .background(.white)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.1), radius: 16, x: 0, y: 8)
        }
    }
}

// MARK: - User Location Marker

/// Custom user location marker with pulsing animation
struct UserLocationMarker: View {
    @State private var isPulsing = false

    var body: some View {
        ZStack {
            // Pulse ring
            Circle()
                .stroke(AppColors.primaryGreen.opacity(0.3), lineWidth: 2)
                .frame(width: 40, height: 40)
                .scaleEffect(isPulsing ? 1.5 : 1.0)
                .opacity(isPulsing ? 0 : 0.8)

            // Outer ring
            Circle()
                .fill(AppColors.primaryGreen.opacity(0.2))
                .frame(width: 32, height: 32)

            // Inner dot
            Circle()
                .fill(AppColors.primaryGreen)
                .frame(width: 16, height: 16)
                .overlay(
                    Circle()
                        .stroke(.white, lineWidth: 3)
                )
        }
        .onAppear {
            withAnimation(
                .easeOut(duration: 1.5)
                .repeatForever(autoreverses: false)
            ) {
                isPulsing = true
            }
        }
    }
}

// MARK: - Previews

#Preview("Sighting Callout") {
    ZStack {
        Color.gray.opacity(0.3)

        SightingCalloutView(
            sighting: MapSightingItem(
                id: UUID(),
                speciesID: "golden-chanterelle",
                speciesName: "Golden Chanterelle",
                locationName: "Discovery Park, Seattle",
                coordinate: CLLocationCoordinate2D(latitude: 47.6615, longitude: -122.4176),
                dateSighted: Date(),
                rarity: .uncommon,
                photoFileName: "golden-chanterelle",
                distance: "0.5 mi"
            ),
            onViewDetails: {},
            onDismiss: {}
        )
        .padding(24)
    }
}

#Preview("Map Filter Pills") {
    struct PreviewWrapper: View {
        @State private var selectedRarity: Rarity? = nil

        var body: some View {
            VStack(spacing: 24) {
                MapFilterPills(selectedRarity: $selectedRarity)

                if let rarity = selectedRarity {
                    Text("Selected: \(rarity.displayName)")
                        .font(.nunito(14, weight: .medium))
                } else {
                    Text("Selected: All")
                        .font(.nunito(14, weight: .medium))
                }
            }
            .padding(.vertical, 24)
            .background(AppColors.background)
        }
    }

    return PreviewWrapper()
}

#Preview("My Location Button") {
    ZStack {
        AppColors.background

        MyLocationButton(action: {})
    }
    .frame(width: 200, height: 200)
}

#Preview("Empty Map State") {
    ZStack {
        Color.gray.opacity(0.3)
        EmptyMapState()
            .padding(24)
    }
}

#Preview("Map Loading Overlay") {
    MapLoadingOverlay()
}

#Preview("User Location Marker") {
    ZStack {
        AppColors.background
        UserLocationMarker()
    }
    .frame(width: 200, height: 200)
}
