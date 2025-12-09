// Eternal-CS329E-Group-Project
// Group 15
// Created / Edits done by Ori Parks (lwp369)

import SwiftUI
import UIKit

final class ShopViewController: UIViewController {

    private let store = HabitStore.shared
    private var theme: Theme { ThemeManager.current(from: store.settings.themeKey) }

    private let balanceLabel = UILabel()
    private var shopItems: [ShopItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = theme.background
        ThemeManager.styleNavBar(navigationController?.navigationBar, theme: theme)
        title = "Shop"
        
        let titleLabel = UILabel()
        titleLabel.text = "Shop"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 34)
        titleLabel.textAlignment = .center
        titleLabel.textColor = theme.text
        navigationItem.titleView = titleLabel
        
        // Load shop items from the sorted catalog
        shopItems = store.sortedShopCatalog
        
        setupUI()
        updateBalance()
        
        // Listen for shop purchases
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleShopPurchase),
            name: NSNotification.Name("ShopItemPurchased"),
            object: nil
        )
        
        // Listen for theme changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleThemeChanged),
            name: NSNotification.Name("ThemeChanged"),
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateBalance()
        
        // Refresh grid ordering and ownership
        view.subviews.forEach { sub in
            if let scroll = sub as? UIScrollView { scroll.removeFromSuperview() }
        }
        setupUI()
    }
    
    @objc private func handleShopPurchase() {
        // Update balance display
        updateBalance()
        
        // Refresh grid ordering and ownership
        view.subviews.forEach { sub in
            if let scroll = sub as? UIScrollView { scroll.removeFromSuperview() }
        }
        setupUI()
    }
    
    @objc private func handleThemeChanged() {
        // Re-apply theme and rebuild UI safely
        view.backgroundColor = theme.background
        ThemeManager.styleNavBar(navigationController?.navigationBar, theme: theme)
        // Remove all subviews before rebuilding to avoid overlay
        view.subviews.forEach { $0.removeFromSuperview() }
        setupUI()
        updateBalance()
    }
    
    private func setupUI() {
        // Balance display card (compact version)
        let balanceCard = createBalanceCard()
        
        // Wager card (compact version)
        let wagerCard = createWagerCard()
        
        // Create grid of shop items (2 columns)
        let gridStack = createItemGrid()
        
        // Main stack
        let mainStack = UIStackView(arrangedSubviews: [balanceCard, wagerCard, gridStack])
        mainStack.axis = .vertical
        mainStack.spacing = 16
        mainStack.alignment = .fill
        
        let scrollView = UIScrollView()
        scrollView.addSubview(mainStack)
        
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            mainStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            mainStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            mainStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            mainStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }
    
    private func createItemGrid() -> UIView {
        let containerView = UIView()
        
        // Ensure using latest sorted catalog
        shopItems = store.sortedShopCatalog
        
        // Create rows with 2 items each
        var rowStacks: [UIStackView] = []
        
        for i in stride(from: 0, to: shopItems.count, by: 2) {
            let leftItem = shopItems[i]
            let leftCard = createCompactShopItemCard(item: leftItem)
            
            if i + 1 < shopItems.count {
                let rightItem = shopItems[i + 1]
                let rightCard = createCompactShopItemCard(item: rightItem)
                
                let rowStack = UIStackView(arrangedSubviews: [leftCard, rightCard])
                rowStack.axis = .horizontal
                rowStack.spacing = 12
                rowStack.distribution = .fillEqually
                rowStacks.append(rowStack)
            } else {
                // Odd number of items - single item in last row
                let spacerView = UIView()
                let rowStack = UIStackView(arrangedSubviews: [leftCard, spacerView])
                rowStack.axis = .horizontal
                rowStack.spacing = 12
                rowStack.distribution = .fillEqually
                rowStacks.append(rowStack)
            }
        }
        
        let gridStack = UIStackView(arrangedSubviews: rowStacks)
        gridStack.axis = .vertical
        gridStack.spacing = 12
        gridStack.alignment = .fill
        
        containerView.addSubview(gridStack)
        gridStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            gridStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            gridStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            gridStack.topAnchor.constraint(equalTo: containerView.topAnchor),
            gridStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
    
    private func createBalanceCard() -> UIView {
        let balanceCard = UIView()
        balanceCard.backgroundColor = theme.card
        balanceCard.layer.cornerRadius = 16
        balanceCard.layer.shadowColor = UIColor.black.cgColor
        balanceCard.layer.shadowOffset = CGSize(width: 0, height: 2)
        balanceCard.layer.shadowOpacity = 0.1
        balanceCard.layer.shadowRadius = 4
        
        // Removed coinIcon UIImageView block
        
        // Balance number
        balanceLabel.font = .boldSystemFont(ofSize: 36)
        balanceLabel.textColor = theme.primary
        balanceLabel.textAlignment = .center
        
        // Replaced stack with balanceLabel directly centered
        balanceCard.addSubview(balanceLabel)
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            balanceLabel.centerXAnchor.constraint(equalTo: balanceCard.centerXAnchor),
            balanceLabel.topAnchor.constraint(equalTo: balanceCard.topAnchor, constant: 20),
            balanceLabel.bottomAnchor.constraint(equalTo: balanceCard.bottomAnchor, constant: -20)
        ])
        
        return balanceCard
    }
    
    private func createWagerCard() -> UIView {
        let card = UIView()
        card.backgroundColor = theme.card
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowOpacity = 0.1
        card.layer.shadowRadius = 4
        
        let iconView = UIImageView()
        iconView.image = UIImage(systemName: "flame.fill")
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = UIColor(red: 0.843, green: 0.137, blue: 0.008, alpha: 1)
        
        let titleLabel = UILabel()
        titleLabel.text = "Place Wager"
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.textColor = theme.text
        
        let descLabel = UILabel()
        descLabel.text = "Bet coins on completing all habits. Win 2x!"
        descLabel.font = .systemFont(ofSize: 14)
        descLabel.textColor = theme.secondaryText
        descLabel.numberOfLines = 2
        
        let button = UIButton(type: .system)
        button.setTitle("Create Wager", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.backgroundColor = UIColor(red: 0.843, green: 0.137, blue: 0.008, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(wagerTapped), for: .touchUpInside)
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel, descLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        
        let contentStack = UIStackView(arrangedSubviews: [iconView, textStack])
        contentStack.axis = .horizontal
        contentStack.spacing = 12
        contentStack.alignment = .center
        
        let mainStack = UIStackView(arrangedSubviews: [contentStack, button])
        mainStack.axis = .vertical
        mainStack.spacing = 12
        
        card.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            mainStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            mainStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            iconView.heightAnchor.constraint(equalToConstant: 40),
            iconView.widthAnchor.constraint(equalToConstant: 40),
            button.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        return card
    }
    
    private func createCompactShopItemCard(item: ShopItem) -> UIView {
        let card = UIView()
        card.backgroundColor = theme.card
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowOpacity = 0.1
        card.layer.shadowRadius = 4
        
        let color = UIColor(hex: item.iconColor) ?? .systemBlue
        
        // Check ownership
        var isOwned = false
        var buttonTitle = "Buy"
        
        switch item.type {
        case .flameColor:
            isOwned = store.isFlameColorOwned(item.name)
        case .customTheme:
            let themeName = item.name.replacingOccurrences(of: " Theme", with: "").lowercased()
            isOwned = store.isThemeUnlocked(themeName)
        case .badge:
            isOwned = store.unlockedBadges.contains(where: { $0.name == item.name })
        default:
            // Consumables can be purchased multiple times
            isOwned = false
        }
        
        if isOwned {
            buttonTitle = "Owned"
            card.layer.borderColor = theme.primary.cgColor
            card.layer.borderWidth = 2
        }
        
        let iconView = UIImageView()
        iconView.image = UIImage(systemName: item.icon)
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = color
        
        let titleLabel = UILabel()
        titleLabel.text = item.name
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textColor = theme.text
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.8
        
        let descLabel = UILabel()
        descLabel.text = item.description
        descLabel.font = .systemFont(ofSize: 12)
        descLabel.textColor = theme.secondaryText
        descLabel.numberOfLines = 3
        descLabel.textAlignment = .center
        
        var previewView: UIView?
        if item.type == .customTheme {
            let themeName = item.name.replacingOccurrences(of: " Theme", with: "").lowercased()
            let preview = UIView()
            let previewTheme = ThemeManager.current(from: themeName)
            preview.backgroundColor = previewTheme.background
            preview.layer.cornerRadius = 8
            preview.layer.borderWidth = 1
            preview.layer.borderColor = previewTheme.primary.cgColor
            previewView = preview
        } else if item.type == .flameColor {
            let swatch = UIView()
            swatch.backgroundColor = color
            swatch.layer.cornerRadius = 6
            swatch.layer.borderWidth = 1
            swatch.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
            previewView = swatch
        }
        
        var arranged: [UIView] = [iconView]
        if let previewView = previewView {
            arranged.append(previewView)
        }
        arranged.append(contentsOf: [titleLabel, descLabel])
        
        let priceLabel = UILabel()
        priceLabel.text = isOwned ? "✓ Owned" : "\(item.price)"
        priceLabel.font = .boldSystemFont(ofSize: 18)
        priceLabel.textColor = isOwned ? theme.primary : color
        priceLabel.textAlignment = .center
        
        let button = UIButton(type: .system)
        button.setTitle(buttonTitle, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.backgroundColor = isOwned ? theme.secondaryText.withAlphaComponent(0.3) : color
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(shopItemTapped(_:)), for: .touchUpInside)
        button.tag = item.id.hashValue
        button.isEnabled = !isOwned
        
        arranged.append(priceLabel)
        arranged.append(button)
        
        let stack = UIStackView(arrangedSubviews: arranged)
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        
        card.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            iconView.heightAnchor.constraint(equalToConstant: 40),
            button.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        if let previewView = previewView {
            previewView.translatesAutoresizingMaskIntoConstraints = false
            if item.type == .customTheme {
                NSLayoutConstraint.activate([
                    previewView.heightAnchor.constraint(equalToConstant: 20),
                    previewView.widthAnchor.constraint(equalToConstant: 60)
                ])
            } else if item.type == .flameColor {
                NSLayoutConstraint.activate([
                    previewView.heightAnchor.constraint(equalToConstant: 12),
                    previewView.widthAnchor.constraint(equalToConstant: 24)
                ])
            }
        }
        
        return card
    }
    
    private func updateBalance() {
        balanceLabel.text = "\(store.wallet.balance)"
    }
    
    @objc private func wagerTapped() {
        let wagerVC = WagerViewController()
        let nav = UINavigationController(rootViewController: wagerVC)
        present(nav, animated: true)
    }
    
    @objc private func shopItemTapped(_ sender: UIButton) {
        // Find the item by tag (using hashValue)
        guard let item = shopItems.first(where: { $0.id.hashValue == sender.tag }) else {
            return
        }
        
        // Check if user has enough coins
        if store.wallet.balance < item.price {
            showAlert(title: "Insufficient Coins", message: "You need \(item.price) coins to purchase this item. You currently have \(store.wallet.balance) coins.")
            return
        }
        
        // Show confirmation alert
        let alert = UIAlertController(
            title: "Purchase \(item.name)?",
            message: "This will cost \(item.price) coins. You currently have \(store.wallet.balance) coins.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Purchase", style: .default) { [weak self] _ in
            self?.processPurchase(item: item)
        })
        
        present(alert, animated: true)
    }
    
    private func processPurchase(item: ShopItem) {
        store.purchaseShopItem(item) { [weak self] success, message in
            DispatchQueue.main.async {
                if success {
                    self?.showAlert(title: "Success!", message: message)
                    self?.updateBalance()
                } else {
                    self?.showAlert(title: "Purchase Failed", message: message)
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UIColor Extension for Hex

extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }
        
        let length = hexSanitized.count
        let r, g, b, a: CGFloat
        
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            a = 1.0
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        } else {
            return nil
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}

