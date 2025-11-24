//
//  PowerButtonView.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 10/30/25.
//

enum PowerButtonState
{
    case connected
    case disconnected
    case connecting
    case disconnecting
}

import UIKit

final class PowerButtonView: UIView
{
    private let outerCircle = UIView()
    private let middleCircle = UIView()
    private let innerCircle = UIView()
    private let powerIcon = UIImageView()
    private var currentState: PowerButtonState = .disconnected

    // MARK: - Init
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        setupView()
    }

    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        
        setupView()
    }
    
    @objc private func appDidBecomeActive() {
        // Re-run the current animation when the app becomes active again
        setState(currentState)
    }
    private func setupView()
    {
        translatesAutoresizingMaskIntoConstraints = false
        
        // Circle sizes
        let outerCircleSize: CGFloat = 130
        let middleCircleSize: CGFloat = 110
        let innerCircleSize: CGFloat = 105
        
        // Outer circle
        outerCircle.backgroundColor = AppDesign.ColorScheme.Themes.primary
        outerCircle.layer.cornerRadius = outerCircleSize / 2
        outerCircle.translatesAutoresizingMaskIntoConstraints = false

        // Shadow for depth
        outerCircle.layer.shadowColor = AppDesign.ColorScheme.Styling.Shadow.standard.cgColor
        outerCircle.layer.shadowOpacity = 0.25
        outerCircle.layer.shadowOffset = CGSize(width: 0, height: 6)
        outerCircle.layer.shadowRadius = 10
        outerCircle.layer.masksToBounds = false
        
        // Middle circle
        middleCircle.backgroundColor = AppDesign.ColorScheme.Styling.Background.surface
        middleCircle.layer.cornerRadius = middleCircleSize / 2
        middleCircle.translatesAutoresizingMaskIntoConstraints = false
        
        // Inner circle
        innerCircle.backgroundColor = AppDesign.ColorScheme.Themes.primary
        innerCircle.layer.cornerRadius = innerCircleSize / 2
        innerCircle.clipsToBounds = true
        innerCircle.translatesAutoresizingMaskIntoConstraints = false
        
        // Power icon
        powerIcon.image = UIImage(systemName: "power")
        powerIcon.tintColor = .white
        powerIcon.contentMode = .scaleAspectFit
        powerIcon.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(outerCircle)
        addSubview(middleCircle)
        addSubview(innerCircle)
        innerCircle.addSubview(powerIcon)
        
        NSLayoutConstraint.activate([
            outerCircle.centerXAnchor.constraint(equalTo: centerXAnchor),
            outerCircle.centerYAnchor.constraint(equalTo: centerYAnchor),
            outerCircle.widthAnchor.constraint(equalToConstant: outerCircleSize),
            outerCircle.heightAnchor.constraint(equalToConstant: outerCircleSize),
            
            middleCircle.centerXAnchor.constraint(equalTo: centerXAnchor),
            middleCircle.centerYAnchor.constraint(equalTo: centerYAnchor),
            middleCircle.widthAnchor.constraint(equalToConstant: middleCircleSize),
            middleCircle.heightAnchor.constraint(equalToConstant: middleCircleSize),
            
            innerCircle.centerXAnchor.constraint(equalTo: centerXAnchor),
            innerCircle.centerYAnchor.constraint(equalTo: centerYAnchor),
            innerCircle.widthAnchor.constraint(equalToConstant: innerCircleSize),
            innerCircle.heightAnchor.constraint(equalToConstant: innerCircleSize),
            
            powerIcon.centerXAnchor.constraint(equalTo: innerCircle.centerXAnchor),
            powerIcon.centerYAnchor.constraint(equalTo: innerCircle.centerYAnchor),
            powerIcon.widthAnchor.constraint(equalToConstant: 40),
            powerIcon.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
}

extension PowerButtonView
{
    func setState(_ state: PowerButtonState)
    {
        currentState = state
        
        switch state {
        case .connected:
            print("Connected")
            connectedAnimation()
        case .disconnected:
            print("Disconnected Animation Started")
            disconnectedAnimation()
        case .connecting:
            print("[Power Button] Settting PowerButton to Connecting State ")
            connectingAnimation()
        case .disconnecting:
            print("Stop Tunnel")
            disconnectingAnimation()
        }
    }
}

extension PowerButtonView
{
    
    private func connectedAnimation2() {
        // First, remove the spinner layer if it exists
        middleCircle.layer.sublayers?.removeAll(where: { $0.name == "spinnerLayer" })
        
        // Reset the middle circle’s background to solid (if you want to make it clean)
        middleCircle.backgroundColor = AppDesign.ColorScheme.Styling.Background.surface
        
        // Base colors for both circles
        outerCircle.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.9)
        innerCircle.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.9)
        
        // Create a shared color pulse animation
        let colorPulse = CABasicAnimation(keyPath: "backgroundColor")
        colorPulse.fromValue = UIColor.systemGreen.withAlphaComponent(0.9).cgColor
        colorPulse.toValue = UIColor.systemGreen.withAlphaComponent(0.4).cgColor
        colorPulse.duration = 1.2
        colorPulse.autoreverses = true
        colorPulse.repeatCount = .infinity
        colorPulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        // Add the animation to both layers
        outerCircle.layer.add(colorPulse, forKey: "connectedPulseOuter")
        innerCircle.layer.add(colorPulse, forKey: "connectedPulseInner")
    }
    
    private func connectedAnimation() {
        print("Running connected animation...")

        // 1. Remove all previous animations and reset states
        outerCircle.layer.removeAllAnimations()
        innerCircle.layer.removeAllAnimations()
        middleCircle.layer.sublayers?.removeAll(where: { $0.name == "spinnerLayer" })
        layer.removeAnimation(forKey: "connectingScalePulse")

        // Explicitly clear any lingering red (from CABasicAnimation)
        CATransaction.begin()
        CATransaction.setDisableActions(true) // Disable implicit animations
        outerCircle.layer.removeAnimation(forKey: "disconnectedPulseOuter")
        innerCircle.layer.removeAnimation(forKey: "disconnectedPulseInner")
        outerCircle.layer.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.9).cgColor
        innerCircle.layer.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.9).cgColor
        middleCircle.backgroundColor = AppDesign.ColorScheme.Styling.Background.surface
        CATransaction.commit()

        // 2. Add quick “pop” feedback animation
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.6,
                       options: [.curveEaseInOut],
                       animations: {
            self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            UIView.animate(withDuration: 0.4,
                           delay: 0,
                           options: [.curveEaseInOut],
                           animations: {
                self.transform = .identity
            })
        }

        // 3. Add subtle “breathing” pulse
        let colorPulse = CABasicAnimation(keyPath: "backgroundColor")
        colorPulse.fromValue = UIColor.systemGreen.withAlphaComponent(0.9).cgColor
        colorPulse.toValue = UIColor.systemGreen.withAlphaComponent(0.6).cgColor
        colorPulse.duration = 1.5
        colorPulse.autoreverses = true
        colorPulse.repeatCount = .infinity
        colorPulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        outerCircle.layer.add(colorPulse, forKey: "connectedPulseOuter")
        innerCircle.layer.add(colorPulse, forKey: "connectedPulseInner")

        // 4. Add gentle scale breathing
        let breathing = CABasicAnimation(keyPath: "transform.scale")
        breathing.fromValue = 1.0
        breathing.toValue = 1.03
        breathing.duration = 2.0
        breathing.autoreverses = true
        breathing.repeatCount = .infinity
        breathing.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        self.layer.add(breathing, forKey: "connectedBreathing")
    }
   
   
    private func connectingAnimation()
    {
        middleCircle.backgroundColor = UIColor.systemGray5.withAlphaComponent(0.4)
        middleCircle.layer.sublayers?.removeAll(where: { $0.name == "spinnerLayer" })
        
        let radius = min(middleCircle.bounds.width, middleCircle.bounds.height) / 2 - 2
        
        // Create spinner layer
        let spinnerLayer = CAShapeLayer()
        spinnerLayer.name = "spinnerLayer"
        
        // Create path at (0,0) since we'll position using anchorPoint
        let path = UIBezierPath(
            arcCenter: CGPoint(x: radius, y: radius), // Offset by radius
            radius: radius,
            startAngle: -(.pi / 2),
            endAngle: .pi / 2,
            clockwise: true
        )
        
        spinnerLayer.path = path.cgPath
        spinnerLayer.fillColor = UIColor.clear.cgColor
        spinnerLayer.strokeColor = UIColor.white.cgColor
        spinnerLayer.lineWidth = 3
        spinnerLayer.lineCap = .round
        spinnerLayer.strokeEnd = 1.0
        
        // Set the frame and anchor point
        spinnerLayer.bounds = CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2)
        spinnerLayer.position = CGPoint(x: middleCircle.bounds.midX, y: middleCircle.bounds.midY)
        spinnerLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5) // Rotate around center
        
        middleCircle.layer.addSublayer(spinnerLayer)
        
        // Rotate animation
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = 2 * CGFloat.pi
        rotationAnimation.duration = 1.5
        rotationAnimation.repeatCount = .infinity
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        
        // Pulse animation
        let pulseAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pulseAnimation.fromValue = 0.3
        pulseAnimation.toValue = 0.7
        pulseAnimation.duration = 0.8
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        spinnerLayer.add(rotationAnimation, forKey: "rotation")
        spinnerLayer.add(pulseAnimation, forKey: "pulse")
        
        // Add a subtle scale pulse to the whole button for a "connecting" feel
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 0.95
        scaleAnimation.toValue = 1.0
        scaleAnimation.duration = 1.2
        scaleAnimation.autoreverses = true
        scaleAnimation.repeatCount = .infinity
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        self.layer.add(scaleAnimation, forKey: "connectingScalePulse")
    }
   
    private func disconnectedAnimation()
    {
        print("Running disconnect Animation ")
        // Base colors for both circles
        outerCircle.backgroundColor = UIColor.systemRed.withAlphaComponent(0.9)
        innerCircle.backgroundColor = UIColor.systemRed.withAlphaComponent(0.9)
        
        // Create a shared color pulse animation
        let colorPulse = CABasicAnimation(keyPath: "backgroundColor")
        colorPulse.fromValue = UIColor.systemRed.withAlphaComponent(0.9).cgColor
        colorPulse.toValue = UIColor.systemRed.withAlphaComponent(0.4).cgColor
        colorPulse.duration = 1.2
        colorPulse.autoreverses = true
        colorPulse.repeatCount = .infinity
        colorPulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        // Add the animation to both layers
        outerCircle.layer.add(colorPulse, forKey: "disconnectedPulseOuter")
        innerCircle.layer.add(colorPulse, forKey: "disconnectedPulseInner")
    }
    
    private func disconnectingAnimation()
    {
        // 1. Clean up any active layers or animations
        middleCircle.layer.sublayers?.removeAll(where: { $0.name == "spinnerLayer" })
        layer.removeAnimation(forKey: "connectingScalePulse")

        // 2. Create a smooth color transition from green to red
        let colorTransition = CABasicAnimation(keyPath: "backgroundColor")
        colorTransition.fromValue = UIColor.systemGreen.withAlphaComponent(0.9).cgColor
        colorTransition.toValue = UIColor.systemRed.withAlphaComponent(0.9).cgColor
        colorTransition.duration = 1.0
        colorTransition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        colorTransition.fillMode = .forwards
        colorTransition.isRemovedOnCompletion = false

        // Apply color transition to both circles
        outerCircle.layer.add(colorTransition, forKey: "disconnectColor")
        innerCircle.layer.add(colorTransition, forKey: "disconnectColorInner")

        // 3. Add a subtle “power down” shrink animation to the whole button
        UIView.animate(withDuration: 0.9, delay: 0, options: [.curveEaseInOut]) {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.alpha = 0.7
        } completion: { _ in
            // 4. Bounce back to normal size and start disconnected pulse
            UIView.animate(withDuration: 0.6, delay: 0, options: [.curveEaseOut]) {
                self.transform = .identity
                self.alpha = 1.0
            } completion: { _ in
                self.disconnectedAnimation()
            }
        }
    }
}
