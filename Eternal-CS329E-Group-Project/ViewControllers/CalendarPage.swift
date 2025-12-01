//
//  CalendarPage.swift
//  Eternal-CS329E-Group-Project
//
//  Created by Colin Day on 10/20/25.
//

import SwiftUI
import UIKit

class CalendarPage: UIViewController, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
    
    private let store = HabitStore.shared
    private var theme: Theme { ThemeManager.current(from: store.settings.themeKey) }
    private var calendarView: UICalendarView!
    private var selectedDateLabel: UILabel!
    private var statsLabel: UILabel!
    private var habitPickerButton: UIButton!
    private var selectedHabit: Habit?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = theme.background
        self.title = "Calendar"
        
        let titleLabel = UILabel()
        titleLabel.text = "Calendar"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 34)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label
        navigationItem.titleView = titleLabel
        
        
        //navigationController?.setNavigationBarHidden(true, animated: false)
        setupUI()
        
        if let firstHabit = store.habits.first {
            selectedHabit = firstHabit
            updateHabitPickerButton()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //navigationController?.setNavigationBarHidden(true, animated: false)
        
        store.loadEntriesFromFirebase { [weak self] in
            DispatchQueue.main.async {
                self?.calendarView.reloadDecorations(forDateComponents: [], animated: true)
                print("📅 Calendar reloaded with Firebase data")
                
                if self?.selectedHabit == nil, let firstHabit = self?.store.habits.first {
                    self?.selectedHabit = firstHabit
                    self?.updateHabitPickerButton()
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Content container inside scrollView
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            // Critical: contentView must match scrollView width
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        
        // Header Card (top stats + habit picker)
        let headerCard = UIView()
        headerCard.backgroundColor = theme.card
        headerCard.layer.cornerRadius = 16
        headerCard.layer.shadowColor = UIColor.black.cgColor
        headerCard.layer.shadowOffset = CGSize(width: 0, height: 2)
        headerCard.layer.shadowOpacity = 0.06
        headerCard.layer.shadowRadius = 4
        
        habitPickerButton = UIButton(type: .system)
        habitPickerButton.setTitle("Select Habit", for: .normal)
        habitPickerButton.titleLabel?.font = .rounded(ofSize: 18, weight: .bold)
        habitPickerButton.setTitleColor(.white, for: .normal)
        habitPickerButton.backgroundColor = theme.primary
        habitPickerButton.layer.cornerRadius = 12
        habitPickerButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        habitPickerButton.addTarget(self, action: #selector(showHabitPicker), for: .touchUpInside)
        
        let flameIcon = UIImageView(image: UIImage(systemName: "calendar"))
        flameIcon.tintColor = theme.primary
        flameIcon.contentMode = .scaleAspectFit
        
        selectedDateLabel = UILabel()
        selectedDateLabel.text = "Select a date"
        selectedDateLabel.font = .rounded(ofSize: 16, weight: .semibold)
        selectedDateLabel.textColor = theme.text
        selectedDateLabel.textAlignment = .center
        
        statsLabel = UILabel()
        statsLabel.text = "Choose a habit to view calendar"
        statsLabel.font = .systemFont(ofSize: 13)
        statsLabel.textColor = theme.secondaryText
        statsLabel.textAlignment = .center
        statsLabel.numberOfLines = 0
        
        let statsStack = UIStackView(arrangedSubviews: [flameIcon, habitPickerButton, selectedDateLabel, statsLabel])
        statsStack.axis = .vertical
        statsStack.spacing = 8
        statsStack.alignment = .center
        
        headerCard.addSubview(statsStack)
        statsStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            statsStack.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 16),
            statsStack.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -16),
            statsStack.topAnchor.constraint(equalTo: headerCard.topAnchor, constant: 8),
            statsStack.bottomAnchor.constraint(equalTo: headerCard.bottomAnchor, constant: -8),
            flameIcon.widthAnchor.constraint(equalToConstant: 24),
            flameIcon.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        // Calendar
        calendarView = UICalendarView()
        calendarView.calendar = Calendar.current
        calendarView.locale = Locale.autoupdatingCurrent
        calendarView.backgroundColor = theme.card
        calendarView.layer.cornerRadius = 16
        calendarView.delegate = self
        calendarView.selectionBehavior = UICalendarSelectionSingleDate(delegate: self)
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.setContentHuggingPriority(.defaultLow, for: .vertical)
        calendarView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        let legendStack = createLegend()
        
        // Main vertical stack
        let mainStack = UIStackView(arrangedSubviews: [headerCard, calendarView])
        mainStack.axis = .vertical
        mainStack.spacing = 12
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            headerCard.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
            legendStack.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    // MARK: - Habit Picker
    @objc private func showHabitPicker() {
        let alert = UIAlertController(title: "Select Habit", message: "Choose which habit to view", preferredStyle: .actionSheet)
        
        for habit in store.habits where !habit.isExtinguished {
            alert.addAction(UIAlertAction(title: habit.name, style: .default) { [weak self] _ in
                self?.selectedHabit = habit
                self?.updateHabitPickerButton()
                self?.calendarView.reloadDecorations(forDateComponents: [], animated: true)
                self?.selectedDateLabel.text = "Select a date"
                self?.statsLabel.text = "Tap a day to see details for \(habit.name)"
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = habitPickerButton
            popover.sourceRect = habitPickerButton.bounds
        }
        
        present(alert, animated: true)
    }
    
    private func updateHabitPickerButton() {
        if let habit = selectedHabit {
            let icon = UIImage(systemName: habit.icon)
            habitPickerButton.setTitle("  \(habit.name)", for: .normal)
            habitPickerButton.setImage(icon, for: .normal)
            habitPickerButton.tintColor = .white
            statsLabel.text = "Tap a day to see details for \(habit.name)"
        } else {
            habitPickerButton.setTitle("Select Habit", for: .normal)
            habitPickerButton.setImage(nil, for: .normal)
            statsLabel.text = "Choose a habit to view calendar"
        }
    }
    
    // MARK: - Legend
    
    private func createLegend() -> UIView {
        let container = UIView()
        container.backgroundColor = theme.card
        container.layer.cornerRadius = 16
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowOpacity = 0.08
        container.layer.shadowRadius = 4
        
        let completed = createLegendItem(emoji: "🔥", label: "Completed")
        let missed = createLegendItem(emoji: "💤", label: "Missed")
        
        let stack = UIStackView(arrangedSubviews: [completed, missed])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 16
        
        container.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            stack.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }
    
    private func createLegendItem(emoji: String, label: String) -> UIView {
        let emojiLabel = UILabel()
        emojiLabel.text = emoji
        emojiLabel.font = .systemFont(ofSize: 24)
        
        let lbl = UILabel()
        lbl.text = label
        lbl.font = .systemFont(ofSize: 14, weight: .medium)
        lbl.textColor = theme.text
        
        let stack = UIStackView(arrangedSubviews: [emojiLabel, lbl])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }
    
    // MARK: - Calendar Delegate
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        guard let habit = selectedHabit,
              let date = Calendar.current.date(from: dateComponents)?.startOfDay else { return nil }
        
        let entries = store.entriesByDay[date] ?? []
        guard let entry = entries.first(where: { $0.habitID == habit.id }) else { return nil }
        
        return entry.didComplete
        ? .default(color: UIColor.systemGreen, size: .large)
        : .default(color: .systemGray4, size: .medium)
    }
    
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        guard let comp = dateComponents,
              let date = Calendar.current.date(from: comp),
              let habit = selectedHabit else { return }
        updateStats(for: date.startOfDay, habit: habit)
    }
    
    // MARK: - Stats update
    private func updateStats(for date: Date, habit: Habit) {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        selectedDateLabel.text = fmt.string(from: date)
        
        let entries = store.entriesByDay[date] ?? []
        guard let entry = entries.first(where: { $0.habitID == habit.id }) else {
            statsLabel.text = "📭 No entry for \(habit.name) on this day"
            return
        }
        
        let streak = calculateStreakAt(date: date, for: habit)
        var status = entry.didComplete
        ? "🔥 \(habit.name) - Completed!\nStreak: \(streak) day\(streak == 1 ? "" : "s")"
        : "💤 \(habit.name) - Missed\nStreak: \(streak) day\(streak == 1 ? "" : "s")"
        
        if let value = entry.value, value > 0 {
            status += "\n\n📊 Value: \(Int(value))"
        }
        
        if let note = entry.note, !note.isEmpty {
            status += "\n\n📝 Note: \(note)"
        } else {
            status += "\n\n📝 No notes"
        }
        
        statsLabel.text = status
    }
    
    private func calculateStreakAt(date: Date, for habit: Habit) -> Int {
        let sortedDates = store.entriesByDay.keys.filter { $0 <= date }.sorted()
        var streak = 0
        var lastDate: Date?
        
        for checkDate in sortedDates.reversed() {
            guard let entry = store.entriesByDay[checkDate]?.first(where: { $0.habitID == habit.id }) else { break }
            if entry.didComplete {
                if let last = lastDate {
                    let daysBetween = Calendar.current.dateComponents([.day], from: checkDate, to: last).day ?? 0
                    if daysBetween == 1 {
                        streak += 1
                        lastDate = checkDate
                    } else { break }
                } else {
                    streak = 1
                    lastDate = checkDate
                }
            } else { break }
        }
        return streak
    }
}
