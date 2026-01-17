//
//  MapViewModel.swift
//  ShroomScout
//
//  ViewModel for the Map screen. Manages map state, sightings, and filtering.
//

import Foundation
import SwiftUI
import MapKit
import SwiftData
import Combine

// MARK: - Map Sighting Item

/// Represents a sighting displayed on the map
struct MapSightingItem: Identifiable, Equatable, Hashable {
    let id: UUID
    let speciesID: String
    let speciesName: String
    let locationName: String?
    let coordinate: CLLocationCoordinate2D
    let dateSighted: Date
    let rarity: Rarity
    let photoFileName: String
    let distance: String?

    static func == (lhs: MapSightingItem, rhs: MapSightingItem) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Bottom Sheet State

enum BottomSheetState {
    case collapsed
    case expanded

    var detentHeight: CGFloat {
        switch self {
        case .collapsed:
            return 120
        case .expanded:
            return 450
        }
    }
}

// MARK: - Map View Model

@MainActor
final class MapViewModel: ObservableObject {
    // MARK: - Published Properties

    /// Current map camera position
    @Published var cameraPosition: MapCameraPosition = .automatic

    /// Search text for filtering species
    @Published var searchText: String = ""

    /// Currently selected rarity filter
    @Published var selectedRarityFilter: Rarity?

    /// All sightings to display on the map
    @Published var sightings: [MapSightingItem] = []

    /// Currently selected sighting for callout
    @Published var selectedSighting: MapSightingItem?

    /// Bottom sheet state
    @Published var bottomSheetState: BottomSheetState = .collapsed

    /// Whether the map is currently loading data
    @Published var isLoading: Bool = false

    /// Error message if any
    @Published var errorMessage: String?

    // MARK: - Dependencies

    let locationService: LocationService

    // MARK: - Computed Properties

    /// Filtered sightings based on search and rarity filter
    var filteredSightings: [MapSightingItem] {
        var result = sightings

        // Apply search filter
        if !searchText.isEmpty {
            result = result.filter {
                $0.speciesName.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Apply rarity filter
        if let rarity = selectedRarityFilter {
            result = result.filter { $0.rarity == rarity }
        }

        return result
    }

    /// Sightings sorted by distance (nearest first)
    var nearbySightings: [MapSightingItem] {
        guard let userLocation = locationService.currentLocation else {
            return filteredSightings.sorted { $0.dateSighted > $1.dateSighted }
        }

        return filteredSightings.sorted { first, second in
            let firstDistance = userLocation.distance(from: CLLocation(
                latitude: first.coordinate.latitude,
                longitude: first.coordinate.longitude
            ))
            let secondDistance = userLocation.distance(from: CLLocation(
                latitude: second.coordinate.latitude,
                longitude: second.coordinate.longitude
            ))
            return firstDistance < secondDistance
        }
    }

    /// Count of nearby discoveries
    var nearbyDiscoveryCount: Int {
        filteredSightings.count
    }

    /// Text for collapsed bottom sheet
    var nearbyDiscoveryText: String {
        let count = nearbyDiscoveryCount
        if count == 0 {
            return "No discoveries nearby"
        } else if count == 1 {
            return "1 discovery nearby"
        } else {
            return "\(count) discoveries nearby"
        }
    }

    // MARK: - Initialization

    init(locationService: LocationService) {
        self.locationService = locationService
        setupBindings()
    }

    /// Convenience init that creates its own LocationService
    convenience init() {
        self.init(locationService: LocationService())
    }

    // MARK: - Public Methods

    /// Center the map on the user's current location
    func centerOnUserLocation() {
        guard let location = locationService.currentLocation else {
            locationService.requestCurrentLocation()
            return
        }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            cameraPosition = .region(MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
        }
    }

    /// Center the map on a specific sighting
    func centerOnSighting(_ sighting: MapSightingItem) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            cameraPosition = .region(MKCoordinateRegion(
                center: sighting.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
            selectedSighting = sighting
        }
    }

    /// Center the map on specific coordinates
    func centerOnCoordinate(latitude: Double, longitude: Double) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            cameraPosition = .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        }
    }

    /// Select a rarity filter
    func selectRarityFilter(_ rarity: Rarity?) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            if selectedRarityFilter == rarity {
                selectedRarityFilter = nil
            } else {
                selectedRarityFilter = rarity
            }
        }
    }

    /// Toggle bottom sheet state
    func toggleBottomSheet() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            bottomSheetState = bottomSheetState == .collapsed ? .expanded : .collapsed
        }
    }

    /// Load sightings from SwiftData
    func loadSightings(from modelContext: ModelContext, species: [Species]) {
        isLoading = true

        do {
            let descriptor = FetchDescriptor<Sighting>(
                sortBy: [SortDescriptor(\.dateSighted, order: .reverse)]
            )
            let fetchedSightings = try modelContext.fetch(descriptor)

            // Convert to MapSightingItems
            sightings = fetchedSightings.compactMap { sighting -> MapSightingItem? in
                guard let matchingSpecies = species.first(where: { $0.id == sighting.speciesID }) else {
                    return nil
                }

                let distance = locationService.formattedDistance(to: sighting.coordinate)

                return MapSightingItem(
                    id: sighting.id,
                    speciesID: sighting.speciesID,
                    speciesName: matchingSpecies.commonName,
                    locationName: sighting.locationName,
                    coordinate: sighting.coordinate,
                    dateSighted: sighting.dateSighted,
                    rarity: matchingSpecies.rarity,
                    photoFileName: sighting.photoFileName,
                    distance: distance
                )
            }

            isLoading = false
        } catch {
            errorMessage = "Failed to load sightings: \(error.localizedDescription)"
            isLoading = false
        }
    }

    /// Load sample data for previews
    func loadSampleData() {
        let sampleLocations: [(name: String, lat: Double, lon: Double, species: SampleSpecies)] = [
            ("Discovery Park, Seattle", 47.6615, -122.4176, SampleData.goldenChanterelle),
            ("Rattlesnake Ledge Trail", 47.4351, -121.7733, SampleData.lionsMane),
            ("Olympic National Forest", 47.8021, -123.6044, SampleData.chickenOfTheWoods),
            ("Mount Rainier NP", 46.8800, -121.7269, SampleData.flyAgaric),
            ("North Cascades", 48.7718, -121.2985, SampleData.destroyingAngel)
        ]

        sightings = sampleLocations.enumerated().map { index, location in
            MapSightingItem(
                id: UUID(),
                speciesID: location.species.id,
                speciesName: location.species.commonName,
                locationName: location.name,
                coordinate: CLLocationCoordinate2D(latitude: location.lat, longitude: location.lon),
                dateSighted: Calendar.current.date(byAdding: .day, value: -index * 2, to: Date()) ?? Date(),
                rarity: location.species.rarity,
                photoFileName: location.species.imageName,
                distance: "\(0.5 + Double(index) * 0.3) mi"
            )
        }

        // Set initial camera position to Seattle area
        if locationService.currentLocation == nil {
            cameraPosition = .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 47.6062, longitude: -122.3321),
                span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
            ))
        }
    }

    // MARK: - Private Methods

    private func setupBindings() {
        // When location updates, refresh distances
        locationService.$currentLocation
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] location in
                guard let self = self, location != nil else { return }
                self.updateSightingDistances()
            }
            .store(in: &cancellables)
    }

    private func updateSightingDistances() {
        sightings = sightings.map { sighting in
            var updated = sighting
            let newDistance = locationService.formattedDistance(to: sighting.coordinate)
            return MapSightingItem(
                id: updated.id,
                speciesID: updated.speciesID,
                speciesName: updated.speciesName,
                locationName: updated.locationName,
                coordinate: updated.coordinate,
                dateSighted: updated.dateSighted,
                rarity: updated.rarity,
                photoFileName: updated.photoFileName,
                distance: newDistance
            )
        }
    }

    private var cancellables = Set<AnyCancellable>()
}

// MARK: - Preview Helper

extension MapViewModel {
    static var preview: MapViewModel {
        let viewModel = MapViewModel(locationService: .preview)
        viewModel.loadSampleData()
        return viewModel
    }
}
