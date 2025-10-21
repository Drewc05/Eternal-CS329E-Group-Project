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
        self.view.backgroundColor = UIColor(red: 0.953, green: 0.918, blue: 0.859, alpha: 1)
        
        let calendarView = UICalendarView()
        setupCalendarView(calendarView: calendarView)
        
    }
    
    private func setupCalendarView(calendarView: UICalendarView){
        calendarView.calendar = Calendar.current
        calendarView.locale = Locale.autoupdatingCurrent
        
        self.view.addSubview(calendarView)
        
        calendarView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    calendarView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                    calendarView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                    calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                    calendarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
                ])
    }


}
