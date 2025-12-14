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
        addNotifcationObservers()
        setBackGroundColor()
        startAnimation()
        
        //MARK: - APP Logic
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
        //Internt Reqired for First Launch
        guard InternetManager.shared.checkConnectionAndAlertIfNeeded() else
        {
            showNoInternetAlert()
            return
        }
        
        validateInitialVPNState()
        
        AppLoggerManager.shared.log("[SplashScreen] Internet connection validated")
        do
        {
            try await ConfigurationManager.shared.fetchServerFromFireBase() // Fetch Servers + Save to JSON
            _ = try await AccountManager.shared.ensureAccountExists() // Check or create anonymous account
            KeyManager.shared.generateKeysIfNeeded()  // Generate keys if none exist
            let server = await ConfigurationManager.shared.getExistingOrSelectServer() // Choose a random server
            AppLoggerManager.shared.logServerDetails(server) //log server detail
            NaviagateHome() // Navigate Home
        }
        catch
        {
            AppLoggerManager.shared.log("[SplashScreen] Error during app flow: \(error.localizedDescription)")
            showNoInternetAlert() //Something Bad Happened
        }
    }
    

    private func validateInitialVPNState()
    {
        //used to set the inital state of the homeViewController button and connection state
        AppLoggerManager.shared.log("[SplashScreen] Validating initial VPN state")
        
        Task
        {
            let isActuallyConnected = await VPNManager.shared.isConnectedToVPN()
            AppLoggerManager.shared.log("[SplashScreen] VPN State: \(isActuallyConnected)")
            
            DispatchQueue.main.async
            {
                // Save corrected state and sync state tracker
                AppLoggerManager.shared.log("[SplashScreen] Saving State\(isActuallyConnected) with Key: \(SkyLinkAssets.AppKeys.UserDefaults.lastConnectionState.description)")
                ConfigurationManager.shared.syncInitialVPNState(isActuallyConnected)
                
            }
        }
    }
    
    private func showNoInternetAlert()
    {
        AppLoggerManager.shared.log("[SplashScreen] No Internet Detected")
        
        let title = SkyLinkAssets.Text.noInternetKey
        let message = SkyLinkAssets.Text.noInternetMessageKey
      
        SkyLinkAssets.Alerts.showAlert(from: self, title: title, message: message)
        {
            AppLoggerManager.shared.log("[SplashScreen] User Tapped Retry. Rechecking Internet Connection")

            Task
            {
                await self.startAppFlow()
            }
        }

    }
    
    private func NaviagateHome()
    {
        AppLoggerManager.shared.log("[SplashScreen] Checks Complete Navigating Home")
        NavigationManager.shared.navigate(to: HomeViewController(),on: navigationController,clearStack: true,animation: .uncover(direction: .down))
        
    }
}

//MARK: - Notification Observer and Corresponding Functions
extension SplashViewController
{
    func addNotifcationObservers()
    {
        NotificationCenter.default.addObserver(self,selector: #selector(appDidBecomeActive),name: UIApplication.didBecomeActiveNotification,object: nil)
        
        NotificationCenter.default.addObserver(self,selector: #selector(appDidEnterBackground),name: UIApplication.didEnterBackgroundNotification,object: nil)
        
        NotificationCenter.default.addObserver(
            self,selector: #selector(appDidBecomeActive),name: UIScene.didActivateNotification,object: nil)
    }
    
    @objc private func appDidBecomeActive()
    {
        animateKey()  // Resume animation
    }
    
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
