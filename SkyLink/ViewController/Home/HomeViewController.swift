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
        startTimer()
        monitorNotifications() //Used to upadte the powerbutton state
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
                   
                    
                   // self.connectionStatusView.setStatus()
                    if connectionStatus
                    {
                        self.powerButtonView.setState(.connected)
                        NotificationCenter.default.post(name: .vpnConnected, object: nil)
                    } else {
                        //print("[HomeViewController] State changed → DISCONNECTED")
                        self.powerButtonView.setState(.disconnected)
                        NotificationCenter.default.post(name: .vpnDisconnected, object: nil)
                    }
                }
                else
                {
                    // State hasn’t changed, do nothing (avoids re-running animation)
                    //print("[HomeViewController] No state change, skipping animation.")
                }
            }
        }
    }
    
}
