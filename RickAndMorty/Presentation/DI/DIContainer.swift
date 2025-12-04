//
//  DIContainer.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import Foundation

final class DIContainer {
    static let shared = DIContainer()

    // repositories
    lazy var characterRepository: CharacterRepository = CharacterRepositoryImpl()
    lazy var episodeRepository: EpisodeRepository = EpisodeRepositoryImpl()

    // use cases
    func makeGetCharactersUseCase() -> GetCharactersProtocol {
        GetCharacters(repository: characterRepository)
    }

    func makeGetCharacterDetailUseCase() -> GetCharacterDetailProtocol {
        GetCharacterDetail(repository: characterRepository)
    }

    func makeToggleFavoriteUseCase() -> ToggleFavoriteProtocol {
        ToggleFavorite(repository: characterRepository)
    }

    func makeGetEpisodesUseCase() -> GetEpisodesProtocol {
        GetEpisodes(repository: episodeRepository)
    }

    func makeToggleEpisodeWatchedUseCase() -> ToggleEpisodeWatchedProtocol {
        ToggleEpisodeWatched(repository: episodeRepository)
    }

    func makeGetCachedCharactersUseCase() -> GetCachedCharactersProtocol {
        GetCachedCharacters(repository: characterRepository)
    }

    // viewModels
    func makeCharacterListViewModel() -> CharacterListViewModel {
        CharacterListViewModel(
            getCharactersUseCase: makeGetCharactersUseCase(),
            getCachedCharactersUseCase: makeGetCachedCharactersUseCase()
        )
    }

    func makeCharacterDetailViewModel(character: Character) -> CharacterDetailViewModel {
        CharacterDetailViewModel(
            character: character,
            getEpisodesUseCase: makeGetEpisodesUseCase(),
            toggleFavoriteUseCase: makeToggleFavoriteUseCase(),
            toggleEpisodeWatchedUseCase: makeToggleEpisodeWatchedUseCase()
        )
    }
}
