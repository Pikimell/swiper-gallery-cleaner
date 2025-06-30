import SwiftUI

struct AppTheme {
    let background: Color
    let card: Color
    let textPrimary: Color
    let textSecondary: Color
    let accent: Color
    let swipeDelete: Color
    let restore: Color
    let trash: Color
    let border: Color
}

extension AppTheme {
    static let light = AppTheme(
        background: Color(hex: "#F5F7FA"),
        card: Color.white,
        textPrimary: Color(hex: "#1F2937"),
        textSecondary: Color(hex: "#6B7280"),
        accent: Color(hex: "#3B82F6"),
        swipeDelete: Color(hex: "#F87171"),
        restore: Color(hex: "#34D399"),
        trash: Color(hex: "#DC2626"),
        border: Color(hex: "#E5E7EB")
    )

    static let dark = AppTheme(
        background: Color(hex: "#1C1C1E"),
        card: Color(hex: "#2C2C2E"),
        textPrimary: Color(hex: "#F5F5F7"),
        textSecondary: Color(hex: "#A1A1AA"),
        accent: Color(hex: "#60A5FA"),
        swipeDelete: Color(hex: "#F87171"),
        restore: Color(hex: "#6EE7B7"),
        trash: Color(hex: "#EF4444"),
        border: Color(hex: "#3A3A3C")
    )
}

// MARK: - EnvironmentKey

private struct ThemeKey: EnvironmentKey {
    static let defaultValue: AppTheme = .light
}

extension EnvironmentValues {
    var theme: AppTheme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

// MARK: - ViewModifier

struct ThemeProvider: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        let theme = colorScheme == .dark ? AppTheme.dark : AppTheme.light
        return content.environment(\.theme, theme)
    }
}

extension View {
    func applyTheme() -> some View {
        self.modifier(ThemeProvider())
    }
}