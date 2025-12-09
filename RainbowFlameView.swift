// Eternal-CS329E-Group-Project
// Group 15
// Created / Edits done by Ori Parks (lwp369)

import UIKit

/// A special animated flame view that cycles through rainbow colors
final class RainbowFlameView: UIView {
    
    private let flameImageView = UIImageView()
    private let glowLayer = CAGradientLayer()
    private var displayLink: CADisplayLink?
    private var time: CFTimeInterval = 0
    
    private let rainbowColors: [UIColor] = [
        UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0),      // Red
        UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0),      // Orange
        UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0),      // Yellow
        UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0),      // Green
        UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0),      // Blue
        UIColor(red: 0.5, green: 0.0, blue: 1.0, alpha: 1.0),      // Purple
        UIColor(red: 1.0, green: 0.0, blue: 0.5, alpha: 1.0)       // Pink
    ]
    
    var intensity: Double = 1.0 {
        didSet {
            updateIntensity()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .clear
        
        // Setup glow layer
        glowLayer.type = .radial
        glowLayer.startPoint = CGPoint(x: 0.5, y: 0.7)
        glowLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        layer.addSublayer(glowLayer)
        
        // Setup flame image
        flameImageView.image = UIImage(systemName: "flame.fill")
        flameImageView.contentMode = .scaleAspectFit
        addSubview(flameImageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        glowLayer.frame = bounds
        flameImageView.frame = bounds
    }
    
    private func updateIntensity() {
        let scale = 0.8 + (intensity * 0.4)
        flameImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        flameImageView.alpha = 0.7 + (intensity * 0.3)
    }
    
    private func getCurrentColor(at time: CFTimeInterval) -> UIColor {
        // Cycle through colors smoothly
        let colorCycleDuration: CFTimeInterval = 3.0 // Complete rainbow every 3 seconds
        let normalizedTime = (time.truncatingRemainder(dividingBy: colorCycleDuration)) / colorCycleDuration
        let colorIndex = normalizedTime * Double(rainbowColors.count)
        
        let index1 = Int(floor(colorIndex)) % rainbowColors.count
        let index2 = (index1 + 1) % rainbowColors.count
        let fraction = CGFloat(colorIndex.truncatingRemainder(dividingBy: 1.0))
        
        // Interpolate between two colors
        return interpolateColor(from: rainbowColors[index1], to: rainbowColors[index2], fraction: fraction)
    }
    
    private func interpolateColor(from color1: UIColor, to color2: UIColor, fraction: CGFloat) -> UIColor {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        return UIColor(
            red: r1 + (r2 - r1) * fraction,
            green: g1 + (g2 - g1) * fraction,
            blue: b1 + (b2 - b1) * fraction,
            alpha: a1 + (a2 - a1) * fraction
        )
    }
    
    func startAnimating() {
        guard displayLink == nil else { return }
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.add(to: .current, forMode: .common)
    }
    
    func stopAnimating() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func update(displayLink: CADisplayLink) {
        time += displayLink.duration
        
        // Get current rainbow color
        let currentColor = getCurrentColor(at: time)
        flameImageView.tintColor = currentColor
        
        // Flickering effect
        let flicker1 = sin(time * 8.0) * 0.03
        let flicker2 = sin(time * 12.5) * 0.02
        let flicker3 = sin(time * 15.0) * 0.015
        let totalFlicker = flicker1 + flicker2 + flicker3
        
        // Scale animation
        let breathe = sin(time * 2.0) * 0.05
        let baseScale = 0.8 + (intensity * 0.4)
        let scale = baseScale + breathe + totalFlicker
        
        // Slight rotation
        let rotation = sin(time * 3.0) * 0.02
        
        // Apply transforms
        let scaleTransform = CGAffineTransform(scaleX: scale, y: scale + 0.05)
        let rotationTransform = CGAffineTransform(rotationAngle: rotation)
        flameImageView.transform = scaleTransform.concatenating(rotationTransform)
        
        // Opacity flicker
        let opacityBase = 0.7 + (intensity * 0.3)
        let opacityFlicker = sin(time * 10.0) * 0.05
        flameImageView.alpha = opacityBase + opacityFlicker
        
        // Animate glow with rainbow color
        let glowIntensity = 0.3 + (sin(time * 2.5) * 0.1)
        let color1 = currentColor.withAlphaComponent(glowIntensity)
        let color2 = currentColor.withAlphaComponent(glowIntensity * 0.5)
        let color3 = currentColor.withAlphaComponent(0.0)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        glowLayer.colors = [color1.cgColor, color2.cgColor, color3.cgColor]
        CATransaction.commit()
    }
    
    deinit {
        stopAnimating()
    }
}
