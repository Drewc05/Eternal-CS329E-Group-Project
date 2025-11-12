// Eternal-CS329E-Group-Project
// Group 15
// Created / Edits done by Ori Parks (lwp369)

import Foundation

struct Habit: Identifiable, Hashable {
    let id: UUID
    var name: String
    var icon: String // SF Symbol name for now
    var createdAt: Date
    var isExtinguished: Bool
    var lastCheckInDate: Date?
    var currentStreak: Int
    var bestStreak: Int
    var brightness: Double // 0.2 ... 1.0

    init(id: UUID = UUID(), name: String, icon: String = "flame.fill", createdAt: Date = .now, isExtinguished: Bool = false, lastCheckInDate: Date? = nil, currentStreak: Int = 0, bestStreak: Int = 0, brightness: Double = 0.6) {
        self.id = id
        self.name = name
        self.icon = icon
        self.createdAt = createdAt
        self.isExtinguished = isExtinguished
        self.lastCheckInDate = lastCheckInDate
        self.currentStreak = currentStreak
        self.bestStreak = bestStreak
        self.brightness = brightness
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case icon
        case createdAt
        case isExtinguished
        case lastCheckInDate
        case currentStreak
        case bestStreak
        case brightness
    }
}

struct HabitEntry: Identifiable, Hashable {
    let id: UUID
    let habitID: UUID
    let date: Date // normalized to start of day
    var didComplete: Bool
    var value: Double?
    var note: String?

    init(id: UUID = UUID(), habitID: UUID, date: Date, didComplete: Bool, value: Double? = nil, note: String? = nil) {
        self.id = id
        self.habitID = habitID
        self.date = Calendar.current.startOfDay(for: date)
        self.didComplete = didComplete
        self.value = value
        self.note = note
    }
}

struct CurrencyWallet {
    var balance: Int = 0
    var totalEarned: Int = 0
}

struct AppSettings {
    var themeKey: String = "default"
    var notificationsEnabled: Bool = true
}

extension Date {
    var startOfDay: Date { Calendar.current.startOfDay(for: self) }
    func isSameDay(as other: Date) -> Bool { Calendar.current.isDate(self, inSameDayAs: other) }
}
