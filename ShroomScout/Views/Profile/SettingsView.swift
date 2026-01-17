//
//  SettingsView.swift
//  ShroomScout
//
//  Settings screen with account, preferences, about, and support sections.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var viewModel: ProfileViewModel

    @State private var showEditNameSheet = false
    @State private var showRegionSheet = false
    @State private var editedName = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Account Section
                    SettingsSection(title: "Account") {
                        SettingsRow(
                            icon: "person.fill",
                            title: "Edit Profile Name",
                            value: viewModel.displayName
                        ) {
                            editedName = viewModel.displayName
                            showEditNameSheet = true
                        }

                        SettingsRow(
                            icon: "mappin.circle.fill",
                            title: "Change Region",
                            value: viewModel.regionDisplayName
                        ) {
                            showRegionSheet = true
                        }
                    }

                    // Preferences Section
                    SettingsSection(title: "Preferences") {
                        SettingsToggleRow(
                            icon: "speaker.wave.2.fill",
                            title: "Sound Effects",
                            isOn: Binding(
                                get: { viewModel.soundEffectsEnabled },
                                set: { viewModel.soundEffectsEnabled = $0 }
                            )
                        )

                        SettingsToggleRow(
                            icon: "iphone.radiowaves.left.and.right",
                            title: "Haptic Feedback",
                            isOn: Binding(
                                get: { viewModel.hapticFeedbackEnabled },
                                set: { viewModel.hapticFeedbackEnabled = $0 }
                            )
                        )
                    }

                    // About Section
                    SettingsSection(title: "About") {
                        SettingsRow(
                            icon: "info.circle.fill",
                            title: "Version",
                            value: "1.0.0"
                        ) { }

                        SettingsRow(
                            icon: "doc.text.fill",
                            title: "Terms of Service"
                        ) {
                            // Open terms URL
                        }

                        SettingsRow(
                            icon: "lock.shield.fill",
                            title: "Privacy Policy"
                        ) {
                            // Open privacy URL
                        }

                        SettingsRow(
                            icon: "exclamationmark.triangle.fill",
                            iconColor: AppColors.caution,
                            title: "Safety Disclaimer"
                        ) {
                            // Open safety disclaimer
                        }
                    }

                    // Support Section
                    SettingsSection(title: "Support") {
                        SettingsRow(
                            icon: "questionmark.circle.fill",
                            title: "Help Center"
                        ) {
                            // Open help
                        }

                        SettingsRow(
                            icon: "envelope.fill",
                            title: "Contact Us"
                        ) {
                            // Open email
                        }

                        SettingsRow(
                            icon: "star.fill",
                            iconColor: AppColors.rarityLegendary,
                            title: "Rate ShroomScout"
                        ) {
                            // Open App Store review
                        }
                    }

                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
            }
            .background(AppColors.background)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.textDark)
                    }
                }
            }
            .sheet(isPresented: $showEditNameSheet) {
                EditNameSheet(
                    name: $editedName,
                    onSave: {
                        viewModel.updateDisplayName(editedName)
                        showEditNameSheet = false
                    }
                )
                .presentationDetents([.height(220)])
            }
            .sheet(isPresented: $showRegionSheet) {
                RegionPickerSheet(
                    selectedRegion: viewModel.userProfile?.selectedRegion ?? "pnw",
                    onSelect: { region in
                        viewModel.updateRegion(region)
                        showRegionSheet = false
                    }
                )
                .presentationDetents([.medium])
            }
        }
    }
}

// MARK: - Settings Section

private struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.nunito(14, weight: .semibold))
                .foregroundColor(AppColors.textLight)
                .padding(.leading, 4)

            VStack(spacing: 2) {
                content
            }
            .background(.white)
            .cornerRadius(16)
            .shadow(
                color: .black.opacity(0.05),
                radius: 5,
                x: 0,
                y: 2
            )
        }
    }
}

// MARK: - Settings Row

private struct SettingsRow: View {
    let icon: String
    var iconColor: Color = AppColors.primaryGreen
    let title: String
    var value: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
                    .frame(width: 28)

                Text(title)
                    .font(.nunito(16, weight: .medium))
                    .foregroundColor(AppColors.textDark)

                Spacer()

                if let value = value {
                    Text(value)
                        .font(.nunito(14, weight: .regular))
                        .foregroundColor(AppColors.textLight)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppColors.textLight)
            }
            .padding(16)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Settings Toggle Row

private struct SettingsToggleRow: View {
    let icon: String
    var iconColor: Color = AppColors.primaryGreen
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(iconColor)
                .frame(width: 28)

            Text(title)
                .font(.nunito(16, weight: .medium))
                .foregroundColor(AppColors.textDark)

            Spacer()

            Toggle("", isOn: $isOn)
                .tint(AppColors.primaryGreen)
                .labelsHidden()
        }
        .padding(16)
    }
}

// MARK: - Edit Name Sheet

private struct EditNameSheet: View {
    @Binding var name: String
    let onSave: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("Edit Profile Name")
                .font(.nunito(20, weight: .bold))
                .foregroundColor(AppColors.textDark)

            TextField("Your name", text: $name)
                .font(.nunito(16, weight: .regular))
                .padding(16)
                .background(AppColors.cream)
                .cornerRadius(12)

            AppButton("Save", style: .primary) {
                onSave()
            }
        }
        .padding(24)
        .background(AppColors.background)
    }
}

// MARK: - Region Picker Sheet

private struct RegionPickerSheet: View {
    let selectedRegion: String
    let onSelect: (String) -> Void

    private let regions: [(id: String, name: String, emoji: String)] = [
        ("pnw", "Pacific Northwest", "🌲"),
        ("ne", "Northeast", "🍂"),
        ("se", "Southeast", "🌴"),
        ("mw", "Midwest", "🌾"),
        ("sw", "Southwest", "🌵")
    ]

    var body: some View {
        VStack(spacing: 20) {
            Text("Select Region")
                .font(.nunito(20, weight: .bold))
                .foregroundColor(AppColors.textDark)
                .padding(.top, 8)

            VStack(spacing: 8) {
                ForEach(regions, id: \.id) { region in
                    Button {
                        onSelect(region.id)
                    } label: {
                        HStack(spacing: 12) {
                            Text(region.emoji)
                                .font(.system(size: 24))

                            Text(region.name)
                                .font(.nunito(16, weight: .medium))
                                .foregroundColor(AppColors.textDark)

                            Spacer()

                            if selectedRegion == region.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(AppColors.primaryGreen)
                            }
                        }
                        .padding(16)
                        .background(selectedRegion == region.id ? AppColors.cream : .white)
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(24)
        .background(AppColors.background)
    }
}

#Preview {
    SettingsView(viewModel: ProfileViewModel())
}
