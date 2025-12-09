// Eternal-CS329E-Group-Project
// Group 15
// Created by Colin Day (cdd2774) / Edits done by Ori Parks (lwp369)

import SwiftUI

class TabController: UITabBarController {
    
    private let store = HabitStore.shared
    private var theme: Theme { ThemeManager.current(from: store.settings.themeKey) }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.SetUpTabs()

        applyTheme(theme)
        
        // Listen for theme changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleThemeChange),
            name: NSNotification.Name("ThemeChanged"),
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyTheme(theme)
    }
    
    @objc private func handleThemeChange() {
        applyTheme(theme)
        
        // Force all view controllers to update
        viewControllers?.forEach { navController in
            if let nav = navController as? UINavigationController {
                nav.viewControllers.forEach { vc in
                    vc.view.setNeedsLayout()
                    vc.view.layoutIfNeeded()
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func applyTheme(_ theme: Theme) {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = theme.card

        let layouts = [
            appearance.stackedLayoutAppearance,
            appearance.inlineLayoutAppearance,
            appearance.compactInlineLayoutAppearance
        ]

        for layout in layouts {
            // Unselected
            layout.normal.iconColor = .systemGray
            layout.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGray]
            // Selected
            layout.selected.iconColor = theme.primary
            layout.selected.titleTextAttributes = [.foregroundColor: theme.primary]
        }

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.isTranslucent = false
    }

    
    //https://www.youtube.com/watch?v=AoQb6Dy6l04
    
    private func SetUpTabs() -> Void {
        let dashboard = self.CreateNav(with: "Dashboard", and: UIImage(systemName: "house"), vc: Dashboard())
        let calendar = self.CreateNav(with: "Calendar", and: UIImage(systemName: "calendar"), vc: CalendarPage())
        let shop = self.CreateNav(with: "Shop", and: UIImage(systemName: "bag"), vc: ShopViewController())
        let profile = self.CreateNav(with: "Profile", and: UIImage(systemName: "person.crop.circle"), vc: Profile())
        self.setViewControllers([dashboard, calendar, shop, profile], animated: true)
    }
    
    private func CreateNav(with title: String, and image: UIImage?, vc: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: vc)
        
        nav.tabBarItem.title = title
        nav.tabBarItem.image = image
        
        return nav
    }

}
