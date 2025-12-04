//
//  CharacterListView.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import SwiftUI

struct CharacterListView: View {
    @StateObject private var viewModel = DIContainer.shared.makeCharacterListViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                contentView
            }
            .navigationTitle("Lista de Personajes")
            .searchable(
                text: $viewModel.searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Buscar por nombre"
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    filterButton
                }
            }
            .sheet(isPresented: $viewModel.showFilters) {
                FilterSheet(viewModel: viewModel)
                    .presentationDetents([.height(360)])
            }
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                await viewModel.loadInitialData()
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.state {
        case .idle, .loading:
            LoadingView()

        case .loaded:
            characterListContent

        case .empty:
            EmptyStateView(
                icon: "person.slash",
                title: "No se encontraron personajes",
                message: "Ajusta los filtros de busqueda",
                action: viewModel.hasActiveFilters ? {
                    Task { await viewModel.clearFilters() }
                } : nil,
                actionTitle: "Limpiar filtros"
            )

        case let .error(message):
            ErrorView(
                message: message,
                retryAction: {
                    Task { await viewModel.refresh() }
                }
            )
        }
    }

    private var characterListContent: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.characters) { character in
                    NavigationLink(value: character) {
                        CharacterRowView(character: character)
                    }
                    .buttonStyle(.plain)
                    .task {
                        await viewModel.loadMoreIfNeeded(currentItem: character)
                    }
                }

                if viewModel.isLoadingMore {
                    LoadingMoreView()
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .navigationDestination(for: Character.self) { character in
            CharacterDetailView(
                viewModel: DIContainer.shared.makeCharacterDetailViewModel(character: character),
                onFavoriteChanged: { id, isFavorite in
                    viewModel.updateCharacterFavorite(id: id, isFavorite: isFavorite)
                }
            )
        }
    }

    private var filterButton: some View {
        Button {
            viewModel.showFilters = true
        } label: {
            Image(systemName: viewModel.hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                .foregroundColor(viewModel.hasActiveFilters ? .rickBlue : .primary)
        }
    }
}
