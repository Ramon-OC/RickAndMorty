//
//  GetCharacterDetailTests.swift
//  RickAndMortyTests
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

@testable import RickAndMorty
import XCTest

final class GetCharacterDetailTests: XCTestCase {
    // properties
    var sut: GetCharacterDetail!
    var mockRepository: MockCharacterRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockCharacterRepository()
        sut = GetCharacterDetail(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Tests

    @MainActor
    func testExecute_WhenCharacterExists_ReturnsCharacter() async throws {
        // Given
        let expectedCharacter = Character.mockRick()
        mockRepository.characterToReturn = expectedCharacter

        // When
        let result = try await sut.execute(id: 1)

        // Then
        XCTAssertEqual(result.id, expectedCharacter.id)
        XCTAssertEqual(result.name, expectedCharacter.name)
        XCTAssertEqual(result.status, expectedCharacter.status)
        XCTAssertEqual(result.species, expectedCharacter.species)
        XCTAssertEqual(mockRepository.getCharacterCalledWithId, 1)
        XCTAssertEqual(mockRepository.getCharacterCallCount, 1)
    }

    @MainActor
    func testExecute_WhenRepositoryThrowsError_ThrowsError() async {
        // Given
        let expectedError = CharacterRepositoryError.notFound
        mockRepository.errorToThrow = expectedError

        // When/Then
        do {
            _ = try await sut.execute(id: 999)
            XCTFail("ocurre un error")
        } catch {
            XCTAssertEqual(error as? CharacterRepositoryError, expectedError)
            XCTAssertEqual(mockRepository.getCharacterCalledWithId, 999)
        }
    }

    @MainActor
    func testExecute_CallsRepositoryWithCorrectId() async throws {
        // Given
        let characterId = 42
        mockRepository.characterToReturn = Character.mockMorty()

        // When
        _ = try await sut.execute(id: characterId)

        // Then
        XCTAssertEqual(mockRepository.getCharacterCalledWithId, characterId)
    }
}

// MARK: - Mock Repository

final class MockCharacterRepository: CharacterRepository {
    // Tracking properties
    var getCharacterCallCount = 0
    var getCharacterCalledWithId: Int?

    // Return values
    var characterToReturn: Character?
    var errorToThrow: Error?

    func getCharacter(id: Int) async throws -> Character {
        getCharacterCallCount += 1
        getCharacterCalledWithId = id

        if let error = errorToThrow {
            throw error
        }

        guard let character = characterToReturn else {
            throw CharacterRepositoryError.notFound
        }

        return character
    }

    // el protocolo me pide ponerlas, pero no son necesarias
    func getCharacters(page _: Int, filter _: CharacterFilter?) async throws -> CharacterPage {
        fatalError("")
    }

    func getCachedCharacters() async -> [Character] {
        return []
    }

    func getFavoriteCharacters() async -> [Character] {
        return []
    }

    func toggleFavorite(characterId _: Int) async throws {}
}

// MARK: - Character Repository Error

enum CharacterRepositoryError: Error, Equatable {
    case notFound
    case networkError
    case decodingError
}

// MARK: - Mock Character Extension

extension Character {
    static func mockRick() -> Character {
        Character(
            id: 1,
            name: "Rick Sanchez",
            status: .alive,
            species: "Human",
            type: "",
            gender: .male,
            origin: CharacterLocation(name: "Earth", url: ""),
            location: CharacterLocation(name: "Earth", url: ""),
            imageURL: URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg"),
            episodeURLs: [URL(string: "https://rickandmortyapi.com/api/episode/1")!],
            coordinates: CharacterCoordinates(latitude: 47.6062, longitude: -122.3321),
            isFavorite: false
        )
    }

    static func mockMorty() -> Character {
        Character(
            id: 2,
            name: "Morty Smith",
            status: .alive,
            species: "Human",
            type: "",
            gender: .male,
            origin: CharacterLocation(name: "Earth", url: ""),
            location: CharacterLocation(name: "Earth", url: ""),
            imageURL: URL(string: "https://rickandmortyapi.com/api/character/avatar/2.jpeg"),
            episodeURLs: [URL(string: "https://rickandmortyapi.com/api/episode/1")!],
            coordinates: CharacterCoordinates(latitude: 47.6205, longitude: -122.3493),
            isFavorite: false
        )
    }
}
