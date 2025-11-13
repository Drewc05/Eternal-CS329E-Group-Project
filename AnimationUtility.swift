// Eternal-CS329E-Group-Project
// Group 15
// Created / Edits done by Ori Parks (lwp369)

import UIKit

enum AnimationUtility {
    
    // MARK: - Spring Animations
    
    static func springScale(_ view: UIView, scale: CGFloat = 1.1, duration: TimeInterval = 0.4, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: [.curveEaseInOut], animations: {
            view.transform = CGAffineTransform(scaleX: scale, y: scale)
        }) { _ in
            UIView.animate(withDuration: duration * 0.5) {
                view.transform = .identity
            } completion: { _ in
                completion?()
            }
        }
    }
    
    static func bounceIn(_ view: UIView, duration: TimeInterval = 0.6, delay: TimeInterval = 0) {
        view.alpha = 0
        view.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [.curveEaseOut], animations: {
            view.alpha = 1
            view.transform = .identity
        })
    }
    
    // MARK: - Fade Animations
    
    static func fadeIn(_ view: UIView, duration: TimeInterval = 0.3, delay: TimeInterval = 0, completion: (() -> Void)? = nil) {
        view.alpha = 0
        UIView.animate(withDuration: duration, delay: delay, options: [.curveEaseIn], animations: {
            view.alpha = 1
        }) { _ in
            completion?()
        }
    }
    
    static func fadeOut(_ view: UIView, duration: TimeInterval = 0.3, delay: TimeInterval = 0, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration, delay: delay, options: [.curveEaseOut], animations: {
            view.alpha = 0
        }) { _ in
            completion?()
        }
    }
    
    // MARK: - Slide Animations
    
    static func slideInFromBottom(_ view: UIView, distance: CGFloat = 100, duration: TimeInterval = 0.5, delay: TimeInterval = 0) {
        view.transform = CGAffineTransform(translationX: 0, y: distance)
        view.alpha = 0
        
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [.curveEaseOut], animations: {
            view.transform = .identity
            view.alpha = 1
        })
    }
    
    static func slideInFromTop(_ view: UIView, distance: CGFloat = 100, duration: TimeInterval = 0.5, delay: TimeInterval = 0) {
        view.transform = CGAffineTransform(translationX: 0, y: -distance)
        view.alpha = 0
        
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [.curveEaseOut], animations: {
            view.transform = .identity
            view.alpha = 1
        })
    }
    
    // MARK: - Shake Animation
    
    static func shake(_ view: UIView, intensity: CGFloat = 10, duration: TimeInterval = 0.5) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = duration
        animation.values = [-intensity, intensity, -intensity * 0.8, intensity * 0.8, -intensity * 0.5, intensity * 0.5, 0]
        view.layer.add(animation, forKey: "shake")
    }
    
    // MARK: - Pulse Animation
    
    static func addPulse(to view: UIView, scale: CGFloat = 1.05, duration: TimeInterval = 1.0, repeatCount: Float = .infinity) {
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.duration = duration
        pulse.fromValue = 1.0
        pulse.toValue = scale
        pulse.autoreverses = true
        pulse.repeatCount = repeatCount
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        view.layer.add(pulse, forKey: "pulse")
    }
    
    static func removePulse(from view: UIView) {
        view.layer.removeAnimation(forKey: "pulse")
    }
    
    // MARK: - Glow Animation
    
    static func addGlow(to view: UIView, color: UIColor, radius: CGFloat = 10, opacity: Float = 0.8) {
        view.layer.shadowColor = color.cgColor
        view.layer.shadowRadius = radius
        view.layer.shadowOpacity = opacity
        view.layer.shadowOffset = .zero
        view.layer.masksToBounds = false
        
        let glow = CABasicAnimation(keyPath: "shadowOpacity")
        glow.fromValue = opacity
        glow.toValue = opacity * 0.5
        glow.duration = 1.5
        glow.autoreverses = true
        glow.repeatCount = .infinity
        view.layer.add(glow, forKey: "glow")
    }
    
    static func removeGlow(from view: UIView) {
        view.layer.removeAnimation(forKey: "glow")
        view.layer.shadowOpacity = 0
    }
    
    // MARK: - Confetti Effect (Simple)
    
    static func celebrateWithEmojis(in view: UIView, emojis: [String] = ["🔥", "⭐️", "✨", "💪", "🎉"], count: Int = 20) {
        for i in 0..<count {
            let emoji = emojis.randomElement() ?? "🔥"
            let label = UILabel()
            label.text = emoji
            label.font = .systemFont(ofSize: 30)
            
            let startX = CGFloat.random(in: 0...view.bounds.width)
            label.frame = CGRect(x: startX, y: -50, width: 40, height: 40)
            view.addSubview(label)
            
            let delay = Double(i) * 0.05
            let duration = Double.random(in: 1.5...2.5)
            let endY = view.bounds.height + 50
            
            UIView.animate(withDuration: duration, delay: delay, options: [.curveEaseIn], animations: {
                label.frame.origin.y = endY
                label.alpha = 0
                label.transform = CGAffineTransform(rotationAngle: .pi * 2)
            }) { _ in
                label.removeFromSuperview()
            }
        }
    }
}
