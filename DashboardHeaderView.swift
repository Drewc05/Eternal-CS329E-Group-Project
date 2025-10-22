// Eternal-CS329E-Group-Project
// Group 15
// Created / Edits done by Ori Parks (lwp369)

import UIKit

final class DashboardHeaderView: UICollectionReusableView {
    static let reuseID = "DashboardHeaderView"

    private let container = UIView()
    private let streakLabel = UILabel()
    private let checkInButton = UIButton(type: .system)

    var onCheckInTapped: (() -> Void)?

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

        container.backgroundColor = UIColor(white: 1.0, alpha: 0.92)
        container.layer.cornerRadius = 18
        container.layer.masksToBounds = true

        streakLabel.font = .boldSystemFont(ofSize: 24)
        streakLabel.textColor = .label
        streakLabel.text = "Streak: 0"

        checkInButton.setTitle("Daily Check-In", for: .normal)
        checkInButton.setTitleColor(.white, for: .normal)
        checkInButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        checkInButton.backgroundColor = UIColor(red: 0.843, green: 0.137, blue: 0.008, alpha: 1)
        checkInButton.layer.cornerRadius = 12
        checkInButton.addTarget(self, action: #selector(checkInTapped), for: .touchUpInside)

        addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            container.topAnchor.constraint(equalTo: topAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        let h = UIStackView(arrangedSubviews: [streakLabel, UIView(), checkInButton])
        h.axis = .horizontal
        h.alignment = .center
        h.spacing = 12

        container.addSubview(h)
        h.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            h.leadingAnchor.constraint(equalTo: container.layoutMarginsGuide.leadingAnchor),
            h.trailingAnchor.constraint(equalTo: container.layoutMarginsGuide.trailingAnchor),
            h.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            h.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
            checkInButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 140),
            checkInButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    @objc private func checkInTapped() {
        onCheckInTapped?()
    }

    func configure(overallStreak: Int) {
        streakLabel.text = "Streak: \(overallStreak)"
    }
}
