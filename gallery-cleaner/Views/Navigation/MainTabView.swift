//
//  MainTabView.swift
//  gallery-cleaner
//
//  Created by Володимир Пащенко on 01.07.2025.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    @EnvironmentObject var viewModel: PhotoLibraryViewModel
    @EnvironmentObject var trashManager: TrashManager
    @Environment(\.theme) private var theme
    @ObservedObject var localization = LocalizationManager.shared

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Label("home_title".localized, systemImage: "house")
                }
                .tag(0)

            GalleryView(selectedTab: $selectedTab)
                .tabItem {
                    Label("gallery_title".localized, systemImage: "photo.on.rectangle")
                }
                .tag(1)

            DuplicateScanView(selectedTab: $selectedTab)
                .tabItem {
                    Label("duplicates_title".localized, systemImage: "rectangle.stack.badge.minus")
                }
                .tag(2)
            
            TrashView()
                .tabItem {
                    Label("trash_title".localized, systemImage: "trash")
                }
                .tag(3)

            

            SettingsView()
                .tabItem {
                    Label("settings_title".localized, systemImage: "gearshape")
                }
                .tag(4)
        }
        .applyTheme()
    }
}
