import UIKit

final class DashboardHabitItemCell: UICollectionViewCell {
    static let reuseID = "DashboardHabitItemCell"

    private let card = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let streakLabel = UILabel()
    private let miniFlameView = UIImageView()

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

        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = UIColor(red: 0.843, green: 0.137, blue: 0.008, alpha: 1)

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
        miniFlameView.tintColor = UIColor(red: 0.843, green: 0.137, blue: 0.008, alpha: 1)

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
    }

    func configure(with habit: Habit) {
        titleLabel.text = habit.name
        streakLabel.text = "\(habit.currentStreak)"
        let base = UIImage(systemName: habit.icon) ?? UIImage(systemName: "flame.fill")
        iconView.image = base?.withRenderingMode(.alwaysTemplate)
        
        // Animate icon based on brightness/streak
        let alpha = CGFloat(max(0.4, min(1.0, habit.brightness)))
        let scale = CGFloat(0.9 + 0.2 * habit.brightness)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
            self.iconView.alpha = alpha
            self.iconView.transform = CGAffineTransform(scaleX: scale, y: scale)
        })
        
        // Highlight card if streak is active
        if habit.currentStreak > 0 {
            card.layer.borderWidth = 2
            card.layer.borderColor = UIColor(red: 0.843, green: 0.137, blue: 0.008, alpha: 0.3).cgColor
            miniFlameView.alpha = 1.0
            
            // Pulse animation for active streaks
            let pulse = CABasicAnimation(keyPath: "transform.scale")
            pulse.duration = 1.5
            pulse.fromValue = 1.0
            pulse.toValue = 1.1
            pulse.autoreverses = true
            pulse.repeatCount = .infinity
            miniFlameView.layer.add(pulse, forKey: "pulse")
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
    }
}
