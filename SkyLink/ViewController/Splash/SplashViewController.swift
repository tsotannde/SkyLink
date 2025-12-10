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
        validateInitialVPNState()
        
        //Internt Reqired for First Launch
        guard InternetManager.shared.checkConnectionAndAlertIfNeeded() else
        {
            showNoInternetAlert()
            return
        }
        
        AppLogger.shared.log("[SplashScreen] Internet connection validated")
        do
        {
            try await ConfigurationManager.shared.fetchServerFromFireBase() // Fetch Servers + Save to JSON
            _ = try await AccountManager.shared.ensureAccountExists() // Check or create anonymous account
            KeyManager.shared.generateKeysIfNeeded()  // Generate keys if none exist
            let server = await ConfigurationManager.shared.getExistingOrSelectServer() // Choose a random server
            AppLogger.shared.logServerDetails(server) //log server detail
            NaviagateHome() // Navigate Home
        }
        catch
        {
            AppLogger.shared.log("[SplashScreen] Error during app flow: \(error.localizedDescription)")
            showNoInternetAlert() //Something Bad Happened
        }
    }
    
    
    /// Validates and updates the initial VPN connection state.
    ///
    /// This function asynchronously checks whether the device is currently connected to a VPN using `VPNManager`.
    /// It then updates the saved VPN connection state in `UserDefaults` under a specific key, ensuring that the
    /// app's state tracker reflects the accurate current VPN connection status.
    /// The validation result is printed to the console for debugging purposes.
    private func validateInitialVPNState()
    {
        //used to set the inital state of the homeViewController button and connection state
        AppLogger.shared.log("[SplashScreen] Validating initial VPN state")
       
        
        Task
        {
            let isActuallyConnected = await VPNManager.shared.isConnectedToVPN()
            AppLogger.shared.log("[SplashScreen] VPN State: \(isActuallyConnected)")
            
            DispatchQueue.main.async
            {
                // Save corrected state and sync state tracker
                AppLogger.shared.log("[SplashScreen] Saving State\(isActuallyConnected) with Key: \(AppDesign.AppKeys.UserDefaults.lastConnectionState.description)")
                UserDefaults.standard.set(isActuallyConnected, forKey: AppDesign.AppKeys.UserDefaults.lastConnectionState)
            }
        }
    }
    
    private func showNoInternetAlert()
    {
        AppLogger.shared.log("[SplashScreen] No Internet Detected")
        let noInternetKey = String(localized: "noInternetKey")
        let noInternetMessageKey = String(localized: "noInternetMessageKey")
        let retryKey = String(localized: "retryKey")
        
        let alert = UIAlertController(title: noInternetKey,message: noInternetMessageKey,preferredStyle: .alert)
        let retryAction = UIAlertAction(title: retryKey, style: .default)
        { _ in
            AppLogger.shared.log("[SplashScreen] User Tapped Retry. Rechecking Internt Connection")
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
        AppLogger.shared.log("[SplashScreen] Checks Complete Navigating Home")
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
        let iv = UIImageView(image: UIImage(named: "skyIcon"))
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }
    
    static func createKeyIcon()->UIImageView
    {
        let iv = UIImageView(image: UIImage(named: "keyIcon"))
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
        view.backgroundColor = DesignSystem.AppColors.Themes.primaryColor
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
