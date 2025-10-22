// Eternal-CS329E-Group-Project
// Group 15
// Created / Edits done by Ori Parks (lwp369)

// Grid cell for shop items. Renders an icon, title, and price. Supports SF Symbols with optional tint.
// Comments follow the project's single-line comment standard.

import UIKit

// ShopItemCell
final class ShopItemCell: UICollectionViewCell {
    static let reuseID = "ShopItemCell"

    // Views
    private let card = UIView()
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()

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
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        // Card container for background and rounding
        card.layer.cornerRadius = 14
        card.layer.masksToBounds = true
        contentView.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            card.topAnchor.constraint(equalTo: contentView.topAnchor),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        // Icon uses aspect fit; size constrained below
        imageView.contentMode = .scaleAspectFit
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        priceLabel.font = .preferredFont(forTextStyle: .subheadline)

        // Vertical stack to center icon, then title and price
        let v = UIStackView(arrangedSubviews: [imageView, titleLabel, priceLabel])
        v.axis = .vertical
        v.alignment = .center
        v.spacing = 8
        card.addSubview(v)
        v.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            v.leadingAnchor.constraint(equalTo: card.layoutMarginsGuide.leadingAnchor),
            v.trailingAnchor.constraint(equalTo: card.layoutMarginsGuide.trailingAnchor),
            v.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            v.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -12)
        ])

        imageView.heightAnchor.constraint(equalToConstant: 56).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 56).isActive = true
    }

    // Configuration
    // Applies theme colors, sets texts, and loads image (SF Symbol preferred). Optional tint overrides theme.
    func configure(title: String, price: Int, imageName: String, theme: Theme, tintColor: UIColor? = nil) {
        card.backgroundColor = theme.card
        titleLabel.textColor = theme.text
        priceLabel.textColor = theme.secondaryText

        titleLabel.text = title
        priceLabel.text = "\(price)"

        // Prefer SF Symbol by name; apply tint
        if let system = UIImage(systemName: imageName) {
            imageView.image = system
            imageView.tintColor = tintColor ?? theme.primary
        }
        // Fall back to asset image if provided
        else if let asset = UIImage(named: imageName) {
            imageView.image = asset
            if let tint = tintColor { imageView.tintColor = tint }
        }
        // Default to flame symbol if neither found
        else {
            imageView.image = UIImage(systemName: "flame.fill")
            imageView.tintColor = tintColor ?? theme.primary
        }
    }
}
