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
    case kb = "KB/s"
    case mb = "MB/s"
    case gb = "GB/s"
    case tb = "TB/s"
}

//MARK: - StatCardData
struct StatCardData
{
    let value: Double          // e.g. 512.3
    let unit: DataUnit         // enum below
    let connectionState: ConnectionState
}

//MARK: - StatCard
class StatCard: UIView
{
    
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let unitLabel = UILabel()
    private let icon = UIImageView()
    
    private var refreshTimer: Timer?
    
    //init(title: String, value: String, unit: String, iconName: String)
    init(title: String, unit: String)
    {
        super.init(frame: .zero)
        self.registerNotifications() //Register Notifications
        
        backgroundColor = AppDesign.ColorScheme.Styling.Background.surface
        layer.cornerRadius = 15
        layer.shadowColor = AppDesign.ColorScheme.Styling.Shadow.standard.cgColor
        layer.shadowOpacity = 0.05
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        
       
        
        // Create icon container
        let iconContainer = UIView()
        iconContainer.backgroundColor = UIColor(named: "primaryTheme")
       
        iconContainer.layer.cornerRadius = 6
        iconContainer.clipsToBounds = true
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconContainer)
        
        icon.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(icon)
        
        // Title label
        titleLabel.text = title
        titleLabel.font = AppDesign.Fonts.semiBold(ofSize: 14)
        titleLabel.textColor = .darkGray
        
        // Configure icon
        icon.image = resolveImage()
        icon.tintColor = UIColor(red: 0.0, green: 0.325, blue: 0.48, alpha: 1.0)
        
        // Value label
        valueLabel.text = "0.00"
        valueLabel.font = AppDesign.Fonts.semiBold(ofSize: 24)
        valueLabel.textColor = .black
        
        // Unit label
        unitLabel.text = unit
        unitLabel.font = AppDesign.Fonts.regular(ofSize: 12)
        unitLabel.textColor = .gray
        
        // Layout
        let valueStack = UIStackView(arrangedSubviews: [valueLabel, unitLabel])
        valueStack.axis = .horizontal
        valueStack.spacing = 4
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel, valueStack])
        textStack.axis = .vertical
        textStack.spacing = 25 //Seprate the Text (Download top
        
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
    
    //convenience init(title: String, value: String, unit: String, icon: UIImage?) {
    convenience init(title: String, unit: String, icon: UIImage?)
    {
        self.init(title: title, unit: unit)
        // Override the icon image when provided directly
        self.icon.image = icon
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private static func formatSpeed(_ bytesPerSecond: Double) -> (String, String)
    {
        guard bytesPerSecond > 0 else { return ("0.00", "B/s") }

        let units = ["B/s", "KB/s", "MB/s", "GB/s", "TB/s"]
        var value = bytesPerSecond
        var index = 0

        while value >= 1024 && index < units.count - 1 {
            value /= 1024
            index += 1
        }

        let formatted = String(format: "%.2f", value)
        return (formatted, units[index])
    }
    
    // Add this method for updates
    func update(speed: Double, state: ConnectionState)
    {
        // Determine color
        switch state
        {
        case .inactive:
            valueLabel.textColor = .gray
        case .active:
            valueLabel.textColor = .systemGreen
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
    
    

   
}

//MARK: - Timers
extension StatCard
{
    func startAutoRefresh(for key: String)
    {
        refreshTimer?.invalidate()
        print("[StatCard] Starting auto-refresh for key: \(key)")

        refreshTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            // Pull from VPNManager instead of stale UserDefaults
            Task {
                let isConnected = await VPNManager.shared.isConnectedToVPN()

                let defaults = UserDefaults(suiteName: AppDesign.AppKeys.UserDefaults.suiteName)
                let speedValue = defaults?.double(forKey: key) ?? 0.0

                print("[StatCard] Timer fired → connected: \(isConnected), key: \(key), value: \(speedValue)")

                DispatchQueue.main.async {
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
    
    func stopAutoRefresh()
    {
        refreshTimer?.invalidate()
        refreshTimer = nil
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

        print("[StatCard] VPN connected → starting refresh for \(key)")
        startAutoRefresh(for: key)
    }
    
    @objc private func vpnDisconnected()
    {
        
    }
    
    @objc private func vpnConnecting()
    {
        valueLabel.textColor = .systemBlue
    }
    
    @objc private func vpnIsDisconnecting()
    {
        valueLabel.textColor = .red
    }
    
    private func resolveSpeedKey() -> String
    {
        switch titleLabel.text
        {
        case AppDesign.Text.downloadKey:
            return "downloadSpeed"
        case AppDesign.Text.uploadKey:
            return "uploadSpeed"
        default:
            return ""
        }
    }
    
    private func resolveImage() -> UIImage
    {
        switch titleLabel.text
        {
        case AppDesign.Text.downloadKey:
            return AppDesign.Images.downloadArrow ?? UIImage(systemName: "arrow.down")!
        case AppDesign.Text.uploadKey:
            return AppDesign.Images.uploadArrow ?? UIImage(systemName: "arrow.up")!
        default:
            return UIImage(systemName: "arrow.up")!
        }
    }
}
