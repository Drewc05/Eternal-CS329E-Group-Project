// Eternal-CS329E-Group-Project
// Group 15
// Created / Edits done by Ori Parks (lwp369)

import UIKit

final class WagerViewController: UIViewController {
    
    private let store = HabitStore.shared
    private var theme: Theme { ThemeManager.current(from: store.settings.themeKey) }
    
    private let amountField = UITextField()
    private let daysField = UITextField()
    private let balanceLabel = UILabel()
    private let infoLabel = UILabel()
    private let createButton = UIButton(type: .system)
    
    private let card = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = theme.background
        title = "Create Wager"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeTapped))
        
        setupUI()
    }
    
    private func setupUI() {
        // Card container
        card.backgroundColor = theme.card
        card.layer.cornerRadius = 20
        card.layer.masksToBounds = true
        
        view.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            card.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24)
        ])
        
        // Balance display
        balanceLabel.text = "Current Balance: $\(store.wallet.balance)"
        balanceLabel.font = .boldSystemFont(ofSize: 24)
        balanceLabel.textColor = theme.primary
        balanceLabel.textAlignment = .center
        
        // Info label
        infoLabel.text = "Wager coins on completing all habits for consecutive days. Double your coins if you succeed!"
        infoLabel.font = .preferredFont(forTextStyle: .body)
        infoLabel.textColor = theme.secondaryText
        infoLabel.textAlignment = .center
        infoLabel.numberOfLines = 0
        
        // Amount field
        amountField.placeholder = "Wager amount"
        amountField.keyboardType = .numberPad
        amountField.borderStyle = .roundedRect
        amountField.font = .preferredFont(forTextStyle: .body)
        amountField.backgroundColor = theme.background
        amountField.textColor = theme.text
        
        // Days field
        daysField.placeholder = "Number of days (1-30)"
        daysField.keyboardType = .numberPad
        daysField.borderStyle = .roundedRect
        daysField.font = .preferredFont(forTextStyle: .body)
        daysField.backgroundColor = theme.background
        daysField.textColor = theme.text
        
        // Create button
        createButton.setTitle("Place Wager", for: .normal)
        createButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        createButton.backgroundColor = theme.primary
        createButton.setTitleColor(.white, for: .normal)
        createButton.layer.cornerRadius = 14
        createButton.addTarget(self, action: #selector(createWagerTapped), for: .touchUpInside)
        
        // Stack layout
        let stack = UIStackView(arrangedSubviews: [balanceLabel, infoLabel, amountField, daysField, createButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .fill
        
        card.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: card.layoutMarginsGuide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: card.layoutMarginsGuide.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -24),
            createButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Tap gesture to dismiss keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func createWagerTapped() {
        guard let amountText = amountField.text,
              let amount = Int(amountText),
              amount > 0 else {
            showAlert(title: "Invalid Amount", message: "Please enter a valid wager amount.")
            return
        }
        
        guard let daysText = daysField.text,
              let days = Int(daysText),
              days >= 1 && days <= 30 else {
            showAlert(title: "Invalid Days", message: "Please enter a number of days between 1 and 30.")
            return
        }
        
        guard amount <= store.wallet.balance else {
            showAlert(title: "Insufficient Funds", message: "You don't have enough coins to place this wager.")
            return
        }
        
        // Confirm wager
        let alert = UIAlertController(
            title: "Confirm Wager",
            message: "Wager $\(amount) over \(days) days?\n\nYou must complete all your habits every day. If you succeed, you'll earn $\(amount * 2). If you fail, you lose your wager.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Confirm", style: .default) { [weak self] _ in
            self?.placeWager(amount: amount, days: days)
        })
        
        present(alert, animated: true)
    }
    
    private func placeWager(amount: Int, days: Int) {
        if store.spendCoins(amount) {
            let wager = Wager(amount: amount, targetDays: days)
            store.addWager(wager)
            
            showSuccessAnimation()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                self?.dismiss(animated: true)
            }
        } else {
            showAlert(title: "Error", message: "Failed to place wager.")
        }
    }
    
    private func showSuccessAnimation() {
        // Create overlay to ensure visibility
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
        
        let successLabel = UILabel()
        successLabel.text = "Wager Placed! 🔥"
        successLabel.font = .boldSystemFont(ofSize: 32)
        successLabel.textColor = theme.primary
        successLabel.textAlignment = .center
        
        let subLabel = UILabel()
        subLabel.text = "Good luck!"
        subLabel.font = .systemFont(ofSize: 18, weight: .medium)
        subLabel.textColor = theme.secondaryText
        subLabel.textAlignment = .center
        
        let stack = UIStackView(arrangedSubviews: [successLabel, subLabel])
        stack.axis = .vertical
        stack.spacing = 12
        
        successCard.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: successCard.leadingAnchor, constant: 40),
            stack.trailingAnchor.constraint(equalTo: successCard.trailingAnchor, constant: -40),
            stack.topAnchor.constraint(equalTo: successCard.topAnchor, constant: 32),
            stack.bottomAnchor.constraint(equalTo: successCard.bottomAnchor, constant: -32)
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
            UIView.animate(withDuration: 0.3, delay: 0.8, options: [], animations: {
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
