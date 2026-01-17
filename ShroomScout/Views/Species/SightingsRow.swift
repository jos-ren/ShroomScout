//
//  SightingsRow.swift
//  ShroomScout
//
//  Horizontal scrolling row of user's sighting photos with dates.
//

import SwiftUI
import CoreLocation

struct SightingsRow: View {
    let sightings: [Sighting]
    var speciesName: String = ""
    var onNavigateToLocation: ((Double, Double) -> Void)?

    @State private var selectedSighting: Sighting?

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                Text(headerText)
                    .font(.nunito(18, weight: .bold))
                    .foregroundColor(AppColors.textDark)

                // Horizontal scroll of sighting photos
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(sightings, id: \.id) { sighting in
                            SightingThumbnail(sighting: sighting)
                                .onTapGesture {
                                    selectedSighting = sighting
                                }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .sheet(item: $selectedSighting) { sighting in
            SightingDetailSheet(
                sighting: sighting,
                speciesName: speciesName,
                onNavigateToLocation: { lat, lon in
                    selectedSighting = nil // Dismiss sheet
                    onNavigateToLocation?(lat, lon)
                }
            )
        }
    }

    private var headerText: String {
        let count = sightings.count
        if count == 1 {
            return "You've found this 1 time"
        } else {
            return "You've found this \(count) times"
        }
    }
}

// MARK: - Sighting Thumbnail

private struct SightingThumbnail: View {
    let sighting: Sighting

    var body: some View {
        VStack(spacing: 8) {
            // Photo container
            ZStack {
                // Placeholder or actual image
                if let image = loadImage() {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 96, height: 96)
                        .clipped()
                } else {
                    // Placeholder
                    Rectangle()
                        .fill(AppColors.cream)
                        .frame(width: 96, height: 96)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 24))
                                .foregroundColor(AppColors.textLight)
                        )
                }
            }
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppColors.primaryGreen.opacity(0.2), lineWidth: 2)
            )

            // Date label
            Text(formattedDate)
                .font(.nunito(12, weight: .regular))
                .foregroundColor(AppColors.textLight)
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: sighting.dateSighted)
    }

    private func loadImage() -> UIImage? {
        // Try to load from documents directory
        guard let documentsURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            return nil
        }

        let imageURL = documentsURL.appendingPathComponent(sighting.photoFileName)
        guard let imageData = try? Data(contentsOf: imageURL),
              let image = UIImage(data: imageData) else {
            return nil
        }

        return image
    }
}

// MARK: - Sighting Detail Sheet

struct SightingDetailSheet: View {
    let sighting: Sighting
    var speciesName: String = ""
    var showViewOnMapButton: Bool = true
    var onNavigateToLocation: ((Double, Double) -> Void)?

    @Environment(\.dismiss) private var dismiss
    @State private var locationName: String = "Loading location..."

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Large photo
                    photoSection

                    // Details
                    VStack(spacing: 16) {
                        // Species name
                        if !speciesName.isEmpty {
                            detailRow(icon: "leaf.fill", title: "Species", value: speciesName)
                        }

                        // Date and time
                        detailRow(icon: "calendar", title: "Date", value: formattedDate)
                        detailRow(icon: "clock.fill", title: "Time", value: formattedTime)

                        // Location
                        detailRow(icon: "mappin.circle.fill", title: "Location", value: locationName)

                        // Coordinates
                        detailRow(
                            icon: "location.fill",
                            title: "Coordinates",
                            value: String(format: "%.4f, %.4f", sighting.latitude, sighting.longitude)
                        )
                    }
                    .padding(.horizontal, 24)

                    // View on Map button (hidden when already on map)
                    if showViewOnMapButton {
                        Button(action: {
                            onNavigateToLocation?(sighting.latitude, sighting.longitude)
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "map.fill")
                                    .font(.system(size: 16, weight: .semibold))

                                Text("View on Map")
                                    .font(.nunito(16, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(AppColors.primaryGreen)
                            .cornerRadius(28)
                            .shadow(color: .black.opacity(0.1), radius: 7.5, x: 0, y: 5)
                        }
                        .buttonStyle(BounceButtonStyle())
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                    }
                }
                .padding(.vertical, 24)
            }
            .background(AppColors.background)
            .navigationTitle("Sighting Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.nunito(16, weight: .semibold))
                    .foregroundColor(AppColors.primaryGreen)
                }
            }
        }
        .onAppear {
            reverseGeocodeLocation()
        }
    }

    // MARK: - Photo Section

    private var photoSection: some View {
        ZStack {
            if let image = loadImage() {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(20)
            } else {
                // Try asset catalog
                Image(sighting.photoFileName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 250)
                    .cornerRadius(20)
            }
        }
        .padding(.horizontal, 24)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }

    // MARK: - Detail Row

    private func detailRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(AppColors.primaryGreen.opacity(0.1))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(AppColors.primaryGreen)
            }

            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.nunito(12, weight: .regular))
                    .foregroundColor(AppColors.textLight)

                Text(value)
                    .font(.nunito(16, weight: .semibold))
                    .foregroundColor(AppColors.textDark)
            }

            Spacer()
        }
        .padding(16)
        .background(AppColors.cream)
        .cornerRadius(16)
    }

    // MARK: - Formatting

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: sighting.dateSighted)
    }

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: sighting.dateSighted)
    }

    // MARK: - Helpers

    private func loadImage() -> UIImage? {
        guard let documentsURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            return nil
        }

        let imageURL = documentsURL.appendingPathComponent(sighting.photoFileName)
        guard let imageData = try? Data(contentsOf: imageURL),
              let image = UIImage(data: imageData) else {
            return nil
        }

        return image
    }

    private func reverseGeocodeLocation() {
        let location = CLLocation(latitude: sighting.latitude, longitude: sighting.longitude)
        let geocoder = CLGeocoder()

        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first {
                var components: [String] = []

                if let name = placemark.name {
                    components.append(name)
                }
                if let locality = placemark.locality {
                    if !components.contains(locality) {
                        components.append(locality)
                    }
                }
                if let state = placemark.administrativeArea {
                    components.append(state)
                }

                if components.isEmpty {
                    locationName = "Unknown Location"
                } else {
                    locationName = components.prefix(2).joined(separator: ", ")
                }
            } else {
                locationName = "Unknown Location"
            }
        }
    }
}

// MARK: - Preview

#Preview("Sightings Row") {
    VStack(spacing: 24) {
        // Single sighting
        SightingsRow(
            sightings: [
                Sighting(
                    speciesID: "chanterelle",
                    photoFileName: "golden-chanterelle",
                    latitude: 47.6062,
                    longitude: -122.3321
                )
            ],
            speciesName: "Golden Chanterelle"
        )

        // Multiple sightings
        SightingsRow(
            sightings: [
                Sighting(
                    speciesID: "chanterelle",
                    photoFileName: "golden-chanterelle",
                    latitude: 47.6062,
                    longitude: -122.3321
                ),
                Sighting(
                    speciesID: "chanterelle",
                    photoFileName: "golden-chanterelle",
                    latitude: 47.6615,
                    longitude: -122.4176
                ),
                Sighting(
                    speciesID: "chanterelle",
                    photoFileName: "golden-chanterelle",
                    latitude: 47.4351,
                    longitude: -121.7733
                )
            ],
            speciesName: "Golden Chanterelle"
        )
    }
    .padding(24)
    .background(AppColors.background)
}

#Preview("Sighting Detail Sheet") {
    SightingDetailSheet(
        sighting: Sighting(
            speciesID: "chanterelle",
            photoFileName: "golden-chanterelle",
            latitude: 47.6062,
            longitude: -122.3321
        ),
        speciesName: "Golden Chanterelle"
    )
}
