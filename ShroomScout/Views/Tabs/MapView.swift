//
//  MapView.swift
//  ShroomScout
//
//  Map tab displaying mushroom sightings on an interactive map.
//  Features:
//  - Full-screen MapKit map centered on user location
//  - Custom mushroom pins color-coded by rarity
//  - Floating search/filter bar
//  - Bottom sheet with nearby discoveries
//

import SwiftUI
import MapKit

struct MapView: View {
    /// Callback when a species is tapped to navigate to detail
    var onSpeciesTapped: ((String) -> Void)?

    /// Target location to center the map on (from sighting detail navigation)
    var targetLocation: (latitude: Double, longitude: Double)?

    @StateObject private var viewModel = MapViewModel()
    @State private var showLocationDeniedAlert = false
    @State private var showCallout = false
    @State private var selectedSightingForDetail: MapSightingItem?

    var body: some View {
        ZStack {
            // Full-screen Map
            mapContent

            // Floating UI overlay
            VStack(spacing: 0) {
                // Search bar at top
                searchFilterBar
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                Spacer()

                // Bottom sheet
                bottomSheet
            }

            // My Location button
            VStack {
                Spacer()

                HStack {
                    Spacer()

                    MyLocationButton {
                        viewModel.centerOnUserLocation()
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, viewModel.bottomSheetState.detentHeight + 16)
                }
            }

            // Callout for selected sighting (above everything)
            if showCallout, let sighting = viewModel.selectedSighting {
                VStack {
                    Spacer()

                    SightingCalloutView(
                        sighting: sighting,
                        onViewDetails: {
                            selectedSightingForDetail = sighting
                        },
                        onDismiss: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                viewModel.selectedSighting = nil
                                showCallout = false
                            }
                        }
                    )
                    .padding(.horizontal, 24)
                    .padding(.bottom, viewModel.bottomSheetState.detentHeight + 16)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // Location permission denied overlay
            if !viewModel.locationService.authorizationStatus.canAccessLocation &&
                viewModel.locationService.authorizationStatus != .notDetermined {
                locationPermissionOverlay
            }

            // Loading overlay
            if viewModel.isLoading {
                MapLoadingOverlay()
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            viewModel.locationService.requestPermission()
            viewModel.loadSampleData() // Load sample data for now

            // Center on target location if provided
            if let target = targetLocation {
                viewModel.centerOnCoordinate(latitude: target.latitude, longitude: target.longitude)
            }
        }
        .onChange(of: targetLocation?.latitude) { _, newValue in
            if let lat = newValue, let lon = targetLocation?.longitude {
                viewModel.centerOnCoordinate(latitude: lat, longitude: lon)
            }
        }
        .onChange(of: viewModel.selectedSighting) { oldValue, newValue in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                showCallout = newValue != nil
            }
        }
        .alert("Location Access Required", isPresented: $showLocationDeniedAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enable location access in Settings to see nearby discoveries and your location on the map.")
        }
        .sheet(item: $selectedSightingForDetail) { mapSighting in
            // Convert MapSightingItem to Sighting for the detail sheet
            let sighting = Sighting(
                speciesID: mapSighting.speciesID,
                photoFileName: mapSighting.photoFileName,
                latitude: mapSighting.coordinate.latitude,
                longitude: mapSighting.coordinate.longitude
            )
            // Set the date to match
            let _ = { sighting.dateSighted = mapSighting.dateSighted }()

            SightingDetailSheet(
                sighting: sighting,
                speciesName: mapSighting.speciesName,
                scientificName: mapSighting.scientificName,
                rarity: mapSighting.rarity,
                showViewOnMapButton: false, // Already on map!
                showViewSpeciesButton: true,
                onViewSpecies: { speciesID in
                    selectedSightingForDetail = nil // Dismiss sheet
                    onSpeciesTapped?(speciesID)
                }
            )
        }
    }

    // MARK: - Map Content

    private var mapContent: some View {
        ClusteredMapView(
            sightings: viewModel.filteredSightings,
            selectedSighting: viewModel.selectedSighting,
            region: $viewModel.mapRegion,
            onSightingSelected: { sighting in
                viewModel.selectedSighting = sighting
            },
            onClusterSelected: { _ in
                // When a cluster is tapped, the map zooms in automatically
            }
        )
        .ignoresSafeArea()
    }

    // MARK: - Search/Filter Bar

    private var searchFilterBar: some View {
        HStack(spacing: 12) {
            // Search icon
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppColors.primaryGreen)
                .frame(width: 32, height: 32)
                .background(AppColors.cream)
                .clipShape(Circle())

            // Search field
            TextField("Search species...", text: $viewModel.searchText)
                .font(.nunito(16, weight: .regular))
                .foregroundColor(AppColors.textDark)

            // Clear button
            if !viewModel.searchText.isEmpty {
                Button(action: {
                    viewModel.searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(AppColors.textLight)
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(.white)
        .cornerRadius(100)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
    }

    // MARK: - Bottom Sheet

    private var bottomSheet: some View {
        VStack(spacing: 0) {
            // Drag handle
            Capsule()
                .fill(AppColors.textLight.opacity(0.3))
                .frame(width: 48, height: 6)
                .padding(.top, 12)

            // Content
            VStack(spacing: 16) {
                // Header
                HStack {
                    Text(viewModel.nearbyDiscoveryText)
                        .font(.nunito(18, weight: .bold))
                        .foregroundColor(AppColors.textDark)

                    Spacer()

                    // Expand/collapse button
                    Button(action: viewModel.toggleBottomSheet) {
                        Image(systemName: viewModel.bottomSheetState == .collapsed ? "chevron.up" : "chevron.down")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppColors.primaryGreen)
                    }
                }
                .padding(.top, 8)

                // Sightings list (visible when expanded)
                if viewModel.bottomSheetState == .expanded {
                    sightingsList
                }
            }
            .padding(.horizontal, 24)

            Spacer(minLength: 0)
        }
        .frame(height: viewModel.bottomSheetState.detentHeight)
        .frame(maxWidth: .infinity)
        .background(.white)
        .cornerRadius(24, corners: [.topLeft, .topRight])
        .shadow(color: .black.opacity(0.15), radius: 25, x: 0, y: -12)
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.height < -50 {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            viewModel.bottomSheetState = .expanded
                        }
                    } else if value.translation.height > 50 {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            viewModel.bottomSheetState = .collapsed
                        }
                    }
                }
        )
    }

    // MARK: - Sightings List

    private var sightingsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.nearbySightings) { sighting in
                    SightingRowView(sighting: sighting) {
                        viewModel.centerOnSighting(sighting)
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            viewModel.bottomSheetState = .collapsed
                        }
                    }
                }
            }
        }
        .frame(maxHeight: 320)
    }

    // MARK: - Location Permission Overlay

    private var locationPermissionOverlay: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 16) {
                MascotView(expression: .encouraging, size: 80)

                Text("Enable Location")
                    .font(.nunito(20, weight: .bold))
                    .foregroundColor(AppColors.textDark)

                Text("Allow location access to see your position on the map and discover nearby mushrooms.")
                    .font(.nunito(14, weight: .regular))
                    .foregroundColor(AppColors.textLight)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                AppButton("Open Settings", style: .primary) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .padding(.horizontal, 48)
                .padding(.top, 8)
            }
            .padding(32)
            .background(.white)
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 24)

            Spacer()
        }
        .background(Color.black.opacity(0.3))
    }
}

// MARK: - Mushroom Pin View

struct MushroomPinView: View {
    let rarity: Rarity
    var isSelected: Bool = false

    private var pinColor: Color {
        AppColors.color(for: rarity)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Pin head with mushroom emoji
            ZStack {
                Circle()
                    .fill(pinColor)
                    .frame(width: isSelected ? 40 : 32, height: isSelected ? 40 : 32)
                    .shadow(color: pinColor.opacity(0.5), radius: isSelected ? 8 : 4, x: 0, y: 2)

                Text("🍄")
                    .font(.system(size: isSelected ? 18 : 14))
            }
            .overlay(
                Circle()
                    .stroke(.white, lineWidth: 2)
            )

            // Pin tail
            MapPinTriangle()
                .fill(pinColor)
                .frame(width: 12, height: 8)
                .offset(y: -2)
        }
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}

// MARK: - Triangle Shape (Map Pin)

private struct MapPinTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Sighting Row View

struct SightingRowView: View {
    let sighting: MapSightingItem
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Photo thumbnail
                photoThumbnail

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(sighting.speciesName)
                        .font(.nunito(18, weight: .semibold))
                        .foregroundColor(AppColors.textDark)
                        .lineLimit(1)

                    // Location
                    if let locationName = sighting.locationName {
                        HStack(spacing: 8) {
                            Image(systemName: "mappin")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(AppColors.textLight)

                            Text(locationName)
                                .font(.nunito(14, weight: .semibold))
                                .foregroundColor(AppColors.textLight)
                                .lineLimit(1)
                        }
                    }

                    // Date
                    Text(sighting.dateSighted.formatted(date: .numeric, time: .omitted))
                        .font(.nunito(12, weight: .semibold))
                        .foregroundColor(AppColors.textLight)
                }

                Spacer()

                // Distance
                if let distance = sighting.distance {
                    Text(distance)
                        .font(.nunito(12, weight: .semibold))
                        .foregroundColor(AppColors.textLight)
                }
            }
            .padding(12)
            .background(AppColors.cream)
            .cornerRadius(16)
        }
        .buttonStyle(BounceButtonStyle())
    }

    private var photoThumbnail: some View {
        ZStack {
            // Placeholder or actual image
            if let uiImage = loadImage() {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                // Try asset catalog image
                Image(sighting.photoFileName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        }
        .frame(width: 64, height: 64)
        .background(AppColors.cream)
        .cornerRadius(12)
        .clipped()
    }

    private func loadImage() -> UIImage? {
        // Try to load from documents directory
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imagePath = documentsPath.appendingPathComponent(sighting.photoFileName)
        return UIImage(contentsOfFile: imagePath.path)
    }
}

// MARK: - Corner Radius Extension

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview

#Preview("Map View") {
    MapView()
}

#Preview("Mushroom Pins") {
    HStack(spacing: 32) {
        VStack(spacing: 8) {
            MushroomPinView(rarity: .common)
            Text("Common")
                .font(.nunito(12, weight: .medium))
        }
        VStack(spacing: 8) {
            MushroomPinView(rarity: .uncommon, isSelected: true)
            Text("Uncommon")
                .font(.nunito(12, weight: .medium))
        }
        VStack(spacing: 8) {
            MushroomPinView(rarity: .rare)
            Text("Rare")
                .font(.nunito(12, weight: .medium))
        }
        VStack(spacing: 8) {
            MushroomPinView(rarity: .legendary)
            Text("Legendary")
                .font(.nunito(12, weight: .medium))
        }
    }
    .padding(40)
    .background(AppColors.background)
}

#Preview("Sighting Row") {
    VStack(spacing: 12) {
        SightingRowView(
            sighting: MapSightingItem(
                id: UUID(),
                speciesID: "golden-chanterelle",
                speciesName: "Golden Chanterelle",
                scientificName: "Cantharellus cibarius",
                locationName: "Discovery Park, Seattle",
                coordinate: CLLocationCoordinate2D(latitude: 47.6615, longitude: -122.4176),
                dateSighted: Date(),
                rarity: .uncommon,
                photoFileName: "golden-chanterelle",
                distance: "0.5 mi"
            ),
            onTap: {}
        )

        SightingRowView(
            sighting: MapSightingItem(
                id: UUID(),
                speciesID: "lions-mane",
                speciesName: "Lion's Mane",
                scientificName: "Hericium erinaceus",
                locationName: "Rattlesnake Ledge Trail",
                coordinate: CLLocationCoordinate2D(latitude: 47.4351, longitude: -121.7733),
                dateSighted: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
                rarity: .rare,
                photoFileName: "lions-mane",
                distance: "2.3 mi"
            ),
            onTap: {}
        )
    }
    .padding(24)
    .background(AppColors.background)
}
