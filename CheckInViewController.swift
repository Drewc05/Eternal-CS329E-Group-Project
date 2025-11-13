// Eternal-CS329E-Group-Project
// Group 15
// Created / Edits done by Ori Parks (lwp369)

import UIKit

final class CheckInViewController: UIViewController {

    private var habit: Habit
    private let store = HabitStore.shared
    var onFinished: (() -> Void)?

    init(habit: Habit) {
        self.habit = habit
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private let questionLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Did you do your habit today?"
        lbl.font = .preferredFont(forTextStyle: .title2)
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        return lbl
    }()

    private let yesButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Yes", for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 18)
        btn.backgroundColor = UIColor(red: 0.843, green: 0.137, blue: 0.008, alpha: 1)
        btn.tintColor = .white
        btn.layer.cornerRadius = 12
        return btn
    }()

    private let noButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("No", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18)
        btn.backgroundColor = .secondarySystemBackground
        btn.tintColor = .label
        btn.layer.cornerRadius = 12
        return btn
    }()

    private let notesField: UITextView = {
        let tv = UITextView()
        tv.font = .preferredFont(forTextStyle: .body)
        tv.layer.cornerRadius = 8
        tv.backgroundColor = .secondarySystemBackground
        tv.text = "Notes (optional)"
        tv.textColor = .secondaryLabel
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = habit.name
        view.backgroundColor = UIColor(red: 0.953, green: 0.918, blue: 0.859, alpha: 1)

        let buttons = UIStackView(arrangedSubviews: [yesButton, noButton])
        buttons.axis = .horizontal
        buttons.spacing = 16
        buttons.distribution = .fillEqually

        let stack = UIStackView(arrangedSubviews: [questionLabel, buttons, notesField])
        stack.axis = .vertical
        stack.spacing = 16

        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            notesField.heightAnchor.constraint(equalToConstant: 150)
        ])

        yesButton.addTarget(self, action: #selector(yesTapped), for: .touchUpInside)
        noButton.addTarget(self, action: #selector(noTapped), for: .touchUpInside)
    }

    @objc private func yesTapped() {
        let note = notesField.textColor == .secondaryLabel ? nil : notesField.text
        // Compute next streak to estimate reward
        if let idx = store.habits.firstIndex(where: { $0.id == habit.id }) {
            let current = store.habits[idx]
            let nextStreak: Int
            if let last = current.lastCheckInDate, Calendar.current.isDate(last.addingTimeInterval(24*60*60), inSameDayAs: Date()) {
                nextStreak = current.currentStreak + 1
            } else if current.lastCheckInDate == nil || !Calendar.current.isDate(current.lastCheckInDate!, inSameDayAs: Date()) {
                nextStreak = 1
            } else {
                nextStreak = current.currentStreak
            }
            let reward = store.estimateReward(forStreak: nextStreak)
            store.checkIn(habitID: habit.id, didComplete: true, note: note)
            showRewardToast(points: reward)
        } else {
            store.checkIn(habitID: habit.id, didComplete: true, note: note)
            showRewardToast(points: 10)
        }
    }

    @objc private func noTapped() {
        let note = notesField.textColor == .secondaryLabel ? nil : notesField.text
        store.checkIn(habitID: habit.id, didComplete: false, note: note)
        navigationController?.popViewController(animated: true)
        onFinished?()
    }

    private func showRewardToast(points: Int) {
        // Celebrate with emojis for milestone streaks
        if let idx = store.habits.firstIndex(where: { $0.id == habit.id }) {
            let streak = store.habits[idx].currentStreak
            if streak % 7 == 0 && streak > 0 {
                AnimationUtility.celebrateWithEmojis(in: view)
            }
        }
        
        let toast = UILabel()
        toast.text = "+\(points) coins"
        toast.font = .boldSystemFont(ofSize: 16)
        toast.textColor = .white
        toast.textAlignment = .center
        toast.backgroundColor = UIColor(red: 0.843, green: 0.137, blue: 0.008, alpha: 1)
        toast.layer.cornerRadius = 12
        toast.layer.masksToBounds = true

        view.addSubview(toast)
        toast.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            toast.widthAnchor.constraint(greaterThanOrEqualToConstant: 140),
            toast.heightAnchor.constraint(equalToConstant: 44)
        ])

        // Use bounce animation
        AnimationUtility.bounceIn(toast, duration: 0.5)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            AnimationUtility.fadeOut(toast, duration: 0.3) { [weak self] in
                self?.navigationController?.popViewController(animated: true)
                self?.onFinished?()
            }
        }
    }
}
