//
//  HomeViewController.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 10/22/25.
//

import UIKit
import FirebaseAuth
import NetworkExtension
import CoreFoundation

class HomeViewController: UIViewController
{
    // MARK: - UI Components
    internal let gridButton = createGridButton()
    internal let premiumButton = createPremiumButton()
    internal let downloadCard = createDownloadCard()
    internal let uploadCard = createUploadCard()
    internal let connectionStatusView = ConnectionStatusView()
    internal let selectedServerView = SelectedServer()
    internal let powerButtonView = PowerButtonView()
    
    private var connectionCheckTimer: Timer?
    private var currentConnectionState: Bool? = nil
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        hideNavigationBar()
        setBackgroundColor()
        constructUserInterface()
        
        downloadCard.startAutoRefresh(for: AppDesign.AppKeys.UserDefaults.downloadSpeed)
           uploadCard.startAutoRefresh(for: AppDesign.AppKeys.UserDefaults.uploadSpeed)
        
        startTimer()
        monitorNotifications() //Used to upadte the powerbutton state
    }
    
}

//MARK: - User Interface Components
extension HomeViewController
{
    static func createGridButton() -> UIButton
    {
        let button = UIButton(type: .system)
        button.setImage(AppDesign.Images.grid, for: .normal)
        button.tintColor = AppDesign.ColorScheme.Styling.Tint.secondary
        
        // Background Color and Border Color
        button.backgroundColor = AppDesign.ColorScheme.Styling.Background.surface
        button.layer.cornerRadius = 16
        button.layer.borderColor = AppDesign.ColorScheme.Styling.Border.subtle.cgColor
        button.layer.borderWidth = 1
        
        // Depth Drop Shadow for Depth
        button.layer.shadowColor = AppDesign.ColorScheme.Styling.Shadow.standard.cgColor
        button.layer.shadowOpacity = 0.15
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        
        return button
    }
    
    static func createPremiumButton() -> UIButton
    {
        let button = UIButton(type: .system)
        
        // Text setup
        var configuration = UIButton.Configuration.plain()
        var container = AttributeContainer()
        container.font = AppDesign.Fonts.semiBold(ofSize: 16)
        configuration.attributedTitle = AttributedString(AppDesign.Text.HomeViewController.goPremium, attributes: container)
        configuration.imagePadding = 8
        configuration.imagePlacement = .leading
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        button.configuration = configuration
    
        
        button.backgroundColor = AppDesign.ColorScheme.Themes.primary
        
        // Corner radius & shadow
        button.layer.cornerRadius = 16
        button.layer.shadowColor = AppDesign.ColorScheme.Styling.Shadow.standard.cgColor
        button.layer.shadowOpacity = 0.4
        button.layer.shadowRadius = 8
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        
        // Add image to left side of text
        let icon = AppDesign.Images.crown?.withRenderingMode(.alwaysOriginal)
        button.setImage(icon, for: .normal)
        button.tintColor = AppDesign.ColorScheme.Styling.Tint.primaryText
        
        // Rounded Rectanger
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 174).isActive = true
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        return button
    }
    
   
    
    static func createDownloadCard()->StatCard
    {
        let defaults = UserDefaults(suiteName: AppDesign.AppKeys.UserDefaults.suiteName)
        
        var downloadBytes = defaults?.double(forKey: AppDesign.AppKeys.UserDefaults.downloadSpeed) ?? 0
        
        let isConnected = defaults?.bool(forKey: AppDesign.AppKeys.UserDefaults.lastConnectionState) ?? false
        // If not connected, ignore any old stored value and set speed to 0.0
        if !isConnected
        {
            downloadBytes = 0.0
        }
        print("[HomeViewController] Create Downnlaod Card State = : \(isConnected)")
        let state: ConnectionState = isConnected ? .active : .inactive
        print("[HomeViewController] Create Downnlaod  State = : \(state)")
       
        let card = StatCard(title: AppDesign.Text.downloadKey, value: downloadBytes.description, unit: AppDesign.Text.speedUnit, icon: AppDesign.Images.downloadArrow)
        card.update(speed: downloadBytes, state: state)
        return card
    }
    
    static func createUploadCard()->StatCard
    {
        let defaults = UserDefaults(suiteName: AppDesign.AppKeys.UserDefaults.suiteName)
        var uploadBytes = defaults?.double(forKey: AppDesign.AppKeys.UserDefaults.uploadSpeed) ?? 0
        let isConnected = defaults?.bool(forKey: AppDesign.AppKeys.UserDefaults.lastConnectionState) ?? false
        // If not connected, ignore any old stored value and set speed to 0.0
        if !isConnected
        {
            uploadBytes = 0.0
        }
        print("[HomeViewController] Create Upload Card State = : \(isConnected)")
        let state: ConnectionState = isConnected ? .active : .inactive
        print("[HomeViewController] Create Upload Card State = : \(isConnected)")
        
        let card = StatCard(title: AppDesign.Text.uploadKey, value: uploadBytes.description, unit: AppDesign.Text.speedUnit, icon: AppDesign.Images.uploadArrow)
        card.update(speed: uploadBytes, state: state)
        return card
    }
}

//MARK: - Constuct User Interface
extension HomeViewController
{
    func hideNavigationBar()
    {
        NavigationManager.shared.toggleNavigationBar(on: navigationController, animated: false, shouldShow: false)
    }
    
    func setBackgroundColor()
    {
        view.backgroundColor = AppDesign.ColorScheme.App.background
    }
    
    func constructUserInterface()
    {
        addTopBar()
        addStatsSection()
        addSelectedServerSection()
        addConnectionStatusSection()
        addPowerButtonView()
    }
    
    private func addTopBar()
    {
        view.addSubview(gridButton)
        view.addSubview(premiumButton)

        gridButton.translatesAutoresizingMaskIntoConstraints = false
        premiumButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            gridButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            gridButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            gridButton.heightAnchor.constraint(equalToConstant: 48),
            gridButton.widthAnchor.constraint(equalToConstant: 48),

            premiumButton.centerYAnchor.constraint(equalTo: gridButton.centerYAnchor),
            premiumButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            premiumButton.heightAnchor.constraint(equalToConstant: 48),
            premiumButton.widthAnchor.constraint(equalToConstant: 174)
        ])
    }
    
    private func addStatsSection()
    {
        // Stack with just the two cards
        let statsStack = UIStackView(arrangedSubviews: [downloadCard, uploadCard])
        statsStack.axis = .horizontal
        statsStack.alignment = .fill
        statsStack.distribution = .fillEqually
        statsStack.spacing = 0
        statsStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statsStack)

        // Constraints for the stack
        NSLayoutConstraint.activate([
            statsStack.topAnchor.constraint(equalTo: gridButton.bottomAnchor, constant: 25),
            statsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            statsStack.heightAnchor.constraint(equalToConstant: 100)
        ])

        // Hairline divider OVER the stack (not arranged)
        let divider = UIView()
        divider.backgroundColor = .separator
        divider.translatesAutoresizingMaskIntoConstraints = false
        statsStack.addSubview(divider)

        let dividerThickness = 6 / UIScreen.main.scale
        NSLayoutConstraint.activate([
            divider.centerXAnchor.constraint(equalTo: statsStack.centerXAnchor),
            divider.topAnchor.constraint(equalTo: statsStack.topAnchor),
            divider.bottomAnchor.constraint(equalTo: statsStack.bottomAnchor),
            divider.widthAnchor.constraint(equalToConstant: dividerThickness)
        ])

        // Round only outer corners of the cards
        downloadCard.layer.cornerRadius = 15
        uploadCard.layer.cornerRadius = 15
        downloadCard.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        uploadCard.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        downloadCard.layer.masksToBounds = true
        uploadCard.layer.masksToBounds = true
    }
    
    private func addSelectedServerSection()
    {
        view.addSubview(selectedServerView)
        selectedServerView.translatesAutoresizingMaskIntoConstraints = false
        selectedServerView.isUserInteractionEnabled = true
        
        NSLayoutConstraint.activate([
            selectedServerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            selectedServerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            selectedServerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            selectedServerView.heightAnchor.constraint(equalToConstant: 55)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectedServerTapped))
           selectedServerView.addGestureRecognizer(tapGesture)
    }
    
    private func addConnectionStatusSection()
    {
        view.addSubview(connectionStatusView)
        connectionStatusView.translatesAutoresizingMaskIntoConstraints = false
        
        // Restore last known connection state before constraints
        let wasConnected = UserDefaults.standard.bool(forKey: AppDesign.AppKeys.UserDefaults.lastConnectionState)
        connectionStatusView.setStatus(isConnected: wasConnected)
        
        NSLayoutConstraint.activate([
            connectionStatusView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            connectionStatusView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            connectionStatusView.bottomAnchor.constraint(equalTo: selectedServerView.topAnchor, constant: -25)
        ])
    }

    private func addPowerButtonView()
    {
        view.addSubview(powerButtonView)
        powerButtonView.translatesAutoresizingMaskIntoConstraints = false
        powerButtonView.isUserInteractionEnabled = true

        // Restore last known connection state or check current VPN status
        let wasConnected = UserDefaults.standard.bool(forKey: AppDesign.AppKeys.UserDefaults.lastConnectionState)
        powerButtonView.setState(wasConnected ? .connected : .disconnected)
        
        NSLayoutConstraint.activate([
            powerButtonView.centerXAnchor.constraint(equalTo: connectionStatusView.centerXAnchor),
            powerButtonView.bottomAnchor.constraint(equalTo: connectionStatusView.topAnchor, constant: -80),
            powerButtonView.widthAnchor.constraint(equalToConstant: 80),
            powerButtonView.heightAnchor.constraint(equalToConstant: 80),
        ])

        // Set an initial neutral animation before connection state is known
        //powerButtonView.setState(.disconnecting) // or .connecting if you prefer spinning blue
        
        
        
        // Gesture for Power Button
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(powerButtonTapped))
        powerButtonView.addGestureRecognizer(tapGesture)
    }
}

//MARK: - Functions
extension HomeViewController
{
    @objc private func selectedServerTapped()
    {
        print("[HomeViewController] Selected server tapped")
        let viewController = ServerSelectionViewController()
        
        if let sheet = viewController.sheetPresentationController
        {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            
            // Make it appear at the top
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        present(viewController, animated: true, completion: nil)
    }
    
    @objc private func powerButtonTapped()
    {
        print("[HomeViewController] Power button tapped")

        Task {
            let connected = await VPNManager.shared.isConnectedToVPN()
            self.powerButtonView.isUserInteractionEnabled = false
            defer { self.powerButtonView.isUserInteractionEnabled = true }

            if connected {
                // User is connected, so they’re disconnecting
                self.powerButtonView.setState(.disconnecting)
                VPNManager.shared.stopTunnel()
            } else {
                // User is disconnected, so they’re connecting
                self.powerButtonView.setState(.connecting)
                await VPNManager.shared.startTunnel()
            }
        }
    }
}

//MARK: - Timer and Notifications
extension HomeViewController
{
    //MARK: - TIMER
    func startTimer()
    {
        print("[HomeViewController] Starting Connection Check Timer")
        // Start the timer to check connection state every 1 second
        connectionCheckTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true)
        { [weak self] _ in
            
            self?.checkConnectionState()
        }
    }
    
   
    // Timer-based connection state check, replaces Darwin notification updates
    private func checkConnectionState()
    {
        //print("[HomeViewController] Checking Connection State")
        Task
        { [weak self] in
            guard let self = self else { return }
            let connectionStatus = await VPNManager.shared.isConnectedToVPN()
           // print("[HomeViewController] Checked State: Current Connection State: \(connectionStatus)")
            
            DispatchQueue.main.async {
                // Only update if state changed
                if self.currentConnectionState != connectionStatus
                {
                    self.currentConnectionState = connectionStatus
                    UserDefaults.standard.set(connectionStatus, forKey: AppDesign.AppKeys.UserDefaults.lastConnectionState)
                    self.connectionStatusView.setStatus(isConnected: connectionStatus)

                    if connectionStatus {
                       // print("[HomeViewController] State changed → CONNECTED")
                        self.powerButtonView.setState(.connected)
                    } else {
                        //print("[HomeViewController] State changed → DISCONNECTED")
                        self.powerButtonView.setState(.disconnected)
                    }
                } else {
                    // State hasn’t changed, do nothing (avoids re-running animation)
                    //print("[HomeViewController] No state change, skipping animation.")
                }
            }
        }
    }
    
    //MARK: - Notifications
    func monitorNotifications()
    {
        // --- Power Button State Notifications ---
        NotificationCenter.default.addObserver(self, selector: #selector(handleVPNIsConnecting), name: .vpnIsConnecting, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleVPNDidConnect), name: .vpnDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleVPNIsDisconnecting), name: .vpnIsDisconnecting, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleVPNDidDisconnect), name: .vpnDidDisconnect, object: nil)

        // --- Server Update ---
        NotificationCenter.default.addObserver(self, selector: #selector(handleServerDidUpdate), name: .serverDidUpdate, object: nil)
    }
    
    @objc private func handleVPNDidConnect()
       {
           print("[HomeViewController] Notification: VPN Connected")
           DispatchQueue.main.async {
               self.powerButtonView.setState(.connected)
           }
       }
       
       @objc private func handleVPNDidDisconnect()
       {
           print("[HomeViewController] Notification: VPN Disconnected")
           DispatchQueue.main.async
           {
               self.powerButtonView.setState(.disconnected)
           }
       }
       
       @objc private func handleVPNIsConnecting()
       {
           print("[HomeViewController] Notification: VPN Connecting")
           DispatchQueue.main.async {
               self.powerButtonView.setState(.connecting)
           }
       }
       
       @objc private func handleVPNIsDisconnecting()
       {
           print("[HomeViewController] Notification: VPN Disconnecting")
           DispatchQueue.main.async {
               self.powerButtonView.setState(.disconnecting)
           }
       }
    
    @objc private func handleServerDidUpdate()
    {
        print("[HomeViewController] Updating Selected Server View")
        Task { [weak self] in
            //Current VPN Selected
            let currentConfiguration = await ConfigurationManager.shared.getOrSelectServer()
            
            let country = currentConfiguration?.country ?? "United States"
            let city = currentConfiguration?.city ?? "Invalid Configuration"
            let state = currentConfiguration?.state ?? "Invalid Configuration"
            
            selectedServerView.configure(countryName: country, city: city, state: state)
            
        }
    }
}
