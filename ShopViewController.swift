// Eternal-CS329E-Group-Project
// Group 15
// Created / Edits done by Ori Parks (lwp369)

import SwiftUI
import UIKit

final class ShopViewController: UIViewController {

    private let store = HabitStore.shared
    private var theme: Theme { ThemeManager.current(from: store.settings.themeKey) }

    private let balanceLabel = UILabel()
    private let wagerButton = UIButton(type: .system)
    private let freezeButton = UIButton(type: .system)
    
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
        
        setupUI()
        updateBalance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateBalance()
    }
    
    private func setupUI() {
        // Balance display card with money bag
        let balanceCard = UIView()
        balanceCard.backgroundColor = theme.card
        balanceCard.layer.cornerRadius = 20
        balanceCard.layer.shadowColor = UIColor.black.cgColor
        balanceCard.layer.shadowOffset = CGSize(width: 0, height: 4)
        balanceCard.layer.shadowOpacity = 0.1
        balanceCard.layer.shadowRadius = 8
        
        // Red coin SF Symbol
        let coinIcon = UIImageView()
        coinIcon.image = UIImage(systemName: "dollarsign.circle.fill")
        coinIcon.contentMode = .scaleAspectFit
        coinIcon.tintColor = UIColor(red: 0.843, green: 0.137, blue: 0.008, alpha: 1)
        
        // Balance number (displayed to the RIGHT of the coin)
        balanceLabel.font = .boldSystemFont(ofSize: 48)
        balanceLabel.textColor = theme.primary
        balanceLabel.textAlignment = .left
        
        // Stack: coin on left, number on right (HORIZONTAL)
        let balanceStack = UIStackView(arrangedSubviews: [coinIcon, balanceLabel])
        balanceStack.axis = .horizontal
        balanceStack.spacing = 12
        balanceStack.alignment = .center
        
        balanceCard.addSubview(balanceStack)
        balanceStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            balanceStack.centerXAnchor.constraint(equalTo: balanceCard.centerXAnchor),
            balanceStack.topAnchor.constraint(equalTo: balanceCard.topAnchor, constant: 30),
            balanceStack.bottomAnchor.constraint(equalTo: balanceCard.bottomAnchor, constant: -30),
            coinIcon.heightAnchor.constraint(equalToConstant: 60),
            coinIcon.widthAnchor.constraint(equalToConstant: 60)
        ])
        
        // Wager Card
        let wagerCard = createFeatureCard(
            icon: "flame.fill",
            iconColor: UIColor(red: 0.843, green: 0.137, blue: 0.008, alpha: 1),
            title: "Place Wager",
            description: "Bet coins on completing all your habits. Win 2x your wager if you succeed!",
            buttonTitle: "Create Wager",
            buttonColor: UIColor(red: 0.843, green: 0.137, blue: 0.008, alpha: 1),
            action: #selector(wagerTapped)
        )
        
        // Streak Freeze Card
        let freezeCard = createFeatureCard(
            icon: "snowflake",
            iconColor: .systemCyan,
            title: "Streak Freeze",
            description: "Protect your streak! Get a free pass if you miss a day. Cost: 150 coins",
            buttonTitle: "Buy Streak Freeze",
            buttonColor: .systemCyan,
            action: #selector(freezeTapped)
        )
        
        // Main stack
        let mainStack = UIStackView(arrangedSubviews: [balanceCard, wagerCard, freezeCard])
        mainStack.axis = .vertical
        mainStack.spacing = 20
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
    
    private func createFeatureCard(icon: String, iconColor: UIColor, title: String, description: String, buttonTitle: String, buttonColor: UIColor, action: Selector) -> UIView {
        let card = UIView()
        card.backgroundColor = theme.card
        card.layer.cornerRadius = 20
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.layer.shadowOpacity = 0.1
        card.layer.shadowRadius = 8
        
        let iconView = UIImageView()
        iconView.image = UIImage(systemName: icon)
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = iconColor
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 26)
        titleLabel.textColor = theme.text
        titleLabel.textAlignment = .center
        
        let descLabel = UILabel()
        descLabel.text = description
        descLabel.font = .systemFont(ofSize: 16)
        descLabel.textColor = theme.secondaryText
        descLabel.textAlignment = .center
        descLabel.numberOfLines = 0
        
        let button = UIButton(type: .system)
        button.setTitle(buttonTitle, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.backgroundColor = buttonColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 14
        button.addTarget(self, action: action, for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [iconView, titleLabel, descLabel, button])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.setCustomSpacing(8, after: titleLabel)
        stack.setCustomSpacing(24, after: descLabel)
        
        card.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -24),
            iconView.heightAnchor.constraint(equalToConstant: 60),
            button.heightAnchor.constraint(equalToConstant: 54)
        ])
        
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
    
    @objc private func freezeTapped() {
        let freezeVC = StreakFreezeViewController()
        let nav = UINavigationController(rootViewController: freezeVC)
        present(nav, animated: true)
    }
}

