//
//  CharacterMapCard.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 02/12/25.
//

import MapKit
import SwiftUI

struct CharacterMapCard: View {
    let coordinate: CLLocationCoordinate2D
    let imageURL: URL

    @State private var showFullMap = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            fixedMap

            Button {
                showFullMap = true
            } label: {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .font(.headline)
                    .padding(10)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .padding(8)
            }
        }
        .sheet(isPresented: $showFullMap) {
            FullInteractiveMap(
                coordinate: coordinate,
                imageURL: imageURL
            )
        }
    }

    private var fixedMap: some View {
        let region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )

        return Map(
            initialPosition: .region(region),
            interactionModes: [] // mapa completamente fijo
        ) {
            Annotation("Última Ubicación", coordinate: coordinate) {
                CharacterPin(imageURL: imageURL)
            }
        }
        .allowsHitTesting(false)
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Full screen map: user can move it, only shows title and pic

struct FullInteractiveMap: View {
    let coordinate: CLLocationCoordinate2D
    let imageURL: URL
    @Environment(\.dismiss) private var dismiss

    @State private var cameraPosition: MapCameraPosition

    init(coordinate: CLLocationCoordinate2D, imageURL: URL) {
        self.coordinate = coordinate
        self.imageURL = imageURL
        _cameraPosition = State(initialValue: .region(
            MKCoordinateRegion(
                center: coordinate,
                span: .init(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        ))
    }

    var body: some View {
        NavigationStack {
            Map(position: $cameraPosition) {
                Annotation("Última Ubicación", coordinate: coordinate) {
                    CharacterPin(imageURL: imageURL)
                }
            }
            .ignoresSafeArea()
            .navigationTitle("Localización")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Character pin with pulse ring

struct CharacterPin: View {
    let imageURL: URL

    var body: some View {
        ZStack {
            PulseRingView(tint: .blue.opacity(0.35), size: 80)

            AsyncImage(url: imageURL) { phase in
                switch phase {
                case let .success(img):
                    img
                        .resizable()
                        .scaledToFill()
                default:
                    ProgressView()
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            .overlay(
                Circle().stroke(.white, lineWidth: 3)
            )
        }
    }
}

#Preview {
    CharacterMapCard(
        coordinate: CLLocationCoordinate2D(latitude: 47.6062, longitude: -122.3321),
        imageURL: URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg")!
    )
}
