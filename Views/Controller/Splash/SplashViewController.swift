//
//  SetupViewController.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 10/22/25.
//

import UIKit
import FirebaseAuth

#warning("Change Design of Splash Screen")
class SplashViewController: UIViewController
{
    private let homeVC = HomeViewController()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        validateInitialVPNState()
        view.backgroundColor = DesignSystem.AppColors.Themes.primaryColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8)
        {
            Task
            {
                await self.startAppFlow()
            }
        }
    }
    
    private func startAppFlow() async
    {
        
        guard InternetManager.shared.checkConnectionAndAlertIfNeeded() else
        {
            showNoInternetAlert()
            return
        }
        
        do
        {
            try await ServerFetcherManager.shared.fetchServers() // Fetch Servers + Save to JSON
            _ = try await AccountManager.shared.ensureAccountExists() // Check or create anonymous account
            KeyManager.shared.generateKeysIfNeeded()  // Generate keys if none exist
            let temp = await ConfigurationManager.shared.getOrSelectServer() // Choose a random server
            print("Chosen Server is \(temp)")
            NaviagateHome() // Navigate Home
        }
        catch
        {
                #warning("Fix this Genral error handling")
                showNoInternetAlert() //Something Bad Happened
        }
    }
 
}

extension SplashViewController
{
    private func showNoInternetAlert()
    {
        let alert = UIAlertController(title: "No Internet Connection",message: "Please check your internet connection and try again.",preferredStyle: .alert)
        let retryAction = UIAlertAction(title: "OK", style: .default)
        { _ in
               Task
            {
                   await self.startAppFlow()
            }
        }
           
        alert.addAction(retryAction)
        present(alert, animated: true)
    }
    
    private func NaviagateHome()
    {
       // NavigationManager.shared.navigate(to: HomeViewController(),on: navigationController,clearStack: true,animation: .fade)
        NavigationManager.shared.navigate(to: homeVC, on: navigationController, clearStack: true, animation: .fade)
    }
    
    // MARK: - Validate Initial Connection State
    private func validateInitialVPNState() {
        print("[SplaViewController] Validating initial VPN state...")
        
        Task {
            let isActuallyConnected = await VPNManager.shared.isConnectedToVPN()
            print("[SplaViewController] Actual VPN State: \(isActuallyConnected)")
            
            DispatchQueue.main.async
            {
                // Save corrected truth and sync state tracker
                UserDefaults.standard.set(isActuallyConnected, forKey: AppDesign.AppKeys.UserDefaults.lastConnectionState)
            }
        }
    }
}



   
 
