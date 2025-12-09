// Eternal-CS329E-Group-Project
// Group 15
// Created / Edits done by Ori Parks (lwp369)

import Foundation

// MARK: - Habit Model

struct Habit: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var icon: String
    var createdAt: Date
    var isExtinguished: Bool
    var lastCheckInDate: Date?
    var currentStreak: Int
    var bestStreak: Int
    var brightness: Double
    var flameColorID: UUID?
    
    init(id: UUID = UUID(), name: String, icon: String = "flame.fill", createdAt: Date = .now, isExtinguished: Bool = false, lastCheckInDate: Date? = nil, currentStreak: Int = 0, bestStreak: Int = 0, brightness: Double = 0.6, flameColorID: UUID? = nil) {
        self.id = id
        self.name = name
        self.icon = icon
        self.createdAt = createdAt
        self.isExtinguished = isExtinguished
        self.lastCheckInDate = lastCheckInDate
        self.currentStreak = currentStreak
        self.bestStreak = bestStreak
        self.brightness = brightness
        self.flameColorID = flameColorID
    }
}

// MARK: - Habit Entry

struct HabitEntry: Identifiable, Hashable, Codable {
    let id: UUID
    let habitID: UUID
    let date: Date
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

// MARK: - Currency Wallet

struct CurrencyWallet: Codable {
    var balance: Int
    var totalEarned: Int
    
    init(balance: Int = 0, totalEarned: Int = 0) {
        self.balance = balance
        self.totalEarned = totalEarned
    }
}

// MARK: - App Settings

struct AppSettings: Codable {
    var themeKey: String
    var notificationsEnabled: Bool
    var notificationHour: Int
    var notificationMinute: Int
    
    init(themeKey: String = "default", notificationsEnabled: Bool = false, notificationHour: Int = 20, notificationMinute: Int = 0) {
        self.themeKey = themeKey
        self.notificationsEnabled = notificationsEnabled
        self.notificationHour = notificationHour
        self.notificationMinute = notificationMinute
    }
}

// MARK: - Wager

struct Wager: Identifiable, Codable {
    let id: UUID
    var amount: Int
    var targetDays: Int
    var startDate: Date
    var endDate: Date
    var isActive: Bool
    var isWon: Bool?
    
    init(id: UUID = UUID(), amount: Int, targetDays: Int, startDate: Date = Date(), isActive: Bool = true, isWon: Bool? = nil) {
        self.id = id
        self.amount = amount
        self.targetDays = targetDays
        self.startDate = startDate
        self.endDate = Calendar.current.date(byAdding: .day, value: targetDays, to: startDate) ?? startDate
        self.isActive = isActive
        self.isWon = isWon
    }
}

// MARK: - Helper Extensions

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }
}
