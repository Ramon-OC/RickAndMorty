//
//  MapViewModel.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import Combine
import CoreData
import MapKit

@MainActor
final class MapViewModel: NSObject, ObservableObject {
    @Published private(set) var characters: [Character] = []
    @Published private(set) var filteredCharacters: [Character] = []
    @Published private(set) var state: ViewState<[Character]> = .idle
    @Published var searchText = ""
    @Published var selectedStatus: CharacterStatus?
    @Published var selectedSpecies: String = ""
    @Published var showFilters = false
    @Published var selectedCharacter: Character?
    @Published var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 47.6062, longitude: -122.3321), // Seattle center
        span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
    )

    private var cancellables = Set<AnyCancellable>()
    private var filterTask: Task<Void, Never>?

    // coredata observation
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<CharacterEntity>?
    private let getCachedCharactersUseCase: GetCachedCharactersProtocol

    // computed
    var displayedCharacters: [Character] { characters }

    init(getCachedCharactersUseCase: GetCachedCharactersProtocol,
         context: NSManagedObjectContext)
    {
        self.getCachedCharactersUseCase = getCachedCharactersUseCase
        self.context = context
        super.init()
        setupFetchedResultsController()
    }

    private func setupFetchedResultsController() {
        let request = NSFetchRequest<CharacterEntity>(entityName: "CharacterEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]

        let frc = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        frc.delegate = self
        fetchedResultsController = frc

        state = .loading
        do {
            try frc.performFetch()
            let entities = frc.fetchedObjects ?? []
            let mapped = entities.map { $0.toDomain() }
            let unique = mapped

            characters = unique
            filteredCharacters = unique
            state = unique.isEmpty ? .empty : .loaded(unique)
        } catch {
            characters = []
            filteredCharacters = []
            state = .error(error.localizedDescription)
        }
    }

    func loadCachedData() async {
        if case .idle = state {
            do {
                try fetchedResultsController?.performFetch()
                let entities = fetchedResultsController?.fetchedObjects ?? []
                let mapped = entities.map { $0.toDomain() }
                let unique = mapped

                characters = unique
                filteredCharacters = unique
                state = unique.isEmpty ? .empty : .loaded(unique)
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }

    func selectCharacter(_ character: Character) {
        selectedCharacter = character
        mapRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: character.coordinates.latitude,
                longitude: character.coordinates.longitude
            ),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }

    func deselectCharacter() {
        selectedCharacter = nil
        mapRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 47.6062, longitude: -122.3321),
            span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
        )
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension MapViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let entities = controller.fetchedObjects as? [CharacterEntity] else { return }
        let mapped = entities.map { $0.toDomain() }
        let unique = mapped

        characters = unique
        filteredCharacters = unique
        state = unique.isEmpty ? .empty : .loaded(unique)
    }
}
