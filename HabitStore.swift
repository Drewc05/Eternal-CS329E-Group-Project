// Eternal-CS329E-Group-Project
// Group 15
// Created / Edits done by Ori Parks (lwp369)

import Foundation

final class HabitStore {
    static let shared = HabitStore()

    private let defaults = UserDefaults.standard
    private enum Keys {
        static let walletBalance = "wallet.balance"
        static let walletTotal = "wallet.total"
        static let themeKey = "settings.themeKey"
        static let notifications = "settings.notifications"
        static let freezes = "inventory.freezes"
        static let multiplierUntil = "inventory.multiplierUntil"
    }

    private(set) var habits: [Habit] = []
    private(set) var entriesByDay: [Date: [HabitEntry]] = [:]
    private(set) var wallet = CurrencyWallet()
    private(set) var settings = AppSettings()

    // Inventory (in-memory)
    private(set) var streakFreezesOwned: Int = 0
    private(set) var activeMultiplierUntil: Date? = nil

    private init() {
        // Seed with a couple of sample habits for now
        habits = [
            Habit(name: "Make Bed", icon: "bed.double.fill", brightness: 0.8),
            Habit(name: "Walk", icon: "figure.walk", brightness: 0.5)
        ]

        wallet.balance = defaults.integer(forKey: Keys.walletBalance)
        wallet.totalEarned = defaults.integer(forKey: Keys.walletTotal)
        settings.themeKey = defaults.string(forKey: Keys.themeKey) ?? settings.themeKey
        settings.notificationsEnabled = defaults.object(forKey: Keys.notifications) as? Bool ?? settings.notificationsEnabled
        streakFreezesOwned = defaults.integer(forKey: Keys.freezes)
        if let ts = defaults.object(forKey: Keys.multiplierUntil) as? TimeInterval {
            activeMultiplierUntil = Date(timeIntervalSince1970: ts)
        }
    }

    // Habit CRUD
    func addHabit(name: String, icon: String) {
        let habit = Habit(name: name, icon: icon)
        habits.append(habit)
    }

    func extinguishHabit(id: UUID) {
        guard let idx = habits.firstIndex(where: { $0.id == id }) else { return }
        habits[idx].isExtinguished = true
    }

    // Check-ins
    func entry(for habitID: UUID, on day: Date = Date().startOfDay) -> HabitEntry? {
        entriesByDay[day]?.first(where: { $0.habitID == habitID })
    }

    func checkIn(habitID: UUID, didComplete: Bool, value: Double? = nil, note: String? = nil, on day: Date = Date()) {
        let day = day.startOfDay
        let entry = HabitEntry(habitID: habitID, date: day, didComplete: didComplete, value: value, note: note)

        if var dayEntries = entriesByDay[day], let idx = dayEntries.firstIndex(where: { $0.habitID == habitID }) {
            // Update existing
            dayEntries[idx] = entry
            entriesByDay[day] = dayEntries
        } else {
            entriesByDay[day, default: []].append(entry)
        }

        updateStreaksAndRewards(for: habitID, didComplete: didComplete, on: day)
        persist()
    }

    func pendingHabitsForToday() -> [Habit] {
        let today = Date().startOfDay
        let completedIDs: Set<UUID> = Set(entriesByDay[today]?.filter { $0.didComplete }.map { $0.habitID } ?? [])
        return habits.filter { !completedIDs.contains($0.id) && !$0.isExtinguished }
    }

    // Logic
    private func updateStreaksAndRewards(for habitID: UUID, didComplete: Bool, on day: Date) {
        guard let idx = habits.firstIndex(where: { $0.id == habitID }) else { return }
        var habit = habits[idx]

        if didComplete {
            if let last = habit.lastCheckInDate, Calendar.current.isDate(last.addingTimeInterval(24*60*60), inSameDayAs: day) {
                habit.currentStreak += 1
            } else if habit.lastCheckInDate == nil || !Calendar.current.isDate(habit.lastCheckInDate!, inSameDayAs: day) {
                habit.currentStreak = 1
            }
            habit.bestStreak = max(habit.bestStreak, habit.currentStreak)
            habit.brightness = min(1.0, habit.brightness + 0.15)
            habit.lastCheckInDate = day
            wallet.balance += rewardForCheckIn(streak: habit.currentStreak)
            wallet.totalEarned += rewardForCheckIn(streak: habit.currentStreak)
        } else {
            // Missed: try to consume a freeze to preserve streak
            if useStreakFreezeIfAvailable() {
                // Preserve streak and brightness; record entry only
            } else {
                habit.brightness = max(0.2, habit.brightness - 0.1)
                // Optionally reset overall streak logic here if implemented
            }
        }

        habits[idx] = habit
        persist()
    }

    private func rewardForCheckIn(streak: Int) -> Int {
        var base = 10 + min(10, streak)
        if isMultiplierActive() { base = Int(Double(base) * 1.5) }
        return base
    }

    func estimateReward(forStreak streak: Int) -> Int {
        return rewardForCheckIn(streak: streak)
    }

    func addStreakFreeze(count: Int = 1) {
        streakFreezesOwned += count
        persist()
    }

    func useStreakFreezeIfAvailable() -> Bool {
        if streakFreezesOwned > 0 {
            streakFreezesOwned -= 1
            persist()
            return true
        } else {
            return false
        }
    }

    func activateMultiplier(hours: Int = 24) {
        activeMultiplierUntil = Date().addingTimeInterval(TimeInterval(hours * 3600))
        persist()
    }

    func isMultiplierActive(now: Date = Date()) -> Bool {
        if let until = activeMultiplierUntil { return now < until } else { return false }
    }

    func setThemeKey(_ key: String) {
        settings.themeKey = key
        persist()
    }

    func setNotificationsEnabled(_ enabled: Bool) {
        settings.notificationsEnabled = enabled
        persist()
    }

    @discardableResult
    func spendCoins(_ amount: Int) -> Bool {
        guard amount > 0, wallet.balance >= amount else { return false }
        wallet.balance -= amount
        persist()
        return true
    }

    func addCoins(_ amount: Int) {
        guard amount > 0 else { return }
        wallet.balance += amount
        wallet.totalEarned += amount
        persist()
    }

    private func persist() {
        defaults.set(wallet.balance, forKey: Keys.walletBalance)
        defaults.set(wallet.totalEarned, forKey: Keys.walletTotal)
        defaults.set(settings.themeKey, forKey: Keys.themeKey)
        defaults.set(settings.notificationsEnabled, forKey: Keys.notifications)
        defaults.set(streakFreezesOwned, forKey: Keys.freezes)
        defaults.set(activeMultiplierUntil?.timeIntervalSince1970, forKey: Keys.multiplierUntil)
    }
}
