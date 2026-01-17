//
//  CollectionView.swift
//  ShroomScout
//
//  Collection tab showing discovered and undiscovered mushrooms.
//

import SwiftUI

struct CollectionView: View {
    /// Callback when a species is tapped to navigate to detail
    var onSpeciesTapped: ((String) -> Void)?

    @State private var viewMode: CollectionViewMode = .allSpecies
    @State private var selectedRarities: Set<Rarity> = []

    private var filteredSpecies: [SampleSpecies] {
        let baseList: [SampleSpecies] = {
            switch viewMode {
            case .allSpecies:
                return SampleData.mixedDiscoveryStates
            case .myFinds:
                return SampleData.mixedDiscoveryStates.filter { $0.isDiscovered }
            }
        }()

        if selectedRarities.isEmpty {
            return baseList
        }

        return baseList.filter { selectedRarities.contains($0.rarity) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                PageHeader(title: "My Collection")

                CollectionProgress(
                    region: "Pacific Northwest",
                    discoveredCount: SampleData.mixedDiscoveryStates.filter { $0.isDiscovered }.count,
                    totalCount: SampleData.mixedDiscoveryStates.count
                )

                CollectionTabs(selectedMode: $viewMode)

                RarityFilters(selectedRarities: $selectedRarities)

                // Collection grid
                CollectionGrid {
                    ForEach(filteredSpecies) { species in
                        CollectionCard(species: species) {
                            onSpeciesTapped?(species.id)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 24)
        }
        .background(AppColors.background)
    }
}

#Preview {
    CollectionView()
}
