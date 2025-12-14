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
    internal func monitorNotifications()
    {
        // --- Power Button State Notifications ---
        NotificationCenter.default.addObserver(self, selector: #selector(handleVPNIsConnecting), name: .vpnConnecting, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleVPNDidConnect), name: .vpnConnected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleVPNIsDisconnecting), name: .vpnDisconnecting, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleVPNDidDisconnect), name: .vpnDisconnected, object: nil)
    }
    
    internal func addTargets()
    {
        premiumButton.addTarget(self, action: #selector(premiumButtonTapped), for: .touchUpInside)
    }
    
    @objc internal func premiumButtonTapped()
    {
        
        NavigationManager.shared.navigate(to: subscribeVC, on: self.navigationController, clearStack: false,animation: .push(direction: .left))
        
    }
    
    @objc internal func selectedServerTapped()
    {
        AppLoggerManager.shared.log("[Home] User Clicked the ServerSelector View")
        let viewController = ServerSelectionViewController()
        
        if let sheet = viewController.sheetPresentationController
        {
            sheet.detents = [.medium(), .large()]
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
        AppLoggerManager.shared.log("[Home] Power Button Tapped")
        
        Task
        {
            let connected = await VPNManager.shared.isConnectedToVPN()
            AppLoggerManager.shared.log("[Home] VPN Status is \(connected)")
            
            self.powerButtonView.isUserInteractionEnabled = false //Disables user from tapping button again
            defer { self.powerButtonView.isUserInteractionEnabled = true }
            
            if connected
            {
                AppLoggerManager.shared.log("[Home] Disconnecting VPN and Stopping Tunnel")
                self.powerButtonView.setState(.disconnecting)
                NotificationCenter.default.post(name: .vpnDisconnecting, object: nil)
                VPNManager.shared.stopTunnel()
            } else
            {
                AppLoggerManager.shared.log("[Home] Connecting VPN and Starting Tunnel")
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
    @objc internal func handleVPNDidConnect()
    {
        AppLoggerManager.shared.log("[Home] VPN Connected")
        DispatchQueue.main.async
        {
            self.powerButtonView.setState(.connected)
        }
    }
    
    @objc internal func handleVPNDidDisconnect()
    {
        print("Recived a disconnect notifivation from the VPN Manager")
        AppLoggerManager.shared.log("[Home] VPN Disconnected")
        DispatchQueue.main.async
        {
            print("I am in the que lets see if i push this update ")
            self.powerButtonView.setState(.disconnected)
        }
    }
    
    @objc internal func handleVPNIsConnecting()
    {
        AppLoggerManager.shared.log("[Home] VPN Connecting")
        DispatchQueue.main.async
        {
            self.powerButtonView.setState(.connecting)
        }
    }
    
    @objc internal func handleVPNIsDisconnecting()
    {
        AppLoggerManager.shared.log("[Home] VPN Disconnecting")
        DispatchQueue.main.async {
            self.powerButtonView.setState(.disconnecting)
        }
    }
    

}
