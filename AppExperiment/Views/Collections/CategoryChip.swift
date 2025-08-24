//
//  CollectionsView+Categories.swift
//  AppExperiment
//
//  Created by Reza Juliandri on 23/08/25.
//
import SwiftUI

struct CategoryChip: View {
    let category: CollectionCategoryEnum
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(category.description)
                .font(.callout.weight(.medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? Color(hex: "0FAAAC") : Color.clear)
                .foregroundStyle(isSelected ? .white : .primary)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? Color(hex: "0FAAAC") : .gray.opacity(0.3), lineWidth: 1)
                )
                .cornerRadius(10)
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: 10))
        .animation(.snappy(duration: 0.15), value: isSelected)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
