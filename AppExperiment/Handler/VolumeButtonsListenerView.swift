//
//  VolumeButtonsListenerView.swift
//  AppExperiment
//
//  Created by Reza Juliandri on 22/08/25.
//


import SwiftUI
import UIKit

/// A tiny SwiftUI bridge that sets up VolumeButtonHandler on a backing UIView.
struct VolumeButtonsListenerView: UIViewRepresentable {
    @Binding var lastButtonLabel: String
    @Binding var isEnabled: Bool
    @Binding var upCount: Int
    @Binding var downCount: Int

    func makeCoordinator() -> Coordinator {
        Coordinator(lastButtonLabel: $lastButtonLabel, upCount: $upCount, downCount: $downCount)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        context.coordinator.attach(to: view)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.setEnabled(isEnabled)
    }

    class Coordinator {
        private var handler: VolumeButtonHandler?
        private weak var container: UIView?
        var lastButtonLabel: Binding<String>
        var upCount: Binding<Int>
        var downCount: Binding<Int>

        init(lastButtonLabel: Binding<String>, upCount: Binding<Int>, downCount: Binding<Int>) {
            self.lastButtonLabel = lastButtonLabel
            self.upCount = upCount
            self.downCount = downCount
        }

        func attach(to container: UIView) {
            self.container = container
        }

        func setEnabled(_ enabled: Bool) {
            if enabled {
                startIfNeeded()
            } else {
                handler?.stop()
            }
        }

        private func startIfNeeded() {
            guard handler == nil, let container else { return }
            let handler = VolumeButtonHandler(containerView: container)
            handler.buttonClosure = { [weak self] button in
                // Light haptic feedback for better demo visibility
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                DispatchQueue.main.async {
                    switch button {
                    case .up:
                        self?.lastButtonLabel.wrappedValue = "Up"
                        self?.upCount.wrappedValue += 1
                    case .down:
                        self?.lastButtonLabel.wrappedValue = "Down"
                        self?.downCount.wrappedValue += 1
                    }
                }
            }
            handler.start()
            self.handler = handler
        }

        deinit {
            handler?.stop()
        }
    }
}
