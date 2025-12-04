//
//  FavoritesListView.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import SwiftUI

struct FavoritesListView: View {
    @StateObject private var viewModel: FavoritesViewModel
    @Environment(\.scenePhase) private var scenePhase

    init(viewModel: FavoritesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isAuthenticated {
                    favoritesListView
                } else {
                    BiometricLockView(
                        biometricAvailability: viewModel.biometricAvailability,
                        onAuthenticate: {
                            viewModel.authenticate()
                        }
                    )
                }
            }
            .navigationTitle("Favoritos")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if viewModel.isAuthenticated {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        lockButton
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}

                if !viewModel.isAuthenticated {
                    Button("Reintentar") {
                        viewModel.retryAuthentication()
                    }
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .onChange(of: scenePhase) { _, newPhase in
                handleScenePhaseChange(newPhase)
            }
        }
    }

    // MARK: - Favorites list

    private var favoritesListView: some View {
        Group {
            if viewModel.isLoading {
                loadingView
            } else if viewModel.favoriteCharacters.isEmpty {
                emptyStateView
            } else {
                favoritesList
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Cargando favoritos")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var favoritesList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.favoriteCharacters) { character in
                    FavoriteCharacterRow(
                        character: character,
                        onRemoveFavorite: {
                            Task {
                                await viewModel.toggleFavorite(character)
                            }
                        }
                    )
                }
            }
            .padding()
        }
    }

    private var lockButton: some View {
        Button(action: {
            withAnimation {
                viewModel.lockScreen()
            }
        }) {
            Image(systemName: "lock.fill")
                .font(.body)
                .foregroundColor(.blue)
        }
    }

    // MARK: - Empty state

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash.fill")
                .font(.system(size: 64))
                .foregroundColor(.gray.opacity(0.5))

            VStack(spacing: 8) {
                Text("No tienes favoritos")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Los personajes que marques como favoritos aparecerán aquí")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Scene phase handling

    private func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .background, .inactive:
            if viewModel.isAuthenticated {
                viewModel.invalidateAuthentication()
            }
        case .active:
            break
        @unknown default:
            break
        }
    }
}
