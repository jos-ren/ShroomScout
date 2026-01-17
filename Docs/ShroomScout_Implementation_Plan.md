# ShroomScout — iOS Implementation Plan

## Project Overview

**App Name:** ShroomScout  
**Platform:** iOS 26+ (iPhone)  
**Language:** Swift 6  
**UI Framework:** SwiftUI  
**Minimum Deployment:** iOS 26.0  
**Architecture:** MVVM with SwiftData

**Summary:** A Pokemon Go-style mushroom collection app. Users scan mushrooms with their camera, get AI-powered identification suggestions, select the best match, and build a regional collection.

---

## Tech Stack

| Component | Technology |
|-----------|------------|
| UI | SwiftUI (iOS 26 with Liquid Glass support) |
| Data Persistence | SwiftData |
| Cloud Sync | CloudKit (via SwiftData) |
| Camera | AVFoundation |
| ML Identification | Core ML (placeholder for MVP) |
| Location | CoreLocation |
| Maps | MapKit |
| Image Storage | FileManager (local) + iCloud sync |

---

## Project Structure

```
ShroomScout/
├── App/
│   ├── ShroomScoutApp.swift          # App entry point
│   └── ContentView.swift              # Root view with tab navigation
│
├── Models/
│   ├── Species.swift                  # Species data model
│   ├── Sighting.swift                 # User's sighting/discovery
│   ├── UserProfile.swift              # User stats and preferences
│   └── Region.swift                   # Regional data
│
├── Views/
│   ├── Home/
│   │   └── HomeView.swift
│   ├── Scanner/
│   │   ├── CameraView.swift
│   │   ├── ScannerView.swift
│   │   └── ScanResultsView.swift
│   ├── Collection/
│   │   ├── CollectionView.swift
│   │   ├── SpeciesCardView.swift
│   │   └── SpeciesDetailView.swift
│   ├── Map/
│   │   └── MapView.swift
│   ├── Profile/
│   │   ├── ProfileView.swift
│   │   └── SettingsView.swift
│   ├── Onboarding/
│   │   └── OnboardingView.swift
│   └── Components/
│       ├── Buttons/
│       │   ├── PrimaryButton.swift
│       │   └── SecondaryButton.swift
│       ├── Cards/
│       │   ├── AppCard.swift
│       │   └── ProgressCard.swift
│       ├── Navigation/
│       │   └── AppNavBar.swift
│       ├── Badges/
│       │   ├── RarityBadge.swift
│       │   └── EdibilityBadge.swift
│       ├── Mascot/
│       │   └── MascotView.swift
│       ├── Feedback/
│       │   ├── LoadingOverlay.swift
│       │   ├── WarningBanner.swift
│       │   └── EmptyStateView.swift
│       └── Common/
│           ├── ProgressBar.swift
│           ├── FilterPill.swift
│           ├── SectionHeader.swift
│           └── ScanButton.swift
│
├── ViewModels/
│   ├── HomeViewModel.swift
│   ├── ScannerViewModel.swift
│   ├── CollectionViewModel.swift
│   ├── MapViewModel.swift
│   └── ProfileViewModel.swift
│
├── Services/
│   ├── CameraService.swift            # Camera capture handling
│   ├── IdentificationService.swift    # ML model interface (placeholder)
│   ├── LocationService.swift          # Location management
│   ├── DataService.swift              # SwiftData operations
│   └── ImageStorageService.swift      # Photo save/load
│
├── Utilities/
│   ├── Constants.swift                # Colors, dimensions, strings
│   ├── Extensions/
│   │   ├── Color+App.swift
│   │   ├── Font+App.swift             # Nunito font extension
│   │   ├── View+Extensions.swift
│   │   └── Image+Extensions.swift
│   └── Modifiers/
│       └── CardModifier.swift
│
├── Resources/
│   ├── Assets.xcassets/
│   │   ├── AppIcon
│   │   ├── Mascot/                    # Mascot images
│   │   ├── Colors/                    # Color assets
│   │   └── Icons/                     # Custom icons
│   ├── Fonts/                         # Nunito font files (.ttf)
│   │   ├── Nunito-Regular.ttf
│   │   ├── Nunito-Medium.ttf
│   │   ├── Nunito-SemiBold.ttf
│   │   ├── Nunito-Bold.ttf
│   │   └── Nunito-Light.ttf
│   └── Data/
│       └── pnw_species.json           # Bundled species data
│
└── Preview Content/
    └── PreviewData.swift              # Sample data for previews
```

---

## Data Models

### Species.swift
```swift
import SwiftData
import Foundation

@Model
final class Species {
    @Attribute(.unique) var id: String
    var commonName: String
    var scientificName: String
    var speciesDescription: String
    var rarity: Rarity
    var edibility: Edibility
    var season: [Season]
    var habitat: String
    var identificationTips: String
    var lookalikes: [String]  // IDs of similar species
    var region: String
    var referenceImageName: String  // Bundled reference image
    
    enum Rarity: String, Codable {
        case common, uncommon, rare, legendary
    }
    
    enum Edibility: String, Codable {
        case edible, inedible, caution, toxic, deadly
    }
    
    enum Season: String, Codable {
        case spring, summer, fall, winter, yearRound
    }
}
```

### Sighting.swift
```swift
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
    
    init(speciesID: String, photoFileName: String, latitude: Double, longitude: Double) {
        self.id = UUID()
        self.speciesID = speciesID
        self.photoFileName = photoFileName
        self.dateSighted = Date()
        self.latitude = latitude
        self.longitude = longitude
        self.userConfirmed = true
        self.confidenceScore = 0.0
    }
}
```

### UserProfile.swift
```swift
import SwiftData
import Foundation

@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID
    var displayName: String
    var selectedRegion: String
    var hasCompletedOnboarding: Bool
    var hasAgreedToDisclaimer: Bool
    var createdAt: Date
    var soundEffectsEnabled: Bool
    var hapticFeedbackEnabled: Bool
    
    init() {
        self.id = UUID()
        self.displayName = "Scout"
        self.selectedRegion = "pnw"
        self.hasCompletedOnboarding = false
        self.hasAgreedToDisclaimer = false
        self.createdAt = Date()
        self.soundEffectsEnabled = true
        self.hapticFeedbackEnabled = true
    }
}
```

---

## Color System

### Constants.swift
```swift
import SwiftUI

struct AppColors {
    // Primary
    static let primaryGreen = Color(hex: "4A7C59")
    static let cream = Color(hex: "FFF8E7")
    static let coral = Color(hex: "FF8A6C")
    static let background = Color(hex: "FFFDF7")
    
    // Text
    static let textDark = Color(hex: "2D3B2D")
    static let textLight = Color(hex: "6B7B6B")
    
    // Rarity
    static let rarityCommon = Color(hex: "9CA3AF")
    static let rarityUncommon = Color(hex: "6EE7B7")
    static let rarityRare = Color(hex: "7DD3FC")
    static let rarityLegendary = Color(hex: "FCD34D")
    
    // Status
    static let caution = Color(hex: "F59E0B")
    static let danger = Color(hex: "EF4444")
}

struct AppDimensions {
    static let cornerRadiusSmall: CGFloat = 12
    static let cornerRadiusMedium: CGFloat = 16
    static let cornerRadiusLarge: CGFloat = 20
    static let cornerRadiusPill: CGFloat = 100
    
    static let paddingSmall: CGFloat = 8
    static let paddingMedium: CGFloat = 16
    static let paddingLarge: CGFloat = 24
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
```

---

## Typography

**Primary Font: Nunito** (Google Font — must be bundled with app)

Download from: https://fonts.google.com/specimen/Nunito

### Font Files Required
Add these to `Resources/Fonts/`:
- Nunito-Regular.ttf
- Nunito-Medium.ttf
- Nunito-SemiBold.ttf
- Nunito-Bold.ttf
- Nunito-Light.ttf

### Info.plist Entry
```xml
<key>UIAppFonts</key>
<array>
    <string>Nunito-Regular.ttf</string>
    <string>Nunito-Medium.ttf</string>
    <string>Nunito-SemiBold.ttf</string>
    <string>Nunito-Bold.ttf</string>
    <string>Nunito-Light.ttf</string>
</array>
```

### Font+App.swift Extension
```swift
import SwiftUI

extension Font {
    static func nunito(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch weight {
        case .bold:
            return .custom("Nunito-Bold", size: size)
        case .semibold:
            return .custom("Nunito-SemiBold", size: size)
        case .medium:
            return .custom("Nunito-Medium", size: size)
        case .light:
            return .custom("Nunito-Light", size: size)
        default:
            return .custom("Nunito-Regular", size: size)
        }
    }
    
    // Convenience presets matching Figma
    static let appLargeTitle = nunito(32, weight: .bold)
    static let appTitle = nunito(24, weight: .bold)
    static let appHeadline = nunito(20, weight: .semibold)
    static let appSubheadline = nunito(17, weight: .semibold)
    static let appBody = nunito(16, weight: .regular)
    static let appCallout = nunito(15, weight: .medium)
    static let appCaption = nunito(13, weight: .regular)
    static let appSmall = nunito(11, weight: .light)
    static let appButton = nunito(17, weight: .semibold)
}
```

### Usage Examples
```swift
// Direct usage
Text("Hello")
    .font(.nunito(16, weight: .semibold))

// Using presets
Text("Welcome to ShroomScout!")
    .font(.appTitle)

Text("Your Collection")
    .font(.appHeadline)

Text("47 species found")
    .font(.appBody)
```

---

## Screen Implementation Priority

### Phase 1: Core Structure
1. **App Entry + Tab Navigation** — Set up ShroomScoutApp.swift and ContentView with TabView
2. **Home Screen** — Main hub with stats and scan button
3. **Collection Screen** — Pokemon Go-style grid with found/unfound states

### Phase 2: Scanner Flow
4. **Camera View** — AVFoundation camera capture
5. **Scan Results View** — Show match options, user selection
6. **Confirmation View** — Celebration screen on discovery

### Phase 3: Details & Polish
7. **Species Detail View** — Full species information page
8. **Onboarding Flow** — First launch experience + disclaimer
9. **Profile Screen** — Stats, achievements, settings

### Phase 4: Map & Data
10. **Map View** — Sighting locations
11. **Settings View** — Preferences
12. **ML Integration** — Placeholder → real Core ML model

---

## iOS 26 Features to Use

- **Liquid Glass materials** — For tab bar, navigation bar, cards
- **New tab bar behavior** — Shrinking tab bar on scroll
- **Improved SwiftUI performance** — Optimized List rendering
- **New animation APIs** — Bouncy spring animations

---

## Tab Bar Structure

The app uses a **custom 5-tab layout** with a raised center action button:

```
┌─────────────────────────────────────────────┐
│                                             │
│              [Current Screen]               │
│                                             │
├─────────────────────────────────────────────┤
│                    ┌───┐                    │
│                    │ 📷│  ← Raised scan     │
│                    └───┘    button          │
│  🏠      📚                 🗺️      👤     │
│ Home  Collection   Scan    Map   Profile    │
└─────────────────────────────────────────────┘
```

**Tab Configuration:**
| Position | Tab | Icon | Behavior |
|----------|-----|------|----------|
| 1 | Home | house.fill | Normal tab |
| 2 | Collection | square.grid.2x2.fill | Normal tab |
| 3 | Scan | camera.fill | **Raised button** — opens Scanner modally |
| 4 | Map | map.fill | Normal tab |
| 5 | Profile | person.fill | Normal tab |

**Center Scan Button:**
- Larger than other tab items
- Raised/floating above the tab bar
- Coral color (#FF8A6C) to stand out
- Opens ScannerView as a **full-screen modal** (not a tab)
- Should have subtle pulse or glow animation

**Implementation Approach:**
- Use a custom `CustomTabBar` component (not default TabView)
- Or overlay a floating button on top of standard TabView
- The scan button triggers `.fullScreenCover` to present ScannerView

---

## Key UI Components

### Card Style Modifier
```swift
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppColors.cream)
            .cornerRadius(AppDimensions.cornerRadiusMedium)
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}
```

### Primary Button Style
```swift
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.headline, design: .rounded, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(AppColors.coral)
            .cornerRadius(AppDimensions.cornerRadiusPill)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
```

### Rarity Badge Component
```swift
struct RarityBadge: View {
    let rarity: Species.Rarity
    
    var color: Color {
        switch rarity {
        case .common: return AppColors.rarityCommon
        case .uncommon: return AppColors.rarityUncommon
        case .rare: return AppColors.rarityRare
        case .legendary: return AppColors.rarityLegendary
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(rarity.rawValue.capitalized)
                .font(.system(.caption, design: .rounded, weight: .medium))
                .foregroundColor(AppColors.textLight)
        }
    }
}
```

---

## Placeholder ML Service

For MVP, the identification service returns mock data. Real Core ML integration comes later.

```swift
import UIKit

struct IdentificationResult {
    let speciesID: String
    let confidence: Double
}

class IdentificationService {
    static let shared = IdentificationService()
    
    func identify(image: UIImage) async -> [IdentificationResult] {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        // Return mock results for MVP
        return [
            IdentificationResult(speciesID: "chanterelle", confidence: 0.87),
            IdentificationResult(speciesID: "false-chanterelle", confidence: 0.65),
            IdentificationResult(speciesID: "yellowfoot", confidence: 0.42)
        ]
    }
}
```

---

## Sample Species Data (pnw_species.json)

```json
[
  {
    "id": "chanterelle",
    "commonName": "Golden Chanterelle",
    "scientificName": "Cantharellus cibarius",
    "description": "The golden chanterelle is one of the most prized edible mushrooms...",
    "rarity": "uncommon",
    "edibility": "edible",
    "season": ["summer", "fall"],
    "habitat": "Conifer and mixed forests, often near Douglas fir",
    "identificationTips": "Look for false gills (ridges) rather than true gills...",
    "lookalikes": ["false-chanterelle", "jack-o-lantern"],
    "region": "pnw",
    "referenceImageName": "chanterelle_ref"
  }
]
```

---

## SwiftData Container Setup

### ShroomScoutApp.swift
```swift
import SwiftUI
import SwiftData

@main
struct ShroomScoutApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Species.self,
            Sighting.self,
            UserProfile.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
```

---

## Notes for Agents

### Critical: Reusable Components

**All reusable UI elements MUST be extracted into the `Views/Components/` folder.** Do not duplicate code across screens. If something appears more than once, it should be a component.

**Required components to create:**

| Component | Usage |
|-----------|-------|
| `PrimaryButton.swift` | Coral pill button used everywhere |
| `SecondaryButton.swift` | Outlined button style |
| `AppNavBar.swift` | Custom navigation bar with back button, title, optional right action |
| `CustomTabBar.swift` | Custom tab bar with 5 tabs and raised center scan button |
| `AppCard.swift` | Standard card container with shadow and rounded corners |
| `RarityBadge.swift` | Colored dot + rarity label |
| `EdibilityBadge.swift` | Icon + edibility status |
| `MascotView.swift` | Mascot display (placeholder for now) |
| `ProgressBar.swift` | Rounded progress bar with customizable color |
| `FilterPill.swift` | Selectable pill for filters |
| `SectionHeader.swift` | Consistent section title styling |
| `LoadingOverlay.swift` | Scanning/loading state overlay |
| `WarningBanner.swift` | Amber warning banner for disclaimers |
| `EmptyStateView.swift` | Reusable empty state with mascot + message + CTA |

**Component guidelines:**
- Each component should be fully self-contained
- Use `@ViewBuilder` for flexible content where needed
- Include SwiftUI Preview with example usage
- Document parameters with comments
- Use app colors from `AppColors` — never hardcode hex values

### Mascot Placeholder

**The mascot is a placeholder until we commission an artist.**

Use the 🍄 mushroom emoji as the mascot placeholder throughout the app:
- Display at appropriate sizes using `.font(.system(size: X))`
- Wrap in `MascotView.swift` component so we can swap it easily later
- Different "expressions" can be indicated with surrounding elements for now:
  - Happy/Excited: 🍄✨ 
  - Curious: 🍄❓
  - Encouraging: 🍄💪
  - Cautious: ⚠️🍄

```swift
// Example MascotView.swift
struct MascotView: View {
    enum Expression {
        case happy, curious, excited, cautious, encouraging
    }
    
    let expression: Expression
    let size: CGFloat
    
    var body: some View {
        // Placeholder implementation - will be replaced with actual mascot art
        Text(emoji)
            .font(.system(size: size))
    }
    
    private var emoji: String {
        switch expression {
        case .happy: return "🍄"
        case .curious: return "🍄"
        case .excited: return "🍄✨"
        case .cautious: return "⚠️🍄"
        case .encouraging: return "🍄💪"
        }
    }
}
```

### Other Guidelines

1. **Follow Figma designs exactly** — Match spacing, colors, and component layout
2. **Use SF Rounded font** — `.system(.body, design: .rounded)` for playful feel
3. **Rounded corners everywhere** — Minimum 12px, buttons should be pill-shaped
4. **Bouncy animations** — Use `.spring(response: 0.3, dampingFraction: 0.6)`
5. **iOS 26 tab bar** — Use system default Liquid Glass styling
6. **Test with Preview** — Every view should have a working preview
7. **Keep views small** — Break large views into smaller components
8. **Never duplicate code** — Extract to Components folder instead

---

## Figma Screen Links

*Agent will be provided Figma links for each screen via MCP*

| Screen | Figma Link |
|--------|------------|
| Home | [provided at runtime] |
| Collection | [provided at runtime] |
| Scanner | [provided at runtime] |
| Scan Results | [provided at runtime] |
| Species Detail | [provided at runtime] |
| Profile | [provided at runtime] |
| Onboarding | [provided at runtime] |