//
//  Sighting.swift
//  ShroomScout
//
//  Created by Joshua Renema on 2026-01-16.
//

import SwiftData
import Foundation
import CoreLocation

@Model
final class Sighting {
    @Attribute(.unique) var id: UUID
    var speciesID: String
    var photoFileName: String
    var dateSighted: Date
    var latitude: Double
    var longitude: Double
    var locationName: String?
    var confidenceScore: Double
    var userConfirmed: Bool

    init(
        speciesID: String,
        photoFileName: String,
        latitude: Double,
        longitude: Double,
        locationName: String? = nil,
        confidenceScore: Double = 0.0
    ) {
        self.id = UUID()
        self.speciesID = speciesID
        self.photoFileName = photoFileName
        self.dateSighted = Date()
        self.latitude = latitude
        self.longitude = longitude
        self.locationName = locationName
        self.confidenceScore = confidenceScore
        self.userConfirmed = true
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
