//
//  ContentView.swift
//  ShroomScout
//
//  Main app view with custom tab navigation.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]
    @Query private var allSpecies: [Species]
    @Query private var allSightings: [Sighting]

    @State private var selectedTab: Tab = .home
    @State private var showScanner: Bool = false
    @State private var navigationPath = NavigationPath()
    @State private var pendingMapLocation: (latitude: Double, longitude: Double)?

    /// Returns true if user has completed onboarding
    private var hasCompletedOnboarding: Bool {
        userProfiles.first?.hasCompletedOnboarding ?? false
    }

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                mainAppView
            } else {
                OnboardingView()
            }
        }
    }

    // MARK: - Main App View

    private var mainAppView: some View {
        NavigationStack(path: $navigationPath) {
            TabBarContainer(selectedTab: $selectedTab, onScanTapped: {
                showScanner = true
            }) {
                Group {
                    switch selectedTab {
                    case .home:
                        HomeView(
                            onSpeciesTapped: navigateToSpecies,
                            onViewCollection: { selectedTab = .collection }
                        )
                    case .collection:
                        CollectionView(onSpeciesTapped: navigateToSpecies)
                    case .scan:
                        // Scan is handled via modal, show home as fallback
                        HomeView(onSpeciesTapped: navigateToSpecies)
                    case .map:
                        MapView(
                            onSpeciesTapped: navigateToSpecies,
                            targetLocation: pendingMapLocation
                        )
                        .onAppear {
                            // Clear pending location after map appears
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                pendingMapLocation = nil
                            }
                        }
                    case .profile:
                        ProfileView()
                    }
                }
            }
            .navigationDestination(for: String.self) { speciesID in
                // Try SwiftData first, fall back to sample data
                if let species = allSpecies.first(where: { $0.id == speciesID }) {
                    let sightings = allSightings.filter { $0.speciesID == speciesID }
                    SpeciesDetailView(
                        species: species,
                        userSightings: sightings,
                        onNavigateToLocation: navigateToLocation
                    )
                } else if let sampleSpecies = SampleData.mixedDiscoveryStates.first(where: { $0.id == speciesID }) {
                    // Check if discovered or not
                    if sampleSpecies.isDiscovered {
                        // Convert sample species to Species for display
                        let species = Species(
                            id: sampleSpecies.id,
                            commonName: sampleSpecies.commonName,
                            scientificName: sampleSpecies.scientificName,
                            speciesDescription: sampleSpecies.description,
                            rarity: sampleSpecies.rarity,
                            edibility: sampleSpecies.edibility,
                            season: sampleSpecies.season,
                            habitat: sampleSpecies.habitat,
                            identificationTips: sampleSpecies.keyFeatures.joined(separator: ". "),
                            lookalikes: [],
                            region: "pnw",
                            referenceImageName: sampleSpecies.imageName
                        )
                        // Create sample sightings using species-specific locations (matching map data)
                        let sampleSightings = sampleSightingsForSpecies(sampleSpecies)
                        SpeciesDetailView(
                            species: species,
                            userSightings: sampleSightings,
                            onNavigateToLocation: navigateToLocation
                        )
                    } else {
                        // Show undiscovered view
                        UndiscoveredSpeciesDetailView(
                            species: sampleSpecies,
                            onStartScanning: {
                                showScanner = true
                            }
                        )
                    }
                }
            }
        }
        .sheet(isPresented: $showScanner) {
            ScannerView(isPresented: $showScanner)
        }
    }

    // MARK: - Navigation Helpers

    private func navigateToSpecies(_ speciesID: String) {
        navigationPath.append(speciesID)
    }

    private func navigateToLocation(_ latitude: Double, _ longitude: Double) {
        // Set pending location and switch to map tab
        pendingMapLocation = (latitude: latitude, longitude: longitude)
        navigationPath.removeLast(navigationPath.count) // Pop all views
        selectedTab = .map
    }

    /// Returns sample sightings for a species with locations matching the map data
    private func sampleSightingsForSpecies(_ species: SampleSpecies) -> [Sighting] {
        // Sample locations matching MapViewModel.loadSampleData()
        let sampleLocations: [String: (lat: Double, lon: Double, name: String)] = [
            "golden-chanterelle": (47.6615, -122.4176, "Discovery Park, Seattle"),
            "lions-mane": (47.4351, -121.7733, "Rattlesnake Ledge Trail"),
            "chicken-of-woods": (47.8021, -123.6044, "Olympic National Forest"),
            "fly-agaric": (46.8800, -121.7269, "Mount Rainier NP"),
            "destroying-angel": (48.7718, -121.2985, "North Cascades")
        ]

        if let location = sampleLocations[species.id] {
            return [
                Sighting(
                    speciesID: species.id,
                    photoFileName: species.imageName,
                    latitude: location.lat,
                    longitude: location.lon,
                    locationName: location.name
                )
            ]
        } else {
            // Fallback for species not in the map
            return [
                Sighting(
                    speciesID: species.id,
                    photoFileName: species.imageName,
                    latitude: 47.6062,
                    longitude: -122.3321,
                    locationName: "Seattle, WA"
                )
            ]
        }
    }
}

#Preview("Main App") {
    ContentView()
        .modelContainer(for: [UserProfile.self, Species.self, Sighting.self], inMemory: true) { result in
            if case .success(let container) = result {
                // Create a user who has completed onboarding
                let profile = UserProfile()
                profile.hasCompletedOnboarding = true
                profile.hasAgreedToDisclaimer = true
                container.mainContext.insert(profile)
            }
        }
}

#Preview("Onboarding") {
    ContentView()
        .modelContainer(for: [UserProfile.self, Species.self, Sighting.self], inMemory: true)
}
