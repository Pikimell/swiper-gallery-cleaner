//
//  StorageCleanupStatsSection.swift
//  gallery-cleaner
//
//  Created by Володимир Пащенко on 09.07.2025.
//

import SwiftUI

struct StorageCleanupStatsSection: View {
    @Environment(\.theme) private var theme

    private var totalDeletedSize: String {
        TrashManager.getTotalDeletedSizeFormatted()
    }

    private var totalDeletedCount: Int {
        TrashManager.getTotalDeletedCount()
    }

    var body: some View {
        Section(header: Text("settings_cleanup_stats_header".localized)) {
            HStack {
                Label("settings_cleanup_total_size".localized, systemImage: "externaldrive.badge.minus")
                Spacer()
                Text(totalDeletedSize)
                    .foregroundColor(theme.textSecondary)
            }

            HStack {
                Label("settings_cleanup_total_count".localized, systemImage: "photo.on.rectangle.angled")
                Spacer()
                Text("\(totalDeletedCount)")
                    .foregroundColor(theme.textSecondary)
            }

            Button(role: .destructive) {
                TrashManager.resetStats()
            } label: {
                Label("settings_cleanup_reset_stats".localized, systemImage: "arrow.counterclockwise")
            }
        }
    }
}
