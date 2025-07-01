//
//  PolicySectionView.swift
//  gallery-cleaner
//
//  Created by Володимир Пащенко on 01.07.2025.
//

import SwiftUI

struct PolicySectionView: View {
    var body: some View {
        Section(header: Text("settings_policy".localized)) {
            Button("settings_privacy_policy".localized) {
                // Insert privacy policy URL here
            }
            Button("settings_terms_of_service".localized) {
                // Insert terms of service URL here
            }
        }
    }
}

#Preview {
    PolicySectionView()
}
