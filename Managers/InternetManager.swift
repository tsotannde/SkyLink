//
//  InternetManager.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 10/22/25.
//
//

import Foundation
import Network
import UIKit

final class InternetManager {
    
    static let shared = InternetManager()
    private init() {}
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private var timer: Timer?
    
    private(set) var isConnected: Bool = false
    
    // MARK: - Start Monitoring
    
    func startMonitoring(interval: TimeInterval = 3.0) {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            let interfaceStatus = path.status == .satisfied
            
            if interfaceStatus {
                self.performConnectivityCheck()
            } else {
                DispatchQueue.main.async {
                    if self.isConnected != false {
                        self.isConnected = false
                        NotificationCenter.default.post(name: .internetDidDisconnect, object: nil)
                    }
                }
            }
        }
        
        monitor.start(queue: queue)
        
        // Continuous heartbeat timer — runs for the entire app lifecycle
        DispatchQueue.main.async {
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.performConnectivityCheck()
            }
            RunLoop.main.add(self.timer!, forMode: .common)
        }
        
        print("Internet monitoring started. Checking every \(interval) seconds.")
    }
    
    // MARK: - Stop Monitoring
    
    func stopMonitoring() {
        monitor.cancel()
        timer?.invalidate()
        timer = nil
        print("Internet monitoring stopped.")
    }
    
    // MARK: - Connectivity Check
    
    private func performConnectivityCheck() {
        let url = URL(string: "https://www.apple.com/library/test/success.html")!
        var request = URLRequest(url: url)
        request.timeoutInterval = 3.0
        #warning("Fix this Remove PRint from Function not needed")
       // print("Performing connectivity check at:", Date(), "URL:", url.absoluteString)
        
        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if let httpResponse = response as? HTTPURLResponse {
               // print("Ping status code:", httpResponse.statusCode)
            } else if let error = error {
                print("Ping error:", error.localizedDescription)
            }
            
            let httpResponse = response as? HTTPURLResponse
            let success = (error == nil) && (httpResponse?.statusCode == 200)
            
            DispatchQueue.main.async {
                if success {
                    if self.isConnected != true {
                        self.isConnected = true
                        print("Internet connection restored")
                        NotificationCenter.default.post(name: .internetDidConnect, object: nil)
                    }
                } else {
                    if self.isConnected != false {
                        self.isConnected = false
                        NotificationCenter.default.post(name: .internetDidDisconnect, object: nil)
                    }
                }
            }
        }
        task.resume()
    }
    
    // MARK: - Public Helper
    
    func checkConnectionAndAlertIfNeeded() -> Bool {
        return isConnected
    }
    
    // MARK: - Utility (top view controller)
    
    private func topViewController(base: UIViewController? = UIApplication.shared.connectedScenes
        .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
        .first?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        } else if let tab = base as? UITabBarController {
            return topViewController(base: tab.selectedViewController)
        } else if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
