//
//  LocalizedString+Extension.swift
//  gallery-cleaner
//
//  Created by Володимир Пащенко on 30.06.2025.
//

import Foundation

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }

    func localized(with arguments: CVarArg...) -> String {
        String(format: self.localized, arguments: arguments)
    }
}
