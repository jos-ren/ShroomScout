//
//  LocationService.swift
//  ShroomScout
//
//  Location management service for handling user location permissions and updates.
//

import Foundation
import CoreLocation
import Combine

// MARK: - Location Authorization Status

enum LocationAuthorizationStatus {
    case notDetermined
    case restricted
    case denied
    case authorizedWhenInUse
    case authorizedAlways

    var canAccessLocation: Bool {
        switch self {
        case .authorizedWhenInUse, .authorizedAlways:
            return true
        default:
            return false
        }
    }

    var userFriendlyMessage: String {
        switch self {
        case .notDetermined:
            return "Location access is needed to show nearby discoveries."
        case .restricted:
            return "Location access is restricted on this device."
        case .denied:
            return "Please enable location access in Settings to see nearby discoveries."
        case .authorizedWhenInUse, .authorizedAlways:
            return "Location access enabled."
        }
    }
}

// MARK: - Location Service

@MainActor
final class LocationService: NSObject, ObservableObject {
    // MARK: - Published Properties

    @Published private(set) var authorizationStatus: LocationAuthorizationStatus = .notDetermined
    @Published private(set) var currentLocation: CLLocation?
    @Published private(set) var isUpdatingLocation: Bool = false
    @Published private(set) var locationError: String?

    // MARK: - Private Properties

    private let locationManager: CLLocationManager
    private var hasRequestedPermission = false

    // MARK: - Initialization

    override init() {
        locationManager = CLLocationManager()
        super.init()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50 // Update every 50 meters

        updateAuthorizationStatus()
    }

    // MARK: - Public Methods

    /// Request location permission from the user
    func requestPermission() {
        guard !hasRequestedPermission else { return }
        hasRequestedPermission = true

        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            // Already denied/restricted, can't request again
            updateAuthorizationStatus()
        case .authorizedWhenInUse, .authorizedAlways:
            // Already authorized
            updateAuthorizationStatus()
            startUpdatingLocation()
        @unknown default:
            break
        }
    }

    /// Start receiving location updates
    func startUpdatingLocation() {
        guard authorizationStatus.canAccessLocation else {
            locationError = authorizationStatus.userFriendlyMessage
            return
        }

        isUpdatingLocation = true
        locationError = nil
        locationManager.startUpdatingLocation()
    }

    /// Stop receiving location updates
    func stopUpdatingLocation() {
        isUpdatingLocation = false
        locationManager.stopUpdatingLocation()
    }

    /// Request a single location update
    func requestCurrentLocation() {
        guard authorizationStatus.canAccessLocation else {
            locationError = authorizationStatus.userFriendlyMessage
            return
        }

        isUpdatingLocation = true
        locationError = nil
        locationManager.requestLocation()
    }

    /// Calculate distance from current location to a coordinate
    func distance(to coordinate: CLLocationCoordinate2D) -> CLLocationDistance? {
        guard let currentLocation = currentLocation else { return nil }
        let targetLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return currentLocation.distance(from: targetLocation)
    }

    /// Format distance for display (e.g., "0.5 mi" or "2.3 km")
    func formattedDistance(to coordinate: CLLocationCoordinate2D, useMetric: Bool = false) -> String {
        guard let meters = distance(to: coordinate) else { return "--" }

        if useMetric {
            if meters < 1000 {
                return String(format: "%.0f m", meters)
            } else {
                return String(format: "%.1f km", meters / 1000)
            }
        } else {
            let miles = meters / 1609.34
            if miles < 0.1 {
                let feet = meters * 3.28084
                return String(format: "%.0f ft", feet)
            } else {
                return String(format: "%.1f mi", miles)
            }
        }
    }

    // MARK: - Private Methods

    private func updateAuthorizationStatus() {
        let status = locationManager.authorizationStatus

        switch status {
        case .notDetermined:
            authorizationStatus = .notDetermined
        case .restricted:
            authorizationStatus = .restricted
        case .denied:
            authorizationStatus = .denied
        case .authorizedWhenInUse:
            authorizationStatus = .authorizedWhenInUse
        case .authorizedAlways:
            authorizationStatus = .authorizedAlways
        @unknown default:
            authorizationStatus = .notDetermined
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        Task { @MainActor in
            self.currentLocation = location
            self.isUpdatingLocation = false
            self.locationError = nil
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.isUpdatingLocation = false

            if let clError = error as? CLError {
                switch clError.code {
                case .denied:
                    self.locationError = "Location access denied. Please enable in Settings."
                    self.authorizationStatus = .denied
                case .locationUnknown:
                    self.locationError = "Unable to determine location. Please try again."
                case .network:
                    self.locationError = "Network error. Please check your connection."
                default:
                    self.locationError = "Location error: \(clError.localizedDescription)"
                }
            } else {
                self.locationError = "Unable to get location: \(error.localizedDescription)"
            }
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.updateAuthorizationStatus()

            if self.authorizationStatus.canAccessLocation {
                self.startUpdatingLocation()
            }
        }
    }
}

// MARK: - Preview Helper

extension LocationService {
    /// Create a mock service for previews with a preset location
    static var preview: LocationService {
        let service = LocationService()
        // Seattle area location for previews
        let seattleLocation = CLLocation(latitude: 47.6062, longitude: -122.3321)
        service.currentLocation = seattleLocation
        service.authorizationStatus = .authorizedWhenInUse
        return service
    }

    /// Create a mock service with denied permission for previews
    static var previewDenied: LocationService {
        let service = LocationService()
        service.authorizationStatus = .denied
        service.locationError = "Please enable location access in Settings to see nearby discoveries."
        return service
    }
}
