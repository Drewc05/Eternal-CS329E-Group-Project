// Eternal-CS329E-Group-Project
// Group 15
// Created / Edits done by Ori Parks (lwp369)

//  Reference guide for consistent animations throughout the app

import UIKit

// MARK: - Animation Constants

enum AnimationDuration {
    static let fast: TimeInterval = 0.2
    static let medium: TimeInterval = 0.3
    static let slow: TimeInterval = 0.5
}

enum AnimationDamping {
    static let tight: CGFloat = 0.8
    static let normal: CGFloat = 0.7
    static let bouncy: CGFloat = 0.5
    static let veryBouncy: CGFloat = 0.4
}

enum SpringVelocity {
    static let gentle: CGFloat = 0.3
    static let normal: CGFloat = 0.5
    static let energetic: CGFloat = 1.0
}

// MARK: - Common Animation Patterns

extension UIView {
    
    // MARK: Button Press Animation
    /// Standard button press feedback - use on all tappable elements
    func animatePress(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: AnimationDuration.fast, animations: {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(
                withDuration: AnimationDuration.fast,
                delay: 0,
                usingSpringWithDamping: AnimationDamping.bouncy,
                initialSpringVelocity: SpringVelocity.normal,
                options: [],
                animations: {
                    self.transform = .identity
                },
                completion: { _ in completion?() }
            )
        }
    }
    
    // MARK: Burst Animation
    /// Dramatic scale-up for celebration moments
    func animateBurst(scale: CGFloat = 1.3, completion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: AnimationDuration.medium,
            delay: 0,
            usingSpringWithDamping: AnimationDamping.veryBouncy,
            initialSpringVelocity: SpringVelocity.energetic,
            options: [],
            animations: {
                self.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        ) { _ in
            UIView.animate(withDuration: AnimationDuration.medium) {
                self.transform = .identity
            } completion: { _ in
                completion?()
            }
        }
    }
    
    // MARK: Fade In
    /// Smooth fade-in with optional scale
    func animateFadeIn(duration: TimeInterval = AnimationDuration.medium, 
                       fromScale: CGFloat = 0.8,
                       completion: (() -> Void)? = nil) {
        alpha = 0
        transform = CGAffineTransform(scaleX: fromScale, y: fromScale)
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: AnimationDamping.normal,
            initialSpringVelocity: SpringVelocity.normal,
            options: [],
            animations: {
                self.alpha = 1.0
                self.transform = .identity
            },
            completion: { _ in completion?() }
        )
    }
    
    // MARK: Pulse Animation
    /// Continuous pulsing for attention
    func startPulsing(scale: CGFloat = 1.1, duration: TimeInterval = 1.5) {
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.duration = duration
        pulse.fromValue = 1.0
        pulse.toValue = scale
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        layer.add(pulse, forKey: "pulse")
    }
    
    func stopPulsing() {
        layer.removeAnimation(forKey: "pulse")
    }
    
    // MARK: Shake Animation
    /// Shake for errors or rejection
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.6
        animation.values = [-20, 20, -20, 20, -10, 10, -5, 5, 0]
        layer.add(animation, forKey: "shake")
    }
}

// MARK: - Haptic Feedback Helper

enum HapticFeedback {
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    static func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    static func heavy() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
    
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
    
    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}


// MARK: - Color Utilities

extension UIColor {
    /// The signature eternal flame color
    static let eternalFlame = UIColor(red: 0.843, green: 0.137, blue: 0.008, alpha: 1)
    
    /// Flame color progression based on streak
    static func flameColor(forStreak streak: Int) -> UIColor {
        switch streak {
        case 0..<7:
            return UIColor(red: 0.843, green: 0.137, blue: 0.008, alpha: 1)
        case 7..<14:
            return UIColor(red: 0.9, green: 0.25, blue: 0.05, alpha: 1)
        case 14..<30:
            return UIColor(red: 0.95, green: 0.35, blue: 0.1, alpha: 1)
        default:
            return UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1)
        }
    }
    
    /// Premium card background
    static let premiumCard = UIColor(white: 1.0, alpha: 0.95)
    
    /// Premium shadow color
    static let premiumShadow = UIColor.black.withAlphaComponent(0.15)
}

// MARK: - Shadow Utilities

extension CALayer {
    /// Apply standard card shadow
    func applyCardShadow() {
        shadowColor = UIColor.black.cgColor
        shadowOffset = CGSize(width: 0, height: 4)
        shadowOpacity = 0.1
        shadowRadius = 8
        masksToBounds = false
    }
    
    /// Apply dramatic shadow for elevated elements
    func applyDramaticShadow() {
        shadowColor = UIColor.black.cgColor
        shadowOffset = CGSize(width: 0, height: 8)
        shadowOpacity = 0.15
        shadowRadius = 16
        masksToBounds = false
    }
    
    /// Apply button shadow with color
    func applyButtonShadow(color: UIColor = .eternalFlame) {
        shadowColor = color.withAlphaComponent(0.4).cgColor
        shadowOffset = CGSize(width: 0, height: 4)
        shadowOpacity = 0.5
        shadowRadius = 8
        masksToBounds = false
    }
}

// MARK: - Design System Constants

enum DesignSystem {
    enum CornerRadius {
        static let small: CGFloat = 12
        static let medium: CGFloat = 16
        static let large: CGFloat = 20
        static let extraLarge: CGFloat = 24
    }
    
    enum Spacing {
        static let tiny: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 20
        static let huge: CGFloat = 24
    }
    
    enum FontSize {
        static let caption: CGFloat = 13
        static let body: CGFloat = 16
        static let headline: CGFloat = 18
        static let title: CGFloat = 22
        static let largeTitle: CGFloat = 34
        static let hero: CGFloat = 56
    }
}
