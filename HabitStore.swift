// Eternal-CS329E-Group-Project
// Group 15
// Created / Edits done by Ori Parks (lwp369)

import Foundation
import FirebaseFirestore
import FirebaseAuth

final class HabitStore {
    static let shared = HabitStore()

    private let db = Firestore.firestore()
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
    private(set) var wagers: [Wager] = []

    private(set) var streakFreezesOwned: Int = 0
    private(set) var activeMultiplierUntil: Date? = nil
    
    private var userId: String? {
        return Auth.auth().currentUser?.uid
    }

    private init() {
        wallet.balance = defaults.integer(forKey: Keys.walletBalance)
        wallet.totalEarned = defaults.integer(forKey: Keys.walletTotal)
        settings.themeKey = defaults.string(forKey: Keys.themeKey) ?? settings.themeKey
        settings.notificationsEnabled = defaults.object(forKey: Keys.notifications) as? Bool ?? settings.notificationsEnabled
        streakFreezesOwned = defaults.integer(forKey: Keys.freezes)
        if let ts = defaults.object(forKey: Keys.multiplierUntil) as? TimeInterval {
            activeMultiplierUntil = Date(timeIntervalSince1970: ts)
        }
    }

    func clearUserData() {
        habits = []
        entriesByDay = [:]
        wallet = CurrencyWallet()
        settings = AppSettings()
        wagers = []
        streakFreezesOwned = 0
        activeMultiplierUntil = nil
    }

    func loadFromFirebase(completion: (() -> Void)? = nil) {
        guard let uid = userId else {
            completion?()
            return
        }
        
        print("📥 Starting Firebase load for user: \(uid)")
        clearUserData()
        
        let group = DispatchGroup()
        
        group.enter()
        loadHabitsFromFirebase(uid: uid) {
            group.leave()
        }
        
        group.enter()
        loadEntriesFromFirebase(uid: uid) {
            group.leave()
        }
        
        group.enter()
        loadWalletFromFirebase(uid: uid) {
            group.leave()
        }
        
        group.enter()
        loadSettingsFromFirebase(uid: uid) {
            group.leave()
        }
        
        group.enter()
        loadInventoryFromFirebase(uid: uid) {
            group.leave()
        }
        
        group.notify(queue: .main) {
            NotificationCenter.default.post(name: NSNotification.Name("HabitDataLoaded"), object: nil)
            print("✅ All data loaded from Firebase")
            completion?()
        }
    }

    private func loadHabitsFromFirebase(uid: String, completion: @escaping () -> Void) {
        print("📥 Loading habits for user: \(uid)")
        db.collection("users").document(uid).collection("habits").getDocuments { [weak self] snapshot, error in
            guard let self = self else {
                completion()
                return
            }
            
            if let error = error {
                print("❌ Error loading habits: \(error.localizedDescription)")
                completion()
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("⚠️ No habit documents found")
                completion()
                return
            }
            
            print("📦 Found \(documents.count) habit documents")
            
            self.habits = documents.compactMap { doc in
                let data = doc.data()
                
                guard
                    let idString = data["id"] as? String,
                    let id = UUID(uuidString: idString),
                    let name = data["name"] as? String,
                    let icon = data["icon"] as? String
                else {
                    print("⚠️ Failed to parse habit document: \(doc.documentID)")
                    return nil
                }
                
                let currentStreak = data["currentStreak"] as? Int ?? 0
                let bestStreak = data["bestStreak"] as? Int ?? 0
                let brightness = data["brightness"] as? Double ?? 0.6
                let isExtinguished = data["isExtinguished"] as? Bool ?? false
                
                var lastCheckInDate: Date? = nil
                if let timestamp = data["lastCheckInDate"] as? Timestamp {
                    lastCheckInDate = timestamp.dateValue()
                }
                
                let habit = Habit(
                    id: id,
                    name: name,
                    icon: icon,
                    createdAt: Date(),
                    isExtinguished: isExtinguished,
                    lastCheckInDate: lastCheckInDate,
                    currentStreak: currentStreak,
                    bestStreak: bestStreak,
                    brightness: brightness
                )
                
                print("✅ Loaded habit: \(habit.name)")
                return habit
            }
            
            print("✅ Total habits loaded: \(self.habits.count)")
            completion()
        }
    }

    func loadEntriesFromFirebase(completion: (() -> Void)? = nil) {
        guard let uid = userId else {
            completion?()
            return
        }
        loadEntriesFromFirebase(uid: uid, completion: completion ?? {})
    }

    private func loadEntriesFromFirebase(uid: String, completion: @escaping () -> Void) {
        print("📥 Loading entries for user: \(uid)")
        db.collection("users").document(uid).collection("entries").order(by: "date", descending: false).getDocuments { [weak self] snapshot, error in
            guard let self = self else {
                completion()
                return
            }
            
            if let error = error {
                print("❌ Error loading entries: \(error.localizedDescription)")
                completion()
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("⚠️ No entry documents found")
                completion()
                return
            }
            
            print("📦 Found \(documents.count) entry documents")
            
            self.entriesByDay.removeAll()
            
            for doc in documents {
                let data = doc.data()
                
                guard
                    let idString = data["id"] as? String,
                    let id = UUID(uuidString: idString),
                    let habitIDString = data["habitID"] as? String,
                    let habitID = UUID(uuidString: habitIDString),
                    let timestamp = data["date"] as? Timestamp,
                    let didComplete = data["didComplete"] as? Bool
                else {
                    print("⚠️ Failed to parse entry document: \(doc.documentID)")
                    continue
                }
                
                let date = timestamp.dateValue().startOfDay
                let value = data["value"] as? Double
                let noteFromFirebase = data["note"] as? String
                
                // Only set note if it's not empty
                let note = (noteFromFirebase?.isEmpty == false) ? noteFromFirebase : nil
                
                let entry = HabitEntry(
                    id: id,
                    habitID: habitID,
                    date: date,
                    didComplete: didComplete,
                    value: value == 0 ? nil : value,
                    note: note
                )
                
                print("📝 Loaded entry - Date: \(date), Completed: \(didComplete), Note: '\(note ?? "nil")'")
                
                self.entriesByDay[date, default: []].append(entry)
            }
            
            print("✅ Loaded \(documents.count) entries from Firebase")
            print("📊 Total days with entries: \(self.entriesByDay.keys.count)")
            completion()
        }
    }
    private func loadWalletFromFirebase(uid: String, completion: @escaping () -> Void) {
        db.collection("users").document(uid).collection("wallet").document("data").getDocument { [weak self] snapshot, error in
            guard let self = self else {
                completion()
                return
            }
            
            if let error = error {
                print("❌ Error loading wallet: \(error.localizedDescription)")
                completion()
                return
            }
            
            if let data = snapshot?.data() {
                if let balance = data["balance"] as? Int {
                    self.wallet.balance = balance
                }
                if let totalEarned = data["totalEarned"] as? Int {
                    self.wallet.totalEarned = totalEarned
                }
                print("✅ Wallet loaded from Firebase")
            }
            
            completion()
        }
    }

    private func loadSettingsFromFirebase(uid: String, completion: @escaping () -> Void) {
        db.collection("users").document(uid).collection("settings").document("data").getDocument { [weak self] snapshot, error in
            guard let self = self else {
                completion()
                return
            }
            
            if let error = error {
                print("❌ Error loading settings: \(error.localizedDescription)")
                completion()
                return
            }
            
            if let data = snapshot?.data() {
                if let themeKey = data["themeKey"] as? String {
                    self.settings.themeKey = themeKey
                }
                if let notificationsEnabled = data["notificationsEnabled"] as? Bool {
                    self.settings.notificationsEnabled = notificationsEnabled
                }
                print("✅ Settings loaded from Firebase")
            }
            
            completion()
        }
    }

    private func loadInventoryFromFirebase(uid: String, completion: @escaping () -> Void) {
        db.collection("users").document(uid).collection("inventory").document("data").getDocument { [weak self] snapshot, error in
            guard let self = self else {
                completion()
                return
            }
            
            if let error = error {
                print("❌ Error loading inventory: \(error.localizedDescription)")
                completion()
                return
            }
            
            if let data = snapshot?.data() {
                self.streakFreezesOwned = data["freezes"] as? Int ?? 0
                if let ts = data["multiplierUntil"] as? Timestamp {
                    self.activeMultiplierUntil = ts.dateValue()
                }
                print("✅ Inventory loaded from Firebase")
            }
            
            completion()
        }
    }

    func addHabit(name: String, icon: String) {
        let habit = Habit(name: name, icon: icon)
        habits.append(habit)
        saveHabitToFirebase(habit)
    }

    private func saveHabitToFirebase(_ habit: Habit) {
        guard let uid = userId else {
            print("❌ No user ID for saving habit")
            return
        }
        
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
        
        print("💾 Saving habit: \(habit.name)")
        db.collection("users").document(uid).collection("habits").document(habit.id.uuidString).setData(habitData, merge: true) { error in
            if let error = error {
                print("❌ Error saving habit: \(error.localizedDescription)")
            } else {
                print("✅ Habit saved successfully")
            }
        }
    }

    func extinguishHabit(id: UUID) {
        guard let idx = habits.firstIndex(where: { $0.id == id }) else { return }
        habits[idx].isExtinguished = true
        saveHabitToFirebase(habits[idx])
    }

    func entry(for habitID: UUID, on day: Date = Date().startOfDay) -> HabitEntry? {
        entriesByDay[day]?.first(where: { $0.habitID == habitID })
    }

    func checkIn(habitID: UUID, didComplete: Bool, value: Double? = nil, note: String? = nil, on day: Date = Date()) {
        let day = day.startOfDay
        let entry = HabitEntry(habitID: habitID, date: day, didComplete: didComplete, value: value, note: note)

        if var dayEntries = entriesByDay[day], let idx = dayEntries.firstIndex(where: { $0.habitID == habitID }) {
            dayEntries[idx] = entry
            entriesByDay[day] = dayEntries
        } else {
            entriesByDay[day, default: []].append(entry)
        }

        saveEntryToFirebase(entry)
        updateStreaksAndRewards(for: habitID, didComplete: didComplete, on: day)
    }

    private func saveEntryToFirebase(_ entry: HabitEntry) {
        guard let uid = userId else {
            print("❌ No user ID for saving entry")
            return
        }
        
        print("💾 Attempting to save entry to Firebase:")
        print("   - Habit ID: \(entry.habitID)")
        print("   - Date: \(entry.date)")
        print("   - Completed: \(entry.didComplete)")
        print("   - Note: '\(entry.note ?? "nil")'")
        print("   - Value: \(entry.value ?? 0)")
        
        let entryData: [String: Any] = [
            "id": entry.id.uuidString,
            "habitID": entry.habitID.uuidString,
            "date": Timestamp(date: entry.date),
            "didComplete": entry.didComplete,
            "value": entry.value ?? 0,
            "note": entry.note ?? "",
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        print("📤 Sending to Firebase: \(entryData)")
        
        db.collection("users").document(uid).collection("entries").document(entry.id.uuidString).setData(entryData, merge: true) { error in
            if let error = error {
                print("❌ Error saving entry: \(error.localizedDescription)")
            } else {
                print("✅ Entry saved successfully to Firebase")
            }
        }
    }

    func pendingHabitsForToday() -> [Habit] {
        let today = Date().startOfDay
        let completedIDs: Set<UUID> = Set(entriesByDay[today]?.filter { $0.didComplete }.map { $0.habitID } ?? [])
        return habits.filter { !completedIDs.contains($0.id) && !$0.isExtinguished }
    }

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
            if useStreakFreezeIfAvailable() {
            } else {
                habit.brightness = max(0.2, habit.brightness - 0.1)
            }
        }

        habits[idx] = habit
        saveHabitToFirebase(habit)
        saveWalletToFirebase()
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
        saveInventoryToFirebase()
    }

    func useStreakFreezeIfAvailable() -> Bool {
        if streakFreezesOwned > 0 {
            streakFreezesOwned -= 1
            saveInventoryToFirebase()
            return true
        } else {
            return false
        }
    }

    func activateMultiplier(hours: Int = 24) {
        activeMultiplierUntil = Date().addingTimeInterval(TimeInterval(hours * 3600))
        saveInventoryToFirebase()
    }

    func isMultiplierActive(now: Date = Date()) -> Bool {
        if let until = activeMultiplierUntil { return now < until } else { return false }
    }

    func setThemeKey(_ key: String) {
        settings.themeKey = key
        saveSettingsToFirebase()
    }

    func setNotificationsEnabled(_ enabled: Bool) {
        settings.notificationsEnabled = enabled
        saveSettingsToFirebase()
    }

    @discardableResult
    func spendCoins(_ amount: Int) -> Bool {
        guard amount > 0, wallet.balance >= amount else { return false }
        wallet.balance -= amount
        saveWalletToFirebase()
        return true
    }

    func addCoins(_ amount: Int) {
        guard amount > 0 else { return }
        wallet.balance += amount
        wallet.totalEarned += amount
        saveWalletToFirebase()
    }

    private func saveWalletToFirebase() {
        guard let uid = userId else { return }
        
        let walletData: [String: Any] = [
            "balance": wallet.balance,
            "totalEarned": wallet.totalEarned,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        db.collection("users").document(uid).collection("wallet").document("data").setData(walletData, merge: true)
        defaults.set(wallet.balance, forKey: Keys.walletBalance)
        defaults.set(wallet.totalEarned, forKey: Keys.walletTotal)
    }

    private func saveSettingsToFirebase() {
        guard let uid = userId else { return }
        
        let settingsData: [String: Any] = [
            "themeKey": settings.themeKey,
            "notificationsEnabled": settings.notificationsEnabled,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        db.collection("users").document(uid).collection("settings").document("data").setData(settingsData, merge: true)
        defaults.set(settings.themeKey, forKey: Keys.themeKey)
        defaults.set(settings.notificationsEnabled, forKey: Keys.notifications)
    }

    private func saveInventoryToFirebase() {
        guard let uid = userId else { return }
        
        let inventoryData: [String: Any] = [
            "freezes": streakFreezesOwned,
            "multiplierUntil": activeMultiplierUntil != nil ? Timestamp(date: activeMultiplierUntil!) : NSNull(),
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        db.collection("users").document(uid).collection("inventory").document("data").setData(inventoryData, merge: true)
        defaults.set(streakFreezesOwned, forKey: Keys.freezes)
        defaults.set(activeMultiplierUntil?.timeIntervalSince1970, forKey: Keys.multiplierUntil)
    }
    
    func addWager(_ wager: Wager) {
        wagers.append(wager)
    }
    
    func checkWagersForToday() {
        let today = Date().startOfDay
        let entriesForToday = entriesByDay[today] ?? []
        let allHabitsCompleted = !habits.isEmpty && entriesForToday.filter { $0.didComplete }.count == habits.count
        
        for (index, wager) in wagers.enumerated() where wager.isActive {
            if today > wager.endDate {
                if allHabitsCompleted {
                    wagers[index].isWon = true
                    wagers[index].isActive = false
                    addCoins(wager.amount * 2)
                } else {
                    wagers[index].isWon = false
                    wagers[index].isActive = false
                }
            } else if !allHabitsCompleted && Calendar.current.isDateInToday(today) {
                wagers[index].isWon = false
                wagers[index].isActive = false
            }
        }
    }
}
