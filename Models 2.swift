// Eternal-CS329E-Group-Project
// Group 15
// Created / Edits done by Ori Parks (lwp369)

import Foundation

// MARK: - Habit Model

struct Habit: Identifiable, Codable {
    let id: UUID
    var name: String
    var icon: String
    var currentStreak: Int
    var bestStreak: Int
    var brightness: Double
    var lastCheckInDate: Date?
    var isExtinguished: Bool
    
    init(id: UUID = UUID(), name: String, icon: String, currentStreak: Int = 0, bestStreak: Int = 0, brightness: Double = 0.5, lastCheckInDate: Date? = nil, isExtinguished: Bool = false) {
        self.id = id
        self.name = name
        self.icon = icon
        self.currentStreak = currentStreak
        self.bestStreak = bestStreak
        self.brightness = brightness
        self.lastCheckInDate = lastCheckInDate
        self.isExtinguished = isExtinguished
    }
}

// MARK: - Habit Entry

struct HabitEntry: Codable {
    let id: UUID
    let habitID: UUID
    let date: Date
    let didComplete: Bool
    let value: Double?
    let note: String?
    
    init(id: UUID = UUID(), habitID: UUID, date: Date, didComplete: Bool, value: Double? = nil, note: String? = nil) {
        self.id = id
        self.habitID = habitID
        self.date = date
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
    var notificationTime: Date?
    
    init(themeKey: String = "default", notificationsEnabled: Bool = true, notificationTime: Date? = nil) {
        self.themeKey = themeKey
        self.notificationsEnabled = notificationsEnabled
        self.notificationTime = notificationTime
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
}
