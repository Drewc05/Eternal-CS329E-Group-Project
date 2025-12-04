// Eternal-CS329E-Group-Project
// Group 15
// Created / Edits done by Ori Parks (lwp369)

import UIKit

// ShopItemCell - Enhanced with modern typography and styling
final class ShopItemCell: UICollectionViewCell {
    private let store = HabitStore.shared
    private var theme: Theme { ThemeManager.current(from: store.settings.themeKey) }
    
    static let reuseID = "ShopItemCell"

    private let card = UIView()
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    private let coinIcon = UILabel()
    private let cardGradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        // Enhanced card with shadow
        card.layer.cornerRadius = 16
        card.layer.masksToBounds = false
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowOpacity = 0.08
        card.layer.shadowRadius = 8
        
        contentView.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])

        cardGradientLayer.colors = theme.cardGradientColors
        cardGradientLayer.locations = [0, 1]
        cardGradientLayer.cornerRadius = 16
        card.layer.insertSublayer(cardGradientLayer, at: 0)

        // Warmer shadow for Amber
        card.layer.shadowColor = theme.warmShadowColor.cgColor

        // Icon with better sizing
        imageView.contentMode = .scaleAspectFit
        
        // Modern typography with rounded font
        titleLabel.font = .rounded(ofSize: 15, weight: .semibold)
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.8
        
        // Coin icon (emoji)
        coinIcon.text = "🔥"
        coinIcon.font = .systemFont(ofSize: 14)
        
        // Price with custom styling
        priceLabel.font = .rounded(ofSize: 16, weight: .bold)
        priceLabel.textAlignment = .center
        
        // Price stack with coin
        let priceStack = UIStackView(arrangedSubviews: [coinIcon, priceLabel])
        priceStack.axis = .horizontal
        priceStack.spacing = 4
        priceStack.alignment = .center

        // Vertical stack
        let v = UIStackView(arrangedSubviews: [imageView, titleLabel, priceStack])
        v.axis = .vertical
        v.alignment = .center
        v.spacing = 8
        
        card.addSubview(v)
        v.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            v.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            v.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            v.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            v.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -16)
        ])

        imageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        cardGradientLayer.frame = card.bounds
    }

    func configure(title: String, price: Int, imageName: String, theme: Theme, tintColor: UIColor? = nil) {
        card.backgroundColor = theme.card
        coinIcon.textColor = theme.primary
        titleLabel.textColor = theme.text
        priceLabel.textColor = theme.primary

        titleLabel.text = title
        priceLabel.text = "\(price)"

        // Load SF Symbol
        if let system = UIImage(systemName: imageName) {
            imageView.image = system
            imageView.tintColor = tintColor ?? theme.primary
        } else {
            imageView.image = UIImage(systemName: "flame.fill")
            imageView.tintColor = tintColor ?? theme.primary
        }
        
        // Add subtle scale animation on appear
        transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.transform = .identity
        })
        
        if theme.isAmber {
            imageView.layer.shadowColor = theme.primary.withAlphaComponent(0.45).cgColor
            imageView.layer.shadowRadius = 8
            imageView.layer.shadowOpacity = 0.6
            imageView.layer.shadowOffset = .zero
        } else {
            imageView.layer.shadowOpacity = 0
        }
    }
}
