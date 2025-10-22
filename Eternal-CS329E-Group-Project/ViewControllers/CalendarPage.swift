//
//  Calendar.swift
//  Eternal-CS329E-Group-Project
//
//  Created by Colin Day on 10/20/25.
//

import SwiftUI

class CalendarPage: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let theme = ThemeManager.current(from: HabitStore.shared.settings.themeKey)
        self.view.backgroundColor = theme.background
        self.title = "Calendar"
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never

        let calendarView = UICalendarView()
        setupCalendarView(calendarView: calendarView)
    }

    private func setupCalendarView(calendarView: UICalendarView){
        calendarView.calendar = Calendar.current
        calendarView.locale = Locale.autoupdatingCurrent
        calendarView.backgroundColor = .clear

        self.view.addSubview(calendarView)
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            calendarView.topAnchor.constraint(equalTo: view.topAnchor),
            calendarView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

