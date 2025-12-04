//
//  View+GlassEffect.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import SwiftUI

extension View { // effect for map carousel cards
    @ViewBuilder
    func optionalGlassEffect(_ colorScheme: ColorScheme, cornerRadius: CGFloat = 30) -> some View {
        let backgroundColor = colorScheme == .dark ? Color.black : Color.white

        if #available(iOS 26, *) {
            glassEffect(.clear.tint(backgroundColor.opacity(0.75)).interactive(), in: .rect(cornerRadius: cornerRadius, style: .continuous))
        } else {
            background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(backgroundColor)
            }
        }
    }
}
