// Eternal-CS329E-Group-Project
// Group 15
// Created / Edits done by Ori Parks (lwp369)

import Foundation
import FirebaseFirestore
import FirebaseAuth

final class HabitStore {
    static let shared = HabitStore()

    private let defaults = UserDefaults.standard
    private let db = Firestore.firestore()
    
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
    private(set) var wagers: [Wager] = []

    // Inventory (in-memory)
    private(set) var streakFreezesOwned: Int = 0
    private(set) var activeMultiplierUntil: Date? = nil
    
    // Firebase helper
    private var userId: String {
        // For now, use a device-specific ID. In production, use Auth.auth().currentUser?.uid
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "default-user"
        return deviceId
    }

    private init() {
        // Seed with sample habits
        habits = [
            Habit(name: "Make Bed", icon: "bed.double.fill", brightness: 0.8),
            Habit(name: "Walk", icon: "figure.walk", brightness: 0.5)
        ]

        // Load from UserDefaults as backup
        wallet.balance = defaults.integer(forKey: Keys.walletBalance)
        wallet.totalEarned = defaults.integer(forKey: Keys.walletTotal)
        settings.themeKey = defaults.string(forKey: Keys.themeKey) ?? settings.themeKey
        settings.notificationsEnabled = defaults.object(forKey: Keys.notifications) as? Bool ?? settings.notificationsEnabled
        streakFreezesOwned = defaults.integer(forKey: Keys.freezes)
        if let ts = defaults.object(forKey: Keys.multiplierUntil) as? TimeInterval {
            activeMultiplierUntil = Date(timeIntervalSince1970: ts)
        }
        
        // Load data from Firebase
        loadFromFirebase()
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
        
        // Save entry to Firebase
        saveEntryToFirebase(entry)
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
    
    // MARK: - Wager Management
    
    func addWager(_ wager: Wager) {
        wagers.append(wager)
    }
    
    func checkWagersForToday() {
        let today = Date().startOfDay
        let entriesForToday = entriesByDay[today] ?? []
        let allHabitsCompleted = !habits.isEmpty && entriesForToday.filter { $0.didComplete }.count == habits.count
        
        for (index, wager) in wagers.enumerated() where wager.isActive {
            if today > wager.endDate {
                // Wager period ended
                if allHabitsCompleted {
                    // Won the wager
                    wagers[index].isWon = true
                    wagers[index].isActive = false
                    addCoins(wager.amount * 2)
                } else {
                    // Lost the wager
                    wagers[index].isWon = false
                    wagers[index].isActive = false
                }
            } else if !allHabitsCompleted && Calendar.current.isDateInToday(today) {
                // Failed to complete all habits today during active wager
                wagers[index].isWon = false
                wagers[index].isActive = false
            }
        }
    }
    
    // MARK: - Firebase Methods
    
    /// Save an entry to Firebase
    private func saveEntryToFirebase(_ entry: HabitEntry) {
        let entryData: [String: Any] = [
            "id": entry.id.uuidString,
            "habitID": entry.habitID.uuidString,
            "date": Timestamp(date: entry.date),
            "didComplete": entry.didComplete,
            "value": entry.value ?? 0,
            "note": entry.note ?? "",
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        db.collection("users")
            .document(userId)
            .collection("entries")
            .document(entry.id.uuidString)
            .setData(entryData, merge: true) { error in
                if let error = error {
                    print("Error saving entry to Firebase: \(error.localizedDescription)")
                } else {
                    print("✅ Entry saved to Firebase successfully")
                }
            }
    }
    
    /// Load all data from Firebase
    func loadFromFirebase() {
        loadEntriesFromFirebase()
        loadHabitsFromFirebase()
        loadWalletFromFirebase()
    }
    
    /// Load entries from Firebase
    func loadEntriesFromFirebase(completion: (() -> Void)? = nil) {
        db.collection("users")
            .document(userId)
            .collection("entries")
            .order(by: "date", descending: false)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error loading entries from Firebase: \(error.localizedDescription)")
                    completion?()
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion?()
                    return
                }
                
                // Clear existing entries
                self.entriesByDay.removeAll()
                
                // Parse documents into entries
                for doc in documents {
                    let data = doc.data()
                    
                    guard
                        let idString = data["id"] as? String,
                        let id = UUID(uuidString: idString),
                        let habitIDString = data["habitID"] as? String,
                        let habitID = UUID(uuidString: habitIDString),
                        let timestamp = data["date"] as? Timestamp,
                        let didComplete = data["didComplete"] as? Bool
                    else { continue }
                    
                    let date = timestamp.dateValue().startOfDay
                    let value = data["value"] as? Double
                    let note = data["note"] as? String
                    
                    let entry = HabitEntry(
                        id: id,
                        habitID: habitID,
                        date: date,
                        didComplete: didComplete,
                        value: value == 0 ? nil : value,
                        note: note?.isEmpty == true ? nil : note
                    )
                    
                    self.entriesByDay[date, default: []].append(entry)
                }
                
                print("✅ Loaded \(documents.count) entries from Firebase")
                completion?()
            }
    }
    
    /// Load habits from Firebase (optional - for future use)
    private func loadHabitsFromFirebase() {
        db.collection("users")
            .document(userId)
            .collection("habits")
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error loading habits: \(error.localizedDescription)")
                    return
                }
                
                // For now, keep using local habits
                // In the future, you can parse and use Firebase habits
                print("✅ Habits collection checked")
            }
    }
    
    /// Load wallet from Firebase (optional - for future use)
    private func loadWalletFromFirebase() {
        db.collection("users")
            .document(userId)
            .collection("wallet")
            .document("main")
            .getDocument { [weak self] snapshot, error in
                guard let self = self, let data = snapshot?.data() else { return }
                
                if let balance = data["balance"] as? Int {
                    self.wallet.balance = balance
                }
                if let totalEarned = data["totalEarned"] as? Int {
                    self.wallet.totalEarned = totalEarned
                }
                
                print("✅ Wallet loaded from Firebase")
            }
    }
    
    /// Save habit to Firebase
    func saveHabitToFirebase(_ habit: Habit) {
        let habitData: [String: Any] = [
            "id": habit.id.uuidString,
            "name": habit.name,
            "icon": habit.icon,
            "currentStreak": habit.currentStreak,
            "bestStreak": habit.bestStreak,
            "brightness": habit.brightness,
            "lastCheckInDate": habit.lastCheckInDate != nil ? Timestamp(date: habit.lastCheckInDate!) : NSNull(),
            "isExtinguished": habit.isExtinguished,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        db.collection("users")
            .document(userId)
            .collection("habits")
            .document(habit.id.uuidString)
            .setData(habitData, merge: true)
    }
}
