# ShroomScout - Claude Code Instructions

## Project Overview
Pokemon Go-style mushroom collection app for iOS 26 using SwiftUI and SwiftData.

## Read These First
- `Docs/ShroomScout_Implementation_Plan.md` — Full technical spec
- `Docs/ShroomScout_Quick_Reference.md` — Colors, fonts, components

## Critical Rules
1. **Font:** Use Nunito (never system font) — see Font+App.swift
2. **Components:** All reusable UI goes in Views/Components/
3. **Colors:** Use AppColors only — never hardcode hex values
4. **Mascot:** Use 🍄 emoji via MascotView until real art exists
5. **Architecture:** MVVM with SwiftData
6. **Target:** iOS 26+
7. **APP CODE > FIGMA:** Always prefer existing app component implementations over Figma designs (see below)

## APP CODE TAKES PRIORITY OVER FIGMA DESIGNS

**THIS IS CRITICAL - DO NOT IGNORE**

When building or modifying components:
- **ALWAYS** check if a component already exists in `Views/Components/`
- **NEVER** change an existing component's appearance to match Figma
- The app's implemented components have been refined and improved beyond the original Figma designs
- Figma is for reference on NEW components only, not for "fixing" existing ones
- If Figma shows something different than the app code, **the app code is correct**

Existing components to NEVER restyle based on Figma:
- CustomTabBar, CollectionCard, CollectionTabs, RarityFilters
- AppButton, AppCard, AppBadge, PageHeader
- MascotView, WarningBanner, ProgressIndicator, CollectionProgress

When in doubt: Read the existing component code first, use it as-is.

## Code Style
- SwiftUI only (no UIKit)
- Every view needs a #Preview
- Bouncy animations: .spring(response: 0.3, dampingFraction: 0.6)
- Rounded corners everywhere (min 12px)