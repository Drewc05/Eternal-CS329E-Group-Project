// Eternal-CS329E-Group-Project
// Group 15
// Created Colin Day (cdd2774) / Edits done by Ori Parks (lwp369)

import UIKit

final class DashboardHeaderView: UICollectionReusableView {
    private let store = HabitStore.shared
    private var theme: Theme { ThemeManager.current(from: store.settings.themeKey) }

    static let reuseID = "DashboardHeaderView"
    
    var onCheckInTapped: (() -> Void)?
    
    private let card = UIView()
    private let animatedFlame = AnimatedFlameView()
    private let particleEmitter = FlameParticleEmitter()
    private let streakLabel = UILabel()
    private let streakTitleLabel = UILabel()
    private let checkInButton = UIButton(type: .system)
    private let badgeLabel = UILabel()  // Badge display (SF Symbol or Emoji)
    private let gradientLayer = CAGradientLayer()
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
        
        // Card with gradient background
        card.backgroundColor = UIColor(white: 1.0, alpha: 0.95)
        
        cardGradientLayer.colors = theme.cardGradientColors
        cardGradientLayer.locations = [0.0, 1.0]
        cardGradientLayer.cornerRadius = 20
        card.layer.insertSublayer(cardGradientLayer, at: 1)
        
        card.layer.cornerRadius = 20
        card.layer.masksToBounds = false
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.12
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.layer.shadowRadius = 10
        
        card.layer.shadowColor = theme.warmShadowColor.cgColor
        card.layer.shadowOpacity = theme.isAmber ? 0.18 : 0.12
        card.layer.shadowRadius = theme.isAmber ? 12 : 10
        
        // Add subtle gradient to card
        gradientLayer.colors = [
            UIColor(white: 1.0, alpha: 0.98).cgColor,
            UIColor(red: 0.99, green: 0.96, blue: 0.93, alpha: 0.98).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.cornerRadius = 20
        card.layer.insertSublayer(gradientLayer, at: 0)
        
        addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            card.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            card.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            card.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
        
        // Animated flame - positioned on LEFT side
        card.addSubview(particleEmitter)
        card.addSubview(animatedFlame)
        animatedFlame.translatesAutoresizingMaskIntoConstraints = false
        
        // Particle emitter behind flame
        card.insertSubview(particleEmitter, belowSubview: animatedFlame)
        particleEmitter.translatesAutoresizingMaskIntoConstraints = false
        
        // Streak number with "days" label
        streakLabel.font = UIFont.rounded(ofSize: 28, weight: .bold)
        streakLabel.textColor = theme.primary
        streakLabel.textAlignment = .left
        streakLabel.text = "0 🔥"
        
        // Badge icon display (SF Symbol or Emoji)
        badgeLabel.font = .systemFont(ofSize: 28)
        badgeLabel.textAlignment = .center
        badgeLabel.isHidden = true  // Hidden by default
        
        // Check-in button - COMPACT
        checkInButton.setTitle("Check-In", for: .normal)
        checkInButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        checkInButton.backgroundColor = theme.primary
        checkInButton.setTitleColor(.white, for: .normal)
        checkInButton.layer.cornerRadius = 12
        checkInButton.layer.shadowColor = theme.primary.withAlphaComponent(0.3).cgColor
        checkInButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        checkInButton.layer.shadowOpacity = 0.4
        checkInButton.layer.shadowRadius = 4
        if theme.isAmber {
            checkInButton.layer.shadowColor = theme.primary.withAlphaComponent(0.45).cgColor
            checkInButton.layer.shadowRadius = 10
            checkInButton.layer.shadowOpacity = 0.6
        }
        checkInButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        checkInButton.addTarget(self, action: #selector(checkInTapped), for: .touchUpInside)
        
        // HORIZONTAL layout - flame | number | spacer | badge | spacing | button
        let mainStack = UIStackView(arrangedSubviews: [animatedFlame, streakLabel, UIView(), badgeLabel, checkInButton])
        mainStack.axis = .horizontal
        mainStack.alignment = .center
        mainStack.spacing = 12
        
        card.addSubview(mainStack)
        
        
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Main horizontal stack
            mainStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            mainStack.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            
            // Flame size
            animatedFlame.widthAnchor.constraint(equalToConstant: 45),
            animatedFlame.heightAnchor.constraint(equalToConstant: 55),
            
            // Particle emitter behind flame
            particleEmitter.centerXAnchor.constraint(equalTo: animatedFlame.centerXAnchor),
            particleEmitter.bottomAnchor.constraint(equalTo: animatedFlame.topAnchor),
            particleEmitter.widthAnchor.constraint(equalToConstant: 65),
            particleEmitter.heightAnchor.constraint(equalToConstant: 85),
            
            // Button size
            checkInButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = card.bounds
        cardGradientLayer.frame = card.bounds
    }
    
    @objc private func checkInTapped() {
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        // Animate button press
        UIView.animate(withDuration: 0.1, animations: {
            self.checkInButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
                self.checkInButton.transform = .identity
            })
        }
        
        // Flame burst effect
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1.0, options: [], animations: {
            self.animatedFlame.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.animatedFlame.transform = .identity
            }
        }
        
        onCheckInTapped?()
    }
    
    func configure(overallStreak: Int) {
        streakLabel.text = "\(overallStreak) 🔥"
        
        // Display active badge if one is equipped
        if let activeBadge = store.getActiveBadge() {
            let icon = activeBadge.icon
            
            // Create attributed string with SF Symbol
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
            if let symbolImage = UIImage(systemName: icon, withConfiguration: symbolConfig) {
                let attachment = NSTextAttachment()
                attachment.image = symbolImage.withTintColor(UIColor(hex: activeBadge.colorHex) ?? theme.primary)
                let attributedString = NSAttributedString(attachment: attachment)
                badgeLabel.attributedText = attributedString
            } else {
                // Fallback to text if symbol not found
                badgeLabel.text = icon
            }
            badgeLabel.isHidden = false
        } else {
            badgeLabel.text = ""
            badgeLabel.attributedText = nil
            badgeLabel.isHidden = true
        }
        
        // Animate streak number change
        streakLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        streakLabel.alpha = 0.5
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [], animations: {
            self.streakLabel.transform = .identity
            self.streakLabel.alpha = 1.0
        })
        
        // Update flame intensity based on streak
        let intensity = min(1.0, Double(overallStreak) / 30.0)
        animatedFlame.intensity = max(0.3, intensity)
        
        // Start animations
        animatedFlame.startAnimating()
        
        if overallStreak > 0 {
            particleEmitter.startEmitting(streak: overallStreak)
        } else {
            particleEmitter.stopEmitting()
        }
        
        // Adjust flame color based on streak milestones
        if overallStreak >= 30 {
            animatedFlame.flameColor = UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1)
            particleEmitter.flameColor = UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1)
        } else if overallStreak >= 14 {
            animatedFlame.flameColor = UIColor(red: 0.95, green: 0.35, blue: 0.1, alpha: 1)
            particleEmitter.flameColor = UIColor(red: 0.95, green: 0.35, blue: 0.1, alpha: 1)
        } else if overallStreak >= 7 {
            animatedFlame.flameColor = UIColor(red: 0.9, green: 0.25, blue: 0.05, alpha: 1)
            particleEmitter.flameColor = UIColor(red: 0.9, green: 0.25, blue: 0.05, alpha: 1)
        } else {
            animatedFlame.flameColor = theme.primary
            particleEmitter.flameColor = theme.primary
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        animatedFlame.stopAnimating()
        particleEmitter.stopEmitting()
    }
}

