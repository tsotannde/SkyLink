//
//  ConnectionStatusView.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 10/30/25.
//

import UIKit

final class ConnectionStatusView: UIView
{
    private let statusLabel = UILabel()
    private let timerLabel = UILabel()
    
    private var timer: Timer?
    private var startTime: Date?
    
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        setupView()
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        setupView()
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    private func setupView()
    {
        translatesAutoresizingMaskIntoConstraints = false
        
        statusLabel.text = AppDesign.Text.disconnectedKey //Default Text
        statusLabel.textColor = .label
        statusLabel.font = AppDesign.Fonts.semiBold(ofSize: 16)
        statusLabel.textAlignment = .center
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        timerLabel.text = "00:00:00" //Defualt Timer
        timerLabel.textColor = AppDesign.ColorScheme.TextColors.PrimaryTheme.secondaryText
        timerLabel.font = AppDesign.Fonts.semiBold(ofSize: 14)
        timerLabel.textAlignment = .center
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let infoStack = UIStackView(arrangedSubviews: [statusLabel, timerLabel])
        infoStack.axis = .vertical
        infoStack.alignment = .center
        infoStack.spacing = 5
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(infoStack)
        
        NSLayoutConstraint.activate([
            infoStack.topAnchor.constraint(equalTo: topAnchor),
            infoStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            infoStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            infoStack.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    func setStatus(isConnected: Bool) {
        if isConnected
        {
            if UserDefaults.standard.object(forKey: "lastConnectedDate") == nil {
                UserDefaults.standard.set(Date(), forKey: "lastConnectedDate")
            }
            performStatusTransition(from: "Connected", to: AppDesign.Text.connectedKey, after: 15)
            startTimer()
        } else {
            statusLabel.text = AppDesign.Text.disconnectedKey
            stopTimer()
        }
    }
    
//    func setTimer(text: String)
//    {
//        timerLabel.text = text
//    }
    
    // MARK: - Timer Logic
    private func startTimer() {
        if let savedDate = UserDefaults.standard.object(forKey: "lastConnectedDate") as? Date {
            startTime = savedDate
        } else {
            startTime = Date()
            UserDefaults.standard.set(startTime, forKey: "lastConnectedDate")
        }
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateElapsedTime()
        }

        RunLoop.main.add(timer!, forMode: .common)
    }
    
    private func updateElapsedTime() {
        guard let start = startTime else { return }
        let elapsed = Date().timeIntervalSince(start)
        let hours = Int(elapsed) / 3600
        let minutes = (Int(elapsed) % 3600) / 60
        let seconds = Int(elapsed) % 60
        let formatted = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        timerLabel.text = formatted
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        startTime = nil
        UserDefaults.standard.removeObject(forKey: "lastConnectedDate")
        timerLabel.text = "00:00:00"
    }
    
    func resumeIfConnected() {
        if let savedStartTime = UserDefaults.standard.object(forKey: "lastConnectedDate") as? Date {
            startTime = savedStartTime
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.updateElapsedTime()
            }
            RunLoop.main.add(timer!, forMode: .common)
            updateElapsedTime()
        }
    }
    
    @objc private func appDidBecomeActive() {
        resumeIfConnected()
    }
    
    @objc private func appDidEnterBackground() {
        timer?.invalidate()
        timer = nil
    }
    
    private func performStatusTransition(from initialText: String, to finalText: String, after seconds: Double) {
        statusLabel.text = initialText
        UIView.transition(with: statusLabel, duration: 0.4, options: .transitionCrossDissolve, animations: {
            self.statusLabel.text = initialText
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            UIView.transition(with: self.statusLabel, duration: 0.6, options: .transitionCrossDissolve, animations: {
                self.statusLabel.text = finalText
            })
        }
    }
}
