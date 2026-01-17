# ShroomScout — Agent Prompts

Use these prompts for coding agents with MCP access to Figma. Each prompt is designed for a specific screen or component. Provide the relevant Figma link when using each prompt.

---

## Setup Prompt (Run First)

```
You are building an iOS app called ShroomScout using SwiftUI for iOS 26.

Project context:
- Pokemon Go-style mushroom collection app
- Users scan mushrooms, identify them, collect species
- Cute, playful aesthetic with rounded UI and bouncy animations
- Uses SwiftData for persistence with CloudKit sync

Tech requirements:
- iOS 26+ deployment target
- Swift 6
- SwiftUI only (no UIKit unless absolutely necessary)
- SwiftData for data persistence
- MVVM architecture

Tab Bar Structure:
- Custom 5-tab layout with RAISED CENTER SCAN BUTTON
- Tabs: Home, Collection, [SCAN], Map, Profile
- Center scan button is larger, coral colored, floating above tab bar
- Scan button opens ScannerView as full-screen modal (not a regular tab)

CRITICAL — Reusable Components:
- ALL reusable UI elements go in Views/Components/ folder
- NEVER duplicate UI code — extract to a component instead
- Components are organized in subfolders: Buttons/, Cards/, Navigation/, Badges/, Mascot/, Feedback/, Common/
- Every component must have a SwiftUI Preview

Typography — Nunito Font:
- App uses Nunito font (Google Font) — NOT system font
- Font files must be bundled in Resources/Fonts/
- Create Font+App.swift extension with .nunito(size, weight) helper
- Font presets: .appTitle, .appHeadline, .appBody, .appCaption, .appButton
- NEVER use .system() font — always use .nunito() or presets

Mascot Placeholder:
- Use 🍄 mushroom emoji as mascot until real art is commissioned
- Wrap in MascotView.swift component with Expression enum (happy, curious, excited, cautious, encouraging)
- Different expressions: 🍄 (default), 🍄✨ (excited), ⚠️🍄 (cautious), 🍄💪 (encouraging)

Design requirements:
- Nunito font throughout (bundled Google Font, NOT system font)
- Rounded corners everywhere (min 12px, buttons pill-shaped)
- Bouncy spring animations: .spring(response: 0.3, dampingFraction: 0.6)
- iOS 26 Liquid Glass for navigation/tab bars

Color palette:
- Primary Green: #4A7C59
- Cream: #FFF8E7  
- Coral (buttons): #FF8A6C
- Background: #FFFDF7
- Text Dark: #2D3B2D
- Text Light: #6B7B6B
- Rarity Common: #9CA3AF
- Rarity Uncommon: #6EE7B7
- Rarity Rare: #7DD3FC
- Rarity Legendary: #FCD34D

Read the full implementation plan at: [provide path to ShroomScout_Implementation_Plan.md]

Confirm you understand the project context before proceeding.
```

---

## Agent 1: Project Setup & Core Components

```
Create the initial Xcode project structure for ShroomScout.

Tasks:
1. Create ShroomScoutApp.swift with SwiftData ModelContainer setup
   - Include Species, Sighting, and UserProfile models in the schema
   - Enable CloudKit sync with .automatic configuration

2. Create ContentView.swift with CUSTOM 5-TAB navigation:
   - 5 tabs: Home, Collection, Scan (CENTER), Map, Profile
   - Use SF Symbols: house.fill, square.grid.2x2.fill, camera.fill, map.fill, person.fill
   - The CENTER SCAN TAB is a raised action button (larger, coral colored, floating above tab bar)
   - Scan button opens ScannerView as a full-screen modal (.fullScreenCover), NOT a normal tab
   - Create a custom tab bar component OR overlay a floating button on standard TabView
   
3. Create the color extension (Color+App.swift) with all app colors

4. Set up Nunito font:
   - Create Font+App.swift extension with .nunito(size, weight) method
   - Include font presets: .appLargeTitle, .appTitle, .appHeadline, .appBody, .appCaption, .appButton
   - Note: Font .ttf files will be added manually to Resources/Fonts/
   - Add Info.plist entries for UIAppFonts

5. Create placeholder views for each tab that just show the tab name

6. Create the base data models:
   - Species.swift with all properties and enums (Rarity, Edibility, Season)
   - Sighting.swift for user discoveries  
   - UserProfile.swift for user data

7. Create the CORE REUSABLE COMPONENTS in Views/Components/:

   Buttons/
   - PrimaryButton.swift — Coral pill button with label, optional icon, bouncy press animation
   - SecondaryButton.swift — Outlined version (green border, transparent fill)

   Cards/
   - AppCard.swift — Container with cream background, rounded corners, shadow

   Navigation/
   - AppNavBar.swift — Custom nav bar with back button, centered title, optional right action
   - CustomTabBar.swift — Custom tab bar with 5 tabs, raised center scan button (coral, larger)

   Badges/
   - RarityBadge.swift — Colored dot + rarity text
   - EdibilityBadge.swift — Icon + edibility status (checkmark/warning/skull)

   Mascot/
   - MascotView.swift — 🍄 emoji placeholder with Expression enum (happy, curious, excited, cautious, encouraging)

   Feedback/
   - LoadingOverlay.swift — Translucent overlay with spinner and message
   - WarningBanner.swift — Amber banner with warning icon and text
   - EmptyStateView.swift — Mascot + message + optional CTA button

   Common/
   - ProgressBar.swift — Rounded progress bar with customizable colors
   - FilterPill.swift — Selectable pill button for filters
   - SectionHeader.swift — Consistent header with optional "See All" action

8. All components MUST:
   - Use Nunito font via .nunito() or presets (NEVER .system())
   - Use AppColors for all colors (no hardcoded hex)
   - Include SwiftUI Preview with example usage
   - Have documentation comments for parameters

Output all files with their complete file paths.
```

---

## Agent 2: Home Screen

```
Build the Home Screen for ShroomScout based on the Figma design.

Figma link: https://www.figma.com/design/axE63WLi48hMjk360vA18V/ShroomScout?node-id=13-8914&t=4qJxElTx6txmDqWz-4

IMPORTANT: Use existing components from Views/Components/ — do NOT recreate them.
Available components: PrimaryButton, SecondaryButton, AppCard, RarityBadge, MascotView, ProgressBar, SectionHeader, EmptyStateView, CustomTabBar

Requirements:
1. Create HomeView.swift and HomeViewModel.swift

2. Layout (top to bottom):
   - Header: "Hey, Scout!" greeting (left), region badge pill (right)
   - Mascot card using MascotView (expression: .happy) with speech bubble
   - Stats card using AppCard containing ProgressBar
   - "Recent Discoveries" using SectionHeader + horizontal scroll
   - NOTE: Scan button is in the custom tab bar (center), NOT on the home screen

3. HomeView-specific views (in Views/Home/):
   - MascotCard.swift — AppCard containing MascotView + speech bubble text
   - StatsCard.swift — AppCard with "Your Collection" title + ProgressBar
   - RecentFindsRow.swift — Horizontal scroll of circular thumbnails

4. Match Figma exactly for:
   - Spacing and padding
   - Font sizes and weights
   - Corner radii
   - Shadow values

5. Use sample data for previews
```

---

## Agent 3: Collection Screen

```
This page is already completed no need to do any further work.
```

---

## Agent 4: Camera/Scanner Screen

```
Build the Camera Scanner Screen for ShroomScout based on the Figma design.

Figma links: 
https://www.figma.com/design/axE63WLi48hMjk360vA18V/ShroomScout?node-id=1-1918&t=4qJxElTx6txmDqWz-4
https://www.figma.com/design/axE63WLi48hMjk360vA18V/ShroomScout?node-id=1-2091&t=4qJxElTx6txmDqWz-4


Requirements:
1. Create ScannerView.swift and ScannerViewModel.swift
2. Create CameraService.swift for AVFoundation camera handling

3. Layout:
   - Full-screen camera preview (AVCaptureVideoPreviewLayer)
   - Top bar (translucent dark): X close button, flash toggle, ? help button
   - Center guide: Rounded rectangle frame with corner brackets
   - Mascot peek: Small mascot in bottom corner with curious expression
   - Bottom controls: Gallery button (left), Capture button (center), flip camera (right)

4. Camera implementation:
   - Request camera permission on appear
   - AVCaptureSession with photo output
   - Capture button takes photo and freezes preview

5. Scanning state (after capture):
   - Photo freezes on screen
   - Animated scanning effect (could be simple pulsing overlay)
   - "Identifying..." text with loading indicator
   - After 1.5s delay, navigate to ScanResultsView

6. Handle permission denied state with friendly message

7. Flash toggle should work (AVCaptureDevice.TorchMode)

8. Close button dismisses the scanner (presented modally from Home)
```

---

## Agent 5: Scan Results Screen

```
Build the Scan Results Screen for ShroomScout based on the Figma design.

Figma link: 
https://www.figma.com/design/axE63WLi48hMjk360vA18V/ShroomScout?node-id=1-1988&t=4qJxElTx6txmDqWz-4

Requirements:
1. Create ScanResultsView.swift

2. Layout (top to bottom):
   - Navigation bar: Back arrow, "Results" title
   - User's captured photo in rounded card (medium size)
   - Warning banner: Amber background, "⚠️ Suggestions only — verify with an expert"
   - Match results: 3-5 cards in scrollable list
   - "None of these look right" text link at bottom
   - Action bar: "Add to Collection" button (disabled until selection)

3. Create MatchCard.swift component:
   - Thumbnail image (left)
   - Common name (bold), scientific name (italic, muted)
   - Confidence percentage (right side, e.g., "87%")
   - Rarity badge (colored dot + label)
   - Edibility icon
   - Selection state: outlined default, filled + checkmark when selected

4. Selection behavior:
   - Single selection only
   - Tap to select, tap again to deselect
   - "Add to Collection" enables when card selected
   - Bouncy scale animation on selection

5. Use mock identification results:
   - 3 hardcoded species with varying confidence scores
   - Wire up to IdentificationService.shared.identify() placeholder

6. "Add to Collection" navigates to ConfirmationView
```

---

## Agent 6: Confirmation Screen

```
Build the Collection Confirmation Screen for ShroomScout based on the Figma design.

Figma link: https://www.figma.com/design/axE63WLi48hMjk360vA18V/ShroomScout?node-id=1-2180&t=4qJxElTx6txmDqWz-4

Requirements:
1. Create ConfirmationView.swift

2. Layout:
   - Celebration area at top (for confetti animation)
   - "New Discovery!" or "Added to Collection!" banner
   - Large species card (photo, name, scientific name, rarity, edibility)
   - Location tag with mini text: "📍 Found near [location]"
   - Two buttons: "View Details" (outlined), "Keep Hunting!" (coral filled)

3. Celebration animation:
   - Confetti or sparkle effect on appear
   - Mascot in excited pose (use SF Symbol star.circle.fill as placeholder)
   - Bouncy entrance animation for the card

4. Different treatment for:
   - New discovery: "New Discovery!" + first found date
   - Repeat sighting: "Found Again!" + sighting count

5. Haptic feedback on appear (if enabled in settings)

6. "Keep Hunting!" dismisses back to Home
7. "View Details" navigates to SpeciesDetailView

8. Save the sighting to SwiftData when this screen appears
```

---

## Agent 7: Species Detail Screen

```
Build the Species Detail Screen for ShroomScout based on the Figma design.

Figma link: https://www.figma.com/design/axE63WLi48hMjk360vA18V/ShroomScout?node-id=1-2263&t=4qJxElTx6txmDqWz-4

Requirements:
1. Create SpeciesDetailView.swift

2. Layout (scrollable):
   - Hero image (full width, rounded bottom corners, gradient overlay)
   - Floating buttons: Back (top left), Share (top right)
   - Title section: Common name, scientific name, rarity + edibility badges
   - "Your Sightings" card (if user has found this species)
   - Quick facts card with icons (edibility, season, habitat)
   - "About" description section
   - "Lookalikes" warning card (amber tint) if applicable
   - "How to Identify" tips section

3. Components:
   - QuickFactsCard.swift — icon rows for edibility, season, habitat
   - LookalikesCard.swift — warning card with similar species
   - SightingsRow.swift — horizontal scroll of user's photos with dates

4. Conditional display:
   - Show "Your Sightings" only if user has found this species
   - Show "Lookalikes" only if species has dangerous lookalikes
   - Different header for found vs unfound species

5. Edibility display:
   - Edible: Green checkmark
   - Caution: Amber warning
   - Toxic/Deadly: Red skull icon

6. Load species data from SwiftData by ID
```

---

## Agent 8: Onboarding Flow

```
Build the Onboarding Flow for ShroomScout based on the Figma design.

Figma link: 
https://www.figma.com/design/axE63WLi48hMjk360vA18V/ShroomScout?node-id=1-2715&t=4qJxElTx6txmDqWz-4
https://www.figma.com/design/axE63WLi48hMjk360vA18V/ShroomScout?node-id=1-2&t=4qJxElTx6txmDqWz-4
https://www.figma.com/design/axE63WLi48hMjk360vA18V/ShroomScout?node-id=1-41&t=4qJxElTx6txmDqWz-4
https://www.figma.com/design/axE63WLi48hMjk360vA18V/ShroomScout?node-id=1-108&t=4qJxElTx6txmDqWz-4
https://www.figma.com/design/axE63WLi48hMjk360vA18V/ShroomScout?node-id=1-162&t=4qJxElTx6txmDqWz-4

IMPORTANT: Use existing components from Views/Components/
Available: PrimaryButton, SecondaryButton, AppCard, MascotView, WarningBanner, EmptyStateView

You will need to create a few new components.

Requirements:
1. Create OnboardingView.swift with TabView for paging

2. Screens (5 total):
   a. Welcome: MascotView(.happy, size: 120), "Welcome to ShroomScout!", subtitle, PrimaryButton
   b. How It Works: Camera → Mushroom → Collection icons, explanation, PrimaryButton
   c. Collection Preview: MascotView(.excited) with mushroom cards around it, "Collect them all!", PrimaryButton
   d. Safety Disclaimer: WarningBanner, MascotView(.cautious), disclaimer text, checkbox + PrimaryButton
   e. Ready: MascotView(.excited, size: 120), "Ready to explore?", PrimaryButton "Start Collecting!"

3. Use MascotView component with appropriate expressions:
   - Welcome: .happy
   - How It Works: .curious  
   - Collection: .excited
   - Disclaimer: .cautious
   - Ready: .excited

4. Disclaimer screen (Screen d) is CRITICAL:
   - Checkbox must be checked before button enables
   - Full disclaimer text about educational purposes only
   - Store agreement in UserProfile.hasAgreedToDisclaimer

5. Page indicators at bottom (dots)

6. Skip functionality NOT allowed (must go through all screens)

7. On completion:
   - Set UserProfile.hasCompletedOnboarding = true
   - Navigate to main app (ContentView)

8. Check onboarding status on app launch — only show if not completed
```

---

## Agent 9: Profile Screen

```
Build the Profile Screen for ShroomScout based on the Figma design.

Figma link: https://www.figma.com/design/axE63WLi48hMjk360vA18V/ShroomScout?node-id=1-2505&t=4qJxElTx6txmDqWz-4

Requirements:
1. Create ProfileView.swift and ProfileViewModel.swift

2. Layout:
   - Header card: Mascot avatar, username, member since date, region badge
   - Stats grid (2x2): Found count, Total sightings, Day streak, Rare finds
   - Rarity breakdown: Horizontal bar or pie chart showing distribution
   - Achievements section: Horizontal scroll of badge icons
   - Settings button (gear icon) → SettingsView

3. Stats should be computed from SwiftData:
   - Found count: Unique species in Sightings
   - Total sightings: All Sighting records
   - Day streak: Consecutive days with sightings (can be placeholder)
   - Rare finds: Sightings where species rarity is rare or legendary

4. Achievements (placeholder for MVP):
   - Show 6-8 badge icons
   - Earned: Full color
   - Locked: Gray with lock overlay
   - Examples: "First Find", "Fungi Fanatic", "Rare Hunter"

5. Create SettingsView.swift:
   - Account section: Edit profile name, Change region
   - Preferences: Sound effects toggle, Haptic toggle
   - About: Version, Terms, Privacy, Safety Disclaimer link
   - Support: Help, Contact, Rate app

6. Settings should read/write to UserProfile in SwiftData
```

---

## Agent 10: Map Screen

```
Build the Map Screen for ShroomScout based on the Figma design.

Figma link: https://www.figma.com/design/axE63WLi48hMjk360vA18V/ShroomScout?node-id=1-2386&t=4qJxElTx6txmDqWz-4

Requirements:
1. Create MapView.swift and MapViewModel.swift

2. Layout:
   - Full-screen MapKit Map
   - Floating search/filter bar at top
   - Custom mushroom pins for sightings
   - Bottom sheet (collapsed): "X discoveries nearby"

3. Map implementation:
   - Use iOS 26 MapKit with SwiftUI
   - Center on user's location (request permission)
   - Show all user's Sightings as pins

4. Custom annotation:
   - Small mushroom icon (SF Symbol leaf.fill)
   - Color-coded by rarity
   - Cluster when zoomed out

5. Pin tap behavior:
   - Show callout with: Photo thumbnail, species name, date
   - "View" button → SpeciesDetailView

6. Bottom sheet:
   - Collapsed: Shows count "12 discoveries nearby"
   - Can expand to list view of nearby sightings
   - Each row: Photo, name, distance, date

7. Filter button:
   - Filter by species
   - Filter by rarity
   - Filter by date range

8. Handle location permission denied gracefully
```

---

## Testing Prompt

```
Review the ShroomScout codebase and ensure:

1. All views have working SwiftUI Previews with sample data
2. Navigation flows work correctly:
   - Home → Scanner → Results → Confirmation → Home
   - Collection → Species Detail
   - Profile → Settings
3. SwiftData operations work:
   - Save new sighting
   - Fetch user's sightings
   - Update user profile
4. No compiler warnings or errors
5. UI matches Figma designs for spacing, colors, typography
6. Animations are smooth and bouncy
7. iOS 26 features are properly used (Liquid Glass, etc.)

Create PreviewData.swift with mock Species and Sightings for testing.
Output a summary of any issues found and their fixes.
```

---

## Notes

### Component Reuse is MANDATORY

Before creating any new UI element, check if a component already exists in `Views/Components/`:
- Buttons → use PrimaryButton or SecondaryButton
- Cards/containers → use AppCard
- Navigation bars → use AppNavBar
- Rarity indicators → use RarityBadge
- Edibility indicators → use EdibilityBadge  
- Mascot → use MascotView with appropriate Expression
- Progress bars → use ProgressBar
- Filter buttons → use FilterPill
- Section titles → use SectionHeader
- Loading states → use LoadingOverlay
- Warnings → use WarningBanner
- Empty states → use EmptyStateView

If you need a new reusable element, create it in Components/ — NOT inline in the view.

### Mascot Reminder
The mascot is 🍄 emoji via MascotView component. Do NOT use SF Symbols for the mascot.

### General Notes
- Always provide the Figma link when using these prompts
- Run the Setup Prompt first before any screen prompts
- Agents can be run in parallel for independent screens
- Agent 1 (Setup) must complete before others
- Agents 4-6 (Scanner flow) should be done in sequence
- Test thoroughly after each agent completes