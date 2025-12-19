//
//  StatCard.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 10/22/25.
//

import UIKit

//MARK: - ConnectionState
enum ConnectionState
{
    case inactive      // value == 0 → gray
    case active        // value > 0 → green
}

//MARK: - DataUnit
enum DataUnit: String
{
    case kb = "KB"
    case mb = "MB"
    case gb = "GB"
    case tb = "TB"
}

//MARK: - StatCardData
struct StatCardData
{
    let value: Double          // e.g. 512.3
    let unit: DataUnit         // enum below
    let connectionState: ConnectionState
}

enum StatType
{
    case download
    case upload
}

//MARK: - StatCard
class StatCard: UIView
{
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let unitLabel = UILabel()
    private let icon = UIImageView()

    private var refreshTimer: Timer?
    private var statType: StatType
    
    init(statType: StatType)
    {
        self.statType = statType
        super.init(frame: .zero)
        self.registerNotifications() //Register Notifications
        
        backgroundColor = SkyLinkAssets.Colors.whiteColor
        layer.cornerRadius = 15
        layer.shadowColor = SkyLinkAssets.Colors.blackColor?.cgColor
        layer.shadowOpacity = 0.05
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        
        // Create icon container
        let iconContainer = UIView()
        iconContainer.backgroundColor = SkyLinkAssets.Colors.Themes.primary
        iconContainer.layer.cornerRadius = 6
        iconContainer.clipsToBounds = true
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconContainer)
        icon.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(icon)
        
        // Title label
        titleLabel.text = resolveTitle()
        titleLabel.font = SkyLinkAssets.Fonts.semiBold(ofSize: 14)
        titleLabel.textColor = SkyLinkAssets.Colors.blackColor
        
        // Configure icon
        icon.image = resolveImage()
        icon.tintColor = SkyLinkAssets.Colors.whiteColor
        
        // Value label
        valueLabel.text = "0.00"
        valueLabel.font = SkyLinkAssets.Fonts.semiBold(ofSize: 24)
        valueLabel.textColor = SkyLinkAssets.Colors.blackColor
        
        // Unit label
        unitLabel.text = SkyLinkAssets.Text.speedUnit //Defualt Unit MB/s
        unitLabel.font = SkyLinkAssets.Fonts.regular(ofSize: 12)
        unitLabel.textColor = SkyLinkAssets.Colors.greyColor
        
        // Layout
        let valueStack = UIStackView(arrangedSubviews: [valueLabel, unitLabel])
        valueStack.axis = .horizontal
        valueStack.spacing = 4
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel, valueStack])
        textStack.axis = .vertical
        textStack.spacing = 25 //Seprate the Text (Download top value Bottom)
        
        addSubview(textStack)
        
        textStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            textStack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            textStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            
            iconContainer.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            iconContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            iconContainer.widthAnchor.constraint(equalToConstant: 25),
            iconContainer.heightAnchor.constraint(equalToConstant: 25),
            
            icon.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 15),
            icon.heightAnchor.constraint(equalToConstant: 15)
        ])
        
        translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit
    {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension StatCard
{
    private func resolveTitle()->String
    {
        switch self.statType
        {
        case .download:
            return SkyLinkAssets.Text.downloadKey
        case .upload:
            return SkyLinkAssets.Text.uploadKey
        }
    }
    
    private func resolveImage() -> UIImage
    {
        switch self.statType
        {
        case .download:
            return SkyLinkAssets.Images.downloadArrow ?? UIImage(systemName: "arrow.down")!
        case .upload:
            return SkyLinkAssets.Images.uploadArrow ?? UIImage(systemName: "arrow.up")!
        }
    }
}
//MARK: - Notifications
extension StatCard
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
        let key = resolveSpeedKey()
        guard !key.isEmpty else { return }

        startAutoRefresh(for: key)
    }
    
    @objc private func vpnDisconnected()
    {
        stopAutoRefresh()
        DispatchQueue.main.async
        {
                self.update(speed: 0.0, state: .inactive)
        }
    }
    
    @objc private func vpnConnecting()
    {
        valueLabel.textColor = SkyLinkAssets.Colors.Themes.primary
    }
    
    @objc private func vpnIsDisconnecting()
    {
        valueLabel.textColor = SkyLinkAssets.Colors.redColor
    }
    
}

//MARK: - Formatting Functon
extension StatCard
{
    private static func formatSpeed(_ bytesPerSecond: Double) -> (String, String)
    {
        guard bytesPerSecond > 0 else { return ("0.00", "B") }

        let units = ["B", "KB", "MB", "GB", "TB"]
        var value = bytesPerSecond
        var index = 0

        while value >= 1024 && index < units.count - 1 {
            value /= 1024
            index += 1
        }

        let formatted = String(format: "%.2f", value)
        return (formatted, units[index])
    }
    
    private func resolveSpeedKey() -> String
    {
        
        switch self.statType
        {
        case .download:
            return "downloadSpeed"
        case .upload:
            return "uploadSpeed"
        }
    }
}

//MARK: - Update Functon and Timer
extension StatCard
{
    func startAutoRefresh(for key: String)
    {
        refreshTimer?.invalidate()

        refreshTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            // Pull from VPNManager instead of stale UserDefaults
            Task {
                let isConnected = await VPNManager.shared.isConnectedToVPN()

                let defaults = UserDefaults(suiteName: SkyLinkAssets.AppKeys.UserDefaults.suiteName)
                let speedValue = defaults?.double(forKey: key) ?? 0.0

              

                DispatchQueue.main.async
                {
                    if isConnected
                    {
                        self.update(speed: speedValue, state: .active)
                    } else
                    {
                        self.update(speed: 0.0, state: .inactive)
                    }
                }
            }
        }
        RunLoop.main.add(refreshTimer!, forMode: .common)
    }
    
    func update(speed: Double, state: ConnectionState)
    {
        // Determine color
        switch state
        {
        case .inactive:
            valueLabel.textColor = SkyLinkAssets.Colors.greyColor
        case .active:
            valueLabel.textColor = SkyLinkAssets.Colors.greenColor
        }

        // Format speed and unit
        let (formattedValue, unit) = StatCard.formatSpeed(speed)
        UIView.transition(with: valueLabel, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.valueLabel.text = formattedValue
        }, completion: nil)
        UIView.transition(with: unitLabel, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.unitLabel.text = unit
        }, completion: nil)
    }
    
    func stopAutoRefresh()
    {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
}
