// Eternal-CS329E-Group-Project
// Group 15
// Created / Edits done by Ori Parks (lwp369)

import Foundation

// MARK: - Shop Item Type

enum ShopItemType: String, Codable {
    case streakFreeze
    case coinMultiplier
    case streakRecovery
    case autoComplete
    case habitSlot
    case flameColor
    case customTheme
    case badge
    case dailyDeal
}

// MARK: - Shop Item

struct ShopItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var price: Int
    var type: ShopItemType
    var icon: String
    var iconColor: String
    var isLimited: Bool
    var isPurchased: Bool
    let stableKey: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        price: Int,
        type: ShopItemType,
        icon: String = "cart.fill",
        iconColor: String = "#FFFFFF",
        isLimited: Bool = false,
        isPurchased: Bool = false,
        stableKey: String? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.type = type
        self.icon = icon
        self.iconColor = iconColor
        self.isLimited = isLimited
        self.isPurchased = isPurchased
        self.stableKey = stableKey
    }
    
    static var defaultCatalog: [ShopItem] {
        return [
            // Power-ups
            ShopItem(
                name: "Streak Freeze",
                description: "Protect your current streak from breaking if you miss one day.",
                price: 50,
                type: .streakFreeze,
                icon: "snowflake",
                iconColor: "#4FC3F7"
            ),
            ShopItem(
                name: "Double Freeze Pack",
                description: "Receive 2 streak freezes to protect your streak.",
                price: 90,
                type: .streakFreeze,
                icon: "wind.snow",
                iconColor: "#80DEEA"
            ),
            ShopItem(
                name: "Mystery Box",
                description: "Get a random coin reward between 50 and 500 coins.",
                price: 75,
                type: .dailyDeal,
                icon: "gift.fill",
                iconColor: "#FF9800",
                isLimited: true
            ),
            ShopItem(
                name: "24h Coin Multiplier",
                description: "Earn 1.5x coins on all habits for the next 24 hours.",
                price: 100,
                type: .coinMultiplier,
                icon: "sparkles",
                iconColor: "#FFD700"
            ),
            ShopItem(
                name: "7-Day Coin Multiplier",
                description: "Earn 1.5x coins on all habits for the next 7 days.",
                price: 500,
                type: .coinMultiplier,
                icon: "sparkles",
                iconColor: "#FFD700"
            ),
            ShopItem(
                name: "Mega Multiplier",
                description: "Earn 2x coins on all habits for the next 24 hours.",
                price: 250,
                type: .coinMultiplier,
                icon: "bolt.fill",
                iconColor: "#FF5722"
            ),
            ShopItem(
                name: "Streak Recovery",
                description: "Restore up to 7 missed days to your current streak.",
                price: 200,
                type: .streakRecovery,
                icon: "heart.fill",
                iconColor: "#E91E63"
            ),
            ShopItem(
                name: "Auto-Complete Pass",
                description: "Automatically complete all your habits for one day.",
                price: 150,
                type: .autoComplete,
                icon: "checkmark.circle.fill",
                iconColor: "#4CAF50"
            ),
            ShopItem(
                name: "Extra Habit Slot",
                description: "Unlock an additional habit slot (up to a max of 10 slots).",
                price: 300,
                type: .habitSlot,
                icon: "plus.circle.fill",
                iconColor: "#9C27B0"
            ),
            
            // Flame Colors
            ShopItem(
                name: "Cool Blue Flame",
                description: "Change your flame color to a cool blue hue.",
                price: 100,
                type: .flameColor,
                icon: "flame.fill",
                iconColor: "#4FC3F7"
            ),
            ShopItem(
                name: "Mystic Purple Flame",
                description: "Change your flame color to a mystic purple shade.",
                price: 150,
                type: .flameColor,
                icon: "flame.fill",
                iconColor: "#9C27B0"
            ),
            ShopItem(
                name: "Emerald Green Flame",
                description: "Change your flame color to an emerald green tone.",
                price: 150,
                type: .flameColor,
                icon: "flame.fill",
                iconColor: "#4CAF50"
            ),
            ShopItem(
                name: "Rose Gold Flame",
                description: "Change your flame color to a rose gold shade.",
                price: 200,
                type: .flameColor,
                icon: "flame.fill",
                iconColor: "#E91E63"
            ),
            ShopItem(
                name: "Electric Cyan Flame",
                description: "Change your flame color to electric cyan.",
                price: 175,
                type: .flameColor,
                icon: "flame.fill",
                iconColor: "#00BCD4"
            ),
            ShopItem(
                name: "Golden Sun Flame",
                description: "Change your flame color to golden sun yellow.",
                price: 250,
                type: .flameColor,
                icon: "flame.fill",
                iconColor: "#FFC107"
            ),
            ShopItem(
                name: "White Hot Flame",
                description: "Intense white flame for the ultimate dedication.",
                price: 300,
                type: .flameColor,
                icon: "flame.fill",
                iconColor: "#F5F5F5"
            ),
            ShopItem(
                name: "Volcanic Orange Flame",
                description: "Burning hot volcanic orange flame.",
                price: 175,
                type: .flameColor,
                icon: "flame.fill",
                iconColor: "#FF6B35"
            ),
            ShopItem(
                name: "Mint Frost Flame",
                description: "Cool mint colored flame with icy undertones.",
                price: 180,
                type: .flameColor,
                icon: "flame.fill",
                iconColor: "#98FB98"
            ),
            ShopItem(
                name: "Rainbow Flame",
                description: "Unlock the legendary rainbow flame color.",
                price: 1000,
                type: .flameColor,
                icon: "flame.fill",
                iconColor: "#E91E63"
            ),
            
            // Premium Themes (All must be purchased except Default and Dark)
            ShopItem(
                name: "Amber Theme",
                description: "Warm amber glow inspired by ancient flames. Applies across all screens.",
                price: 350,
                type: .customTheme,
                icon: "sun.max.fill",
                iconColor: "#FFA000",
                stableKey: "theme.amber"
            ),
            ShopItem(
                name: "Night Theme",
                description: "Deep purple night sky with soft text and lavender accents. Applies across all screens.",
                price: 400,
                type: .customTheme,
                icon: "moon.stars.fill",
                iconColor: "#5E35B1",
                stableKey: "theme.night"
            ),
            ShopItem(
                name: "Inferno Theme",
                description: "Intense red and orange inferno colors. Applies across all screens.",
                price: 450,
                type: .customTheme,
                icon: "flame.fill",
                iconColor: "#FF4500",
                stableKey: "theme.inferno"
            ),
            ShopItem(
                name: "Forest Theme",
                description: "Natural earthy greens inspired by forest flames. Applies across all screens.",
                price: 400,
                type: .customTheme,
                icon: "leaf.fill",
                iconColor: "#2E7D32",
                stableKey: "theme.forest"
            ),
            ShopItem(
                name: "Sunset Theme",
                description: "Warm sunset oranges and browns. Applies across all screens.",
                price: 400,
                type: .customTheme,
                icon: "sunset.fill",
                iconColor: "#FF6F00",
                stableKey: "theme.sunset"
            ),
            
            // Badges & Cosmetics
            ShopItem(
                name: "Champion Badge",
                description: "Show off your dedication with a champion badge.",
                price: 500,
                type: .badge,
                icon: "trophy.fill",
                iconColor: "#FFD700"
            ),
            ShopItem(
                name: "Royalty Badge",
                description: "Display your royal status and elite dedication.",
                price: 800,
                type: .badge,
                icon: "crown.fill",
                iconColor: "#FFD700"
            )
        ]
    }
}

// MARK: - Purchased Item

struct PurchasedItem: Identifiable, Codable {
    let id: UUID
    let shopItemID: UUID
    let purchaseDate: Date
    let type: ShopItemType
    var isActive: Bool
    
    init(
        id: UUID = UUID(),
        shopItemID: UUID,
        purchaseDate: Date = Date(),
        type: ShopItemType,
        isActive: Bool = false
    ) {
        self.id = id
        self.shopItemID = shopItemID
        self.purchaseDate = purchaseDate
        self.type = type
        self.isActive = isActive
    }
}

// MARK: - Flame Color

struct FlameColor: Identifiable, Codable {
    let id: UUID
    var name: String
    var colorHex: String
    var gradientColors: [String]
    var price: Int
    var isPurchased: Bool
    
    init(
        id: UUID = UUID(),
        name: String,
        colorHex: String,
        gradientColors: [String],
        price: Int,
        isPurchased: Bool = false
    ) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.gradientColors = gradientColors
        self.price = price
        self.isPurchased = isPurchased
    }
    
    static var defaultColors: [FlameColor] {
        return [
            FlameColor(
                name: "Classic Fire",
                colorHex: "#FF6B35",
                gradientColors: ["#FF6B35", "#FFD23F"],
                price: 0,
                isPurchased: true
            ),
            FlameColor(
                name: "Cool Blue",
                colorHex: "#4FC3F7",
                gradientColors: ["#4FC3F7", "#B2EBF2"],
                price: 100,
                isPurchased: false
            ),
            FlameColor(
                name: "Mystic Purple",
                colorHex: "#9C27B0",
                gradientColors: ["#9C27B0", "#E1BEE7"],
                price: 150,
                isPurchased: false
            ),
            FlameColor(
                name: "Emerald Green",
                colorHex: "#4CAF50",
                gradientColors: ["#4CAF50", "#A5D6A7"],
                price: 150,
                isPurchased: false
            ),
            FlameColor(
                name: "Rose Gold",
                colorHex: "#E91E63",
                gradientColors: ["#E91E63", "#F8BBD0"],
                price: 200,
                isPurchased: false
            )
        ]
    }
}

// MARK: - Badge

struct Badge: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var icon: String
    var colorHex: String
    var requirement: Int
    var isUnlocked: Bool
    var unlockedDate: Date?
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        icon: String,
        colorHex: String = "#FFD700",
        requirement: Int,
        isUnlocked: Bool = false,
        unlockedDate: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.colorHex = colorHex
        self.requirement = requirement
        self.isUnlocked = isUnlocked
        self.unlockedDate = unlockedDate
    }
    
    static var defaultBadges: [Badge] {
        return [
            Badge(
                name: "First Step",
                description: "Complete your first habit",
                icon: "star.fill",
                requirement: 1
            ),
            Badge(
                name: "Week Warrior",
                description: "Maintain a 7-day streak",
                icon: "flame.fill",
                requirement: 7
            ),
            Badge(
                name: "Monthly Master",
                description: "Maintain a 30-day streak",
                icon: "crown.fill",
                requirement: 30
            ),
            Badge(
                name: "Hundred Club",
                description: "Maintain a 100-day streak",
                icon: "trophy.fill",
                colorHex: "#FFD700",
                requirement: 100
            ),
            Badge(
                name: "Coin Collector",
                description: "Earn 1,000 total coins",
                icon: "dollarsign.circle.fill",
                colorHex: "#4CAF50",
                requirement: 1000
            ),
            Badge(
                name: "Shopaholic",
                description: "Purchase 10 items from the shop",
                icon: "cart.fill",
                colorHex: "#9C27B0",
                requirement: 10
            )
        ]
    }
}

