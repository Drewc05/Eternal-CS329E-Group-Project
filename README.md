#  README

Beta Release

Contributions

    Colin
    - Login and Sign Up Screens + Functionality
    - Firebase Auth integration and Firebase project creation
    - Deleted duplicate files preventing project from building
    - Forgot password/Sign out functionality
    - Created Firestore Database infrastructure
    - Calendar page initial implementation with UICalendarView
    - Calendar delegate and selection handling
    
    Ori
    - Real-time data persistence with cloud sync
    - Calendar loads from Firebase on every view
    - Fixed calendar layout to show ALL days (1-30/31)
    - Removed navigation bar for extra space
    - Increased calendar height from 320pt to 420pt
    - Added SF Rounded fonts throughout app
    - Implemented emoji-based legend (completed/missed days)
    - Added contextual stats messages with animations
    - Redesigned home screen header to horizontal layout
    - Created animated flame with particle effects at 60fps
    - Flame color progression based on streak milestones
    - Haptic feedback on check-in
    - Spring animations throughout app
    - Shop system overhaul with 21 unique items
    - Custom alert system for purchases with item descriptions
    - Insufficient funds handling
    - Confirmation dialogs before purchase
    - Success animations with haptic feedback
    - Fixed scrolling to display all shop items
    - Created custom SF Rounded font extension
    - Consistent typography hierarchy throughout app
    - Professional shadow system
    - Unified color palette with theme support
    - Fixed all layout constraint issues
    - Resolved duplicate file redeclaration errors
    - Optimized collection view layouts
    - Proper safe area handling throughout
    - Memory-efficient animations with cleanup
    - 60fps performance maintained
    - Created reusable animation utilities
    - Comprehensive documentation
    
    Drew
    - Implemented Firebase/Firestore functionality so all habits/streaks save
    - expanded firebase to include shop purchases
    - 

Deviations
    - Enhanced beyond original scope with sophisticated animations and cloud sync
    - Removed unnecessary navigation bars for better space utilization
    - Upgraded shop from simple purchase to detailed confirmation flows
    - Created comprehensive design system with typography and spacing standards
│   ├── Dashboard.swift
│   ├── CalendarPage.swift (Enhanced)
│   ├── ShopViewController.swift (Overhauled)
│   ├── Login.swift
│   └── SignUp.swift
├── Custom Components/
│   ├── AnimatedFlameView.swift (NEW)
│   ├── DashboardHeaderView.swift (Enhanced)
│   ├── ShopItemCell.swift (Enhanced)
│   └── DashboardHabitItemCell.swift (Enhanced)
├── Utilities/
│   ├── Theme.swift
│   ├── UIFont+Rounded.swift (NEW)
│   └── AnimationUtilities.swift (NEW)
└── App/
    ├── AppDelegate.swift (Firebase configured)
    └── SceneDelegate.swift
```

---


