// Eternal-CS329E-Group-Project
// Group 15
// Created / Edits done by Ori Parks (lwp369)

import Foundation
import FirebaseFirestore
import FirebaseAuth
import UIKit
import Combine

final class HabitStore: ObservableObject {
    static let shared = HabitStore()

    private let db = Firestore.firestore()
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let walletBalance = "wallet.balance"
        static let walletTotal = "wallet.total"
        static let themeKey = "settings.themeKey"
        static let notifications = "settings.notifications"
        static let notificationHour = "settings.notificationHour"
        static let notificationMinute = "settings.notificationMinute"
        static let freezes = "inventory.freezes"
        static let multiplierUntil = "inventory.multiplierUntil"
        static let multiplierStrength = "inventory.multiplierStrength"
        static let activeFlameColorID = "inventory.activeFlameColorID"
        static let activeBadgeID = "inventory.activeBadgeID"
    }

    private(set) var habits: [Habit] = []
    private(set) var entriesByDay: [Date: [HabitEntry]] = [:]
    private(set) var wallet = CurrencyWallet()
    @Published private(set) var settings = AppSettings()
    private(set) var wagers: [Wager] = []

    private(set) var streakFreezesOwned: Int = 0
    private(set) var activeMultiplierUntil: Date? = nil
    private(set) var activeMultiplierStrength: Double = 1.0
    private(set) var activeFlameColorID: UUID? = nil
    private(set) var activeBadgeID: UUID? = nil
    
    // New inventory counts for stockpiling
    private(set) var streakRecoveryPasses: Int = 0
    private(set) var multiplier24hCount: Int = 0
    private(set) var multiplier7dCount: Int = 0
    private(set) var multiplierMegaCount: Int = 0
    
    // Shop items
    private(set) var shopCatalog: [ShopItem] = ShopItem.defaultCatalog
    private(set) var purchasedItems: [PurchasedItem] = []
    private(set) var ownedFlameColors: [FlameColor] = []
    private(set) var unlockedBadges: [Badge] = []
    private(set) var maxHabitSlots: Int = 5
    private(set) var autoCompletePasses: Int = 0
    @Published private(set) var ownedThemes: Set<String> = []
    
    // Sorted and grouped shop catalog for UI consumption
    var sortedShopCatalog: [ShopItem] {
        // Establish group partitions while preserving UX group order
        // Power-ups subgroups: streak freezes together; mystery box; multipliers; recovery/auto/slot
        let freezes = shopCatalog.filter { $0.type == .streakFreeze }
            .sorted { $0.price < $1.price }
        let mystery = shopCatalog.filter { $0.type == .dailyDeal && $0.name.lowercased().contains("mystery") }
            .sorted { $0.price < $1.price }
        let multipliers = shopCatalog.filter { $0.type == .coinMultiplier }
            .sorted { $0.price < $1.price }
        let recoveryAutoSlot = shopCatalog.filter { $0.type == .streakRecovery || $0.type == .autoComplete || $0.type == .habitSlot }
            .sorted { $0.price < $1.price }

        // Flames group (all flameColor)
        let flames = shopCatalog.filter { $0.type == .flameColor }
            .sorted { $0.price < $1.price }

        // Themes group (customTheme)
        let themes = shopCatalog.filter { $0.type == .customTheme }
            .sorted { $0.price < $1.price }

        // Badges group (badge)
        let badges = shopCatalog.filter { $0.type == .badge }
            .sorted { $0.price < $1.price }

        // Concatenate in desired UX order
        return freezes + mystery + multipliers + recoveryAutoSlot + flames + themes + badges
    }
    
    private var userId: String? {
        return Auth.auth().currentUser?.uid
    }

    private init() {
        wallet.balance = defaults.integer(forKey: Keys.walletBalance)
        wallet.totalEarned = defaults.integer(forKey: Keys.walletTotal)
        settings.themeKey = defaults.string(forKey: Keys.themeKey) ?? settings.themeKey
        settings.notificationsEnabled = defaults.object(forKey: Keys.notifications) as? Bool ?? settings.notificationsEnabled
        settings.notificationHour = defaults.integer(forKey: Keys.notificationHour)
        if settings.notificationHour == 0 { settings.notificationHour = 20 }
        settings.notificationMinute = defaults.integer(forKey: Keys.notificationMinute)
        streakFreezesOwned = defaults.integer(forKey: Keys.freezes)
        if let ts = defaults.object(forKey: Keys.multiplierUntil) as? TimeInterval {
            activeMultiplierUntil = Date(timeIntervalSince1970: ts)
        }
        activeMultiplierStrength = defaults.double(forKey: Keys.multiplierStrength)
        if activeMultiplierStrength == 0 { activeMultiplierStrength = 1.0 }
        if let idString = defaults.string(forKey: Keys.activeFlameColorID),
           let id = UUID(uuidString: idString) {
            activeFlameColorID = id
        }
        if let badgeIDString = defaults.string(forKey: Keys.activeBadgeID),
           let bid = UUID(uuidString: badgeIDString) {
            activeBadgeID = bid
        }
        
        // Initialize default flame colors
        ownedFlameColors = FlameColor.defaultColors
    }

    func clearUserData() {
        habits = []
        entriesByDay = [:]
        wallet = CurrencyWallet()
        settings = AppSettings()
        wagers = []
        streakFreezesOwned = 0
        activeMultiplierUntil = nil
        activeMultiplierStrength = 1.0
        activeFlameColorID = nil
        activeBadgeID = nil
        shopCatalog = ShopItem.defaultCatalog
        purchasedItems = []
        ownedFlameColors = []
        unlockedBadges = []
        maxHabitSlots = 5
        autoCompletePasses = 0
        ownedThemes = []
        streakRecoveryPasses = 0
        multiplier24hCount = 0
        multiplier7dCount = 0
        multiplierMegaCount = 0
    }

    func loadFromFirebase(completion: (() -> Void)? = nil) {
        guard let uid = userId else {
            completion?()
            return
        }
        
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
        
        group.enter()
        loadWagersFromFirebase(uid: uid) {
            group.leave()
        }
        
        group.notify(queue: .main) {
            NotificationCenter.default.post(name: NSNotification.Name("HabitDataLoaded"), object: nil)
            completion?()
        }
    }

    private func loadHabitsFromFirebase(uid: String, completion: @escaping () -> Void) {
        db.collection("users").document(uid).collection("habits").getDocuments { [weak self] snapshot, error in
            guard let self = self else {
                completion()
                return
            }
            
            if let error = error {
                completion()
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion()
                return
            }
            
            self.habits = documents.compactMap { doc in
                let data = doc.data()
                
                guard
                    let idString = data["id"] as? String,
                    let id = UUID(uuidString: idString),
                    let name = data["name"] as? String,
                    let icon = data["icon"] as? String
                else {
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
                
                var flameColorID: UUID? = nil
                if let flameString = data["flameColorID"] as? String, let fid = UUID(uuidString: flameString) {
                    flameColorID = fid
                }
                
                var habit = Habit(
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
                habit.flameColorID = flameColorID
                return habit
            }
            
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
        db.collection("users").document(uid).collection("entries").order(by: "date", descending: false).getDocuments { [weak self] snapshot, error in
            guard let self = self else {
                completion()
                return
            }
            
            if let error = error {
                completion()
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion()
                return
            }
            
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
                    continue
                }
                
                let date = timestamp.dateValue().startOfDay
                let value = data["value"] as? Double
                let noteFromFirebase = data["note"] as? String
                
                let note = (noteFromFirebase?.isEmpty == false) ? noteFromFirebase : nil
                
                let entry = HabitEntry(
                    id: id,
                    habitID: habitID,
                    date: date,
                    didComplete: didComplete,
                    value: value == 0 ? nil : value,
                    note: note
                )
                
                self.entriesByDay[date, default: []].append(entry)
            }
            
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
                if let notificationHour = data["notificationHour"] as? Int {
                    self.settings.notificationHour = notificationHour
                }
                if let notificationMinute = data["notificationMinute"] as? Int {
                    self.settings.notificationMinute = notificationMinute
                }
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
                completion()
                return
            }
            
            if let data = snapshot?.data() {
                self.streakFreezesOwned = data["freezes"] as? Int ?? 0
                if let ts = data["multiplierUntil"] as? Timestamp {
                    self.activeMultiplierUntil = ts.dateValue()
                }
                self.activeMultiplierStrength = data["multiplierStrength"] as? Double ?? 1.0
                
                self.maxHabitSlots = data["maxHabitSlots"] as? Int ?? 5
                self.autoCompletePasses = data["autoCompletePasses"] as? Int ?? 0
                
                self.streakRecoveryPasses = data["streakRecoveryPasses"] as? Int ?? 0
                self.multiplier24hCount = data["multiplier24hCount"] as? Int ?? 0
                self.multiplier7dCount = data["multiplier7dCount"] as? Int ?? 0
                self.multiplierMegaCount = data["multiplierMegaCount"] as? Int ?? 0
                
                // Load active flame color ID
                if let activeFlameColorIDString = data["activeFlameColorID"] as? String,
                   let id = UUID(uuidString: activeFlameColorIDString) {
                    self.activeFlameColorID = id
                }
                
                // Load active badge ID
                if let activeBadgeIDString = data["activeBadgeID"] as? String,
                   let bid = UUID(uuidString: activeBadgeIDString) {
                    self.activeBadgeID = bid
                }
                
                // Load flame colors
                if let flameColorsString = data["flameColors"] as? String,
                   let flameColorsData = flameColorsString.data(using: .utf8) {
                    self.ownedFlameColors = (try? JSONDecoder().decode([FlameColor].self, from: flameColorsData)) ?? FlameColor.defaultColors
                } else {
                    self.ownedFlameColors = FlameColor.defaultColors
                }
                
                // Load badges
                if let badgesString = data["badges"] as? String,
                   let badgesData = badgesString.data(using: .utf8) {
                    self.unlockedBadges = (try? JSONDecoder().decode([Badge].self, from: badgesData)) ?? []
                }
                
                // Load purchased items
                if let purchasedItemsString = data["purchasedItems"] as? String,
                   let purchasedItemsData = purchasedItemsString.data(using: .utf8) {
                    self.purchasedItems = (try? JSONDecoder().decode([PurchasedItem].self, from: purchasedItemsData)) ?? []
                }
                
                // Purge legacy badges from unlockedBadges and purchasedItems
                let legacyNames: Set<String> = ["diamond badge", "king badge", "queen badge"]
                self.unlockedBadges = self.unlockedBadges.filter { badge in
                    !legacyNames.contains(where: { legacyName in
                        badge.name.localizedCaseInsensitiveContains(legacyName)
                    })
                }
                self.purchasedItems = self.purchasedItems.filter { p in
                    if p.type == .badge,
                       let shopItem = self.shopCatalog.first(where: { $0.id == p.shopItemID }) {
                        return !legacyNames.contains(shopItem.name.lowercased())
                    }
                    return true
                }
                
                // Save inventory after purge
                // Load owned themes (stable by key)
                if let ownedThemesString = data["ownedThemes"] as? String,
                   let ownedThemesData = ownedThemesString.data(using: .utf8) {
                    let decoded = (try? JSONDecoder().decode([String].self, from: ownedThemesData)) ?? []
                    self.ownedThemes = Set(decoded.map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) })
                    self.saveInventoryToFirebase()
                    
                    // Also add any themes inferred from purchasedItems to ensure persistence
                    for purchasedItem in self.purchasedItems where purchasedItem.type == .customTheme {
                        if let shopItem = self.shopCatalog.first(where: { $0.id == purchasedItem.shopItemID }) {
                            let name = shopItem.name.replacingOccurrences(of: " Theme", with: "").lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                            self.ownedThemes.insert(name)
                        }
                    }
                    
                } else {
                    // Fallback: infer from purchasedItems where possible
                    var inferred: Set<String> = []
                    for purchasedItem in self.purchasedItems where purchasedItem.type == .customTheme {
                        if let shopItem = self.shopCatalog.first(where: { $0.id == purchasedItem.shopItemID }) {
                            let name = shopItem.name.replacingOccurrences(of: " Theme", with: "").lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                            inferred.insert(name)
                        }
                    }
                    self.ownedThemes = inferred
                    self.saveInventoryToFirebase()
                }
            } else {
                // No data exists yet, use defaults
                self.ownedFlameColors = FlameColor.defaultColors
            }
            
            completion()
        }
    }

    func addHabit(name: String, icon: String) {
        guard canAddHabit() else { return }
        let habit = Habit(name: name, icon: icon)
        habits.append(habit)
        saveHabitToFirebase(habit)
    }

    private func saveHabitToFirebase(_ habit: Habit) {
        guard let uid = userId else { return }
        
        let habitData: [String: Any] = [
            "id": habit.id.uuidString,
            "name": habit.name,
            "icon": habit.icon,
            "currentStreak": habit.currentStreak,
            "bestStreak": habit.bestStreak,
            "brightness": habit.brightness,
            "lastCheckInDate": habit.lastCheckInDate != nil ? Timestamp(date: habit.lastCheckInDate!) : NSNull(),
            "isExtinguished": habit.isExtinguished,
            "flameColorID": habit.flameColorID != nil ? habit.flameColorID!.uuidString : NSNull(),
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        db.collection("users").document(uid).collection("habits").document(habit.id.uuidString).setData(habitData, merge: true)
    }

    func extinguishHabit(id: UUID) {
        guard let idx = habits.firstIndex(where: { $0.id == id }) else { return }
        habits[idx].isExtinguished = true
        saveHabitToFirebase(habits[idx])
    }
    
    func deleteHabit(id: UUID) {
        guard let uid = userId else { return }
        
        guard let idx = habits.firstIndex(where: { $0.id == id }) else { return }
        habits.remove(at: idx)
        
        db.collection("users").document(uid).collection("habits").document(id.uuidString).delete()
        
        for (date, entries) in entriesByDay {
            entriesByDay[date] = entries.filter { $0.habitID != id }
            if entriesByDay[date]?.isEmpty == true {
                entriesByDay.removeValue(forKey: date)
            }
        }
        
        db.collection("users").document(uid).collection("entries").whereField("habitID", isEqualTo: id.uuidString).getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            let batch = self.db.batch()
            documents.forEach { doc in
                batch.deleteDocument(doc.reference)
            }
            batch.commit()
        }
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
        guard let uid = userId else { return }
        
        let entryData: [String: Any] = [
            "id": entry.id.uuidString,
            "habitID": entry.habitID.uuidString,
            "date": Timestamp(date: entry.date),
            "didComplete": entry.didComplete,
            "value": entry.value ?? 0,
            "note": entry.note ?? "",
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        db.collection("users").document(uid).collection("entries").document(entry.id.uuidString).setData(entryData, merge: true)
    }

    /// Save or update today's note for a habit without changing completion status or streaks.
    /// If an entry exists for the day, its note is updated. Otherwise, a new entry is created with didComplete = false.
    func saveNote(for habitID: UUID, note: String?, on day: Date = Date()) {
        let day = day.startOfDay
        if var dayEntries = entriesByDay[day], let idx = dayEntries.firstIndex(where: { $0.habitID == habitID }) {
            var entry = dayEntries[idx]
            entry.note = (note?.isEmpty == true) ? nil : note
            dayEntries[idx] = entry
            entriesByDay[day] = dayEntries
            saveEntryToFirebase(entry)
        } else {
            let entry = HabitEntry(habitID: habitID, date: day, didComplete: false, value: nil, note: (note?.isEmpty == true) ? nil : note)
            entriesByDay[day, default: []].append(entry)
            saveEntryToFirebase(entry)
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
        if isMultiplierActive() { 
            base = Int(Double(base) * activeMultiplierStrength)
        }
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

    func activateMultiplier(hours: Int = 24, strength: Double = 1.5) {
        activeMultiplierUntil = Date().addingTimeInterval(TimeInterval(hours * 3600))
        activeMultiplierStrength = strength
        saveInventoryToFirebase()
    }

    func isMultiplierActive(now: Date = Date()) -> Bool {
        if let until = activeMultiplierUntil { return now < until } else { return false }
    }

    func setThemeKey(_ key: String) {
        settings.themeKey = key
        // Update purchasedItems active flags for themes
        for index in purchasedItems.indices {
            if purchasedItems[index].type == .customTheme {
                if let shopItem = shopCatalog.first(where: { $0.id == purchasedItems[index].shopItemID }) {
                    let themeName = shopItem.name.replacingOccurrences(of: " Theme", with: "").lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                    purchasedItems[index].isActive = (themeName == key.lowercased())
                }
            }
        }
        saveSettingsToFirebase()
        saveInventoryToFirebase()
        
        // Notify all view controllers that theme changed
        NotificationCenter.default.post(name: NSNotification.Name("ThemeChanged"), object: nil)
        objectWillChange.send()
    }

    func setNotificationsEnabled(_ enabled: Bool) {
        settings.notificationsEnabled = enabled
        saveSettingsToFirebase()
    }
    
    func setNotificationTime(hour: Int, minute: Int) {
        settings.notificationHour = hour
        settings.notificationMinute = minute
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
            "notificationHour": settings.notificationHour,
            "notificationMinute": settings.notificationMinute,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        db.collection("users").document(uid).collection("settings").document("data").setData(settingsData, merge: true)
        defaults.set(settings.themeKey, forKey: Keys.themeKey)
        defaults.set(settings.notificationsEnabled, forKey: Keys.notifications)
        defaults.set(settings.notificationHour, forKey: Keys.notificationHour)
        defaults.set(settings.notificationMinute, forKey: Keys.notificationMinute)
    }

    private func saveInventoryToFirebase() {
        guard let uid = userId else { return }
        
        let flameColorsData = (try? JSONEncoder().encode(ownedFlameColors)).flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
        let badgesData = (try? JSONEncoder().encode(unlockedBadges)).flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
        let purchasedItemsData = (try? JSONEncoder().encode(purchasedItems)).flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
        let ownedThemesData = (try? JSONEncoder().encode(Array(ownedThemes))).flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
        
        let inventoryData: [String: Any] = [
            "freezes": streakFreezesOwned,
            "multiplierUntil": activeMultiplierUntil != nil ? Timestamp(date: activeMultiplierUntil!) : NSNull(),
            "multiplierStrength": activeMultiplierStrength,
            "maxHabitSlots": maxHabitSlots,
            "autoCompletePasses": autoCompletePasses,
            "streakRecoveryPasses": streakRecoveryPasses,
            "multiplier24hCount": multiplier24hCount,
            "multiplier7dCount": multiplier7dCount,
            "multiplierMegaCount": multiplierMegaCount,
            "activeFlameColorID": activeFlameColorID?.uuidString ?? "",
            "activeBadgeID": activeBadgeID?.uuidString ?? "",
            "flameColors": flameColorsData,
            "badges": badgesData,
            "purchasedItems": purchasedItemsData,
            "ownedThemes": ownedThemesData,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        db.collection("users").document(uid).collection("inventory").document("data").setData(inventoryData, merge: true)
        defaults.set(streakFreezesOwned, forKey: Keys.freezes)
        defaults.set(activeMultiplierUntil?.timeIntervalSince1970, forKey: Keys.multiplierUntil)
        defaults.set(activeMultiplierStrength, forKey: Keys.multiplierStrength)
        defaults.set(activeFlameColorID?.uuidString, forKey: Keys.activeFlameColorID)
        defaults.set(activeBadgeID?.uuidString, forKey: Keys.activeBadgeID)
    }
    
    
    // MARK: - Shop Methods
    
    func purchaseShopItem(_ item: ShopItem, completion: @escaping (Bool, String) -> Void) {
        switch item.type {
        case .streakFreeze:
            guard spendCoins(item.price) else {
                completion(false, "Not enough coins!")
                return
            }
            // Check for special "Double Freeze Pack"
            let count = item.name.contains("Double") ? 2 : 1
            addStreakFreeze(count: count)
            let message = count > 1 ? "\(count) Streak Freezes purchased!" : "Streak Freeze purchased!"
            completion(true, message)
            
        case .coinMultiplier:
            guard spendCoins(item.price) else {
                completion(false, "Not enough coins!")
                return
            }
            // Stockpile multiplier counts instead of immediate activation
            if item.name.contains("Mega") {
                multiplierMegaCount += 1
            } else if item.name.contains("7-Day") || item.name.contains("7 Day") {
                multiplier7dCount += 1
            } else if item.name.contains("24h") {
                multiplier24hCount += 1
            } else {
                // Default to 24h 1.5x
                multiplier24hCount += 1
            }
            saveInventoryToFirebase()
            completion(true, "Multiplier added to inventory! Use it from Inventory.")
            
        case .streakRecovery:
            guard spendCoins(item.price) else {
                completion(false, "Not enough coins!")
                return
            }
            // Stockpile streak recovery passes instead of immediate use
            streakRecoveryPasses += 1
            saveInventoryToFirebase()
            completion(true, "Streak Recovery added to inventory! Use it from Inventory.")
            
        case .autoComplete:
            guard spendCoins(item.price) else {
                completion(false, "Not enough coins!")
                return
            }
            autoCompletePasses += 1
            saveInventoryToFirebase()
            completion(true, "Auto-complete pass added!")
            
        case .habitSlot:
            guard spendCoins(item.price) else {
                completion(false, "Not enough coins!")
                return
            }
            if maxHabitSlots >= 10 {
                completion(false, "Maximum habit slots reached!")
                return
            }
            maxHabitSlots += 1
            saveInventoryToFirebase()
            completion(true, "Extra habit slot unlocked!")
            
        case .flameColor:
            guard spendCoins(item.price) else {
                completion(false, "Not enough coins!")
                return
            }
            // Create flame color with proper configuration
            var colorHex = item.iconColor
            var gradientColors = [item.iconColor, item.iconColor]
            
            // Special handling for Rainbow flame
            if item.name.lowercased().contains("rainbow") {
                colorHex = "#FF0000" // Start with red
                gradientColors = ["#FF0000", "#FF7F00", "#FFFF00", "#00FF00", "#0000FF", "#4B0082", "#9400D3"]
            }
            
            let flameColor = FlameColor(
                name: item.name,
                colorHex: colorHex,
                gradientColors: gradientColors,
                price: item.price,
                isPurchased: true
            )
            
            // Check if already owned (shouldn't happen but safety check)
            if !ownedFlameColors.contains(where: { $0.name == flameColor.name }) {
                ownedFlameColors.append(flameColor)
            }
            
            saveInventoryToFirebase()
            completion(true, "\(item.name) unlocked!")
            
        case .customTheme:
            guard spendCoins(item.price) else {
                completion(false, "Not enough coins!")
                return
            }
            // Extract theme name from item name (remove " Theme" suffix)
            let themeName = item.name.replacingOccurrences(of: " Theme", with: "").lowercased()
            ownedThemes.insert(themeName)
            self.saveInventoryToFirebase()
            
            // Create purchased item record
            let purchasedItem = PurchasedItem(
                shopItemID: item.id,
                type: .customTheme,
                isActive: false
            )
            
            // Check if already purchased
            if !purchasedItems.contains(where: { $0.shopItemID == item.id }) {
                purchasedItems.append(purchasedItem)
            }
            
            saveInventoryToFirebase()
            completion(true, "\(item.name) unlocked! Visit Inventory to apply it.")
            
        case .badge:
            // Prevent purchase of legacy badges
            let legacyNames: Set<String> = ["diamond badge", "king badge", "queen badge"]
            if legacyNames.contains(item.name.lowercased()) {
                completion(false, "This badge is no longer available.")
                return
            }
            
            guard spendCoins(item.price) else {
                completion(false, "Not enough coins!")
                return
            }
            
            let badge = Badge(
                name: item.name,
                description: item.description,
                icon: item.icon,
                colorHex: item.iconColor,
                requirement: 0,
                isUnlocked: true,
                unlockedDate: Date()
            )
            
            // Check if already unlocked
            if !unlockedBadges.contains(where: { $0.name == badge.name }) {
                unlockedBadges.append(badge)
            }
            
            saveInventoryToFirebase()
            completion(true, "Badge earned!")
            
        case .dailyDeal:
            guard spendCoins(item.price) else {
                completion(false, "Not enough coins!")
                return
            }
            // Mystery box - random coin reward
            let reward = Int.random(in: 50...500)
            addCoins(reward)
            completion(true, "Mystery box opened! You got \(reward) coins!")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("ShopItemPurchased"), object: nil)
    }
    
    func canAddHabit() -> Bool {
        return habits.count < maxHabitSlots
    }
    
    // MARK: - Flame Color Management
    
    func getActiveFlameColor() -> FlameColor {
        if let activeID = activeFlameColorID,
           let color = ownedFlameColors.first(where: { $0.id == activeID && $0.isPurchased }) {
            return color
        }
        // Default to first owned color (Classic Fire)
        if let defaultColor = ownedFlameColors.first(where: { $0.isPurchased }) {
            return defaultColor
        }
        // Fallback to classic fire
        return FlameColor.defaultColors[0]
    }
    
    func setActiveFlameColor(_ colorID: UUID) {
        // Verify the color is owned
        guard ownedFlameColors.contains(where: { $0.id == colorID && $0.isPurchased }) else {
            print("Cannot equip flame color that isn't owned")
            return
        }
        
        activeFlameColorID = colorID
        defaults.set(colorID.uuidString, forKey: Keys.activeFlameColorID)
        saveInventoryToFirebase()
        NotificationCenter.default.post(name: NSNotification.Name("FlameColorChanged"), object: nil)
    }
    
    func getOwnedFlameColors() -> [FlameColor] {
        return ownedFlameColors.filter { $0.isPurchased }
    }
    
    func isFlameColorOwned(_ colorName: String) -> Bool {
        return ownedFlameColors.contains(where: { $0.name == colorName && $0.isPurchased })
    }
    
    // Get flame color for a specific habit (falls back to global if not set)
    func getFlameColor(for habitID: UUID) -> FlameColor {
        guard let habit = habits.first(where: { $0.id == habitID }),
              let colorID = habit.flameColorID,
              let color = ownedFlameColors.first(where: { $0.id == colorID && $0.isPurchased }) else {
            return getActiveFlameColor() // Fall back to global
        }
        return color
    }
    
    // Set flame color for a specific habit
    func setFlameColor(_ colorID: UUID, for habitID: UUID) {
        guard let idx = habits.firstIndex(where: { $0.id == habitID }) else { return }
        guard ownedFlameColors.contains(where: { $0.id == colorID && $0.isPurchased }) else { return }
        
        habits[idx].flameColorID = colorID
        saveHabitToFirebase(habits[idx])
        NotificationCenter.default.post(name: NSNotification.Name("HabitFlameColorChanged"), object: habitID)
    }
    
    // MARK: - Badge Management
    
    func getActiveBadge() -> Badge? {
        guard let id = activeBadgeID else { return nil }
        return unlockedBadges.first(where: { $0.id == id })
    }

    func setActiveBadge(_ badgeID: UUID) {
        guard unlockedBadges.contains(where: { $0.id == badgeID }) else { return }
        activeBadgeID = badgeID
        saveInventoryToFirebase()
        NotificationCenter.default.post(name: NSNotification.Name("BadgeChanged"), object: nil)
    }
    
    // MARK: - Theme Management
    
    func isThemeUnlocked(_ themeName: String) -> Bool {
        let defaultThemes = ["default", "dark"]  // Only these two are free
        let normalized = themeName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if defaultThemes.contains(normalized) { return true }
        if ownedThemes.contains(normalized) { return true }
        // Backward compatibility: check purchasedItems by matching shop item names
        for purchasedItem in purchasedItems where purchasedItem.type == .customTheme {
            if let shopItem = shopCatalog.first(where: { $0.id == purchasedItem.shopItemID }) {
                let shopThemeName = shopItem.name.replacingOccurrences(of: " Theme", with: "").lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                if shopThemeName == normalized { return true }
            }
        }
        return false
    }
    
    func getUnlockedThemes() -> [String] {
        var themes: Set<String> = ["default", "amber", "dark"]
        themes.formUnion(ownedThemes)
        // Backward compatibility: add any themes discoverable via purchasedItems
        for purchasedItem in purchasedItems where purchasedItem.type == .customTheme {
            if let shopItem = shopCatalog.first(where: { $0.id == purchasedItem.shopItemID }) {
                let themeName = shopItem.name.replacingOccurrences(of: " Theme", with: "").lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                themes.insert(themeName)
            }
        }
        return Array(themes)
    }
    
    func useAutoCompletePass(on date: Date = Date()) -> Bool {
        guard autoCompletePasses > 0 else { return false }
        
        let day = date.startOfDay
        let activeHabits = habits.filter { !$0.isExtinguished }
        
        for habit in activeHabits {
            checkIn(habitID: habit.id, didComplete: true, on: day)
        }
        
        autoCompletePasses -= 1
        saveInventoryToFirebase()
        
        NotificationCenter.default.post(
            name: NSNotification.Name("AutoCompleteUsed"),
            object: nil
        )
        
        return true
    }
    
    // MARK: - New Use Methods for Stockpiled Items
    
    func useStreakRecovery(on habit: Habit) -> Bool {
        guard streakRecoveryPasses > 0 else { return false }
        // Only allow if not completed today
        let today = Date().startOfDay
        let entries = entriesByDay[today] ?? []
        let didCompleteToday = entries.contains(where: { $0.habitID == habit.id && $0.didComplete })
        guard !didCompleteToday else { return false }
        guard let idx = habits.firstIndex(where: { $0.id == habit.id }) else { return false }
        let recoveredStreak = min(habits[idx].bestStreak, habits[idx].currentStreak + 7)
        habits[idx].currentStreak = recoveredStreak
        saveHabitToFirebase(habits[idx])
        streakRecoveryPasses -= 1
        saveInventoryToFirebase()
        return true
    }

    func useMultiplier24h() -> Bool {
        guard multiplier24hCount > 0 else { return false }
        activateMultiplier(hours: 24, strength: 1.5)
        multiplier24hCount -= 1
        saveInventoryToFirebase()
        return true
    }

    func useMultiplier7d() -> Bool {
        guard multiplier7dCount > 0 else { return false }
        activateMultiplier(hours: 24 * 7, strength: 1.5)
        multiplier7dCount -= 1
        saveInventoryToFirebase()
        return true
    }

    func useMultiplierMega() -> Bool {
        guard multiplierMegaCount > 0 else { return false }
        activateMultiplier(hours: 24, strength: 2.0)
        multiplierMegaCount -= 1
        saveInventoryToFirebase()
        return true
    }
    
    // Helper to get habits not completed today, for UI or inventory use
    func habitsNotCompletedToday() -> [Habit] {
        let today = Date().startOfDay
        let completedIDs = Set(entriesByDay[today]?.filter { $0.didComplete }.map { $0.habitID } ?? [])
        return habits.filter { !$0.isExtinguished && !completedIDs.contains($0.id) }
    }
    
    func addWager(_ wager: Wager) {
        wagers.append(wager)
        saveWagerToFirebase(wager)
    }
    
    func activeWagers() -> [Wager] {
        return wagers.filter { $0.isActive }
    }
    
    private func saveWagerToFirebase(_ wager: Wager) {
        guard let uid = userId else { return }
        
        let wagerData: [String: Any] = [
            "id": wager.id.uuidString,
            "amount": wager.amount,
            "targetDays": wager.targetDays,
            "startDate": Timestamp(date: wager.startDate),
            "endDate": Timestamp(date: wager.endDate),
            "isActive": wager.isActive,
            "isWon": wager.isWon as Any,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        db.collection("users").document(uid).collection("wagers").document(wager.id.uuidString).setData(wagerData, merge: true)
    }
    
    private func loadWagersFromFirebase(uid: String, completion: @escaping () -> Void) {
        db.collection("users").document(uid).collection("wagers").order(by: "startDate", descending: true).getDocuments { [weak self] snapshot, error in
            guard let self = self else {
                completion()
                return
            }
            
            if let error = error {
                print("Error loading wagers: \(error.localizedDescription)")
                completion()
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion()
                return
            }
            
            self.wagers = documents.compactMap { doc in
                let data = doc.data()
                
                guard
                    let idString = data["id"] as? String,
                    let id = UUID(uuidString: idString),
                    let amount = data["amount"] as? Int,
                    let targetDays = data["targetDays"] as? Int,
                    let startTimestamp = data["startDate"] as? Timestamp,
                    let endTimestamp = data["endDate"] as? Timestamp,
                    let isActive = data["isActive"] as? Bool
                else {
                    return nil
                }
                
                let isWon = data["isWon"] as? Bool
                
                return Wager(
                    id: id,
                    amount: amount,
                    targetDays: targetDays,
                    startDate: startTimestamp.dateValue(),
                    isActive: isActive,
                    isWon: isWon
                )
            }
            
            completion()
        }
    }
    
    func checkWagersForToday() {
        let today = Date().startOfDay
        let entriesForToday = entriesByDay[today] ?? []
        
        // Check if all habits were completed today
        let allHabitsCompletedToday = !habits.filter({ !$0.isExtinguished }).isEmpty && 
            entriesForToday.filter { $0.didComplete }.count == habits.filter({ !$0.isExtinguished }).count
        
        var wagersUpdated = false
        
        for (index, wager) in wagers.enumerated() where wager.isActive {
            // If wager period has ended
            if today > wager.endDate {
                // Check if user completed ALL days in the wager period
                let wagerWon = checkWagerCompletion(wager: wager)
                
                wagers[index].isWon = wagerWon
                wagers[index].isActive = false
                
                if wagerWon {
                    // User wins! Double the wager amount
                    addCoins(wager.amount * 2)
                    
                    // Show celebration
                    NotificationCenter.default.post(
                        name: NSNotification.Name("WagerWon"),
                        object: nil,
                        userInfo: ["amount": wager.amount * 2]
                    )
                } else {
                    // User loses - already spent the coins when placing wager
                    NotificationCenter.default.post(
                        name: NSNotification.Name("WagerLost"),
                        object: nil,
                        userInfo: ["amount": wager.amount]
                    )
                }
                
                saveWagerToFirebase(wagers[index])
                wagersUpdated = true
            }
            // If user missed today's habits while wager is active
            else if !allHabitsCompletedToday && today >= wager.startDate && today <= wager.endDate {
                // Check if it's end of day (after 11:59 PM) - for now we'll check immediately
                // In production, you might want to wait until end of day
                let calendar = Calendar.current
                if calendar.component(.hour, from: Date()) >= 23 {
                    wagers[index].isWon = false
                    wagers[index].isActive = false
                    
                    NotificationCenter.default.post(
                        name: NSNotification.Name("WagerLost"),
                        object: nil,
                        userInfo: ["amount": wager.amount]
                    )
                    
                    saveWagerToFirebase(wagers[index])
                    wagersUpdated = true
                }
            }
        }
        
        if wagersUpdated {
            NotificationCenter.default.post(name: NSNotification.Name("WagersUpdated"), object: nil)
        }
    }
    
    private func checkWagerCompletion(wager: Wager) -> Bool {
        var currentDate = wager.startDate
        let endDate = wager.endDate
        let activeHabits = habits.filter { !$0.isExtinguished }
        
        guard !activeHabits.isEmpty else { return false }
        
        // Check every day in the wager period
        while currentDate <= endDate {
            let entries = entriesByDay[currentDate] ?? []
            let completedCount = entries.filter { $0.didComplete }.count
            
            // If any day has missing completions, wager is lost
            if completedCount < activeHabits.count {
                return false
            }
            
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? endDate.addingTimeInterval(86400)
        }
        
        return true
    }
    
    func deleteAllUserData(uid: String, completion: @escaping (Bool) -> Void) {
        let group = DispatchGroup()
        var hasError = false
        
        group.enter()
        db.collection("users").document(uid).collection("habits").getDocuments { snapshot, error in
            if let error = error {
                hasError = true
                group.leave()
                return
            }
            
            let deleteBatch = self.db.batch()
            snapshot?.documents.forEach { doc in
                deleteBatch.deleteDocument(doc.reference)
            }
            
            deleteBatch.commit { error in
                if let error = error {
                    hasError = true
                }
                group.leave()
            }
        }
        
        group.enter()
        db.collection("users").document(uid).collection("entries").getDocuments { snapshot, error in
            if let error = error {
                hasError = true
                group.leave()
                return
            }
            
            let deleteBatch = self.db.batch()
            snapshot?.documents.forEach { doc in
                deleteBatch.deleteDocument(doc.reference)
            }
            
            deleteBatch.commit { error in
                if let error = error {
                    hasError = true
                }
                group.leave()
            }
        }
        
        group.enter()
        db.collection("users").document(uid).collection("wallet").document("data").delete { error in
            if let error = error {
                hasError = true
            }
            group.leave()
        }
        
        group.enter()
        db.collection("users").document(uid).collection("settings").document("data").delete { error in
            if let error = error {
                hasError = true
            }
            group.leave()
        }
        
        group.enter()
        db.collection("users").document(uid).collection("inventory").document("data").delete { error in
            if let error = error {
                hasError = true
            }
            group.leave()
        }
        
        group.enter()
        db.collection("users").document(uid).collection("wagers").getDocuments { snapshot, error in
            if let error = error {
                hasError = true
                group.leave()
                return
            }
            
            let deleteBatch = self.db.batch()
            snapshot?.documents.forEach { doc in
                deleteBatch.deleteDocument(doc.reference)
            }
            
            deleteBatch.commit { error in
                if let error = error {
                    hasError = true
                }
                group.leave()
            }
        }
        
        group.enter()
        db.collection("users").document(uid).delete { error in
            if let error = error {
                hasError = true
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            if hasError {
                completion(false)
            } else {
                self.clearUserData()
                self.defaults.removeObject(forKey: Keys.walletBalance)
                self.defaults.removeObject(forKey: Keys.walletTotal)
                self.defaults.removeObject(forKey: Keys.themeKey)
                self.defaults.removeObject(forKey: Keys.notifications)
                self.defaults.removeObject(forKey: Keys.notificationHour)
                self.defaults.removeObject(forKey: Keys.notificationMinute)
                self.defaults.removeObject(forKey: Keys.freezes)
                self.defaults.removeObject(forKey: Keys.multiplierUntil)
                self.defaults.removeObject(forKey: Keys.multiplierStrength)
                self.defaults.removeObject(forKey: Keys.activeFlameColorID)
                self.defaults.removeObject(forKey: Keys.activeBadgeID)
                completion(true)
            }
        }
    }
}

