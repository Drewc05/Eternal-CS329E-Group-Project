// Eternal-CS329E-Group-Project
// Group 15
// Created / Edits done by Ori Parks (lwp369)

import UIKit

// ShopHeaderView - Enhanced with modern design
final class ShopHeaderView: UICollectionReusableView {
    static let reuseID = "ShopHeaderView"

    private let card = UIView()
    private let imageView = UIImageView()
    private let balanceLabel = UILabel()
    private let coinIcon = UILabel()
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

    private func setup() {
        backgroundColor = .clear

        // Enhanced card with better shadow
        card.layer.cornerRadius = 20
        card.layer.masksToBounds = false
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.layer.shadowOpacity = 0.1
        card.layer.shadowRadius = 10
        
        addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            card.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            card.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
        ])

        // Flame icon
        imageView.contentMode = .scaleAspectFit
        
        // Coin emoji
        coinIcon.text = "🔥"
        coinIcon.font = .systemFont(ofSize: 28)

        // Modern balance with rounded font
        balanceLabel.font = .rounded(ofSize: 36, weight: .heavy)

        // Enhanced wager button
        wagerButton.setTitle("Wager", for: .normal)
        wagerButton.titleLabel?.font = .rounded(ofSize: 16, weight: .bold)
        wagerButton.layer.cornerRadius = 14
        wagerButton.layer.shadowColor = UIColor.black.cgColor
        wagerButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        wagerButton.layer.shadowOpacity = 0.2
        wagerButton.layer.shadowRadius = 6
        wagerButton.addTarget(self, action: #selector(tapped), for: .touchUpInside)

        // Horizontal layout with balance stack
        let balanceStack = UIStackView(arrangedSubviews: [coinIcon, balanceLabel])
        balanceStack.axis = .horizontal
        balanceStack.spacing = 8
        balanceStack.alignment = .center
        
        let h = UIStackView(arrangedSubviews: [balanceStack, UIView(), wagerButton])
        h.axis = .horizontal
        h.alignment = .center
        h.spacing = 16
        
        card.addSubview(h)
        h.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            h.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            h.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            h.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            h.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])

        wagerButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        wagerButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }

    @objc private func tapped() {
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        // Animate button
        UIView.animate(withDuration: 0.1, animations: {
            self.wagerButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
                self.wagerButton.transform = .identity
            })
        }
        
        onWagerTapped?()
    }

    func configure(balance: Int, imageName: String, theme: Theme, tintColor: UIColor? = nil) {
        card.backgroundColor = theme.card
        balanceLabel.textColor = theme.primary
        wagerButton.backgroundColor = theme.primary
        wagerButton.setTitleColor(.white, for: .normal)
        
        balanceLabel.text = "\(balance)"
    }
}
