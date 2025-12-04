// Eternal-CS329E-Group-Project
// Group 15
// Created / Edits done by Ori Parks (lwp369)

import UIKit

final class StreakFreezeViewController: UIViewController {
    
    private let store = HabitStore.shared
    private var theme: Theme { ThemeManager.current(from: store.settings.themeKey) }
    
    private let balanceLabel = UILabel()
    private let infoLabel = UILabel()
    private let priceLabel = UILabel()
    private let ownedLabel = UILabel()
    private let purchaseButton = UIButton(type: .system)
    
    private let card = UIView()
    private let iconView = UIImageView()
    
    private let freezePrice = 150
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = theme.background
        title = "Streak Freeze"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeTapped))
        
        setupUI()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    private func setupUI() {
        // Card container
        card.backgroundColor = theme.card
        card.layer.cornerRadius = 20
        card.layer.masksToBounds = false
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.layer.shadowOpacity = 0.15
        card.layer.shadowRadius = 12
        
        card.layer.shadowColor = theme.warmShadowColor.cgColor
        card.layer.shadowOpacity = theme.isAmber ? 0.18 : 0.15
        card.layer.shadowRadius = theme.isAmber ? 12 : 12
        
        view.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            card.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24)
        ])
        
        // Large snowflake icon
        iconView.image = UIImage(systemName: "snowflake")
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .systemCyan
        
        // Balance display
        balanceLabel.text = "Current Coins: \(store.wallet.balance)"
        balanceLabel.font = .boldSystemFont(ofSize: 24)
        balanceLabel.textColor = theme.primary
        balanceLabel.textAlignment = .center
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = "Streak Freeze"
        titleLabel.font = .boldSystemFont(ofSize: 32)
        titleLabel.textColor = theme.text
        titleLabel.textAlignment = .center
        
        // Info label
        infoLabel.text = "Protect your hard-earned streak! Get ONE free pass if you miss a day. Your streak won't break! Perfect for busy days or emergencies."
        infoLabel.font = .preferredFont(forTextStyle: .body)
        infoLabel.textColor = theme.secondaryText
        infoLabel.textAlignment = .center
        infoLabel.numberOfLines = 0
        
        // Price label
        priceLabel.text = "Cost: \(freezePrice) coins"
        priceLabel.font = .boldSystemFont(ofSize: 28)
        priceLabel.textColor = .systemCyan
        priceLabel.textAlignment = .center
        
        // Owned label
        ownedLabel.font = .systemFont(ofSize: 18, weight: .medium)
        ownedLabel.textColor = theme.secondaryText
        ownedLabel.textAlignment = .center
        
        // Purchase button
        purchaseButton.setTitle("Purchase Streak Freeze", for: .normal)
        purchaseButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        purchaseButton.backgroundColor = .systemCyan
        purchaseButton.setTitleColor(.white, for: .normal)
        purchaseButton.layer.cornerRadius = 14
        
        if theme.isAmber {
            purchaseButton.layer.shadowColor = theme.primary.withAlphaComponent(0.5).cgColor
            purchaseButton.layer.shadowRadius = 10
            purchaseButton.layer.shadowOpacity = 0.6
            purchaseButton.layer.shadowOffset = .zero
        }
        
        purchaseButton.addTarget(self, action: #selector(purchaseTapped), for: .touchUpInside)
        
        // Stack layout
        let stack = UIStackView(arrangedSubviews: [
            iconView,
            titleLabel,
            balanceLabel,
            priceLabel,
            ownedLabel,
            infoLabel,
            purchaseButton
        ])
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .fill
        stack.setCustomSpacing(8, after: titleLabel)
        stack.setCustomSpacing(12, after: balanceLabel)
        stack.setCustomSpacing(24, after: infoLabel)
        
        card.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 32),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -32),
            
            iconView.heightAnchor.constraint(equalToConstant: 80),
            purchaseButton.heightAnchor.constraint(equalToConstant: 54)
        ])
    }
    
    private func updateUI() {
        balanceLabel.text = "Current Coins: \(store.wallet.balance)"
        ownedLabel.text = "You own: \(store.streakFreezesOwned) Streak Freeze\(store.streakFreezesOwned == 1 ? "" : "s")"
        
        // Update button state
        let canAfford = store.wallet.balance >= freezePrice
        purchaseButton.isEnabled = canAfford
        purchaseButton.alpha = canAfford ? 1.0 : 0.5
        
        if !canAfford {
            purchaseButton.setTitle("Not Enough Coins", for: .normal)
        } else {
            purchaseButton.setTitle("Purchase Streak Freeze", for: .normal)
        }
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func purchaseTapped() {
        guard store.wallet.balance >= freezePrice else {
            showAlert(title: "Not Enough Coins", message: "You need \(freezePrice) coins to purchase a Streak Freeze. You currently have \(store.wallet.balance) coins.")
            return
        }
        
        // Confirm purchase
        let alert = UIAlertController(
            title: "Purchase Streak Freeze?",
            message: "Cost: \(freezePrice) coins\n\nThis will protect your streak for ONE missed day. The freeze will be automatically used if you miss a check-in.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Purchase", style: .default) { [weak self] _ in
            self?.completePurchase()
        })
        
        present(alert, animated: true)
    }
    
    private func completePurchase() {
        if store.spendCoins(freezePrice) {
            store.addStreakFreeze()
            
            // Haptic feedback
            let impact = UINotificationFeedbackGenerator()
            impact.notificationOccurred(.success)
            
            showSuccessAnimation()
            updateUI()
        } else {
            showAlert(title: "Purchase Failed", message: "Unable to complete purchase.")
        }
    }
    
    private func showSuccessAnimation() {
        // Create overlay
        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        overlay.alpha = 0
        
        // Create success card
        let successCard = UIView()
        successCard.backgroundColor = theme.card
        successCard.layer.cornerRadius = 24
        successCard.layer.shadowColor = UIColor.black.cgColor
        successCard.layer.shadowOffset = CGSize(width: 0, height: 10)
        successCard.layer.shadowOpacity = 0.3
        successCard.layer.shadowRadius = 20
        
        // Snowflake icon
        let successIcon = UIImageView()
        successIcon.image = UIImage(systemName: "snowflake")
        successIcon.contentMode = .scaleAspectFit
        successIcon.tintColor = .systemCyan
        
        let successLabel = UILabel()
        successLabel.text = "Purchased! ❄️"
        successLabel.font = .boldSystemFont(ofSize: 32)
        successLabel.textColor = .systemCyan
        successLabel.textAlignment = .center
        
        let subLabel = UILabel()
        subLabel.text = "Your streak is protected!"
        subLabel.font = .systemFont(ofSize: 18, weight: .medium)
        subLabel.textColor = theme.secondaryText
        subLabel.textAlignment = .center
        
        let stack = UIStackView(arrangedSubviews: [successIcon, successLabel, subLabel])
        stack.axis = .vertical
        stack.spacing = 16
        
        successCard.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: successCard.leadingAnchor, constant: 40),
            stack.trailingAnchor.constraint(equalTo: successCard.trailingAnchor, constant: -40),
            stack.topAnchor.constraint(equalTo: successCard.topAnchor, constant: 40),
            stack.bottomAnchor.constraint(equalTo: successCard.bottomAnchor, constant: -40),
            successIcon.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        view.addSubview(overlay)
        view.addSubview(successCard)
        
        overlay.translatesAutoresizingMaskIntoConstraints = false
        successCard.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlay.topAnchor.constraint(equalTo: view.topAnchor),
            overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            successCard.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            successCard.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            successCard.widthAnchor.constraint(equalToConstant: 300)
        ])
        
        successCard.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        successCard.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            overlay.alpha = 1
            successCard.alpha = 1
            successCard.transform = .identity
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 1.2, options: [], animations: {
                overlay.alpha = 0
                successCard.alpha = 0
                successCard.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }) { _ in
                overlay.removeFromSuperview()
                successCard.removeFromSuperview()
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

