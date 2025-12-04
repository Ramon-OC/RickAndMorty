//
//  CharacterDetailView.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import SwiftUI

struct CharacterDetailView: View {
    @StateObject var viewModel: CharacterDetailViewModel
    var onFavoriteChanged: ((Int, Bool) -> Void)?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerSection /// name, picture, state, genre
                VStack(spacing: 20) {
                    characterInfoSection // genre, species, origin, location
                    mapSection // compact and expandable map
                    Divider()
                    episodesSection // list of episodes in which the character appears
                }
                .padding()
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(Color(.systemGroupedBackground))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                favoriteButton
            }
        }
        .task {
            await viewModel.loadEpisodes()
        }
        .onAppear {
            viewModel.onFavoriteChanged = onFavoriteChanged
        }
        .alert("Quitar de Favoritos", isPresented: $viewModel.showingRemoveFavoriteAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Quitar", role: .destructive) {
                Task { await viewModel.confirmRemoveFavorite() }
            }
        } message: {
            Text("¿Estás seguro que deseas quitar a \(viewModel.character.name) de tus favoritos?")
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        ZStack(alignment: .bottom) {
            AsyncImage(url: viewModel.character.imageURL) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay { ProgressView() }
                case let .success(image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay {
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        }
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 350)
            .clipped()

            LinearGradient( // Gradient Overlay
                colors: [.clear, .black.opacity(0.7)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 150)

            VStack(alignment: .leading, spacing: 8) { // Name and Status
                Text(viewModel.character.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                HStack(spacing: 50) {
                    CharacterStatusCircle(status: viewModel.character.status)
                    Text(viewModel.character.species)
                        .foregroundColor(.white.opacity(0.9))
                }
                .font(.subheadline)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }

    // MARK: - Character Info Section

    private var characterInfoSection: some View {
        VStack(spacing: 16) {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
            ], spacing: 12) {
                InfoCard(
                    icon: "figure.child",
                    title: "Género",
                    value: viewModel.character.gender.displayName
                )

                InfoCard(
                    icon: "lizard.fill",
                    title: "Especie",
                    value: viewModel.character.species
                )

                InfoCard(
                    icon: "globe",
                    title: "Origen",
                    value: viewModel.character.origin.name
                )

                InfoCard(
                    icon: "map.fill",
                    title: "Ubicación",
                    value: viewModel.character.location.name
                )
            }
        }
    }

    // MARK: - Map Section

    private var mapSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Localización del personaje")
                .font(.title3)
                .fontWeight(.bold)
            CharacterMapCard(coordinate: viewModel.getCoordinate(), imageURL: viewModel.character.imageURL!)
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 4)
        }
    }

    // MARK: - Episodes Section

    private var episodesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Lista de Episodios")
                        .font(.title3)
                        .fontWeight(.bold)

                    if viewModel.totalEpisodesCount > 0 {
                        Text("\(viewModel.watchedEpisodesCount) de \(viewModel.totalEpisodesCount) episodios vistos")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()
            }

            if viewModel.totalEpisodesCount > 0 { // Progress Bar
                ProgressView(value: viewModel.watchedProgress)
                    .tint(.blue)
                    .scaleEffect(y: 2)
                    .clipShape(Capsule())
            }

            episodesContent // list of episodes
        }
    }

    @ViewBuilder
    private var episodesContent: some View {
        switch viewModel.episodesState {
        case .idle, .loading:
            HStack {
                Spacer()
                ProgressView()
                    .padding()
                Spacer()
            }

        case let .loaded(episodes):
            LazyVStack(spacing: 8) {
                ForEach(episodes) { episode in
                    EpisodeRow(
                        episode: episode,
                        onToggleWatched: {
                            Task { await viewModel.toggleEpisodeWatched(episode: episode) }
                        }
                    )
                }
            }

        case .empty:
            Text("No se encontraron episodios")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .padding()

        case let .error(message):
            VStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.orange)
                Text(message)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }

    // MARK: Favorite Button

    private var favoriteButton: some View {
        Button {
            Task { await viewModel.toggleFavorite() }
        } label: {
            Image(systemName: viewModel.character.isFavorite ? "heart.fill" : "heart")
                .foregroundColor(viewModel.character.isFavorite ? .red : .primary)
                .font(.title3)
                .scaleEffect(viewModel.character.isFavorite ? 1.1 : 1.0)
        }
        .disabled(viewModel.isTogglingFavorite)
        .animation(.easeInOut(duration: 0.2), value: viewModel.character.isFavorite)
    }
}

#Preview("Character Detail") {
    NavigationStack {
        CharacterDetailView(
            viewModel: DIContainer.shared.makeCharacterDetailViewModel(
                character: Character(
                    id: 1,
                    name: "Rick Sanchez",
                    status: .alive,
                    species: "Human",
                    type: "",
                    gender: .male,
                    origin: CharacterLocation(name: "Earth (C-137)", url: ""),
                    location: CharacterLocation(name: "Citadel of Ricks", url: ""),
                    imageURL: URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg"),
                    episodeURLs: [],
                    coordinates: CharacterCoordinates.deterministicInSeattle(for: 1)
                )
            )
        )
    }
}
