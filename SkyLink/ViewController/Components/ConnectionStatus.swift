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
        registerNotifications()
        setupView()
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    //Denits all the Notifications
    deinit
    {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK: - UI Components and Helper Functions
extension ConnectionStatusView
{
    private func setupView()
    {
        //Get the last connection State ie true / false
        let isConnected = UserDefaults.standard.bool(forKey: AppDesign.AppKeys.UserDefaults.lastConnectionState)
        //sets the connection state Text based on the key returned
        statusLabel.text = isConnected ? AppDesign.Text.connectedKey : AppDesign.Text.disconnectedKey

        //Set the Status Label properties
        statusLabel.textColor = UIColor(named: "softWhite") //Primary color
        statusLabel.layer.shadowColor = UIColor(named: "greyColor")?.cgColor //Shadow
        statusLabel.layer.shadowOpacity = 0.8
        statusLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        statusLabel.layer.shadowRadius = 3
        statusLabel.font = AppDesign.Fonts.semiBold(ofSize: 16)//Text
        statusLabel.textAlignment = .center
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
       
        //Set Timer
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

    
    /// Returns the current connection duration as a formatted string in "HH:mm:ss" format.
    /// 
    /// - If the user is not currently connected (`lastConnectionState` is `false`), returns "00:00:00".
    /// - If connected, retrieves the last connection start date from `UserDefaults` using
    ///   `AppDesign.AppKeys.UserDefaults.lastConnectedDate`, calculates the elapsed time since then,
    ///   and formats it as hours, minutes, and seconds.
    /// - If the start date cannot be found, also returns "00:00:00".
    ///
    /// - Returns: A string representing the elapsed connection time in "HH:mm:ss" format.
    private func getCurrentTimerTextSync() -> String
    {
       
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
    private func startTimer()
    {

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
        UserDefaults.standard.removeObject(forKey: AppDesign.AppKeys.UserDefaults.lastConnectedDate)
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

