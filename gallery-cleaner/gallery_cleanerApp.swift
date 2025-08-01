//
//  gallery_cleanerApp.swift
//  gallery-cleaner
//
//  Created by Володимир Пащенко on 30.06.2025.
//
import GoogleMobileAds
import SwiftUI


@main
struct gallery_cleanerApp: App {
    @StateObject private var trashManager = TrashManager()
    @StateObject private var viewModel = PhotoLibraryViewModel()
    @StateObject private var storeKitManager = StoreKitManager()
    
    init() {
            MobileAds.shared.start { status in
                print("AdMob started: \(status.adapterStatusesByClassName)!")
            }
        }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                   .environmentObject(viewModel)
                   .environmentObject(trashManager)
                   .environmentObject(storeKitManager)
                   .applyTheme()
        }
    }
}
