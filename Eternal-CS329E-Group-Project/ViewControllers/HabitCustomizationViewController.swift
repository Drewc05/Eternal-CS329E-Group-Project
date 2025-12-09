import UIKit

final class HabitCustomizationViewController: UIViewController {
    private let habit: Habit
    private let store = HabitStore.shared
    private var theme: Theme { ThemeManager.current(from: store.settings.themeKey) }
    private let scrollView = UIScrollView()
    private let gridStack = UIStackView()

    init(habit: Habit) {
        self.habit = habit
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Customize \(habit.name)"
        view.backgroundColor = theme.background
        ThemeManager.styleNavBar(navigationController?.navigationBar, theme: theme)

        setupLayout()
        loadOwnedColors()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleThemeChanged),
            name: NSNotification.Name("ThemeChanged"),
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        gridStack.axis = .vertical
        gridStack.spacing = 12
        gridStack.alignment = .fill
        gridStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(gridStack)

        NSLayoutConstraint.activate([
            gridStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            gridStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            gridStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            gridStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            gridStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }

    @objc private func handleThemeChanged() {
        view.backgroundColor = theme.background
        ThemeManager.styleNavBar(navigationController?.navigationBar, theme: theme)
        // Rebuild grid with new theme
        gridStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        loadOwnedColors()
    }

    private func loadOwnedColors() {
        let colors = store.getOwnedFlameColors()
        gridStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Determine currently selected per-habit color (if any)
        let currentHabit = store.habits.first(where: { $0.id == habit.id })
        let selectedID = currentHabit?.flameColorID

        for i in stride(from: 0, to: colors.count, by: 2) {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 12
            row.distribution = .fillEqually

            let left = createColorCard(for: colors[i], isSelected: selectedID == colors[i].id)
            row.addArrangedSubview(left)

            if i + 1 < colors.count {
                let right = createColorCard(for: colors[i + 1], isSelected: selectedID == colors[i + 1].id)
                row.addArrangedSubview(right)
            } else {
                let spacer = UIView()
                row.addArrangedSubview(spacer)
            }

            gridStack.addArrangedSubview(row)
        }
    }

    private func createColorCard(for color: FlameColor, isSelected: Bool) -> UIView {
        let card = UIView()
        card.backgroundColor = theme.card
        card.layer.cornerRadius = 12
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowOpacity = 0.08
        card.layer.shadowRadius = 4
        if isSelected {
            card.layer.borderWidth = 2
            card.layer.borderColor = (UIColor(hex: color.colorHex) ?? theme.primary).withAlphaComponent(0.5).cgColor
        }

        let icon = UIImageView(image: UIImage(systemName: "flame.fill"))
        icon.contentMode = .scaleAspectFit
        icon.tintColor = UIColor(hex: color.colorHex) ?? theme.primary

        let nameLabel = UILabel()
        nameLabel.text = color.name
        nameLabel.font = .boldSystemFont(ofSize: 16)
        nameLabel.textColor = theme.text
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 2

        let button = UIButton(type: .system)
        button.setTitle(isSelected ? "Selected" : "Choose", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.backgroundColor = isSelected ? theme.secondaryText.withAlphaComponent(0.3) : theme.primary
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.isEnabled = !isSelected
        button.tag = color.id.hashValue
        button.addTarget(self, action: #selector(selectColor(_:)), for: .touchUpInside)

        let v = UIStackView(arrangedSubviews: [icon, nameLabel, button])
        v.axis = .vertical
        v.alignment = .center
        v.spacing = 8

        card.addSubview(v)
        v.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            v.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            v.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            v.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            v.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            icon.widthAnchor.constraint(equalToConstant: 36),
            icon.heightAnchor.constraint(equalToConstant: 36),
            button.heightAnchor.constraint(equalToConstant: 34)
        ])

        return card
    }

    @objc private func selectColor(_ sender: UIButton) {
        let colors = store.getOwnedFlameColors()
        guard let color = colors.first(where: { $0.id.hashValue == sender.tag }) else { return }
        store.setFlameColor(color.id, for: habit.id)

        let alert = UIAlertController(title: "Flame Color Set", message: "\(color.name) applied to \(habit.name).", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}
