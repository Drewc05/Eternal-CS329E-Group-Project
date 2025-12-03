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
    - Created the drop down menu in the calendar page where you can select the specific calendar display for your habit
    - linked each day of the calendar to the specific notes written for the habit that day
    - expanded firebase to save the notes you write each day
    - improved the writing notes function so you don't have to backspace all the placeholder text
    - resized the calendar to fit every day

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

Final Release

Colin
- Improved software keyboard functionality on Login/Signup screens
- Made tab bar more readable by changing colors and code structure
- Made layouts more consistent. Notably standardized title sizes
- Improved the calendar screen
    - Made it scrollable
    - Removed the legend
- Made the flame particles on the dashboard flow vertically, and slightly increase in rate for the first couple days of a new streak

Drew
- Added a delete habit option, press hold on a habit on the dashboard and an option to delete will appear
- Added a change password button in the settings that functions similar to the forgot password button in the login page
- Changed notifications so now on the settings screen if you click the notifications button you can pick what specific time you would like to recieve your daily reminder
- added a delete account button on the settings screen
- implemented firebase for all these new features
- altered calendar screen so it is scrollable and the bottom of the calendar isn't cut off anymore
