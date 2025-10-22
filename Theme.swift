// Eternal-CS329E-Group-Project
// Group 15
// Created / Edits done by Ori Parks (lwp369)

import UIKit

struct Theme {
    let name: String
    let background: UIColor
    let card: UIColor
    let primary: UIColor
    let text: UIColor
    let secondaryText: UIColor

    static let `default` = Theme(
        name: "default",
        background: UIColor { trait in trait.userInterfaceStyle == .dark ? UIColor.black : UIColor(red: 0.953, green: 0.918, blue: 0.859, alpha: 1) },
        card: UIColor { trait in trait.userInterfaceStyle == .dark ? UIColor(white: 0.12, alpha: 1) : UIColor(white: 1.0, alpha: 0.95) },
        primary: UIColor { _ in UIColor(red: 0.843, green: 0.137, blue: 0.008, alpha: 1) },
        text: UIColor { trait in trait.userInterfaceStyle == .dark ? .white : .label },
        secondaryText: UIColor { trait in trait.userInterfaceStyle == .dark ? .lightGray : .secondaryLabel }
    )

    static let ember = Theme(
        name: "ember",
        background: UIColor { trait in trait.userInterfaceStyle == .dark ? UIColor.black : UIColor(red: 0.97, green: 0.93, blue: 0.88, alpha: 1) },
        card: UIColor { trait in trait.userInterfaceStyle == .dark ? UIColor(white: 0.12, alpha: 1) : UIColor(white: 1.0, alpha: 0.96) },
        primary: UIColor { _ in UIColor(red: 0.9, green: 0.25, blue: 0.0, alpha: 1) },
        text: UIColor { trait in trait.userInterfaceStyle == .dark ? .white : .label },
        secondaryText: UIColor { trait in trait.userInterfaceStyle == .dark ? .lightGray : .secondaryLabel }
    )

    static let dark = Theme(
        name: "dark",
        background: UIColor.black,
        card: UIColor(white: 0.12, alpha: 1),
        primary: UIColor(red: 0.95, green: 0.35, blue: 0.2, alpha: 1),
        text: .white,
        secondaryText: .lightGray
    )
}

enum ThemeManager {
    static func current(from key: String) -> Theme {
        switch key.lowercased() {
        case "ember": return .ember
        case "dark": return .dark
        default: return .default
        }
    }

    static func styleNavBar(_ navBar: UINavigationBar?, theme: Theme) {
        navBar?.tintColor = theme.primary
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = theme.background
        appearance.titleTextAttributes = [.foregroundColor: theme.text]
        appearance.largeTitleTextAttributes = [.foregroundColor: theme.text]
        navBar?.standardAppearance = appearance
        navBar?.scrollEdgeAppearance = appearance
    }
}
