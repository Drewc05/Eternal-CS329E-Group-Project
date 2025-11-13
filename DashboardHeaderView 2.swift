// Eternal-CS329E-Group-Project
// Group 15
// Created / Edits done by Ori Parks (lwp369)

import UIKit

final class DashboardHeaderView: UICollectionReusableView {
    static let reuseID = "DashboardHeaderView"
    
    var onCheckInTapped: (() -> Void)?
    
    private let card = UIView()
    private let flameIcon = UIImageView()
    private let streakLabel = UILabel()
    private let streakTitleLabel = UILabel()
    private let checkInButton = UIButton(type: .system)
    
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
        
        card.backgroundColor = UIColor(white: 1.0, alpha: 0.95)
        card.layer.cornerRadius = 20
        card.layer.masksToBounds = true
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.1
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.layer.shadowRadius = 8
        
        addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: leadingAnchor),
            card.trailingAnchor.constraint(equalTo: trailingAnchor),
            card.topAnchor.constraint(equalTo: topAnchor),
            card.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
        
        // Flame icon
        flameIcon.image = UIImage(systemName: "flame.fill")?.withRenderingMode(.alwaysTemplate)
        flameIcon.tintColor = UIColor(red: 0.843, green: 0.137, blue: 0.008, alpha: 1)
        flameIcon.contentMode = .scaleAspectFit
        
        // Streak title
        streakTitleLabel.text = "Overall Streak"
        streakTitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        streakTitleLabel.textColor = .secondaryLabel
        streakTitleLabel.textAlignment = .center
        
        // Streak number
        streakLabel.font = UIFont.boldSystemFont(ofSize: 48)
        streakLabel.textColor = UIColor(red: 0.843, green: 0.137, blue: 0.008, alpha: 1)
        streakLabel.textAlignment = .center
        
        // Check-in button
        checkInButton.setTitle("Daily Check-In", for: .normal)
        checkInButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        checkInButton.backgroundColor = UIColor(red: 0.843, green: 0.137, blue: 0.008, alpha: 1)
        checkInButton.setTitleColor(.white, for: .normal)
        checkInButton.layer.cornerRadius = 14
        checkInButton.addTarget(self, action: #selector(checkInTapped), for: .touchUpInside)
        
        // Layout
        let iconStack = UIStackView(arrangedSubviews: [flameIcon, streakLabel])
        iconStack.axis = .horizontal
        iconStack.alignment = .center
        iconStack.spacing = 12
        
        let contentStack = UIStackView(arrangedSubviews: [streakTitleLabel, iconStack, checkInButton])
        contentStack.axis = .vertical
        contentStack.alignment = .center
        contentStack.spacing = 12
        
        card.addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: card.layoutMarginsGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: card.layoutMarginsGuide.trailingAnchor),
            contentStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            contentStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
        
        flameIcon.widthAnchor.constraint(equalToConstant: 40).isActive = true
        flameIcon.heightAnchor.constraint(equalToConstant: 40).isActive = true
        checkInButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 200).isActive = true
        checkInButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    @objc private func checkInTapped() {
        // Animate button press
        UIView.animate(withDuration: 0.1, animations: {
            self.checkInButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.checkInButton.transform = .identity
            }
        }
        onCheckInTapped?()
    }
    
    func configure(overallStreak: Int) {
        streakLabel.text = "\(overallStreak)"
        
        // Animate flame icon based on streak
        let scale = 1.0 + (Double(min(overallStreak, 30)) / 100.0)
        UIView.animate(withDuration: 0.3) {
            self.flameIcon.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
        
        // Update flame brightness based on streak
        let alpha = max(0.6, min(1.0, Double(overallStreak) / 30.0))
        flameIcon.alpha = alpha
    }
}
