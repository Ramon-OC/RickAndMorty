//
//  MapView.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import MapKit
import SwiftUI

struct MapView: View {
    @StateObject private var viewModel: MapViewModel

    @State private var cameraPosition: MapCameraPosition
    @State private var selectedCharacterID: Int?
    @State private var expandedCharacter: Character?

    // environment properties
    @Namespace private var animationID
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    init(getCachedCharactersUseCase: GetCachedCharactersProtocol) {
        let vm = MapViewModel(
            getCachedCharactersUseCase: getCachedCharactersUseCase,
            context: CoreDataStack.shared.viewContext
        )

        _viewModel = StateObject(wrappedValue: vm)

        // MARK: SEATTLE camera, implement device location in the future

        _cameraPosition = State(initialValue: .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 47.6062, longitude: -122.3321),
            span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
        )))
    }

    var body: some View {
        NavigationStack {
            Map(position: $cameraPosition) {
                ForEach(viewModel.characters) { character in
                    Annotation(character.name, coordinate: CLLocationCoordinate2D(
                        latitude: character.coordinates.latitude,
                        longitude: character.coordinates.longitude
                    )) {
                        AnnotationView(character)
                    }
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) { // bottom carousel
                GeometryReader {
                    let size = $0.size
                    BottomCarousel(size)
                }
                .frame(height: 220)
            }
            .navigationTitle("Ubicación de Personajes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        expandMapView()
                    } label: {
                        Image(systemName: "arrow.down.left.and.arrow.up.right")
                            .font(.title3)
                            .foregroundStyle(Color.primary)
                    }
                }
            }
        }
        .sheet(item: $expandedCharacter) { character in
            CharacterDetailSheet(character: character)
                .navigationTransition(.zoom(sourceID: character.id, in: animationID))
                .presentationDetents([
                    .height(600), // máxima
                ])
        }
//        .task {
//            if case .idle = viewModel.state {
//                await viewModel.loadCachedData()
//            }
//        }
    }

    // MARK: - Map Expansion

    private func expandMapView() {
        withAnimation(animation) {
            // Reset camera to show all characters or a broader view of Seattle area
            if !viewModel.characters.isEmpty {
                // Calculate bounds to show all characters
                let coordinates = viewModel.characters.map { character in
                    CLLocationCoordinate2D(
                        latitude: character.coordinates.latitude,
                        longitude: character.coordinates.longitude
                    )
                }

                let minLat = coordinates.map(\.latitude).min() ?? 47.6062
                let maxLat = coordinates.map(\.latitude).max() ?? 47.6062
                let minLon = coordinates.map(\.longitude).min() ?? -122.3321
                let maxLon = coordinates.map(\.longitude).max() ?? -122.3321

                let centerLat = (minLat + maxLat) / 2
                let centerLon = (minLon + maxLon) / 2

                let latitudeDelta = max(abs(maxLat - minLat) * 1.5, 0.3) // Add padding and minimum span
                let longitudeDelta = max(abs(maxLon - minLon) * 1.5, 0.3)

                cameraPosition = .region(MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
                    span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
                ))
            } else {
                // Reset to default Seattle view if no characters
                cameraPosition = .region(MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: 47.6062, longitude: -122.3321),
                    span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
                ))
            }

            // Clear selected character to reset any focused view
            selectedCharacterID = nil
        }
    }

    // MARK: - Bottom Carousel

    @ViewBuilder
    func BottomCarousel(_ size: CGSize) -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                ForEach(viewModel.characters) { character in
                    BottomCarouselCardView(character)
                        .padding(.horizontal, 15)
                        .padding(.bottom, 15)
                        .frame(width: size.width, height: size.height)
                        .matchedTransitionSource(id: character.id, in: animationID)
                }
            }
            .scrollTargetLayout()
        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $selectedCharacterID, anchor: .center)
        .onChange(of: selectedCharacterID) { _, newValue in
            guard let character = viewModel.characters.first(where: { $0.id == newValue }) else {
                return
            }

            withAnimation(animation) {
                cameraPosition = .camera(.init(
                    centerCoordinate: CLLocationCoordinate2D(
                        latitude: character.coordinates.latitude,
                        longitude: character.coordinates.longitude
                    ),
                    distance: 5000
                ))
            }
        }
    }

    // MARK: - Bottom Carousel Card

    @ViewBuilder
    func BottomCarouselCardView(_ character: Character?) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let character {
                // Character Header with Image
                HStack(spacing: 12) {
                    AsyncImage(url: character.imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(.gray.opacity(0.3))
                            .overlay {
                                ProgressView()
                            }
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text(character.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .lineLimit(1)

                        HStack(spacing: 4) {
                            Circle()
                                .fill(character.status.characterStatusColor)
                                .frame(width: 8, height: 8)
                            Text(character.status.displayName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Text(character.species)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    Spacer(minLength: 0)
                }

                Divider()

                VStack(alignment: .leading, spacing: 4) {
                    // Ubicación
                    HStack(spacing: 4) {
                        Image(systemName: "map.fill")
                            .font(.caption2)

                        Text("Ubicación:")
                            .font(.caption)
                            .bold() // <- texto del label
                            .foregroundStyle(.primary)

                        Text(character.location.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .lineLimit(1)

                    // Origen
                    HStack(spacing: 4) {
                        Image(systemName: "globe")
                            .font(.caption2)

                        Text("Origen:")
                            .font(.caption)
                            .bold()
                            .foregroundStyle(.primary)

                        Text(character.origin.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .lineLimit(1)
                }

                Spacer(minLength: 0)

                // Learn More Button
                Button {
                    expandedCharacter = character
                } label: {
                    Text("Más Información")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .buttonBorderShape(.capsule)
            }
        }
        .padding(15)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }

    // MARK: - Annotation View

    @ViewBuilder
    func AnnotationView(_ character: Character) -> some View {
        let isSelected = character.id == selectedCharacterID

        AsyncImage(url: character.imageURL) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Image(systemName: "person.circle.fill")
                .resizable()
                .foregroundStyle(.blue)
        }
        .frame(width: isSelected ? 60 : 30, height: isSelected ? 60 : 30)
        .clipShape(Circle())
        .overlay {
            Circle()
                .stroke(character.status.characterStatusColor, lineWidth: isSelected ? 3 : 2)
        }
        .background {
            Circle()
                .fill(.white)
                .padding(-2)
        }
        .animation(animation, value: isSelected)
        /// Pulse ring for selected character
        .background {
            if isSelected {
                PulseRingView(tint: character.status.characterStatusColor, size: 90)
            }
        }
        .contentShape(.rect)
        .onTapGesture {
            withAnimation(animation) {
                selectedCharacterID = character.id
            }
        }
    }

    var animation: Animation {
        .smooth(duration: 0.45, extraBounce: 0)
    }
}

// MARK: - Character Detail Sheet

struct CharacterDetailSheet: View {
    var character: Character

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Character Image
                AsyncImage(url: character.imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(.gray.opacity(0.3))
                        .overlay {
                            ProgressView()
                        }
                }
                .frame(width: 200, height: 200)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(character.status.characterStatusColor, lineWidth: 4)
                }

                // Character Name
                Text(character.name)
                    .font(.title)
                    .fontWeight(.bold)

                // Status Badge
                HStack(spacing: 8) {
                    Circle()
                        .fill(character.status.characterStatusColor)
                        .frame(width: 12, height: 12)
                    Text(character.status.displayName)
                        .font(.headline)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                // .background(character.status.color.opacity(0.2))
                .cornerRadius(20)

                Divider()
                    .padding(.horizontal)

                // Character Info
                VStack(alignment: .leading, spacing: 12) {
                    InfoRow(icon: "lizard.fill", label: "Especie", value: character.species)
                    InfoRow(icon: "figure.child", label: "Género", value: character.gender.rawValue)
                    InfoRow(icon: "map.fill", label: "Ubicación", value: character.location.name)
                    InfoRow(icon: "globe", label: "Origen", value: character.origin.name)
                    InfoRow(icon: "film.fill", label: "Número de Episodios", value: "\(character.episodeIds.count)")
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Info Row Helper

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.body)
                    .fontWeight(.medium)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#Preview {
    MapView(
        getCachedCharactersUseCase: PreviewGetCachedCharactersUseCase()
    )
}

// MARK: - Preview Mock

final class PreviewGetCachedCharactersUseCase: GetCachedCharactersProtocol {
    func execute() async -> [Character] {
        // Return mock characters for preview
        return []
    }
}

// MARK: - Extensions for CharacterStatus

extension CharacterStatus {
    var characterStatusColor: Color {
        switch self {
        case .alive:
            return .green
        case .dead:
            return .red
        case .unknown:
            return .yellow
        }
    }
}
