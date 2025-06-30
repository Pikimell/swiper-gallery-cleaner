//
//  HomeView_Previews.swift
//  gallery-cleaner
//
//  Created by Володимир Пащенко on 30.06.2025.
//

import SwiftUI

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(PhotoLibraryViewModel())
            .environmentObject(TrashManager())
    }
}

#Preview {
    HomeView()
        .environmentObject(PhotoLibraryViewModel())
        .environmentObject(TrashManager())
}
