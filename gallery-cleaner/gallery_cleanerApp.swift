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
    @StateObject private var viewModel = PhotoLibraryViewModel()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                   .environmentObject(viewModel)
                   .environmentObject(trashManager)
                   .applyTheme()
        }
    }
}
