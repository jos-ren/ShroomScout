//
//  PageHeader.swift
//  ShroomScout
//
//  Reusable page header component for any screen.
//

import SwiftUI

struct PageHeader: View {
    let title: String
    var alignment: HorizontalAlignment = .leading

    var body: some View {
        Text(title)
            .font(.nunito(24, weight: .bold))
            .foregroundColor(AppColors.textDark)
            .frame(maxWidth: .infinity, alignment: alignment == .leading ? .leading : alignment == .center ? .center : .trailing)
    }
}

#Preview {
    VStack(spacing: 24) {
        PageHeader(title: "My Collection")
        PageHeader(title: "Home")
        PageHeader(title: "Profile")
        PageHeader(title: "Centered Title", alignment: .center)
    }
    .padding(24)
    .background(AppColors.background)
}
