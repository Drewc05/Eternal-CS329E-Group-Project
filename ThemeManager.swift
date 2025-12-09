// Eternal-CS329E-Group-Project
// Group 15
// Created / Edits done by Ori Parks (lwp369)

import SwiftUI
import Combine

// SwiftUI-friendly theme wrapper
struct SwiftUITheme: Equatable {
    let name: String
    let background: Color
    let foreground: Color
    let accent: Color
    
    init(from uiKitTheme: Theme) {
        self.name = uiKitTheme.name
        self.background = Color(uiKitTheme.background)
        self.foreground = Color(uiKitTheme.text)
        self.accent = Color(uiKitTheme.primary)
    }
}

// Observable ThemeManager class deriving theme from HabitStore.settings.themeKey
final class SwiftUIThemeManager: ObservableObject {
    @Published private(set) var current: SwiftUITheme
    
    private var cancellables = Set<AnyCancellable>()
    private let store: HabitStore
    
    init(store: HabitStore = .shared) {
        self.store = store
        let uiKitTheme = ThemeManager.current(from: store.settings.themeKey)
        self.current = SwiftUITheme(from: uiKitTheme)
        
        store.$settings
            .map { settings -> SwiftUITheme in
                let theme = ThemeManager.current(from: settings.themeKey)
                return SwiftUITheme(from: theme)
            }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] theme in
                self?.current = theme
            }
            .store(in: &cancellables)
    }
}
