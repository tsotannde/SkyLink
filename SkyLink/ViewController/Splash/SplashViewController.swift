//
//  SetupViewController.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 10/22/25.
//

import UIKit
import FirebaseAuth

class SplashViewController: UIViewController
{
    let cloud = createCloudIcon()
    let key = createKeyIcon()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //MARK: - User Interface
        // Register for app lifecycle notifications early so splash animations
        // can pause/resume correctly when the app backgrounds or foregrounds.
        addNotifcationObservers()
        setBackGroundColor()
        // Start the splash animation immediately to give visual feedback
        // while app initialization work is prepared.
        startAnimation()
        
        // Delay the startup logic slightly so the splash screen is visible
        // before heavy async initialization begins.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8)
        {
            Task
            {
                await self.startAppFlow()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        hideNavigationBar()
    }
    
    //Denits all the Notifications
    deinit
    {
        NotificationCenter.default.removeObserver(self)
    }
}

extension SplashViewController
{
    private func startAppFlow() async
    {
        // Main startup coordinator for the app.
        // Responsible for validating prerequisites, preparing configuration,
        // and navigating to Home once the app is ready.
        
        // Internet connectivity is required on first launch.
        // If unavailable, present an alert and retry when the user dismisses it.
        guard InternetManager.shared.checkConnectionAndAlertIfNeeded() else
        {
            showNoInternetAlert()
            return
        }
        
        
        // Synchronize the initial VPN connection state so HomeViewController
        // starts with the correct power button and status indicators.
        validateInitialVPNState()
        
        // Perform all required startup tasks sequentially.
        // Any failure here is treated as a startup failure and handled uniformly.
        do
        {
            try await ConfigurationManager.shared.fetchServerFromFireBase() // Fetch Servers + Save to JSON
            _ = try await AccountManager.shared.ensureAccountExists() // Check or create anonymous account
            KeyManager.shared.generateKeysIfNeeded()  // Generate keys if none exist
            let server = await ConfigurationManager.shared.getExistingOrSelectServer() // Choose a random server
            // All startup tasks completed successfully — transition to Home screen.
            NaviagateHome() // Navigate Home
        }
        catch
        {
            showNoInternetAlert() //Something Bad Happened
        }
    }
    

    private func validateInitialVPNState()
    {
        // Queries the system VPN state and syncs it into the app's configuration layer.
        // This ensures the UI reflects the real tunnel state on first load.
        
        // Run asynchronously so startup is not blocked by VPN state resolution.
        Task
        {
            let isActuallyConnected = await VPNManager.shared.isConnectedToVPN()
            
            DispatchQueue.main.async
            {
                // Save corrected state and sync state tracker
                
                ConfigurationManager.shared.syncInitialVPNState(isActuallyConnected)
                
            }
        }
    }
    
    private func showNoInternetAlert()
    {
        
        let title = SkyLinkAssets.Text.noInternetKey
        let message = SkyLinkAssets.Text.noInternetMessageKey
      
        // Present a blocking alert informing the user that connectivity is required.
        // When dismissed, the startup flow is retried.
        SkyLinkAssets.Alerts.showAlert(from: self, title: title, message: message)
        {
            Task
            {
                await self.startAppFlow()
            }
        }

    }
    
    private func NaviagateHome()
    {
        // Replace the splash screen with Home as the root view controller.
        // The navigation stack is cleared to prevent returning to splash.
        NavigationManager.shared.navigate(to: HomeViewController(),on: navigationController,clearStack: true,animation: .uncover(direction: .down))
        
    }
}

//MARK: - Notification Observer and Corresponding Functions
extension SplashViewController
{
    // Observes app lifecycle events to pause and resume splash animations
    // when the app moves between foreground and background.
    func addNotifcationObservers()
    {
        NotificationCenter.default.addObserver(self,selector: #selector(appDidBecomeActive),name: UIApplication.didBecomeActiveNotification,object: nil)
        
        NotificationCenter.default.addObserver(self,selector: #selector(appDidEnterBackground),name: UIApplication.didEnterBackgroundNotification,object: nil)
        
        NotificationCenter.default.addObserver(
            self,selector: #selector(appDidBecomeActive),name: UIScene.didActivateNotification,object: nil)
    }
    
    // Resume splash animation when the app becomes active again.
    @objc private func appDidBecomeActive()
    {
        animateKey()  // Resume animation
    }
    
    // Stop splash animation when the app enters the background
    // to avoid unnecessary GPU/CPU work.
    @objc private func appDidEnterBackground()
    {
        key.layer.removeAllAnimations()  // Stop animation
    }
    
}

//MARK: - UI Components
extension SplashViewController
{
    static func createCloudIcon()->UIImageView
    {
        let iv = UIImageView(image: SkyLinkAssets.Images.skyIcon)
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }
    
    static func createKeyIcon()->UIImageView
    {
        let iv = UIImageView(image: SkyLinkAssets.Images.keyIcon)
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }
}

//MARK: - Contruct User Interface
extension SplashViewController
{
    func setBackGroundColor()
    {
        view.backgroundColor = SkyLinkAssets.Colors.Themes.primary
       
    }
    
    func hideNavigationBar()
    {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func startAnimation()
    {
        setupSplashLayers()
        animateKey()
    }
    
    private func setupSplashLayers()
    {
        view.addSubview(cloud)
        view.addSubview(key)
        
        NSLayoutConstraint.activate([
            // CLOUD — same constraints as launch screen
            cloud.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            cloud.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            cloud.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.40),
            cloud.heightAnchor.constraint(equalTo: cloud.widthAnchor),
            
            // KEY — EXACT same size/position as cloud
            key.centerXAnchor.constraint(equalTo: cloud.centerXAnchor),
            key.centerYAnchor.constraint(equalTo: cloud.centerYAnchor),
            key.widthAnchor.constraint(equalTo: cloud.widthAnchor),
            key.heightAnchor.constraint(equalTo: cloud.heightAnchor)
        ])
    }
    
    private func animateKey()
    {
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 1.0       // fully visible
        fade.toValue = 0.3         // fade out a bit
        fade.duration = 1.3
        fade.autoreverses = true
        fade.repeatCount = .infinity
        fade.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        key.layer.add(fade, forKey: "fade")
    }
}
