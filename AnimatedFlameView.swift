// Eternal-CS329E-Group-Project
// Group 15
// Created / Edits done by Ori Parks (lwp369)

import UIKit

/// An animated flame view that flickers and pulses realistically
final class AnimatedFlameView: UIView {
    
    private let flameImageView = UIImageView()
    private let glowLayer = CAGradientLayer()
    private var displayLink: CADisplayLink?
    private var time: CFTimeInterval = 0
    
    var flameColor: UIColor = UIColor(red: 0.843, green: 0.137, blue: 0.008, alpha: 1) {
        didSet {
            flameImageView.tintColor = flameColor
            updateGlowColors()
        }
    }
    
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
        updateGlowColors()
        layer.addSublayer(glowLayer)
        
        // Setup flame image
        flameImageView.image = UIImage(systemName: "flame.fill")
        flameImageView.contentMode = .scaleAspectFit
        flameImageView.tintColor = flameColor
        addSubview(flameImageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        glowLayer.frame = bounds
        flameImageView.frame = bounds
    }
    
    private func updateGlowColors() {
        let color1 = flameColor.withAlphaComponent(0.4)
        let color2 = flameColor.withAlphaComponent(0.2)
        let color3 = flameColor.withAlphaComponent(0.0)
        glowLayer.colors = [color1.cgColor, color2.cgColor, color3.cgColor]
    }
    
    private func updateIntensity() {
        let scale = 0.8 + (intensity * 0.4)
        flameImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        flameImageView.alpha = 0.7 + (intensity * 0.3)
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
        
        // Flickering effect using multiple sine waves
        let flicker1 = sin(time * 8.0) * 0.03
        let flicker2 = sin(time * 12.5) * 0.02
        let flicker3 = sin(time * 15.0) * 0.015
        let totalFlicker = flicker1 + flicker2 + flicker3
        
        // Scale animation
        let breathe = sin(time * 2.0) * 0.05
        let baseScale = 0.8 + (intensity * 0.4)
        let scale = baseScale + breathe + totalFlicker
        
        // Slight rotation for more dynamic movement
        let rotation = sin(time * 3.0) * 0.02
        
        // Apply transforms
        let scaleTransform = CGAffineTransform(scaleX: scale, y: scale + 0.05)
        let rotationTransform = CGAffineTransform(rotationAngle: rotation)
        flameImageView.transform = scaleTransform.concatenating(rotationTransform)
        
        // Opacity flicker
        let opacityBase = 0.7 + (intensity * 0.3)
        let opacityFlicker = sin(time * 10.0) * 0.05
        flameImageView.alpha = opacityBase + opacityFlicker
        
        // Animate glow
        let glowIntensity = 0.3 + (sin(time * 2.5) * 0.1)
        let color1 = flameColor.withAlphaComponent(glowIntensity)
        let color2 = flameColor.withAlphaComponent(glowIntensity * 0.5)
        let color3 = flameColor.withAlphaComponent(0.0)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        glowLayer.colors = [color1.cgColor, color2.cgColor, color3.cgColor]
        CATransaction.commit()
    }
    
    deinit {
        stopAnimating()
    }
}

/// Particle emitter for sparks/embers
final class FlameParticleEmitter: UIView {
    
    private let emitterLayer = CAEmitterLayer()
    
    var flameColor: UIColor = UIColor(red: 0.843, green: 0.137, blue: 0.008, alpha: 1) {
        didSet {
            updateParticleColors()
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
        
        emitterLayer.emitterPosition = CGPoint(x: bounds.midX, y: bounds.maxX)
        emitterLayer.emitterSize = CGSize(width: 20, height: 5)
        emitterLayer.emitterShape = .rectangle
        emitterLayer.renderMode = .additive
        
        let cell = CAEmitterCell()
        cell.birthRate = 10
        cell.lifetime = 3.0
        cell.lifetimeRange = 2
        cell.velocity = 40
        cell.velocityRange = 10
        cell.emissionLongitude = .pi * 1.5 // Upward
        cell.emissionRange = .pi * 0.3
        cell.spin = 2
        cell.spinRange = 2
        cell.scale = 0.07
        cell.scaleRange = 0.02
        cell.alphaSpeed = -0.5
        cell.contents = createParticleImage().cgImage
        
        emitterLayer.emitterCells = [cell]
        layer.addSublayer(emitterLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        emitterLayer.emitterPosition = CGPoint(x: bounds.midX, y: bounds.maxY)
    }
    
    private func createParticleImage() -> UIImage {
        let size = CGSize(width: 10, height: 10)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }
        
        context.setFillColor(flameColor.cgColor)
        context.fillEllipse(in: CGRect(origin: .zero, size: size))
        
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return image
    }
    
    private func updateParticleColors() {
        guard let cell = emitterLayer.emitterCells?.first else { return }
        cell.contents = createParticleImage().cgImage
    }
    
    func startEmitting(streak: Int) {
        let rate = streak
        let clampedRate = [rate, 4].min()
        emitterLayer.birthRate = Float(clampedRate!)
    }
    
    func stopEmitting() {
        emitterLayer.birthRate = 0.0
    }
}
