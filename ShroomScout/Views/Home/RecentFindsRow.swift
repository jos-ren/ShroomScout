//
//  RecentFindsRow.swift
//  ShroomScout
//
//  Horizontal scrolling row of recent mushroom discoveries with circular thumbnails.
//

import SwiftUI

struct RecentFindsRow: View {
    /// Section title
    let title: String

    /// Recent discoveries to display
    let discoveries: [RecentDiscovery]

    /// Action when a discovery is tapped
    var onDiscoveryTapped: ((RecentDiscovery) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            Text(title)
                .font(.nunito(18, weight: .bold))
                .foregroundColor(AppColors.textDark)
                .padding(.horizontal, 24)

            // Horizontal scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(discoveries) { discovery in
                        RecentFindItem(discovery: discovery) {
                            onDiscoveryTapped?(discovery)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 4) // Extra padding for shadow
            }
        }
    }
}

// MARK: - Recent Find Item

private struct RecentFindItem: View {
    let discovery: RecentDiscovery
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Circular thumbnail
                ZStack {
                    // Outer ring with rarity-based border
                    Circle()
                        .stroke(
                            AppColors.primaryGreen.opacity(0.2),
                            lineWidth: 2
                        )
                        .frame(width: 80, height: 80)

                    // Image container
                    Circle()
                        .fill(AppColors.cream)
                        .frame(width: 76, height: 76)

                    // Mushroom image or placeholder
                    if let uiImage = UIImage(named: discovery.imageName) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 76, height: 76)
                            .clipShape(Circle())
                    } else {
                        // Placeholder with mushroom emoji
                        Text("🍄")
                            .font(.system(size: 32))
                    }
                }
                .shadow(
                    color: .black.opacity(0.08),
                    radius: 4,
                    x: 0,
                    y: 2
                )

                // Name label
                Text(discovery.name)
                    .font(.nunito(12, weight: .semibold))
                    .foregroundColor(AppColors.textDark)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(width: 80, height: 32)
            }
        }
        .buttonStyle(BounceButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 32) {
        RecentFindsRow(
            title: "Recent Discoveries",
            discoveries: [
                RecentDiscovery(
                    id: "golden-chanterelle",
                    name: "Golden Chanterelle",
                    imageName: "golden-chanterelle",
                    rarity: .uncommon
                ),
                RecentDiscovery(
                    id: "black-morel",
                    name: "Black Morel",
                    imageName: "black-morel",
                    rarity: .rare
                ),
                RecentDiscovery(
                    id: "oyster-mushroom",
                    name: "Oyster Mushroom",
                    imageName: "oyster-mushroom",
                    rarity: .common
                ),
                RecentDiscovery(
                    id: "shiitake",
                    name: "Shiitake",
                    imageName: "shiitake",
                    rarity: .uncommon
                )
            ]
        ) { discovery in
            print("Tapped: \(discovery.name)")
        }

        RecentFindsRow(
            title: "This Week",
            discoveries: [
                RecentDiscovery(
                    id: "lions-mane",
                    name: "Lion's Mane",
                    imageName: "lions-mane",
                    rarity: .rare
                ),
                RecentDiscovery(
                    id: "fly-agaric",
                    name: "Fly Agaric",
                    imageName: "fly-agaric",
                    rarity: .common
                )
            ]
        )
    }
    .padding(.vertical, 24)
    .background(AppColors.background)
}
