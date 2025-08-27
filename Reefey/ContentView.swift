//
//  ContentView.swift
//  Reefey
//
//  Created by Reza Juliandri on 15/08/25.
//

import SwiftUI
import SwiftData

enum NavigationPath: Hashable {
    case lockedCamera
    case collectionDetail(MarineSpecies)
}

struct ContentView: View {
    @State var navigationPath: [NavigationPath] = []
    @State var cameraShow: Bool = false
    
    var body: some View {
        // TabView {
            // Collections Tab
            NavigationStack(path: $navigationPath) {
                CollectionsView(path: $navigationPath, cameraShow: $cameraShow)
                    .navigationDestination(for: NavigationPath.self){ nav in
                        switch nav {
                        case .lockedCamera:
                            CameraLockView(path: $navigationPath, cameraShow: $cameraShow)
                        case .collectionDetail(let collection):
                            CollectionDetailView(collection: collection)
                        }
                    }
            }
            // .tabItem {
            //     Image(systemName: "photo.stack")
            //     Text("Collections")
            // }
            
            // // Marine Species Tab
            // MarineListView()
            //     .tabItem {
            //         Image(systemName: "fish")
            //         Text("Marine Species")
            //     }
        // }
    }
}

#Preview {
    ContentView()
}
