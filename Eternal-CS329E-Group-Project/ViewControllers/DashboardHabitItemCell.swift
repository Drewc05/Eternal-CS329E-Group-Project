import UIKit

final class DashboardHabitItemCell: UICollectionViewCell {
    static let reuseID = "DashboardHabitItemCell"

    private let card = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let streakLabel = UILabel()

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

        card.backgroundColor = UIColor(white: 1.0, alpha: 0.9)
        card.layer.cornerRadius = 16
        card.layer.masksToBounds = true

        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = UIColor(red: 0.843, green: 0.137, blue: 0.008, alpha: 1)

        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1

        streakLabel.font = .preferredFont(forTextStyle: .subheadline)
        streakLabel.textColor = .secondaryLabel

        contentView.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            card.topAnchor.constraint(equalTo: contentView.topAnchor),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        let vstack = UIStackView(arrangedSubviews: [iconView, titleLabel, streakLabel])
        vstack.axis = .vertical
        vstack.alignment = .leading
        vstack.spacing = 6

        card.addSubview(vstack)
        vstack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vstack.leadingAnchor.constraint(equalTo: card.layoutMarginsGuide.leadingAnchor),
            vstack.trailingAnchor.constraint(equalTo: card.layoutMarginsGuide.trailingAnchor),
            vstack.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            vstack.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -12)
        ])

        iconView.widthAnchor.constraint(equalToConstant: 28).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 28).isActive = true
    }

    func configure(with habit: Habit) {
        titleLabel.text = habit.name
        streakLabel.text = "Streak: \(habit.currentStreak)"
        let base = UIImage(systemName: habit.icon) ?? UIImage(systemName: "flame.fill")
        iconView.image = base?.withRenderingMode(.alwaysTemplate)
        iconView.alpha = CGFloat(max(0.2, min(1.0, habit.brightness)))
        let scale = CGFloat(0.95 + 0.1 * habit.brightness)
        iconView.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
}
