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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = theme.background
        
        // Hide the navigation bar title to save space
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Keep navigation bar hidden
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Load latest entries from Firebase
        store.loadEntriesFromFirebase { [weak self] in
            DispatchQueue.main.async {
                // Reload calendar decorations with fresh data
                self?.calendarView.reloadDecorations(forDateComponents: [], animated: true)
                print("📅 Calendar reloaded with Firebase data")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show navigation bar when leaving (for other screens)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func setupUI() {
        // Header card with stats - COMPACT
        let headerCard = UIView()
        headerCard.backgroundColor = theme.card
        headerCard.layer.cornerRadius = 16
        headerCard.layer.masksToBounds = false
        headerCard.layer.shadowColor = UIColor.black.cgColor
        headerCard.layer.shadowOffset = CGSize(width: 0, height: 2)
        headerCard.layer.shadowOpacity = 0.06
        headerCard.layer.shadowRadius = 4
        
        // Add decorative flame icon
        let flameIcon = UIImageView()
        flameIcon.image = UIImage(systemName: "flame.fill")
        flameIcon.tintColor = theme.primary
        flameIcon.contentMode = .scaleAspectFit
        
        selectedDateLabel = UILabel()
        selectedDateLabel.text = "Track Your Journey 🗓️"
        selectedDateLabel.font = .rounded(ofSize: 16, weight: .bold)
        selectedDateLabel.textColor = theme.text
        selectedDateLabel.textAlignment = .center
        selectedDateLabel.numberOfLines = 1
        
        statsLabel = UILabel()
        statsLabel.text = "Select a date to view your progress"
        statsLabel.font = .systemFont(ofSize: 13, weight: .regular)
        statsLabel.textColor = theme.secondaryText
        statsLabel.textAlignment = .center
        statsLabel.numberOfLines = 2
        
        let statsStack = UIStackView(arrangedSubviews: [flameIcon, selectedDateLabel, statsLabel])
        statsStack.axis = .vertical
        statsStack.spacing = 4
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
        
        // Calendar view - TALLER to show all days including day 30!
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
        
        // Legend - COMPACT
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
            
            // Optimized sizes - no nav bar means more space!
            headerCard.heightAnchor.constraint(equalToConstant: 85),
            calendarView.heightAnchor.constraint(equalToConstant: 420),
            legendStack.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    private func createLegend() -> UIView {
        let container = UIView()
        container.backgroundColor = theme.card
        container.layer.cornerRadius = 16
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowOpacity = 0.08
        container.layer.shadowRadius = 4
        
        let completedDot = createLegendItem(emoji: "🔥", label: "Completed Day")
        let incompleteDot = createLegendItem(emoji: "💤", label: "Missed Day")
        
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

    // MARK: - UICalendarViewDelegate
    
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        guard let date = Calendar.current.date(from: dateComponents)?.startOfDay else { return nil }
        
        // Check if any habit was completed on this day
        let entriesForDay = store.entriesByDay[date] ?? []
        let hasCompletedHabit = entriesForDay.contains { $0.didComplete }
        let hasIncompleteEntry = !entriesForDay.isEmpty && !hasCompletedHabit
        
        if hasCompletedHabit {
            return .default(color: UIColor(red: 0.2, green: 0.8, blue: 0.3, alpha: 1), size: .large)
        } else if hasIncompleteEntry {
            return .default(color: .systemGray4, size: .medium)
        }
        
        return nil
    }
    
    // MARK: - UICalendarSelectionSingleDateDelegate
    
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        guard let dateComponents = dateComponents,
              let selectedDate = Calendar.current.date(from: dateComponents) else {
            return
        }
        
        updateStats(for: selectedDate.startOfDay)
    }
    
    private func updateStats(for date: Date) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        selectedDateLabel.text = formatter.string(from: date)
        
        let entriesForDay = store.entriesByDay[date] ?? []
        
        if entriesForDay.isEmpty {
            statsLabel.text = "No activity recorded 📭"
        } else {
            let completed = entriesForDay.filter { $0.didComplete }.count
            let total = entriesForDay.count
            
            if completed == total {
                statsLabel.text = "🔥 Perfect day! \(completed) of \(total) habits completed!"
            } else if completed > 0 {
                statsLabel.text = "✨ \(completed) of \(total) habits completed"
            } else {
                statsLabel.text = "💤 No habits completed"
            }
        }
        
        // Animate the update with a pulse effect
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
}

