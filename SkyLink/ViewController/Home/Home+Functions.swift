//
//  Home+Functions.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 11/21/25.
//

import Foundation

//MARK: - Direct User Interaction Functons
extension HomeViewController
{
    //Notifincations for updating the HomeViewController
    func monitorNotifications()
    {
        // --- Power Button State Notifications ---
        NotificationCenter.default.addObserver(self, selector: #selector(handleVPNIsConnecting), name: .vpnConnecting, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleVPNDidConnect), name: .vpnConnected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleVPNIsDisconnecting), name: .vpnDisconnecting, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleVPNDidDisconnect), name: .vpnDisconnected, object: nil)

        // --- Server Update ---
        NotificationCenter.default.addObserver(self, selector: #selector(handleServerDidUpdate), name: .serverDidUpdate, object: nil)
    }
    
    @objc internal func selectedServerTapped()
    {
        AppLogger.shared.log("[Home] User Clicked the ServerSelector View")
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
    
    @objc internal func powerButtonTapped()
    {
        AppLogger.shared.log("[Home] Power Button Tapped")
        
        Task
        {
            let connected = await VPNManager.shared.isConnectedToVPN()
            AppLogger.shared.log("[Home] VPN Status is \(connected)")
            
            self.powerButtonView.isUserInteractionEnabled = false //Disables user from tapping button again
            defer { self.powerButtonView.isUserInteractionEnabled = true }
            
            if connected
            {
                AppLogger.shared.log("[Home] Disconnecting VPN and Stopping Tunnel")
                self.powerButtonView.setState(.disconnecting)
                NotificationCenter.default.post(name: .vpnDisconnecting, object: nil)
                VPNManager.shared.stopTunnel()
            } else
            {
                AppLogger.shared.log("[Home] Connecting VPN and Starting Tunnel")
                self.powerButtonView.setState(.connecting)
                NotificationCenter.default.post(name: .vpnConnecting, object: nil)
                VPNManager.shared.startTunnel()
            }
        }
    }
}

//MARK: - VPN State Function
extension HomeViewController
{
    @objc private func handleVPNDidConnect()
    {
        AppLogger.shared.log("[Home] VPN Connected")
        DispatchQueue.main.async
        {
            self.powerButtonView.setState(.connected)
        }
    }
    
    @objc private func handleVPNDidDisconnect()
    {
        AppLogger.shared.log("[Home] VPN Disconnected")
        DispatchQueue.main.async
        {
            self.powerButtonView.setState(.disconnected)
        }
    }
    
    @objc private func handleVPNIsConnecting()
    {
        AppLogger.shared.log("[Home] VPN Connecting")
        DispatchQueue.main.async
        {
            self.powerButtonView.setState(.connecting)
        }
    }
    
    @objc private func handleVPNIsDisconnecting()
    {
        AppLogger.shared.log("[Home] VPN Disconnecting")
        DispatchQueue.main.async {
            self.powerButtonView.setState(.disconnecting)
        }
    }
    
    @objc private func handleServerDidUpdate()
    {
        //Update Server Selection View
        AppLogger.shared.log("[Home] New Server Selected. Updating UI")
        Task { [weak self] in
            //Current VPN Selected
            let currentConfiguration = await ConfigurationManager.shared.getOrSelectServer()
            
            let country = currentConfiguration?.country ?? "United States"
            let city = currentConfiguration?.city ?? "Invalid Configuration"
            let state = currentConfiguration?.state ?? "Contact Support"
            
            selectedServerView.configure(countryName: country, city: city, state: state)
            
        }
    }
}
