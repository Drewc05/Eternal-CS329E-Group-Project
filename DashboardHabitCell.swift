// Eternal-CS329E-Group-Project
// Group 15
// Created / Edits done by Ori Parks (lwp369)

import UIKit

final class DashboardHabitCell: UITableViewCell {
    static let reuseID = "DashboardHabitCell"

    private let card = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let streakLabel = UILabel()

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
        iconView.alpha = CGFloat(max(0.2, min(1.0, habit.brightness)))
        // subtle scale effect by brightness
        let scale = CGFloat(0.95 + 0.1 * habit.brightness)
        iconView.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
}
