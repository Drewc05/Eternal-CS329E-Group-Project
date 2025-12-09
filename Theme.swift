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

    static let amber = Theme(
        name: "amber",
        background: UIColor { trait in
            if trait.userInterfaceStyle == .dark {
                return UIColor(red: 0.06, green: 0.06, blue: 0.06, alpha: 1)
            } else {
                return UIColor(red: 0.99, green: 0.96, blue: 0.90, alpha: 1)
            }
        },
        card: UIColor { trait in
            if trait.userInterfaceStyle == .dark {
                return UIColor(red: 0.12, green: 0.10, blue: 0.08, alpha: 1)
            } else {
                return UIColor(red: 1.0, green: 0.985, blue: 0.96, alpha: 0.98)
            }
        },
        primary: UIColor { _ in UIColor(red: 1.0, green: 0.62, blue: 0.0, alpha: 1) },
        text: UIColor { trait in
            if trait.userInterfaceStyle == .dark {
                return UIColor(white: 0.95, alpha: 1)
            } else {
                return UIColor(red: 0.20, green: 0.15, blue: 0.10, alpha: 1)
            }
        },
        secondaryText: UIColor { trait in
            if trait.userInterfaceStyle == .dark {
                return UIColor(white: 0.75, alpha: 1)
            } else {
                return UIColor(red: 0.45, green: 0.37, blue: 0.30, alpha: 1)
            }
        }
    )

    static let dark = Theme(
        name: "dark",
        background: UIColor.black,
        card: UIColor(white: 0.12, alpha: 1),
        primary: UIColor(red: 0.95, green: 0.35, blue: 0.2, alpha: 1),
        text: .white,
        secondaryText: .lightGray
    )
    
    static let night = Theme(
        name: "night",
        background: UIColor(red: 0.08, green: 0.05, blue: 0.15, alpha: 1),
        card: UIColor(red: 0.12, green: 0.09, blue: 0.20, alpha: 1),
        primary: UIColor(red: 0.60, green: 0.40, blue: 0.90, alpha: 1),
        text: UIColor(red: 0.95, green: 0.93, blue: 1.0, alpha: 1),
        secondaryText: UIColor(red: 0.75, green: 0.70, blue: 0.85, alpha: 1)
    )
    
    static let inferno = Theme(
        name: "inferno",
        background: UIColor(red: 0.08, green: 0.02, blue: 0.02, alpha: 1),
        card: UIColor(red: 0.15, green: 0.05, blue: 0.05, alpha: 1),
        primary: UIColor(red: 1.0, green: 0.27, blue: 0.0, alpha: 1),
        text: UIColor(red: 1.0, green: 0.95, blue: 0.90, alpha: 1),
        secondaryText: UIColor(red: 0.95, green: 0.70, blue: 0.60, alpha: 1)
    )
    
    static let forest = Theme(
        name: "forest",
        background: UIColor(red: 0.12, green: 0.18, blue: 0.12, alpha: 1),
        card: UIColor(red: 0.18, green: 0.25, blue: 0.18, alpha: 1),
        primary: UIColor(red: 0.18, green: 0.49, blue: 0.20, alpha: 1),
        text: UIColor(red: 0.95, green: 0.97, blue: 0.95, alpha: 1),
        secondaryText: UIColor(red: 0.70, green: 0.85, blue: 0.70, alpha: 1)
    )
    
    static let sunset = Theme(
        name: "sunset",
        background: UIColor(red: 0.20, green: 0.12, blue: 0.08, alpha: 1),
        card: UIColor(red: 0.28, green: 0.18, blue: 0.12, alpha: 1),
        primary: UIColor(red: 1.0, green: 0.43, blue: 0.0, alpha: 1),
        text: UIColor(red: 1.0, green: 0.95, blue: 0.90, alpha: 1),
        secondaryText: UIColor(red: 0.95, green: 0.75, blue: 0.65, alpha: 1)
    )
}

enum ThemeManager {
    static func current(from key: String) -> Theme {
        switch key.lowercased() {
        case "amber": return .amber
        case "dark": return .dark
        case "night": return .night
        case "inferno": return .inferno
        case "forest": return .forest
        case "sunset": return .sunset
        default: return .default
        }
    }
    
    static var allThemes: [Theme] {
        return [.default, .amber, .dark, .night, .inferno, .forest, .sunset]
    }

    // Centralizes navigation bar styling to fix dark mode header colors across screens.
    static func styleNavBar(_ navBar: UINavigationBar?, theme: Theme) {
        navBar?.tintColor = theme.primary
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = theme.background
        appearance.shadowColor = theme.card.withAlphaComponent(0.3)
        appearance.titleTextAttributes = [
            .foregroundColor: theme.text,
            .font: UIFont.boldSystemFont(ofSize: 17)
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: theme.text,
            .font: UIFont.boldSystemFont(ofSize: 34)
        ]
        navBar?.standardAppearance = appearance
        navBar?.scrollEdgeAppearance = appearance
        navBar?.compactAppearance = appearance
        navBar?.tintColor = theme.primary
    }
}

extension Theme {
    var isAmber: Bool { name.lowercased() == "amber" }
    
    /// Gradient colors used for amber card backgrounds
    var amberGradient: [CGColor] {
        return [
            UIColor(red: 1.00, green: 0.84, blue: 0.60, alpha: 0.35).cgColor,
            UIColor(red: 1.00, green: 0.95, blue: 0.85, alpha: 0.0).cgColor
        ]
    }
    
    /// Theme-wide card gradient to apply on cards for all themes
    var cardGradientColors: [CGColor] {
        switch name.lowercased() {
        case "amber":
            return amberGradient
        case "dark":
            // Subtle lightening for dark cards
            return [
                UIColor.white.withAlphaComponent(0.06).cgColor,
                UIColor.clear.cgColor
            ]
        default:
            // Default theme: gentle highlight using primary tint
            return [
                primary.withAlphaComponent(0.15).cgColor,
                UIColor.white.withAlphaComponent(0.0).cgColor
            ]
        }
    }
    
    /// Warmer, softer shadow color for amber; otherwise a subtle black
    var warmShadowColor: UIColor {
        return isAmber ? primary.withAlphaComponent(0.25) : UIColor.black.withAlphaComponent(0.12)
    }
}
