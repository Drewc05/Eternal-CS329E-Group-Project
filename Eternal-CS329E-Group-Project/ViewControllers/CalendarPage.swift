//
//  Calendar.swift
//  Eternal-CS329E-Group-Project
//
//  Created by Colin Day on 10/20/25.
//

//
//  Calendar.swift
//  Eternal-CS329E-Group-Project
//
//  Created by Colin Day on 10/20/25.
//

//
//  Calendar.swift
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
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupUI()
        
        if let firstHabit = store.habits.first {
            selectedHabit = firstHabit
            updateHabitPickerButton()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
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
    
    private func setupUI() {
        let headerCard = UIView()
        headerCard.backgroundColor = theme.card
        headerCard.layer.cornerRadius = 16
        headerCard.layer.masksToBounds = false
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
        habitPickerButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        habitPickerButton.addTarget(self, action: #selector(showHabitPicker), for: .touchUpInside)
        
        let flameIcon = UIImageView()
        flameIcon.image = UIImage(systemName: "calendar")
        flameIcon.tintColor = theme.primary
        flameIcon.contentMode = .scaleAspectFit
        
        selectedDateLabel = UILabel()
        selectedDateLabel.text = "Select a date"
        selectedDateLabel.font = .rounded(ofSize: 16, weight: .semibold)
        selectedDateLabel.textColor = theme.text
        selectedDateLabel.textAlignment = .center
        selectedDateLabel.numberOfLines = 1
        
        statsLabel = UILabel()
        statsLabel.text = "Choose a habit to view calendar"
        statsLabel.font = .systemFont(ofSize: 13, weight: .regular)
        statsLabel.textColor = theme.secondaryText
        statsLabel.textAlignment = .center
        statsLabel.numberOfLines = 0
        statsLabel.lineBreakMode = .byWordWrapping
        
        let statsStack = UIStackView(arrangedSubviews: [flameIcon, habitPickerButton, selectedDateLabel, statsLabel])
        statsStack.axis = .vertical
        statsStack.spacing = 8
        statsStack.alignment = .center
        
        headerCard.addSubview(statsStack)
        statsStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            statsStack.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 16),
            statsStack.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -16),
            statsStack.topAnchor.constraint(equalTo: headerCard.topAnchor, constant: 12),
            statsStack.bottomAnchor.constraint(equalTo: headerCard.bottomAnchor, constant: -12),
            flameIcon.widthAnchor.constraint(equalToConstant: 24),
            flameIcon.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        calendarView = UICalendarView()
        calendarView.calendar = Calendar.current
        calendarView.locale = Locale.autoupdatingCurrent
        calendarView.backgroundColor = theme.card
        calendarView.layer.cornerRadius = 16
        calendarView.layer.masksToBounds = true
        calendarView.delegate = self
        
        let dateSelection = UICalendarSelectionSingleDate(delegate: self)
        calendarView.selectionBehavior = dateSelection
        
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        
        let legendStack = createLegend()
        
        let mainStack = UIStackView(arrangedSubviews: [headerCard, calendarView, legendStack])
        mainStack.axis = .vertical
        mainStack.spacing = 12
        
        view.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            mainStack.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            
            headerCard.heightAnchor.constraint(greaterThanOrEqualToConstant: 140),
            calendarView.heightAnchor.constraint(equalToConstant: 380),
            legendStack.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    @objc private func showHabitPicker() {
        let alert = UIAlertController(title: "Select Habit", message: "Choose which habit to view", preferredStyle: .actionSheet)
        
        for habit in store.habits where !habit.isExtinguished {
            let action = UIAlertAction(title: habit.name, style: .default) { [weak self] _ in
                self?.selectedHabit = habit
                self?.updateHabitPickerButton()
                self?.calendarView.reloadDecorations(forDateComponents: [], animated: true)
                self?.selectedDateLabel.text = "Select a date"
                self?.statsLabel.text = "Tap a day to see details for \(habit.name)"
            }
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = habitPickerButton
            popoverController.sourceRect = habitPickerButton.bounds
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
    
    private func createLegend() -> UIView {
        let container = UIView()
        container.backgroundColor = theme.card
        container.layer.cornerRadius = 16
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowOpacity = 0.08
        container.layer.shadowRadius = 4
        
        let completedDot = createLegendItem(emoji: "🔥", label: "Completed")
        let incompleteDot = createLegendItem(emoji: "💤", label: "Missed")
        
        let stack = UIStackView(arrangedSubviews: [completedDot, incompleteDot])
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

    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        guard let habit = selectedHabit,
              let date = Calendar.current.date(from: dateComponents)?.startOfDay else {
            return nil
        }
        
        let entriesForDay = store.entriesByDay[date] ?? []
        let habitEntry = entriesForDay.first { $0.habitID == habit.id }
        
        if let entry = habitEntry {
            if entry.didComplete {
                return .default(color: UIColor(red: 0.2, green: 0.8, blue: 0.3, alpha: 1), size: .large)
            } else {
                return .default(color: .systemGray4, size: .medium)
            }
        }
        
        return nil
    }
    
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        guard let dateComponents = dateComponents,
              let selectedDate = Calendar.current.date(from: dateComponents),
              let habit = selectedHabit else {
            return
        }
        
        updateStats(for: selectedDate.startOfDay, habit: habit)
    }
    
    private func updateStats(for date: Date, habit: Habit) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        selectedDateLabel.text = formatter.string(from: date)
        
        
        
        let entriesForDay = store.entriesByDay[date] ?? []
        
        
        for (index, e) in entriesForDay.enumerated() {
        
        }
        
        let habitEntry = entriesForDay.first { $0.habitID == habit.id }
        
        
        if let entry = habitEntry {
            
            
            let streakAtDate = calculateStreakAt(date: date, for: habit)
            
            var statusText = ""
            if entry.didComplete {
                statusText = "🔥 \(habit.name) - Completed!\n"
                statusText += "Streak: \(streakAtDate) day\(streakAtDate == 1 ? "" : "s")"
            } else {
                statusText = "💤 \(habit.name) - Missed\n"
                statusText += "Streak: \(streakAtDate) day\(streakAtDate == 1 ? "" : "s")"
            }
            
            if let value = entry.value, value > 0 {
                statusText += "\n\n📊 Value: \(Int(value))"
            }
            
            // Debug the note logic
            
            if let note = entry.note {
                if !note.isEmpty {
                    statusText += "\n\n📝 Note: \(note)"
                } else {
                    print("  Note is empty, showing 'No notes'")
                    statusText += "\n\n📝 No notes"
                }
            } else {
                print("  Note is nil, showing 'No notes'")
                statusText += "\n\n📝 No notes"
            }
            
            print("Final statusText: '\(statusText)'")
            statsLabel.text = statusText
            
        } else {
            statsLabel.text = "📭 No entry for \(habit.name) on this day"
        }
        print("=== END DEBUG ===\n")
        
        UIView.animate(withDuration: 0.15) {
            self.statsLabel.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.statsLabel.alpha = 0.5
        } completion: { _ in
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [], animations: {
                self.statsLabel.transform = .identity
                self.statsLabel.alpha = 1
            })
        }
    }
    private func calculateStreakAt(date: Date, for habit: Habit) -> Int {
        let sortedDates = store.entriesByDay.keys
            .filter { $0 <= date }
            .sorted()
        
        var streak = 0
        var lastDate: Date?
        
        for checkDate in sortedDates.reversed() {
            let entries = store.entriesByDay[checkDate] ?? []
            guard let entry = entries.first(where: { $0.habitID == habit.id }) else {
                break
            }
            
            if entry.didComplete {
                if let last = lastDate {
                    let daysBetween = Calendar.current.dateComponents([.day], from: checkDate, to: last).day ?? 0
                    if daysBetween == 1 {
                        streak += 1
                        lastDate = checkDate
                    } else {
                        break
                    }
                } else {
                    streak = 1
                    lastDate = checkDate
                }
            } else {
                break
            }
        }
        
        return streak
    }
}
