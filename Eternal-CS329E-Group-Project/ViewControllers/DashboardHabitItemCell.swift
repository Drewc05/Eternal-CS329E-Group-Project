import UIKit

final class DashboardHabitItemCell: UICollectionViewCell {
    private let store = HabitStore.shared
    private var theme: Theme { ThemeManager.current(from: store.settings.themeKey) }
    
    static let reuseID = "DashboardHabitItemCell"
    
    private let card = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let streakLabel = UILabel()
    private let miniFlameView = UIImageView()
    private let cardGradientLayer = CAGradientLayer()
    private var rainbowFlameView: RainbowFlameView?

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

        card.backgroundColor = UIColor(white: 1.0, alpha: 0.95)
        card.layer.cornerRadius = 18
        card.layer.masksToBounds = false
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowOpacity = 0.1
        card.layer.shadowRadius = 6
        
        cardGradientLayer.colors = theme.cardGradientColors
        cardGradientLayer.locations = [0, 1]
        cardGradientLayer.cornerRadius = 18
        card.layer.insertSublayer(cardGradientLayer, at: 0)
        
        // Warmer shadow in Amber
        card.layer.shadowColor = theme.warmShadowColor.cgColor

        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = theme.primary

        // Enhanced with rounded font
        titleLabel.font = .rounded(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.8

        streakLabel.font = .rounded(ofSize: 14, weight: .bold)
        streakLabel.textColor = .secondaryLabel
        streakLabel.textAlignment = .center
        
        // Mini flame indicator for streak
        miniFlameView.image = UIImage(systemName: "flame.fill")
        miniFlameView.contentMode = .scaleAspectFit
        miniFlameView.tintColor = theme.primary

        contentView.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])

        let streakStack = UIStackView(arrangedSubviews: [miniFlameView, streakLabel])
        streakStack.axis = .horizontal
        streakStack.spacing = 4
        streakStack.alignment = .center
        
        let vstack = UIStackView(arrangedSubviews: [iconView, titleLabel, streakStack])
        vstack.axis = .vertical
        vstack.alignment = .center
        vstack.spacing = 8

        card.addSubview(vstack)
        vstack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vstack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            vstack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            vstack.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            vstack.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -12)
        ])

        iconView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        miniFlameView.widthAnchor.constraint(equalToConstant: 12).isActive = true
        miniFlameView.heightAnchor.constraint(equalToConstant: 12).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Add gradient border effect for active habits
        if card.layer.borderWidth > 0 {
            let gradientBorder = CAGradientLayer()
            gradientBorder.frame = card.bounds
            gradientBorder.colors = [
                UIColor(red: 0.843, green: 0.137, blue: 0.008, alpha: 0.8).cgColor,
                UIColor(red: 0.95, green: 0.35, blue: 0.1, alpha: 0.6).cgColor
            ]
            gradientBorder.startPoint = CGPoint(x: 0, y: 0)
            gradientBorder.endPoint = CGPoint(x: 1, y: 1)
            gradientBorder.cornerRadius = 18
        }
        
        cardGradientLayer.frame = card.bounds
    }

    func configure(with habit: Habit) {
        titleLabel.text = habit.name
        streakLabel.text = "\(habit.currentStreak)"
        let base = UIImage(systemName: habit.icon) ?? UIImage(systemName: "flame.fill")
        iconView.image = base?.withRenderingMode(.alwaysTemplate)
        
        // Get habit-specific flame color (falls back to global if not set)
        let activeFlameColor = store.getFlameColor(for: habit.id)
        
        // Remove existing rainbow flame if any
        if let existingRainbow = rainbowFlameView {
            existingRainbow.stopAnimating()
            existingRainbow.removeFromSuperview()
            rainbowFlameView = nil
        }
        
        // Check if rainbow flame
        if activeFlameColor.name.lowercased().contains("rainbow") {
            // Hide static icon and create rainbow animation
            iconView.alpha = 0
            
            let rainbow = RainbowFlameView(frame: iconView.bounds)
            rainbow.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(rainbow)
            
            NSLayoutConstraint.activate([
                rainbow.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
                rainbow.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
                rainbow.widthAnchor.constraint(equalToConstant: 32),
                rainbow.heightAnchor.constraint(equalToConstant: 32)
            ])
            
            rainbow.startAnimating()
            rainbowFlameView = rainbow
            
            // Mini flame also rainbow (use a representative color)
            miniFlameView.tintColor = UIColor(red: 1.0, green: 0.3, blue: 0.5, alpha: 1)
        } else {
            // Regular flame color
            iconView.alpha = 1.0
            let flameUIColor = UIColor(hex: activeFlameColor.colorHex) ?? theme.primary
            iconView.tintColor = flameUIColor
            miniFlameView.tintColor = flameUIColor
        }
        
        // Animate icon based on brightness/streak
        let scale = CGFloat(0.9 + 0.2 * habit.brightness)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
            if self.rainbowFlameView == nil {
                self.iconView.alpha = CGFloat(max(0.4, min(1.0, habit.brightness)))
            }
            self.iconView.transform = CGAffineTransform(scaleX: scale, y: scale)
        })
        
        // Highlight card if streak is active
        if habit.currentStreak > 0 {
            let borderColor = UIColor(hex: activeFlameColor.colorHex) ?? theme.primary
            card.layer.borderWidth = 2
            card.layer.borderColor = borderColor.withAlphaComponent(0.3).cgColor
            miniFlameView.alpha = 1.0
            
            // Pulse animation for active streaks
            let pulse = CABasicAnimation(keyPath: "transform.scale")
            pulse.duration = 1.5
            pulse.fromValue = 1.0
            pulse.toValue = 1.1
            pulse.autoreverses = true
            pulse.repeatCount = .infinity
            miniFlameView.layer.add(pulse, forKey: "pulse")
            
            if theme.isAmber {
                self.card.layer.shadowColor = theme.primary.withAlphaComponent(0.35).cgColor
                self.card.layer.shadowRadius = 10
                self.card.layer.shadowOpacity = 0.6
            }
        } else {
            card.layer.borderWidth = 0
            miniFlameView.alpha = 0.3
            miniFlameView.layer.removeAllAnimations()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        miniFlameView.layer.removeAllAnimations()
        card.layer.borderWidth = 0
        
        // Stop and remove rainbow flame
        if let rainbow = rainbowFlameView {
            rainbow.stopAnimating()
            rainbow.removeFromSuperview()
            rainbowFlameView = nil
        }
        
        iconView.alpha = 1.0
    }
}

