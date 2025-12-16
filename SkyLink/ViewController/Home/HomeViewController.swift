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
    internal let notSubscribedButton = createNotSubscribedButton()
    internal let  subscribedButton = createSubscribedButtons()
    internal let downloadCard = createDownloadCard()
    internal let uploadCard = createUploadCard()
    internal let connectionStatusView = ConnectionStatusView()
    internal let selectedServerView = SelectedServer()
    internal let powerButtonView = PowerButtonView()
    private var connectionCheckTimer: Timer?
    private var currentConnectionState: Bool? = nil
    
    let subscribeVC = SubscribeViewController()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        hideNavigationBar()
        setBackgroundColor()
        constructUserInterface()
        
        updatePremiumButon()
        startTimer()
        monitorNotifications() //Used to upadte the powerbutton state and other functions
    }
    
    deinit
    {
        NotificationCenter.default.removeObserver(self)
    }
        
}

//MARK: - Timer
extension HomeViewController
{
    //MARK: - TIMER
    func startTimer()
    {
        guard connectionCheckTimer == nil else
        {
          
            return
        }

        connectionCheckTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true)
        { [weak self] _ in
            self?.checkConnectionState()
        }
    }
    
    func stopTimer()
    {
        connectionCheckTimer?.invalidate()
        connectionCheckTimer = nil
    }
    
    // Timer-based connection state check, replaces Darwin notification updates
    private func checkConnectionState()
    {
        Task
        { [weak self] in
            guard let self = self else { return }
            // Timer tick: we are about to query VPNManager for the current connection state.
            // This runs periodically while the Home screen (and app) are active.

            // Ask VPNManager for the *actual* current VPN connection state (true/false).
            // This is the source of truth for whether the tunnel is connected.
            let connectionStatus =  await VPNManager.shared.isConnectedToVPN()
          
            DispatchQueue.main.async
            {
                // Compare the last known state with the newly fetched state.
                // - On first run, currentConnectionState is nil, so this will always pass.
                // - On later runs, this only passes when the VPN state truly changes.
                if self.currentConnectionState != connectionStatus
                {
                    // Persist the new state locally so future timer ticks can detect real changes
                    // instead of re-triggering UI updates every second.
                    self.currentConnectionState = connectionStatus
                    UserDefaults.standard.set(connectionStatus, forKey: SkyLinkAssets.AppKeys.UserDefaults.lastConnectionState)
                   
                    
                   // self.connectionStatusView.setStatus()
                    if connectionStatus
                    {
                        self.powerButtonView.setState(.connected)
                        NotificationCenter.default.post(name: .vpnConnected, object: nil)
                    } else
                    {
                        //State changed → DISCONNECTED
                        self.powerButtonView.setState(.disconnected)
                        NotificationCenter.default.post(name: .vpnDisconnected, object: nil)
                    }
                }
                else
                {
                    // State has not changed since the last check.
                    // Intentionally do nothing here to avoid re-running animations,
                    // reposting notifications, or spamming the UI.
                }
            }
        }
    }
    
}

   
