//
//  LoadingMoreView.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import SwiftUI

struct LoadingMoreView: View {
    var body: some View {
        HStack(spacing: 12) {
            ProgressView()
            Text("Cargando más...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}
