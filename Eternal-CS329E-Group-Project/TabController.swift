// Eternal-CS329E-Group-Project
// Group 15
// Created / Edits done by Ori Parks (lwp369)

import SwiftUI

class TabController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.SetUpTabs()

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        let brandRed = UIColor(red: 0.843, green: 0.137, blue: 0.008, alpha: 1)
        appearance.backgroundColor = brandRed

        // Unselected state
        appearance.stackedLayoutAppearance.normal.iconColor = .systemGray5
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGray5]

        // Selected state
        appearance.stackedLayoutAppearance.selected.iconColor = .white
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]

        // Apply to all appearances
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = .white
        tabBar.unselectedItemTintColor = .systemGray5

        tabBar.isTranslucent = false
        tabBar.layer.masksToBounds = false
        tabBar.layer.cornerRadius = 0
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
