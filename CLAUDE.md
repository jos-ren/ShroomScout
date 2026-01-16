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

## Code Style
- SwiftUI only (no UIKit)
- Every view needs a #Preview
- Bouncy animations: .spring(response: 0.3, dampingFraction: 0.6)
- Rounded corners everywhere (min 12px)