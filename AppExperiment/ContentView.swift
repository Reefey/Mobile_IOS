//
//  ContentView.swift
//  AppExperiment
//
//  Created by Reza Juliandri on 15/08/25.
//

import SwiftUI
import SwiftData

enum NavigationPath: String {
    case lockedCamera = "locked-camera"
}

struct ContentView: View {
    @State var navigationPath: [NavigationPath] = []
    @State var cameraShow: Bool = false
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            CollectionsView(path: $navigationPath, cameraShow: $cameraShow)
                .navigationDestination(for: NavigationPath.self){ nav in
                    switch nav {
                    case .lockedCamera:
                        CameraLockView(path: $navigationPath, cameraShow: $cameraShow)
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}
