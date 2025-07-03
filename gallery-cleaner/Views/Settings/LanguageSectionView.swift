//
//  LanguageSectionView.swift
//  gallery-cleaner
//
//  Created by Володимир Пащенко on 03.07.2025.
//

import SwiftUI

struct LanguageSectionView: View {
    @Binding var selectedLanguage: String
    var body: some View {
        Section(header: Text("settings_language".localized)) {
                    Picker("settings_language".localized, selection: $selectedLanguage) {
                        Text("English").tag("en")
                        Text("Українська").tag("uk")
                    }
                }
    }
}

