// Eternal-CS329E-Group-Project
// Group 15
// Created / Edits done by Ori Parks (lwp369)

import UIKit

final class DashboardHabitCell: UITableViewCell {
    static let reuseID = "DashboardHabitCell"

    private let store = HabitStore.shared
    private let card = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let streakLabel = UILabel()
    private var flameView: UIView?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear
        selectionStyle = .none

        card.backgroundColor = UIColor(white: 1.0, alpha: 0.9)
        card.layer.cornerRadius = 16
        card.layer.masksToBounds = true

        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = UIColor(red: 0.843, green: 0.137, blue: 0.008, alpha: 1)

        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textColor = .label

        streakLabel.font = .preferredFont(forTextStyle: .subheadline)
        streakLabel.textColor = .secondaryLabel

        contentView.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])

        let hstack = UIStackView(arrangedSubviews: [iconView, titleLabel, UIView(), streakLabel])
        hstack.axis = .horizontal
        hstack.alignment = .center
        hstack.spacing = 12

        card.addSubview(hstack)
        hstack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hstack.leadingAnchor.constraint(equalTo: card.layoutMarginsGuide.leadingAnchor),
            hstack.trailingAnchor.constraint(equalTo: card.layoutMarginsGuide.trailingAnchor),
            hstack.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            hstack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])

        iconView.widthAnchor.constraint(equalToConstant: 28).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 28).isActive = true
    }

    func configure(with habit: Habit) {
        titleLabel.text = habit.name
        streakLabel.text = "\(habit.currentStreak)🔥"
        let base = UIImage(systemName: habit.icon) ?? UIImage(systemName: "flame.fill")
        iconView.image = base?.withRenderingMode(.alwaysTemplate)
        
        // Get habit-specific flame color (falls back to global if not set)
        let flameColor = store.getFlameColor(for: habit.id)
        applyFlameColor(flameColor)
        
        // Animate alpha and scale changes
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
            self.iconView.alpha = CGFloat(max(0.2, min(1.0, habit.brightness)))
            let scale = CGFloat(0.95 + 0.1 * habit.brightness)
            self.iconView.transform = CGAffineTransform(scaleX: scale, y: scale)
        })
        
        // Add subtle pulse animation for high streaks
        if habit.currentStreak >= 7 {
            addPulseAnimation()
        } else {
            card.layer.removeAnimation(forKey: "pulse")
        }
    }
    
    private func applyFlameColor(_ flameColor: FlameColor) {
        // Remove existing rainbow flame if any
        if let existingFlame = flameView {
            if let rainbowFlame = existingFlame as? RainbowFlameView {
                rainbowFlame.stopAnimating()
            }
            existingFlame.removeFromSuperview()
            flameView = nil
        }
        
        // Check if it's rainbow flame
        if flameColor.name.lowercased().contains("rainbow") {
            // Hide the static icon
            iconView.alpha = 0
            
            // Create rainbow flame view overlaying the icon
            let rainbowFlame = RainbowFlameView(frame: iconView.bounds)
            rainbowFlame.translatesAutoresizingMaskIntoConstraints = false
            
            // Add to card, not iconView
            card.addSubview(rainbowFlame)
            
            NSLayoutConstraint.activate([
                rainbowFlame.leadingAnchor.constraint(equalTo: iconView.leadingAnchor),
                rainbowFlame.trailingAnchor.constraint(equalTo: iconView.trailingAnchor),
                rainbowFlame.topAnchor.constraint(equalTo: iconView.topAnchor),
                rainbowFlame.bottomAnchor.constraint(equalTo: iconView.bottomAnchor)
            ])
            
            rainbowFlame.startAnimating()
            flameView = rainbowFlame
        } else {
            // Regular color - show the icon
            iconView.alpha = 1.0
            iconView.tintColor = UIColor(hex: flameColor.colorHex) ?? UIColor(red: 0.843, green: 0.137, blue: 0.008, alpha: 1)
        }
    }
    
    private func addPulseAnimation() {
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.duration = 1.5
        pulse.fromValue = 1.0
        pulse.toValue = 1.02
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        card.layer.add(pulse, forKey: "pulse")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if let rainbowFlame = flameView as? RainbowFlameView {
            rainbowFlame.stopAnimating()
        }
        flameView?.removeFromSuperview()
        flameView = nil
        card.layer.removeAnimation(forKey: "pulse")
    }
}
