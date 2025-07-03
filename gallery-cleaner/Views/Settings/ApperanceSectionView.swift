//
//  ApperanceSectionView.swift
//  gallery-cleaner
//
//  Created by Володимир Пащенко on 03.07.2025.
//

import SwiftUI

struct ApperanceSectionView: View {
    @Binding var selectedTheme: AppThemeMode
    var body: some View {
        Section(header: Text("settings_appearance".localized)) {
                    Picker("settings_theme".localized, selection: $selectedTheme) {
                        ForEach(AppThemeMode.allCases) { mode in
                            Text(mode.localizedTitle).tag(mode)
                        }
                    }
                }
    }
}
