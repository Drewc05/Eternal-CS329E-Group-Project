// Eternal-CS329E-Group-Project
// Group 15
// Created / Edits done by Ori Parks (lwp369)

import UIKit

final class InventoryViewController: UIViewController {
    
    private let store = HabitStore.shared
    private var theme: Theme { ThemeManager.current(from: store.settings.themeKey) }
    
    private let segmentedControl = UISegmentedControl(items: ["Flames", "Themes", "Items"])
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = theme.background
        ThemeManager.styleNavBar(navigationController?.navigationBar, theme: theme)
        title = "Inventory"
        
        setupUI()
        loadContent()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInventoryUpdate),
            name: NSNotification.Name("HabitDataLoaded"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInventoryUpdate),
            name: NSNotification.Name("ShopItemPurchased"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInventoryUpdate),
            name: NSNotification.Name("FlameColorChanged"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleThemeChanged),
            name: NSNotification.Name("ThemeChanged"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInventoryUpdate),
            name: NSNotification.Name("BadgeChanged"),
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Reload content when returning to inventory
        loadContent()
    }
    
    @objc private func handleThemeChanged() {
        // Refresh entire UI with new theme
        view.backgroundColor = theme.background
        ThemeManager.styleNavBar(navigationController?.navigationBar, theme: theme)
        segmentedControl.backgroundColor = theme.card
        loadContent()
    }
    
    private func setupUI() {
        // Segmented control
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        segmentedControl.backgroundColor = theme.card
        segmentedControl.selectedSegmentTintColor = theme.primary
        segmentedControl.setTitleTextAttributes([.foregroundColor: theme.text], for: .normal)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        
        view.addSubview(segmentedControl)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        // Scroll view and content stack
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.alignment = .fill
        
        scrollView.addSubview(contentStack)
        view.addSubview(scrollView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            scrollView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }
    
    @objc private func segmentChanged() {
        loadContent()
    }
    
    @objc private func handleInventoryUpdate() {
        loadContent()
    }
    
    private func loadContent() {
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            loadFlameColors()
        case 1:
            loadThemes()
        case 2:
            loadItems()
        default:
            break
        }
    }
    
    private func loadFlameColors() {
        let ownedColors = store.getOwnedFlameColors()
        let activeColor = store.getActiveFlameColor()
        
        if ownedColors.isEmpty {
            let emptyLabel = createEmptyLabel(text: "No flame colors unlocked yet.\nVisit the shop to purchase!")
            contentStack.addArrangedSubview(emptyLabel)
            return
        }
        
        for color in ownedColors {
            let card = createFlameColorCard(color: color, isActive: color.id == activeColor.id)
            contentStack.addArrangedSubview(card)
        }
    }
    
    private func loadThemes() {
        let unlockedThemes = store.getUnlockedThemes()
        let currentTheme = store.settings.themeKey.lowercased()
        
        for themeName in unlockedThemes {
            let theme = ThemeManager.current(from: themeName)
            let card = createThemeCard(theme: theme, isActive: themeName == currentTheme)
            contentStack.addArrangedSubview(card)
        }
    }
    
    private func loadItems() {
        // Streak Freezes (info only - auto-applied)
        let freezeCard = createItemCard(
            icon: "snowflake",
            iconColor: .systemCyan,
            title: "Streak Freezes",
            description: "Protect your streak when you miss a day (auto-applied)",
            count: store.streakFreezesOwned,
            actionTitle: nil,
            action: nil
        )
        contentStack.addArrangedSubview(freezeCard)
        
        // Auto-Complete Passes (with USE button)
        let passCard = createItemCard(
            icon: "checkmark.circle.fill",
            iconColor: .systemGreen,
            title: "Auto-Complete Passes",
            description: "Tap to instantly complete all habits for today",
            count: store.autoCompletePasses,
            actionTitle: store.autoCompletePasses > 0 ? "USE NOW" : nil,
            action: store.autoCompletePasses > 0 ? { [weak self] in
                self?.useAutoCompletePass()
            } : nil
        )
        contentStack.addArrangedSubview(passCard)

        // Streak Recovery (stockpiled, with USE button)
        let recoveryCard = createItemCard(
            icon: "heart.fill",
            iconColor: .systemPink,
            title: "Streak Recovery",
            description: "Restore up to 7 missed days on a habit. Choose which habit when using.",
            count: store.streakRecoveryPasses,
            actionTitle: store.streakRecoveryPasses > 0 ? "USE NOW" : nil,
            action: store.streakRecoveryPasses > 0 ? { [weak self] in
                self?.presentHabitPickerForStreakRecovery()
            } : nil
        )
        contentStack.addArrangedSubview(recoveryCard)

        // Multipliers (stockpiled, with USE buttons)
        let m24Card = createItemCard(
            icon: "sparkles",
            iconColor: .systemYellow,
            title: "24h Coin Multiplier",
            description: "Earn 1.5x coins for the next 24 hours.",
            count: store.multiplier24hCount,
            actionTitle: store.multiplier24hCount > 0 ? "USE NOW" : nil,
            action: store.multiplier24hCount > 0 ? { [weak self] in
                if self?.store.useMultiplier24h() == true { self?.loadContent() }
            } : nil
        )
        contentStack.addArrangedSubview(m24Card)

        let m7Card = createItemCard(
            icon: "sparkles",
            iconColor: .systemYellow,
            title: "7-Day Coin Multiplier",
            description: "Earn 1.5x coins for the next 7 days.",
            count: store.multiplier7dCount,
            actionTitle: store.multiplier7dCount > 0 ? "USE NOW" : nil,
            action: store.multiplier7dCount > 0 ? { [weak self] in
                if self?.store.useMultiplier7d() == true { self?.loadContent() }
            } : nil
        )
        contentStack.addArrangedSubview(m7Card)

        let megaCard = createItemCard(
            icon: "bolt.fill",
            iconColor: .systemOrange,
            title: "Mega Multiplier",
            description: "Earn 2x coins for the next 24 hours.",
            count: store.multiplierMegaCount,
            actionTitle: store.multiplierMegaCount > 0 ? "USE NOW" : nil,
            action: store.multiplierMegaCount > 0 ? { [weak self] in
                if self?.store.useMultiplierMega() == true { self?.loadContent() }
            } : nil
        )
        contentStack.addArrangedSubview(megaCard)
        
        // Habit Slots (info only)
        let slotsCard = createItemCard(
            icon: "plus.circle.fill",
            iconColor: .systemPurple,
            title: "Habit Slots",
            description: "Maximum number of habits you can track",
            count: store.maxHabitSlots,
            actionTitle: nil,
            action: nil
        )
        contentStack.addArrangedSubview(slotsCard)
        
        // Multiplier status
        if store.isMultiplierActive() {
            let timeRemaining = store.activeMultiplierUntil!.timeIntervalSinceNow
            let hours = Int(timeRemaining / 3600)
            let minutes = Int((timeRemaining.truncatingRemainder(dividingBy: 3600)) / 60)
            let strengthText = store.activeMultiplierStrength == 2.0 ? "2x" : "1.5x"
            
            let multiplierCard = createItemCard(
                icon: "sparkles",
                iconColor: .systemYellow,
                title: "Coin Multiplier Active",
                description: "Earning \(strengthText) coins! Time remaining: \(hours)h \(minutes)m",
                count: nil,
                actionTitle: nil,
                action: nil
            )
            contentStack.addArrangedSubview(multiplierCard)
        }
        
        // Badges section
        if !store.unlockedBadges.isEmpty {
            let header = createSectionHeader(title: "Badges (\(store.unlockedBadges.count))")
            contentStack.addArrangedSubview(header)
            for badge in store.unlockedBadges {
                let card = createBadgeCard(badge: badge)
                contentStack.addArrangedSubview(card)
            }
        }
    }
    
    private func createFlameColorCard(color: FlameColor, isActive: Bool) -> UIView {
        let card = UIView()
        card.backgroundColor = theme.card
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowOpacity = 0.1
        card.layer.shadowRadius = 4
        
        if isActive {
            card.layer.borderColor = theme.primary.cgColor
            card.layer.borderWidth = 3
        }
        
        let flameColor = UIColor(hex: color.colorHex) ?? .systemOrange
        
        // Flame preview
        let flameIcon = UIImageView()
        flameIcon.image = UIImage(systemName: "flame.fill")
        flameIcon.tintColor = flameColor
        flameIcon.contentMode = .scaleAspectFit
        
        let nameLabel = UILabel()
        nameLabel.text = color.name
        nameLabel.font = .boldSystemFont(ofSize: 20)
        nameLabel.textColor = theme.text
        
        let statusLabel = UILabel()
        statusLabel.text = isActive ? "✓ Equipped" : "Owned"
        statusLabel.font = .systemFont(ofSize: 16)
        statusLabel.textColor = isActive ? theme.primary : theme.secondaryText
        
        let equipButton = UIButton(type: .system)
        equipButton.setTitle(isActive ? "Equipped" : "Equip", for: .normal)
        equipButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        equipButton.backgroundColor = isActive ? theme.secondaryText.withAlphaComponent(0.3) : theme.primary
        equipButton.setTitleColor(.white, for: .normal)
        equipButton.layer.cornerRadius = 12
        equipButton.isEnabled = !isActive
        equipButton.tag = color.id.hashValue
        equipButton.addTarget(self, action: #selector(equipFlameColor(_:)), for: .touchUpInside)
        
        let textStack = UIStackView(arrangedSubviews: [nameLabel, statusLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        
        let topStack = UIStackView(arrangedSubviews: [flameIcon, textStack])
        topStack.axis = .horizontal
        topStack.spacing = 16
        topStack.alignment = .center
        
        let mainStack = UIStackView(arrangedSubviews: [topStack, equipButton])
        mainStack.axis = .vertical
        mainStack.spacing = 12
        
        card.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            flameIcon.widthAnchor.constraint(equalToConstant: 50),
            flameIcon.heightAnchor.constraint(equalToConstant: 50),
            equipButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        return card
    }
    
    private func createThemeCard(theme: Theme, isActive: Bool) -> UIView {
        let card = UIView()
        card.backgroundColor = theme.card
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowOpacity = 0.1
        card.layer.shadowRadius = 4
        
        if isActive {
            card.layer.borderColor = theme.primary.cgColor
            card.layer.borderWidth = 3
        }
        
        // Theme preview
        let previewView = UIView()
        previewView.backgroundColor = theme.background
        previewView.layer.cornerRadius = 8
        previewView.layer.borderWidth = 1
        previewView.layer.borderColor = theme.primary.cgColor
        
        let nameLabel = UILabel()
        nameLabel.text = theme.name.capitalized
        nameLabel.font = .boldSystemFont(ofSize: 20)
        // Use contrasting text color based on card background luminance
        nameLabel.textColor = theme.text
        
        let statusLabel = UILabel()
        statusLabel.text = isActive ? "✓ Active" : "Unlocked"
        statusLabel.font = .systemFont(ofSize: 16)
        statusLabel.textColor = isActive ? theme.primary : theme.secondaryText
        
        let applyButton = UIButton(type: .system)
        applyButton.setTitle(isActive ? "Active" : "Apply", for: .normal)
        applyButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        applyButton.backgroundColor = isActive ? self.theme.secondaryText.withAlphaComponent(0.3) : self.theme.primary
        applyButton.setTitleColor(.white, for: .normal)
        applyButton.layer.cornerRadius = 12
        applyButton.isEnabled = !isActive
        applyButton.accessibilityLabel = theme.name
        applyButton.addTarget(self, action: #selector(applyTheme(_:)), for: .touchUpInside)
        
        let textStack = UIStackView(arrangedSubviews: [nameLabel, statusLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        
        let topStack = UIStackView(arrangedSubviews: [previewView, textStack])
        topStack.axis = .horizontal
        topStack.spacing = 16
        topStack.alignment = .center
        
        let mainStack = UIStackView(arrangedSubviews: [topStack, applyButton])
        mainStack.axis = .vertical
        mainStack.spacing = 12
        
        card.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            previewView.widthAnchor.constraint(equalToConstant: 50),
            previewView.heightAnchor.constraint(equalToConstant: 50),
            applyButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        return card
    }
    
    private func createItemCard(icon: String, iconColor: UIColor, title: String, description: String, count: Int?, actionTitle: String?, action: (() -> Void)?) -> UIView {
        let card = UIView()
        card.backgroundColor = theme.card
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowOpacity = 0.1
        card.layer.shadowRadius = 4
        
        let iconView = UIImageView()
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = iconColor
        iconView.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.textColor = theme.text
        
        let descLabel = UILabel()
        descLabel.text = description
        descLabel.font = .systemFont(ofSize: 14)
        descLabel.textColor = theme.secondaryText
        descLabel.numberOfLines = 0
        
        let countLabel = UILabel()
        if let count = count {
            countLabel.text = "×\(count)"
            countLabel.font = .boldSystemFont(ofSize: 24)
            countLabel.textColor = theme.primary
        }
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel, descLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        
        let topStack = UIStackView(arrangedSubviews: [iconView, textStack, countLabel])
        topStack.axis = .horizontal
        topStack.spacing = 16
        topStack.alignment = .center
        
        card.addSubview(topStack)
        topStack.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints = [
            topStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            topStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            topStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalToConstant: 40)
        ]
        
        // Add action button if provided
        if let actionTitle = actionTitle, let action = action {
            let button = UIButton(type: .system)
            button.setTitle(actionTitle, for: .normal)
            button.titleLabel?.font = .boldSystemFont(ofSize: 16)
            button.backgroundColor = theme.primary
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 12
            
            // Store action in closure
            button.addAction(UIAction { _ in
                action()
            }, for: .touchUpInside)
            
            card.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            
            constraints.append(contentsOf: [
                button.topAnchor.constraint(equalTo: topStack.bottomAnchor, constant: 12),
                button.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
                button.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
                button.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
                button.heightAnchor.constraint(equalToConstant: 44)
            ])
        } else {
            constraints.append(
                topStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
            )
        }
        
        NSLayoutConstraint.activate(constraints)
        
        return card
    }
    
    private func createBadgeCard(badge: Badge) -> UIView {
        let card = UIView()
        card.backgroundColor = theme.card
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowOpacity = 0.1
        card.layer.shadowRadius = 4

        let iconView = UIImageView()
        iconView.image = UIImage(systemName: badge.icon)
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = UIColor(hex: badge.colorHex) ?? theme.primary

        let nameLabel = UILabel()
        nameLabel.text = badge.name
        nameLabel.font = .boldSystemFont(ofSize: 18)
        nameLabel.textColor = theme.text

        let descLabel = UILabel()
        descLabel.text = badge.description
        descLabel.font = .systemFont(ofSize: 14)
        descLabel.textColor = theme.secondaryText
        descLabel.numberOfLines = 0

        let statusLabel = UILabel()
        let isActive = (store.getActiveBadge()?.id == badge.id)
        statusLabel.text = isActive ? "✓ Displaying" : (badge.isUnlocked ? "Unlocked" : "Locked")
        statusLabel.font = .systemFont(ofSize: 14)
        statusLabel.textColor = isActive ? theme.primary : theme.secondaryText

        let equipButton = UIButton(type: .system)
        equipButton.setTitle(isActive ? "Displayed" : "Display", for: .normal)
        equipButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        equipButton.backgroundColor = isActive ? theme.secondaryText.withAlphaComponent(0.3) : theme.primary
        equipButton.setTitleColor(.white, for: .normal)
        equipButton.layer.cornerRadius = 12
        equipButton.isEnabled = !isActive
        equipButton.tag = badge.id.hashValue
        equipButton.addTarget(self, action: #selector(equipBadge(_:)), for: .touchUpInside)

        let textStack = UIStackView(arrangedSubviews: [nameLabel, descLabel, statusLabel])
        textStack.axis = .vertical
        textStack.spacing = 4

        let topStack = UIStackView(arrangedSubviews: [iconView, textStack])
        topStack.axis = .horizontal
        topStack.spacing = 12
        topStack.alignment = .center

        let mainStack = UIStackView(arrangedSubviews: [topStack, equipButton])
        mainStack.axis = .vertical
        mainStack.spacing = 12

        card.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            iconView.widthAnchor.constraint(equalToConstant: 48),
            iconView.heightAnchor.constraint(equalToConstant: 48),
            equipButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        return card
    }
    
    private func createEmptyLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 18)
        label.textColor = theme.secondaryText
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }
    
    private func createSectionHeader(title: String) -> UIView {
        let label = UILabel()
        label.text = title
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = theme.primary
        label.textAlignment = .left
        return label
    }
    
    @objc private func equipFlameColor(_ sender: UIButton) {
        let ownedColors = store.getOwnedFlameColors()
        guard let color = ownedColors.first(where: { $0.id.hashValue == sender.tag }) else { return }
        
        store.setActiveFlameColor(color.id)
        loadContent()
        
        let alert = UIAlertController(
            title: "Flame Color Equipped!",
            message: "\(color.name) is now active on all your habits.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func applyTheme(_ sender: UIButton) {
        guard let themeName = sender.accessibilityLabel else { return }
        
        store.setThemeKey(themeName)
        
        // Reload entire UI with new theme
        view.backgroundColor = theme.background
        ThemeManager.styleNavBar(navigationController?.navigationBar, theme: theme)
        segmentedControl.backgroundColor = theme.card
        loadContent()
        
        // Notify other screens to update
        NotificationCenter.default.post(name: NSNotification.Name("ThemeChanged"), object: nil)
        
        // Prompt user to restart for full effect
        let alert = UIAlertController(
            title: "Theme Applied!",
            message: "\(themeName.capitalized) theme is now active.\n\nFor the best experience, we recommend restarting the app to ensure all UI elements update properly.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func equipBadge(_ sender: UIButton) {
        guard let badge = store.unlockedBadges.first(where: { $0.id.hashValue == sender.tag }) else { return }
        store.setActiveBadge(badge.id)
        loadContent()
        let alert = UIAlertController(title: "Badge Displayed", message: "\(badge.name) is now shown on your profile.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func useAutoCompletePass() {
        let alert = UIAlertController(
            title: "Use Auto-Complete Pass?",
            message: "This will instantly complete ALL of your habits for today. You cannot undo this action.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Use Pass", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            let success = self.store.useAutoCompletePass()
            
            if success {
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred()
                
                let successAlert = UIAlertController(
                    title: "✓ All Habits Completed!",
                    message: "All your habits for today have been marked as complete. Great job!",
                    preferredStyle: .alert
                )
                successAlert.addAction(UIAlertAction(title: "Awesome!", style: .default))
                self.present(successAlert, animated: true)
                
                // Reload to show updated count
                self.loadContent()
            } else {
                let errorAlert = UIAlertController(
                    title: "Error",
                    message: "Could not use Auto-Complete Pass. Make sure you have habits to complete.",
                    preferredStyle: .alert
                )
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(errorAlert, animated: true)
            }
        })
        
        present(alert, animated: true)
    }
    
    private func presentHabitPickerForStreakRecovery() {
        let eligible = store.habitsNotCompletedToday()
        guard !eligible.isEmpty else {
            let alert = UIAlertController(title: "No Eligible Habits", message: "All habits are already completed today.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        let sheet = UIAlertController(title: "Use Streak Recovery", message: "Choose a habit to restore up to 7 days.", preferredStyle: .actionSheet)
        for habit in eligible {
            sheet.addAction(UIAlertAction(title: habit.name, style: .default, handler: { [weak self] _ in
                if self?.store.useStreakRecovery(on: habit) == true {
                    let success = UIAlertController(title: "Streak Recovered!", message: "\(habit.name) has been restored by up to 7 days.", preferredStyle: .alert)
                    success.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(success, animated: true)
                    self?.loadContent()
                } else {
                    let fail = UIAlertController(title: "Unable to Use", message: "Could not use Streak Recovery on this habit.", preferredStyle: .alert)
                    fail.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(fail, animated: true)
                }
            }))
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }
}

