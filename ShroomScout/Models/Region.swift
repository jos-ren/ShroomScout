//
//  Region.swift
//  ShroomScout
//
//  Defines all supported foraging regions worldwide.
//

import Foundation

struct Region: Identifiable, Hashable {
    let id: String
    let name: String
    let shortName: String
    let continent: Continent
    let description: String
    let isActive: Bool

    enum Continent: String, CaseIterable {
        case northAmerica = "North America"
        case europe = "Europe"
        case asia = "Asia"
        case southernHemisphere = "Southern Hemisphere"
    }
}

// MARK: - All Regions

extension Region {
    static let all: [Region] = [
        // North America
        Region(
            id: "pnw",
            name: "Pacific Northwest",
            shortName: "PNW",
            continent: .northAmerica,
            description: "Washington, Oregon, British Columbia",
            isActive: true
        ),
        Region(
            id: "california",
            name: "California",
            shortName: "CA",
            continent: .northAmerica,
            description: "Mediterranean & mountain ecosystems",
            isActive: true
        ),
        Region(
            id: "rocky_mountains",
            name: "Rocky Mountains",
            shortName: "Rockies",
            continent: .northAmerica,
            description: "Colorado, Montana, Idaho, Wyoming",
            isActive: false
        ),
        Region(
            id: "northeast",
            name: "Northeast",
            shortName: "NE",
            continent: .northAmerica,
            description: "New England & Mid-Atlantic",
            isActive: true
        ),
        Region(
            id: "great_lakes",
            name: "Great Lakes / Midwest",
            shortName: "Midwest",
            continent: .northAmerica,
            description: "Michigan, Wisconsin, Minnesota, Ohio",
            isActive: false
        ),
        Region(
            id: "southeast",
            name: "Southeast",
            shortName: "SE",
            continent: .northAmerica,
            description: "Southern Appalachia & coastal plains",
            isActive: false
        ),
        Region(
            id: "alaska",
            name: "Alaska",
            shortName: "AK",
            continent: .northAmerica,
            description: "Arctic & subarctic species",
            isActive: false
        ),

        // Europe
        Region(
            id: "british_isles",
            name: "British Isles",
            shortName: "UK",
            continent: .europe,
            description: "United Kingdom & Ireland",
            isActive: false
        ),
        Region(
            id: "nordic",
            name: "Nordic",
            shortName: "Nordic",
            continent: .europe,
            description: "Scandinavia & Finland",
            isActive: false
        ),
        Region(
            id: "central_europe",
            name: "Central Europe",
            shortName: "Central EU",
            continent: .europe,
            description: "Germany, Poland, Czech, Austria, Switzerland",
            isActive: false
        ),
        Region(
            id: "western_europe",
            name: "Western Europe",
            shortName: "Western EU",
            continent: .europe,
            description: "France & Benelux",
            isActive: false
        ),
        Region(
            id: "mediterranean",
            name: "Mediterranean",
            shortName: "Med",
            continent: .europe,
            description: "Spain, Italy, Greece",
            isActive: false
        ),
        Region(
            id: "eastern_europe",
            name: "Eastern Europe",
            shortName: "Eastern EU",
            continent: .europe,
            description: "Balkans, Romania, Ukraine",
            isActive: false
        ),

        // Asia
        Region(
            id: "japan",
            name: "Japan",
            shortName: "Japan",
            continent: .asia,
            description: "Temperate & subtropical forests",
            isActive: false
        ),
        Region(
            id: "korea",
            name: "Korea",
            shortName: "Korea",
            continent: .asia,
            description: "Korean Peninsula",
            isActive: false
        ),
        Region(
            id: "china_coastal",
            name: "China (Coastal)",
            shortName: "China",
            continent: .asia,
            description: "Coastal & temperate regions",
            isActive: false
        ),
        Region(
            id: "siberia",
            name: "Siberia / Russian Far East",
            shortName: "Siberia",
            continent: .asia,
            description: "Boreal & taiga ecosystems",
            isActive: false
        ),

        // Southern Hemisphere
        Region(
            id: "australia_nz",
            name: "Australia / New Zealand",
            shortName: "ANZ",
            continent: .southernHemisphere,
            description: "Oceania temperate regions",
            isActive: false
        ),
        Region(
            id: "south_africa",
            name: "South Africa",
            shortName: "SA",
            continent: .southernHemisphere,
            description: "Cape region & highlands",
            isActive: false
        ),
        Region(
            id: "patagonia",
            name: "Southern South America",
            shortName: "Patagonia",
            continent: .southernHemisphere,
            description: "Chile & Argentina",
            isActive: false
        )
    ]

    /// Returns only the currently active regions
    static var active: [Region] {
        all.filter { $0.isActive }
    }

    /// Find a region by its ID
    static func find(byId id: String) -> Region? {
        all.first { $0.id == id }
    }
}
