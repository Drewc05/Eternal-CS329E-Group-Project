// Eternal-CS329E-Group-Project
// Group 15
// Created / Edits done by Ori Parks (lwp369)

//Testing

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var themeManager: SwiftUIThemeManager

    var body: some View {
        VStack {
            Text("Test")
        }
        .background(themeManager.current.background)
        .foregroundStyle(themeManager.current.foreground)
    }
}
