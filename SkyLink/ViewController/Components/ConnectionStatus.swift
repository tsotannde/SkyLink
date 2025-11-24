//
//  ConnectionStatusView.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 10/30/25.
//

import UIKit

//Fully Self Updating UI Component View Responbile for updating its own UI via a timer.
final class ConnectionStatusView: UIView
{
    private let statusLabel = UILabel()
    private let timerLabel = UILabel()
    private var timer: Timer?
    private var startTime: Date?
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        registerNotifications()
        setupView()
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        registerNotifications()
        setupView()
    }
}

//MARK: - UI Components and Helper Functions
extension ConnectionStatusView
{
    private func setupView()
    {
        let isConnected = UserDefaults.standard.bool(forKey: AppDesign.AppKeys.UserDefaults.lastConnectionState)
        statusLabel.text = isConnected ? AppDesign.Text.connectedKey : AppDesign.Text.disconnectedKey

        
        statusLabel.textColor = UIColor(named: "softWhite") //Primary clor
        statusLabel.layer.shadowColor = UIColor(named: "greyColor")?.cgColor //Shadow
        statusLabel.layer.shadowOpacity = 0.8
        statusLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        statusLabel.layer.shadowRadius = 3
        statusLabel.font = AppDesign.Fonts.semiBold(ofSize: 16)//Text
        statusLabel.textAlignment = .center
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
       
        timerLabel.text = getCurrentTimerTextSync()
        timerLabel.textColor = UIColor(named: "softWhite")
        timerLabel.layer.shadowColor = UIColor(named: "greyColor")?.cgColor
        timerLabel.layer.shadowOpacity = 0.8
        timerLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        timerLabel.layer.shadowRadius = 3
        timerLabel.font = AppDesign.Fonts.semiBold(ofSize: 14)
        timerLabel.textAlignment = .center
        timerLabel.translatesAutoresizingMaskIntoConstraints = false

        translatesAutoresizingMaskIntoConstraints = false

        let infoStack = UIStackView(arrangedSubviews: [statusLabel, timerLabel])
        infoStack.axis = .vertical
        infoStack.alignment = .center
        infoStack.spacing = 8
        infoStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(infoStack)
        NSLayoutConstraint.activate([
            infoStack.topAnchor.constraint(equalTo: topAnchor),
            infoStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            infoStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            infoStack.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    private func getCurrentTimerTextSync() -> String {
        let isConnected = UserDefaults.standard.bool(forKey: AppDesign.AppKeys.UserDefaults.lastConnectionState)

        guard isConnected else { return "00:00:00" }

        guard let savedStart = UserDefaults.standard.object(
            forKey: AppDesign.AppKeys.UserDefaults.lastConnectedDate
        ) as? Date else {
            return "00:00:00"
        }

        let elapsed = Date().timeIntervalSince(savedStart)
        let hours = Int(elapsed) / 3600
        let minutes = (Int(elapsed) % 3600) / 60
        let seconds = Int(elapsed) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

  
}

//MARK: - Timer Functions
extension ConnectionStatusView
{
    private func startTimer() {

    // Restore saved timestamp if exists, else create one
    if let saved = UserDefaults.standard.object(
        forKey: AppDesign.AppKeys.UserDefaults.lastConnectedDate
    ) as? Date {
        startTime = saved
    } else {
        let now = Date()
        startTime = now
        UserDefaults.standard.set(now, forKey: AppDesign.AppKeys.UserDefaults.lastConnectedDate)
    }

    // Reset existing timer
    timer?.invalidate()

    // Start ticking
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
        guard let self = self, let start = self.startTime else { return }
        
        let elapsed = Date().timeIntervalSince(start)

        let hours = Int(elapsed) / 3600
        let minutes = (Int(elapsed) % 3600) / 60
        let seconds = Int(elapsed) % 60

        self.timerLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    RunLoop.main.add(timer!, forMode: .common)
}
    
    private func stopTimer()
    {
        timer?.invalidate()
        timer = nil
        startTime = nil
        UserDefaults.standard.removeObject(forKey: "lastConnectedDate")
        timerLabel.text = "00:00:00"
    }
    
}

//MARK: - Notification and Helper Functons
extension ConnectionStatusView
{
    private func registerNotifications()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(vpnConnected), name: .vpnConnected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(vpnDisconnected), name: .vpnDisconnected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(vpnConnecting), name: .vpnConnecting, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(vpnIsDisconnecting), name: .vpnDisconnecting, object: nil)
    }
    
    @objc private func vpnConnected()
    {
        statusLabel.text = AppDesign.Text.connectedKey
        startTimer()
    }
    
    @objc private func vpnDisconnected()
    {
        statusLabel.text = AppDesign.Text.disconnectedKey
        stopTimer()
    }
    
    @objc private func vpnConnecting()
    {
        statusLabel.text = AppDesign.Text.connectingKey
    }
    
    @objc private func vpnIsDisconnecting()
    {
        statusLabel.text = AppDesign.Text.disconnectingKey
    }
    
}

