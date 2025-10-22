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

    // Layout
    private func createLayout() -> UICollectionViewCompositionalLayout {
        // Use fixed heights to avoid underestimation that can disable scrolling
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(160))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        // Two items per row with spacing
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(180))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)
        group.interItemSpacing = .fixed(12)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        // Section insets for breathing room around content
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 24, trailing: 16)
        section.contentInsetsReference = .automatic

        // Header shows balance and wager button
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(120))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [header]

        // Respect safe area for proper content sizing and scrolling
        let layout = UICollectionViewCompositionalLayout(section: section)
        layout.configuration.contentInsetsReference = .safeArea
        return layout
    }

    // Data
    // Populate the shop with flame variants; tint colors match labels
    private func configureItems() {
        items = [
            ItemModel(title: "Theme: Ember", price: 200, imageName: "flame.fill", tintColor: UIColor(red: 0.843, green: 0.137, blue: 0.008, alpha: 1)) { [weak self] in
                self?.store.setThemeKey("ember")
                self?.view.backgroundColor = self?.theme.background
                self?.collectionView.reloadData()
            },
            ItemModel(title: "Streak Freeze", price: 150, imageName: "flame.fill", tintColor: .systemTeal) { [weak self] in
                self?.store.addStreakFreeze()
            },
            ItemModel(title: "Multiplier x1.5 (24h)", price: 300, imageName: "flame.fill", tintColor: .systemOrange) { [weak self] in
                self?.store.activateMultiplier(hours: 24)
            },
            ItemModel(title: "Flame: Classic", price: 50, imageName: "flame.fill", tintColor: UIColor(red: 0.843, green: 0.137, blue: 0.008, alpha: 1)) { },
            ItemModel(title: "Flame: Blue", price: 60, imageName: "flame.fill", tintColor: .systemBlue) { },
            ItemModel(title: "Flame: Green", price: 60, imageName: "flame.fill", tintColor: .systemGreen) { },
            ItemModel(title: "Flame: Purple", price: 70, imageName: "flame.fill", tintColor: .systemPurple) { },
            ItemModel(title: "Flame: Gold", price: 80, imageName: "flame.fill", tintColor: .systemYellow) { },
            ItemModel(title: "Flame: Cyan", price: 60, imageName: "flame.fill", tintColor: .cyan) { },
            ItemModel(title: "Flame: Magenta", price: 70, imageName: "flame.fill", tintColor: UIColor.systemPink) { },
            ItemModel(title: "Flame: Teal", price: 65, imageName: "flame.fill", tintColor: .systemTeal) { },
            ItemModel(title: "Flame: Rose", price: 65, imageName: "flame.fill", tintColor: UIColor(red: 1.0, green: 0.4, blue: 0.6, alpha: 1)) { },
            ItemModel(title: "Flame: Lime", price: 55, imageName: "flame.fill", tintColor: UIColor(red: 0.75, green: 0.95, blue: 0.3, alpha: 1)) { },
            ItemModel(title: "Flame: Indigo", price: 70, imageName: "flame.fill", tintColor: .systemIndigo) { },
            ItemModel(title: "Flame: Silver", price: 75, imageName: "flame.fill", tintColor: UIColor(white: 0.85, alpha: 1)) { },
            ItemModel(title: "Flame: Obsidian", price: 85, imageName: "flame.fill", tintColor: UIColor(white: 0.2, alpha: 1)) { },
            ItemModel(title: "Flame: Ember XL", price: 120, imageName: "flame.fill", tintColor: UIColor(red: 0.9, green: 0.25, blue: 0.0, alpha: 1)) { },
            ItemModel(title: "Flame: Ember XXL", price: 160, imageName: "flame.fill", tintColor: UIColor(red: 0.95, green: 0.3, blue: 0.05, alpha: 1)) { },
            ItemModel(title: "Flame: Ember XXXL", price: 220, imageName: "flame.fill", tintColor: UIColor(red: 1.0, green: 0.35, blue: 0.1, alpha: 1)) { }
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
        if store.spendCoins(model.price) {
            model.action()
            collectionView.reloadData()
            showToast("Purchased: \(model.title)")
        } else {
            showToast("Not enough coins")
        }
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
    // Simple placeholder wager flow; add validation as needed
    private func presentWager() {
        let alert = UIAlertController(title: "Wager", message: "Place a wager (placeholder)", preferredStyle: .alert)
        alert.addTextField { tf in tf.placeholder = "Amount"; tf.keyboardType = .numberPad }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { [weak self] _ in
            guard let text = alert.textFields?.first?.text, let amount = Int(text), amount > 0 else { return }
            if self?.store.spendCoins(amount) == true {
                self?.showToast("Wager placed: $\(amount)")
            } else {
                self?.showToast("Not enough coins")
            }
        }))
        present(alert, animated: true)
    }

    // UI Helpers
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

