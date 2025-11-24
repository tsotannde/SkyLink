//
//  VPNManager.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 10/24/25.
//

import Foundation
import NetworkExtension


final class VPNManager {
    static let shared = VPNManager()
    
    init() {
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(vpnStatusDidChange),
//            name: .NEVPNStatusDidChange,
//            object: nil
//        )
    }

    private var manager: NETunnelProviderManager?

    // MARK: - Start Tunnel
    func startTunnel2() async {
        do {
            print("[VPNManager] Starting tunnel...")

            // Get or select the server
            guard let server = await ConfigurationManager.shared.getOrSelectServer() else {
                print("No server found.")
                return
            }
            
            guard let serverIP = server.publicIP else {
                print("Server public IP is nil.")
                return
            }

            // Generate keys or load stored ones
            guard let privateKey = KeyManager.shared.getPrivateKey() else {
                print("Private key is nil.")
                return
            }
            guard let publicKey = KeyManager.shared.getPublicKey() else {
                print("Public key is nil.")
                return
            }

            // Call Firebase to get assigned IP, server pubkey, and port
            let response = try await FirebaseRequestManager.shared.sendRequest(
                serverIP: serverIP,
                serverPort: server.port ?? 5000,
                publicKey: publicKey
            )

            print("[VPNManager] Received IP: \(response.ip), Port: \(response.port)")

            // Build wg-quick configuration string
            let wgQuickConfig = """
            [Interface]
            PrivateKey = \(privateKey)
            Address = \(response.ip)/32
            DNS = 1.1.1.1

            [Peer]
            PublicKey = \(response.publicKey)
            Endpoint = \(server.publicIP ?? "0.0.0.0"):\(response.port)
            AllowedIPs = 0.0.0.0/0
            PersistentKeepalive = 25
            """
            print("[VPNManager] Final Config:\n\(wgQuickConfig)")

            // Load or create the Tunnel Provider
            let tunnelManager = try await loadOrCreateTunnelProvider()
            tunnelManager.protocolConfiguration = makeProtocolConfig(wgQuickConfig: wgQuickConfig)
            tunnelManager.localizedDescription = "SkyLink VPN"
            tunnelManager.isEnabled = true
            try await tunnelManager.saveToPreferences()

            // Start the tunnel
            try await tunnelManager.connection.startVPNTunnel()
            self.manager = tunnelManager
            print("VPN Tunnel Started Successfully")
        

        } catch {
            print("[VPNManager] Failed to start tunnel: \(error.localizedDescription)")
        }
    }

    func startTunnel()
    {
        print("[VPN Manager] Starting tunnel in background...")
        Task.detached(priority: .userInitiated)
        {
            await self._startTunnelAsync()
        }
    }

    private func _startTunnelAsync() async
    {
        do {
            print("[VPNManager] Starting tunnel...")

            //loads the server that will be used for connecting
            guard let server = await ConfigurationManager.shared.getOrSelectServer() else
            {
                print("No server found.")
                return
            }
            
            //Req to make a request to firebase ie what server to send a request to
            guard let serverIP = server.publicIP else
            {
                print("Server public IP is nil.")
                return
            }

            #warning("Private key not really needed here")
            guard let privateKey = KeyManager.shared.getPrivateKey(), let publicKey = KeyManager.shared.getPublicKey() else
            {
                print("Keys missing.")
                return
            }

            //Send a Request to Firebase, Response is here
            let response = try await FirebaseRequestManager.shared.sendRequest(
                serverIP: serverIP,
                serverPort: server.port ?? 5000,
                publicKey: publicKey
            )

            print("[VPNManager] Received IP: \(response.ip), Port: \(response.port)")

            print("[VPNManager] Creating VPN configuration...")
            let wgQuickConfig = """
            [Interface]
            PrivateKey = \(privateKey)
            Address = \(response.ip)/32
            DNS = 1.1.1.1

            [Peer]
            PublicKey = \(response.publicKey)
            Endpoint = \(server.publicIP ?? "0.0.0.0"):\(response.port)
            AllowedIPs = 0.0.0.0/0
            PersistentKeepalive = 25
            """

            print("[VPNManager] VPN Configuration Created \n\(wgQuickConfig)\n")
            
            print("[VPNManager] Using Configuration to establish a connection...")
            let tunnelManager = try await self.loadOrCreateTunnelProvider()
            tunnelManager.protocolConfiguration = self.makeProtocolConfig(wgQuickConfig: wgQuickConfig)
            tunnelManager.localizedDescription = "SkyLink VPN" //Name that appears in VPN Settings
            tunnelManager.isEnabled = true
            try await tunnelManager.saveToPreferences()

            try  tunnelManager.connection.startVPNTunnel()
            self.manager = tunnelManager

            print("[VPNManager] - VPN Tunnel Started Successfully")
        } catch {
            print("[VPNManager] Failed to start tunnel: \(error.localizedDescription)")
        }
    }
    
    
     //MARK: - Stop Tunnel
//    func stopTunnel()
//    {
//        guard let connection = manager?.connection else
//        {
//            print("No active tunnel to stop.")
//            return
//        }
//
//        connection.stopVPNTunnel()
//        print("🛑 VPN Tunnel Stopped")
//       
//    }
    
    func stopTunnel() {
        Task {
            do {
                let managers = try await NETunnelProviderManager.loadAllFromPreferences()
                guard let active = managers.first else {
                    print("[VPNManager] No saved tunnel found.")
                    return
                }

                if active.connection.status == .connected || active.connection.status == .connecting {
                    active.connection.stopVPNTunnel()
                    print("[VPNManager] Stop request sent to system.")
                } else {
                    print("[VPNManager] Tunnel already disconnected.")
                }
            } catch {
                print("[VPNManager] Stop failed: \(error)")
            }
        }
    }
//
//    @objc private func vpnStatusDidChange(_ notification: Notification) {
//        guard let connection = manager?.connection else { return }
//
//        switch connection.status {
//        case .connected:
//            print("[VPNManager] System confirmed VPN is connected ✅")
//            NotificationCenter.default.post(name: Notification.Name("vpnConnected"), object: nil)
//
//        case .disconnected, .invalid:
//            print("[VPNManager] System confirmed VPN is disconnected 🛑")
//            NotificationCenter.default.post(name: Notification.Name("vpnDisconnected"), object: nil)
//
//        default:
//            break
//        }
//    }
//
    // MARK: - Helpers
    private func loadOrCreateTunnelProvider() async throws -> NETunnelProviderManager
    {
        print("[VPNManager] Loading existing tunnel configurations from preferences...")
        let managers = try await NETunnelProviderManager.loadAllFromPreferences()
        print("[VPNManager] Found \(managers.count) tunnel configuration(s).")
        if let existing = managers.first {
            print("[VPNManager] Reusing existing tunnel configuration: \(existing.localizedDescription ?? "Unnamed")")
            return existing
        }

        print("[VPNManager] No existing tunnel found. Creating a new one...")
        let newManager = NETunnelProviderManager()
        newManager.protocolConfiguration = makeProtocolConfig(wgQuickConfig: "")
        newManager.isEnabled = true
        print("[VPNManager] New tunnel provider created and configured successfully.")
        return newManager
    }

    private func makeProtocolConfig(wgQuickConfig: String) -> NETunnelProviderProtocol
    {
        print("[VPNManager] Building protocol configuration with WireGuard config...")
        let proto = NETunnelProviderProtocol()
        proto.providerBundleIdentifier = "com.adebayosotannde.SkyLink.network-extension"
        proto.serverAddress = "SkyLink VPN"
        proto.providerConfiguration = ["wgQuickConfig": wgQuickConfig]
        print("[VPNManager] Protocol configuration completed with providerBundleIdentifier: \(proto.providerBundleIdentifier ?? "nil")")
        return proto
    }
}

// MARK: - VPN Status Check
extension VPNManager
{
    func isConnectedToVPNold() async -> Bool
    {
        do {
            // 1. Get the currently selected server
            guard let currentServer = await ConfigurationManager.shared.getOrSelectServer(),
                  let serverIP = currentServer.publicIP else {
                print("[VPNManager] No saved server or public IP.")
                return false
            }

            // 2. Fetch user's current public IP
            guard let url = URL(string: "https://api.ipify.org?format=json") else {
                print("[VPNManager] Invalid IPify URL.")
                return false
            }

            let (data, _) = try await URLSession.shared.data(from: url)
            let ipResponse = try JSONDecoder().decode(IPResponse.self, from: data)
            let userIP = ipResponse.ip

            print("[VPNManager] User IP: \(userIP), Server IP: \(serverIP)")

            // 3. Compare and return result
            return userIP == serverIP
            
            

        }
        catch
        {
            print("[VPNManager] Failed to check VPN connection: \(error.localizedDescription)")
            return false
        }
    }

    func isConnectedToVPN() async -> Bool
    {
        do {
            guard let currentServer = await ConfigurationManager.shared.getOrSelectServer(),
                  let serverIP = currentServer.publicIP else {
                print("[VPNManager] No saved server or public IP.")
                AppLogger.shared.log("[VPNManager] No saved server or public IP.")
                // Save state
                UserDefaults.standard.set("disconnected", forKey: AppDesign.AppKeys.UserDefaults.vpnState)
                return false
            }

            guard let url = URL(string: "https://api.ipify.org?format=json") else {
                print("[VPNManager] Invalid IPify URL.")
                AppLogger.shared.log("[VPNManager] Invalid IPify URL.")
                // Save state
                UserDefaults.standard.set("disconnected", forKey: AppDesign.AppKeys.UserDefaults.vpnState)
                return false
            }

            let (data, _) = try await URLSession.shared.data(from: url)
            let ipResponse = try JSONDecoder().decode(IPResponse.self, from: data)
            let userIP = ipResponse.ip

            print("[VPNManager] User IP: \(userIP), Server IP: \(serverIP)")
            AppLogger.shared.log("[VPNManager] User IP: \(userIP), Server IP: \(serverIP)")
            let isConnected = (userIP == serverIP)

            // ✅ Save the computed state IMMEDIATELY
            UserDefaults.standard.set(
                isConnected ? "connected" : "disconnected",
                forKey: AppDesign.AppKeys.UserDefaults.vpnState
            )

            return isConnected
        }
        catch {
            print("[VPNManager] Failed to check VPN connection: \(error.localizedDescription)")
            AppLogger.shared.log("[VPNManager] Failed to check VPN connection: \(error.localizedDescription)")
            // Connection check failed → assume disconnected
            UserDefaults.standard.set("disconnected", forKey: AppDesign.AppKeys.UserDefaults.vpnState)

            return false
        }
    }
    
    

    // MARK: - Save State Helper
    private func saveState(_ connected: Bool) {
        UserDefaults.standard.set(connected, forKey: AppDesign.AppKeys.UserDefaults.vpnState)

        if connected {
            // Do NOT override old date — only set if missing
            if UserDefaults.standard.object(forKey: AppDesign.AppKeys.UserDefaults.lastConnectedDate) == nil {
                UserDefaults.standard.set(Date(), forKey: AppDesign.AppKeys.UserDefaults.lastConnectedDate)
            }
        } else {
            UserDefaults.standard.removeObject(forKey: AppDesign.AppKeys.UserDefaults.lastConnectedDate)
        }
    }
    // Helper struct for decoding ipify JSON
    private struct IPResponse: Decodable {
        let ip: String
    }
}
