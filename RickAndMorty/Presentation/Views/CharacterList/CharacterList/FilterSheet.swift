//
//  FilterSheet.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import SwiftUI

struct FilterSheet: View {
    @ObservedObject var viewModel: CharacterListViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section { // Status search filter
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Estado")
                            .font(.headline)

                        Text("Selecciona una de las opciones de estado para filtrar los resultados de búsqueda")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Picker("Estado", selection: $viewModel.selectedStatus) {
                            Text("Todos").tag(nil as CharacterStatus?)
                            ForEach(CharacterStatus.allCases, id: \.self) { status in
                                Text(status.displayName).tag(status as CharacterStatus?)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }

                Section { // Species Filter
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Especies")
                            .font(.headline)

                        Text("Prueba con \"human\", \"alien\", \"robot\", etc.")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        TextField("Escribe una especie", text: $viewModel.selectedSpecies)
                            .textInputAutocapitalization(.words)
                    }
                }
            }
            .navigationTitle("Filtros")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Limpiar") {
                        Task { await viewModel.clearFilters() }
                    }
                    .disabled(!viewModel.hasActiveFilters)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Aplicar") {
                        Task { await viewModel.applyFilters() }
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
