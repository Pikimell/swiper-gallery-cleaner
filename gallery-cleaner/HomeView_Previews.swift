//
//  HomeView_Previews.swift
//  gallery-cleaner
//
//  Created by Володимир Пащенко on 30.06.2025.
//

import SwiftUI

struct HomeView_Previews: PreviewProvider {
    @State static var selectedTab = 0

    static var previews: some View {
        HomeView(selectedTab: $selectedTab)
            .environmentObject(PhotoLibraryViewModel())
            .environmentObject(TrashManager())
    }
}
