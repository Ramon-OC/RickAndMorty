//
//  PulseRingView.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 02/12/25.
//

import SwiftUI

struct PulseRingView: View {
    var tint: Color
    var size: CGFloat

    @State private var animate: [Bool] = [false, false, false]
    @State private var showView: Bool = false
    @Environment(\.scenePhase) private var scenePhase
    var body: some View {
        ZStack {
            if showView { // the ring is based on three circles
                ZStack {
                    RingView(index: 0)
                    RingView(index: 1)
                    RingView(index: 2)
                }
            }
        }
        .onChange(of: scenePhase, initial: true) { _, newValue in
            showView = newValue != .background
            if showView {
                startAnimation()
            } else {
                resetAnimation()
            }
        }
        .onAppear {
            showView = true
            startAnimation()
        }
        .onDisappear {
            showView = false
            resetAnimation()
        }
        .frame(width: size, height: size)
    }

    private func startAnimation() {
        for index in 0 ..< animate.count {
            let delay = Double(index) * 0.2
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: false).delay(delay)) {
                animate[index] = true
            }
        }
    }

    private func resetAnimation() {
        animate = [false, false, false]
    }

    @ViewBuilder
    private func RingView(index: Int) -> some View {
        Circle()
            .fill(tint)
            .opacity(animate[index] ? 0 : 0.4)
            .scaleEffect(animate[index] ? 2 : 0)
    }
}

#Preview {
    PulseRingView(tint: .primary, size: 100)
}
