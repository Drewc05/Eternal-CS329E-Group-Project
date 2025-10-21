//
//  TabController.swift
//  Eternal-CS329E-Group-Project
//
//  Created by Colin Day on 10/20/25.
//

import SwiftUI

class TabController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.SetUpTabs()
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(_colorLiteralRed: 0.843, green: 0.137, blue: 0.008, alpha: 1)
        
        appearance.stackedLayoutAppearance.normal.iconColor = .systemGray5
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGray5]
                    
        // Set the appearance for all states
        self.tabBar.standardAppearance = appearance
        self.tabBar.scrollEdgeAppearance = appearance
        self.tabBar.tintColor = .white
        
        self.tabBar.isTranslucent = true
        self.tabBar.layer.masksToBounds = true
        self.tabBar.layer.cornerRadius = 50
        self.tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

    }
    
    //https://www.youtube.com/watch?v=AoQb6Dy6l04
    
    private func SetUpTabs() -> Void {
        let dashboard = self.CreateNav(with: "Dashboard", and: UIImage(systemName: "house"), vc: Dashboard())
        let calendar = self.CreateNav(with: "Calendar", and: UIImage(systemName: "calendar"), vc: CalendarPage())
        let shop = self.CreateNav(with: "Shop", and: UIImage(systemName: "bag"), vc: Shop())
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
