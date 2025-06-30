//
//  gallery_cleanerApp.swift
//  gallery-cleaner
//
//  Created by Володимир Пащенко on 30.06.2025.
//

import SwiftUI

@main
struct gallery_cleanerApp: App {
    @StateObject private var trashManager = TrashManager()

    var body: some Scene {
        WindowGroup {
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }

                GalleryView()
                    .tabItem {
                        Label("Gallery", systemImage: "photo.on.rectangle")
                    }

                TrashView()
                    .tabItem {
                        Label("Trash", systemImage: "trash")
                    }
            }
            .environmentObject(trashManager)
        }
    }
}
