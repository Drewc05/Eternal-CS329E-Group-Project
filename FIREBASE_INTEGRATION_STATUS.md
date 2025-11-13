# Calendar Fixes & Firebase Integration Status

## ✅ Issues Fixed

### 1. Calendar Height - Day 30 Now Visible
**Change:** Increased calendar height from 380pt to **405pt**

**Result:** All days 1-30 (or 31) now visible!

### 2. Header Text Fixed
**Problem:** Text showing as "------- 🔥 -------" (broken/wrapped)

**Changes:**
- Reduced font size: 18pt → **16pt**
- Reduced icon size: 28pt → **24pt**  
- Tighter padding: 16pt → **12pt**
- Fixed label constraints to prevent wrapping
- Set `numberOfLines = 1` for title
- Set `numberOfLines = 2` for subtitle

**Result:** Clean, readable text "Track Your Journey 🗓️"

### 3. Overall Layout
- Header: **85pt** (compact)
- Calendar: **405pt** (tall enough for all days!)
- Legend: **55pt** (compact)
- Spacing: **12pt** between elements
- Top margin: **8pt**

**Total height:** ~570pt (fits in safe area on all devices)

---

## ⚠️ Firebase Integration Needed

### Current Status
**HabitStore.swift** is using `UserDefaults` for persistence:
- ✅ Works offline
- ❌ No cloud sync
- ❌ Data not shared across devices
- ❌ Calendar not showing completed habits

### What Needs to Be Done

#### 1. Add Firebase Imports
```swift
import Foundation
import FirebaseFirestore
import FirebaseAuth
```

#### 2. Update HabitStore
Replace UserDefaults persistence with Firestore:

**Current:**
```swift
private let defaults = UserDefaults.standard
```

**Needed:**
```swift
private let db = Firestore.firestore()
private let auth = Auth.auth()
```

#### 3. Sync Operations Needed

**Habits:**
- `saveHabits()` → Firestore collection "habits"
- `loadHabits()` → From Firestore
- Real-time listener for updates

**Entries:**
- `addEntry()` → Save to Firestore "entries"
- `loadEntries()` → Load by user ID
- Update `entriesByDay` dictionary

**Wallet:**
- `spendCoins()` → Update Firestore "users/{userId}/wallet"
- `earnCoins()` → Update Firestore

**Wagers:**
- Save/load from Firestore "wagers"

#### 4. Calendar Integration
Update `CalendarPage.swift` to:
- Load entries from Firestore
- Show real-time updates
- Display completion status

---

## 🛠️ Implementation Steps

### Step 1: Add Firebase to HabitStore
```swift
import FirebaseFirestore
import FirebaseAuth

final class HabitStore {
    static let shared = HabitStore()
    
    private let db = Firestore.firestore()
    private var userId: String? {
        return Auth.auth().currentUser?.uid
    }
    
    // ... rest of implementation
}
```

### Step 2: Save Habits to Firestore
```swift
func addHabit(name: String, icon: String) {
    let habit = Habit(name: name, icon: icon)
    habits.append(habit)
    
    // Save to Firestore
    guard let userId = userId else { return }
    let habitData: [String: Any] = [
        "id": habit.id.uuidString,
        "name": habit.name,
        "icon": habit.icon,
        "currentStreak": habit.currentStreak,
        "bestStreak": habit.bestStreak,
        "brightness": habit.brightness,
        "isExtinguished": habit.isExtinguished,
        "timestamp": FieldValue.serverTimestamp()
    ]
    
    db.collection("users")
        .document(userId)
        .collection("habits")
        .document(habit.id.uuidString)
        .setData(habitData)
}
```

### Step 3: Save Entries to Firestore
```swift
func addEntry(_ entry: HabitEntry) {
    let day = entry.date.startOfDay
    entriesByDay[day, default: []].append(entry)
    
    // Save to Firestore
    guard let userId = userId else { return }
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
        .setData(entryData)
}
```

### Step 4: Load Entries for Calendar
```swift
func loadEntries(completion: @escaping () -> Void) {
    guard let userId = userId else {
        completion()
        return
    }
    
    db.collection("users")
        .document(userId)
        .collection("entries")
        .order(by: "date", descending: false)
        .getDocuments { [weak self] snapshot, error in
            guard let documents = snapshot?.documents else {
                completion()
                return
            }
            
            self?.entriesByDay.removeAll()
            
            for doc in documents {
                let data = doc.data()
                // Parse and add to entriesByDay
                // ... conversion logic
            }
            
            completion()
        }
}
```

### Step 5: Update Calendar to Reload Data
```swift
// In CalendarPage.swift
override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Load latest data from Firestore
    store.loadEntries { [weak self] in
        DispatchQueue.main.async {
            self?.calendarView.reloadDecorations(forDateComponents: [], animated: true)
        }
    }
}
```

---

## 📊 Data Structure in Firestore

```
users/
  {userId}/
    habits/
      {habitId}/
        - id: string
        - name: string
        - icon: string
        - currentStreak: int
        - bestStreak: int
        - brightness: double
        - isExtinguished: bool
        - timestamp: timestamp
    
    entries/
      {entryId}/
        - id: string
        - habitID: string
        - date: timestamp
        - didComplete: bool
        - value: double?
        - note: string?
        - timestamp: timestamp
    
    wallet/
      - balance: int
      - totalEarned: int
    
    wagers/
      {wagerId}/
        - amount: int
        - targetDays: int
        - startDate: timestamp
        - endDate: timestamp
        - isActive: bool
        - isWon: bool?
```

---

## 🎯 Why Calendar Isn't Showing Completions

**Current Issue:**
1. User completes habit → Entry saved to `UserDefaults`
2. Calendar loads → Reads from `entriesByDay` dictionary
3. Dictionary is empty on app restart (not persisted)
4. Calendar shows no decorations

**Solution:**
- Save entries to Firestore
- Load entries on calendar view appear
- Calendar will show decorations for completed days

---

## ⚡ Quick Fix (Without Full Firebase)

If you want a temporary fix to see entries on calendar:

**In CalendarPage.swift - viewWillAppear:**
```swift
override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Manually trigger data reload
    store.refreshEntries() // You'd need to implement this
    
    // Reload calendar with latest data
    calendarView.reloadDecorations(forDateComponents: [], animated: true)
}
```

---

## 🚀 Next Steps

1. **Decide on Firebase implementation scope:**
   - Full migration (habits, entries, wallet, wagers)
   - Partial (just entries for calendar)
   - Keep UserDefaults + add Firebase sync

2. **Add authentication:**
   - Users need to be signed in to use Firebase
   - Add sign-in flow if not present

3. **Test thoroughly:**
   - Offline functionality
   - Sync across devices
   - Error handling

4. **Consider migration:**
   - Move existing UserDefaults data to Firebase
   - Or keep dual system temporarily

---

## 💡 Recommendation

Given the complexity of full Firebase integration, I recommend:

1. **Fix calendar first** (DONE ✅)
2. **Add Firebase for entries only** (simpler scope)
3. **Test calendar decorations work**
4. **Then expand to full Firebase** (habits, wallet, etc.)

This way you get the calendar working quickly, then can add more Firebase features incrementally.

---

## ✅ What's Working Now

- Calendar shows all 30/31 days ✅
- Header text displays correctly ✅
- Layout fits perfectly ✅
- Shop system is complete ✅
- Home screen is fixed ✅

## ⚠️ What Needs Work

- Firebase integration for entries
- Calendar decorations (depends on Firebase)
- Cross-device sync
- Real-time updates

Let me know if you'd like me to implement the Firebase integration! I'm ready to help. 🚀
