// Eternal-CS329E-Group-Project
// Group 15
// Created / Edits done by Ori Parks (lwp369)

// Header for the Shop section. Shows balance, a flame icon, and a Wager button.
// Comments follow the project's single-line comment standard.

import UIKit

// ShopHeaderView
final class ShopHeaderView: UICollectionReusableView {
    static let reuseID = "ShopHeaderView"

    // Views
    private let card = UIView()
    private let imageView = UIImageView()
    private let balanceLabel = UILabel()
    private let wagerButton = UIButton(type: .system)

    var onWagerTapped: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // Setup
    private func setup() {
        // Transparent background; card provides visual container
        backgroundColor = .clear

        addSubview(card)
        card.layer.cornerRadius = 18
        card.layer.masksToBounds = true
        card.translatesAutoresizingMaskIntoConstraints = false
        // Pin card to layout margins; rounded corners
        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            card.topAnchor.constraint(equalTo: topAnchor),
            card.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // Icon sizing and content mode
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentHuggingPriority(.required, for: .vertical)

        // Prominent balance and a primary-colored Wager button
        balanceLabel.font = UIFont.boldSystemFont(ofSize: 32)

        wagerButton.setTitle("Wager", for: .normal)
        wagerButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        wagerButton.layer.cornerRadius = 12
        wagerButton.addTarget(self, action: #selector(tapped), for: .touchUpInside)

        let h = UIStackView(arrangedSubviews: [imageView, balanceLabel, UIView(), wagerButton])
        h.axis = .horizontal
        h.alignment = .center
        h.spacing = 12
        addSubview(h)
        h.translatesAutoresizingMaskIntoConstraints = false
        // Horizontal layout: icon, balance, spacer, button
        NSLayoutConstraint.activate([
            h.leadingAnchor.constraint(equalTo: card.layoutMarginsGuide.leadingAnchor),
            h.trailingAnchor.constraint(equalTo: card.layoutMarginsGuide.trailingAnchor),
            h.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            h.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])

        imageView.widthAnchor.constraint(equalToConstant: 64).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 64).isActive = true
        wagerButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 120).isActive = true
        wagerButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }

    // Actions
    @objc private func tapped() { onWagerTapped?() }

    // Configuration
    func configure(balance: Int, imageName: String, theme: Theme, tintColor: UIColor? = nil) {
        // Theme-driven colors and safe symbol/asset loading
        card.backgroundColor = theme.card
        balanceLabel.textColor = theme.text
        wagerButton.backgroundColor = theme.primary
        wagerButton.setTitleColor(.white, for: .normal)
        // Prefer SF Symbol, then asset, else default flame
        if let system = UIImage(systemName: imageName) {
            imageView.image = system
        } else if let asset = UIImage(named: imageName) {
            imageView.image = asset
        } else {
            imageView.image = UIImage(systemName: "flame.fill")
        }
        imageView.tintColor = tintColor ?? theme.primary
        balanceLabel.text = "$\(NumberFormatter.localizedString(from: NSNumber(value: balance), number: .decimal))"
    }
}
