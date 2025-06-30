//
//  MainTabView.swift
//  gallery-cleaner
//
//  Created by Володимир Пащенко on 01.07.2025.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var viewModel: PhotoLibraryViewModel
    @EnvironmentObject var trashManager: TrashManager
    @Environment(\.theme) private var theme

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("home_title".localized, systemImage: "house")
                }

            GalleryView()
                .tabItem {
                    Label("gallery_title".localized, systemImage: "photo.on.rectangle")
                }

            TrashView()
                .tabItem {
                    Label("trash_title".localized, systemImage: "trash")
                }
            
            SettingsView()
                .tabItem {
                    Label("settings_title".localized, systemImage: "gearshape")
                }
        }
        .applyTheme()
    }
}
