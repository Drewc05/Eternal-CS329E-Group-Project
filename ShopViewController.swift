// Eternal-CS329E-Group-Project
// Group 15
// Created / Edits done by Ori Parks (lwp369)

// Displays the in-app Shop as a grid of items. Implements compositional layout, safe-area aware scrolling,
// and purchase actions. Comments follow the project's single-line comment standard.

import SwiftUI
import UIKit

// ShopViewController
final class ShopViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    // Properties
    private let store = HabitStore.shared
    private var theme: Theme { ThemeManager.current(from: store.settings.themeKey) }

    private var collectionView: UICollectionView!

    private struct ItemModel {
        let title: String
        let price: Int
        let imageName: String
        let tintColor: UIColor?
        let description: String
        let benefit: String
        let action: () -> Void
    }

    private var items: [ItemModel] = []

    // Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Apply background from current theme
        view.backgroundColor = theme.background
        title = "Shop"
        ThemeManager.styleNavBar(navigationController?.navigationBar, theme: theme)
        
        let titleLabel = UILabel()
        titleLabel.text = "Shop"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 34)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label
        navigationItem.titleView = titleLabel

        // Build a compositional layout for a two-column grid
        let layout = createLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        // Ensure vertical scrolling and bottom inset so last rows aren't obscured by the tab bar
        collectionView.alwaysBounceVertical = true
        collectionView.isScrollEnabled = true
        collectionView.contentInset.bottom = 24
        collectionView.verticalScrollIndicatorInsets.bottom = 24
        collectionView.register(ShopItemCell.self, forCellWithReuseIdentifier: ShopItemCell.reuseID)
        collectionView.register(ShopHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ShopHeaderView.reuseID)

        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        configureItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }

    // Layout
    private func createLayout() -> UICollectionViewCompositionalLayout {
        // Use absolute heights to ensure proper scrolling
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(170))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6)

        // Create horizontal group with 2 items
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(170))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 100, trailing: 12)

        // Header shows balance and wager button - compact
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        header.pinToVisibleBounds = false
        section.boundarySupplementaryItems = [header]

        let layout = UICollectionViewCompositionalLayout(section: section)
        layout.configuration.scrollDirection = .vertical
        return layout
    }

    // Data
    // Populate the shop with diverse, creative items - each with unique benefits!
    private func configureItems() {
        items = [
            // Themes
            ItemModel(
                title: "Theme: Ember",
                price: 200,
                imageName: "paintpalette.fill",
                tintColor: UIColor(red: 0.9, green: 0.25, blue: 0.0, alpha: 1),
                description: "Transform your app with the warm Ember theme",
                benefit: "Changes app colors to warm orange tones. Makes your habit tracking feel even more fiery! 🎨",
                action: { [weak self] in
                    self?.store.setThemeKey("ember")
                    self?.view.backgroundColor = self?.theme.background
                    self?.collectionView.reloadData()
                }
            ),
            
            // Power-ups
            ItemModel(
                title: "Streak Freeze",
                price: 150,
                imageName: "snowflake",
                tintColor: .systemCyan,
                description: "Protect your hard-earned streak!",
                benefit: "Get ONE free pass if you miss a day. Your streak won't break! Perfect for busy days or emergencies. ❄️",
                action: { [weak self] in self?.store.addStreakFreeze() }
            ),
            ItemModel(
                title: "2x Multiplier (24h)",
                price: 300,
                imageName: "bolt.fill",
                tintColor: .systemOrange,
                description: "Supercharge your coin earnings!",
                benefit: "Double all coin rewards for 24 hours! Complete habits to earn twice the coins. Stack those rewards! ⚡",
                action: { [weak self] in self?.store.activateMultiplier(hours: 24) }
            ),
            ItemModel(
                title: "Shield Protection",
                price: 250,
                imageName: "shield.fill",
                tintColor: .systemGreen,
                description: "Ultimate streak defender",
                benefit: "Protects your streak for 3 days! Miss up to 3 days without breaking your streak. Peace of mind guaranteed. 🛡️",
                action: { }
            ),
            ItemModel(
                title: "Time Warp",
                price: 400,
                imageName: "clock.arrow.circlepath",
                tintColor: .systemPurple,
                description: "Travel back in time!",
                benefit: "Go back and check-in for ONE missed day from the past week. Fix that one day you forgot! ⏰",
                action: { }
            ),
            
            // Flame Styles
            ItemModel(
                title: "Classic Flame",
                price: 50,
                imageName: "flame.fill",
                tintColor: UIColor(red: 0.843, green: 0.137, blue: 0.008, alpha: 1),
                description: "The original eternal flame",
                benefit: "Traditional red-orange flame. Classic, powerful, and timeless. Where it all began! 🔥",
                action: { }
            ),
            ItemModel(
                title: "Blue Flame",
                price: 75,
                imageName: "flame.fill",
                tintColor: .systemBlue,
                description: "Cool and collected",
                benefit: "Blue flames burn the hottest! Show your cool determination with this rare flame color. 💙",
                action: { }
            ),
            ItemModel(
                title: "Green Flame",
                price: 75,
                imageName: "flame.fill",
                tintColor: .systemGreen,
                description: "Natural energy",
                benefit: "Harness the power of nature! Green represents growth, renewal, and fresh starts. 💚",
                action: { }
            ),
            ItemModel(
                title: "Purple Flame",
                price: 90,
                imageName: "flame.fill",
                tintColor: .systemPurple,
                description: "Mystical power",
                benefit: "Purple flame of wisdom and mystery. For those who walk the path less traveled. 💜",
                action: { }
            ),
            ItemModel(
                title: "Gold Flame",
                price: 150,
                imageName: "flame.fill",
                tintColor: .systemYellow,
                description: "Premium luxury",
                benefit: "The ultimate status symbol! Gold flames represent achievement, success, and excellence. ✨",
                action: { }
            ),
            
            // Special Icons
            ItemModel(
                title: "Star Power",
                price: 100,
                imageName: "star.fill",
                tintColor: .systemYellow,
                description: "Shine bright like a star!",
                benefit: "Replace your flame with a shining star. Stand out from the crowd with celestial energy! ⭐",
                action: { }
            ),
            ItemModel(
                title: "Lightning Bolt",
                price: 120,
                imageName: "bolt.fill",
                tintColor: .systemYellow,
                description: "Electric energy",
                benefit: "High voltage motivation! Lightning bolt icon shows your electrifying dedication. ⚡",
                action: { }
            ),
            ItemModel(
                title: "Heart Icon",
                price: 85,
                imageName: "heart.fill",
                tintColor: .systemPink,
                description: "Lead with love",
                benefit: "Build habits with love! Heart icon perfect for wellness and self-care focused goals. ❤️",
                action: { }
            ),
            ItemModel(
                title: "Trophy",
                price: 200,
                imageName: "trophy.fill",
                tintColor: .systemYellow,
                description: "Champion status",
                benefit: "You're a winner! Display the trophy to show you're serious about crushing your goals. 🏆",
                action: { }
            ),
            ItemModel(
                title: "Crown",
                price: 250,
                imageName: "crown.fill",
                tintColor: .systemYellow,
                description: "Rule your habits",
                benefit: "Become the king/queen of habits! Crown icon shows ultimate mastery and dominance. 👑",
                action: { }
            ),
            
            // Nature Pack
            ItemModel(
                title: "Leaf Icon",
                price: 60,
                imageName: "leaf.fill",
                tintColor: .systemGreen,
                description: "Nature's way",
                benefit: "Organic growth mindset. Leaf icon perfect for environmental and wellness habits. 🍃",
                action: { }
            ),
            ItemModel(
                title: "Moon Icon",
                price: 80,
                imageName: "moon.stars.fill",
                tintColor: .systemIndigo,
                description: "Nighttime routines",
                benefit: "Master your evening habits! Moon and stars icon ideal for sleep and night routines. 🌙",
                action: { }
            ),
            ItemModel(
                title: "Sun Icon",
                price: 70,
                imageName: "sun.max.fill",
                tintColor: .systemOrange,
                description: "Morning motivation",
                benefit: "Rise and shine! Sun icon perfect for morning routines and daytime habits. ☀️",
                action: { }
            ),
            ItemModel(
                title: "Cloud Icon",
                price: 55,
                imageName: "cloud.fill",
                tintColor: .systemBlue,
                description: "Peaceful progress",
                benefit: "Float above the stress! Cloud icon for mindfulness and meditation habits. ☁️",
                action: { }
            ),
            
            // Premium Pack
            ItemModel(
                title: "Diamond",
                price: 500,
                imageName: "diamond.fill",
                tintColor: .systemCyan,
                description: "Rare and precious",
                benefit: "Ultimate luxury icon! Diamond represents unbreakable commitment and rare dedication. 💎",
                action: { }
            ),
            ItemModel(
                title: "Infinity",
                price: 999,
                imageName: "infinity",
                tintColor: .systemPurple,
                description: "Eternal commitment",
                benefit: "The final unlock! Infinity symbol represents unlimited potential and eternal dedication. ∞",
                action: { }
            )
        ]
    }

    // UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShopItemCell.reuseID, for: indexPath) as! ShopItemCell
        let model = items[indexPath.item]
        cell.configure(title: model.title, price: model.price, imageName: model.imageName, theme: theme, tintColor: model.tintColor)
        return cell
    }

    // UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = items[indexPath.item]
        let currentBalance = store.wallet.balance
        
        // Check if user has enough coins
        if currentBalance < model.price {
            // Show "not enough coins" alert
            let alert = UIAlertController(
                title: "Insufficient Coins 💰",
                message: "You need \(model.price) 🔥 coins but only have \(currentBalance) 🔥.\n\nKeep building your habits to earn more coins!",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Show purchase confirmation with item details
        let alert = UIAlertController(
            title: model.title,
            message: "\(model.description)\n\n💡 BENEFIT:\n\(model.benefit)\n\n💰 Price: \(model.price) 🔥\n💵 Your Balance: \(currentBalance) 🔥",
            preferredStyle: .alert
        )
        
        // Cancel button
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // Confirm purchase button
        alert.addAction(UIAlertAction(title: "Confirm Purchase", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            // Attempt purchase
            if self.store.spendCoins(model.price) {
                // Execute item action
                model.action()
                
                // Show success with haptic
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                
                // Reload to update balance
                self.collectionView.reloadData()
                
                // Show success message
                self.showSuccessToast("Purchased: \(model.title) ✨")
            } else {
                // This shouldn't happen since we checked, but just in case
                self.showToast("Purchase failed")
            }
        })
        
        present(alert, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ShopHeaderView.reuseID, for: indexPath) as! ShopHeaderView
        header.configure(balance: store.wallet.balance, imageName: "flame.fill", theme: theme, tintColor: UIColor(red: 0.843, green: 0.137, blue: 0.008, alpha: 1))
        header.onWagerTapped = { [weak self] in
            self?.presentWager()
        }
        return header
    }

    // Actions
    // Wager flow now presents a dedicated view controller
    private func presentWager() {
        let wagerVC = WagerViewController()
        let nav = UINavigationController(rootViewController: wagerVC)
        present(nav, animated: true)
    }

    // UI Helpers
    // Success toast with celebration
    private func showSuccessToast(_ message: String) {
        let toast = UIView()
        toast.backgroundColor = UIColor(red: 0.2, green: 0.8, blue: 0.3, alpha: 0.95)
        toast.layer.cornerRadius = 16
        toast.layer.masksToBounds = true
        
        let label = UILabel()
        label.text = message
        label.font = .rounded(ofSize: 16, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        
        toast.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(toast)
        toast.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: toast.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: toast.trailingAnchor, constant: -20),
            label.topAnchor.constraint(equalTo: toast.topAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: toast.bottomAnchor, constant: -16),
            
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            toast.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 40),
            toast.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -40)
        ])

        toast.alpha = 0
        toast.transform = CGAffineTransform(translationX: 0, y: 20)
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            toast.alpha = 1
            toast.transform = .identity
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 1.5, options: [], animations: {
                toast.alpha = 0
                toast.transform = CGAffineTransform(translationX: 0, y: 20)
            }) { _ in
                toast.removeFromSuperview()
            }
        }
    }
    
    // Lightweight toast for transient feedback
    private func showToast(_ message: String) {
        let toast = UILabel()
        toast.text = message
        toast.font = .boldSystemFont(ofSize: 16)
        toast.textColor = .white
        toast.textAlignment = .center
        toast.backgroundColor = theme.primary
        toast.layer.cornerRadius = 12
        toast.layer.masksToBounds = true

        view.addSubview(toast)
        toast.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            toast.widthAnchor.constraint(greaterThanOrEqualToConstant: 180),
            toast.heightAnchor.constraint(equalToConstant: 44)
        ])

        toast.alpha = 0
        UIView.animate(withDuration: 0.2, animations: {
            toast.alpha = 1
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                UIView.animate(withDuration: 0.25, animations: {
                    toast.alpha = 0
                }) { _ in
                    toast.removeFromSuperview()
                }
            }
        }
    }
}

