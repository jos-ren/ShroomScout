//
//  SightingsRow.swift
//  ShroomScout
//
//  Horizontal scrolling row of user's sighting photos with dates.
//

import SwiftUI
import CoreLocation
import MapKit

struct SightingsRow: View {
    let sightings: [Sighting]
    var speciesName: String = ""
    var scientificName: String = ""
    var rarity: Rarity = .common
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
                scientificName: scientificName,
                rarity: rarity,
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
    var scientificName: String = ""
    var rarity: Rarity = .common
    var showViewOnMapButton: Bool = true
    var showViewSpeciesButton: Bool = false
    var onNavigateToLocation: ((Double, Double) -> Void)?
    var onViewSpecies: ((String) -> Void)?

    @Environment(\.dismiss) private var dismiss
    @State private var locationName: String = "Loading location..."

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(speciesName.isEmpty ? "Sighting Details" : speciesName)
                    .font(.nunito(24, weight: .bold))
                    .foregroundColor(AppColors.textDark)

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppColors.textDark)
                        .frame(width: 32, height: 32)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 12)

            ScrollView {
                VStack(spacing: 12) {
                    // Photo card
                    photoSection
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 4)

                    // Date discovered card
                    detailCard(icon: "calendar", title: "Date Discovered", value: formattedDateTime)
                        .padding(.horizontal, 24)

                    // Location card
                    detailCard(icon: "mappin.circle.fill", title: "Location", value: locationName)
                        .padding(.horizontal, 24)

                    // Coordinates card
                    detailCard(icon: "location.circle.fill", title: "Coordinates", value: formattedCoordinates)
                        .padding(.horizontal, 24)

                    // Mini map preview with button overlay
                    if showViewOnMapButton {
                        miniMapSection
                            .padding(.horizontal, 24)
                            .padding(.top, 4)
                    }

                    // View Species button (for map sighting details)
                    if showViewSpeciesButton {
                        Button(action: {
                            onViewSpecies?(sighting.speciesID)
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "leaf.fill")
                                    .font(.system(size: 16, weight: .semibold))

                                Text("View Species Details")
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
                    }
                }
                .padding(.bottom, 24)
            }
        }
        .background(AppColors.background)
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
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 220)
                    .clipped()
            } else {
                // Try asset catalog
                Image(sighting.photoFileName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 220)
                    .clipped()
            }
        }
    }

    // MARK: - Detail Card

    private func detailCard(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 14) {
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
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.nunito(12, weight: .regular))
                    .foregroundColor(AppColors.textLight)

                Text(value)
                    .font(.nunito(16, weight: .semibold))
                    .foregroundColor(AppColors.textDark)
                    .textSelection(.enabled)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.white)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.1), radius: 7.5, x: 0, y: 5)
    }

    // MARK: - Formatting

    private var formattedCoordinates: String {
        let lat = String(format: "%.4f", sighting.latitude)
        let lon = String(format: "%.4f", sighting.longitude)
        return "\(lat), \(lon)"
    }

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

    private var formattedDateTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        return "\(dateFormatter.string(from: sighting.dateSighted)) at \(timeFormatter.string(from: sighting.dateSighted))"
    }

    // MARK: - Mini Map Section

    private var miniMapSection: some View {
        ZStack {
            // Static map with custom mushroom pin
            // Offset center slightly south so pin appears in upper portion of map
            Map(initialPosition: .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: sighting.latitude - 0.0015, longitude: sighting.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))) {
                Annotation("", coordinate: CLLocationCoordinate2D(latitude: sighting.latitude, longitude: sighting.longitude)) {
                    // Custom mushroom pin - circle with rarity color and mushroom emoji
                    ZStack {
                        Circle()
                            .fill(AppColors.color(for: rarity))
                            .frame(width: 36, height: 36)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)

                        Text("🍄")
                            .font(.system(size: 18))
                    }
                }
            }
            .disabled(true)
            .frame(height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .id(sighting.id) // Force map recreation when sighting changes

            // Button overlay
            VStack {
                Spacer()
                Button(action: {
                    onNavigateToLocation?(sighting.latitude, sighting.longitude)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.system(size: 12, weight: .semibold))

                        Text("View on Map")
                            .font(.nunito(13, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(AppColors.primaryGreen)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                .buttonStyle(BounceButtonStyle())
                .padding(.bottom, 12)
            }
        }
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
            speciesName: "Golden Chanterelle",
            scientificName: "Cantharellus cibarius"
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
            speciesName: "Golden Chanterelle",
            scientificName: "Cantharellus cibarius"
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
        speciesName: "Golden Chanterelle",
        scientificName: "Cantharellus cibarius"
    )
}
