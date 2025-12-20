//
//  VPNManager.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 10/24/25.
//

import Foundation
import NetworkExtension

final class VPNManager
{
    static let shared = VPNManager()
    
    init(){}

    private var manager: NETunnelProviderManager?

    func startTunnel()
    {
        print("[VPN Manager] Starting tunnel in background...")
        Task.detached(priority: .userInitiated)
        {
            await self.startTunnelAsync()
        }
    }

    private func startTunnelAsync() async
    {
        do {
            print("[VPNManager] Starting tunnel...")

            //loads the server that will be used for connecting
            guard let server = await ConfigurationManager.shared.getExistingOrSelectServer() else
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

            guard let privateKey = KeyManager.shared.getPrivateKey(), let publicKey = KeyManager.shared.getPublicKey() else
            {
                print("Keys missing.")
                return
            }

            //Send a Request to Firebase, Response is here
            let response = try await FirebaseRequestManager.shared.sendRequest( serverIP: serverIP, serverPort: server.port ?? 5000, publicKey: publicKey)

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

            let tunnelManager = try await self.loadOrCreateTunnelProvider()
            tunnelManager.protocolConfiguration = self.makeProtocolConfig(wgQuickConfig: wgQuickConfig)
            tunnelManager.localizedDescription = "SkyLink VPN" //Name that appears in VPN Settings
            tunnelManager.isEnabled = true
            try await tunnelManager.saveToPreferences()

            try  tunnelManager.connection.startVPNTunnel()
            self.manager = tunnelManager

        }
        catch
        {
            print("[VPNManager] Failed to start tunnel: \(error.localizedDescription)")
            DispatchQueue.main.async
            {
                NotificationCenter.default.post(name: .vpnDisconnected, object: nil)
            }
        }
    }
    
    
    func stopTunnel()
    {
        Task {
            do
            {
                let managers = try await NETunnelProviderManager.loadAllFromPreferences()
                guard let active = managers.first else
                {
                    return
                }

                if active.connection.status == .connected || active.connection.status == .connecting
                {
                    active.connection.stopVPNTunnel() //stops the tunnedl
                }
                else
                {
                }
            }
            catch
            {
            }
        }
    }

    // MARK: - Helpers
    private func loadOrCreateTunnelProvider() async throws -> NETunnelProviderManager
    {
        let managers = try await NETunnelProviderManager.loadAllFromPreferences()

        if let existing = managers.first
        {
            return existing //Reused existing config
        }

        let newManager = NETunnelProviderManager()
        newManager.protocolConfiguration = makeProtocolConfig(wgQuickConfig: "")
        newManager.isEnabled = true
        return newManager
    }

    private func makeProtocolConfig(wgQuickConfig: String) -> NETunnelProviderProtocol
    {
        let proto = NETunnelProviderProtocol()
        proto.providerBundleIdentifier = SkyLinkAssets.Extensions.shared
        proto.serverAddress = "SkyLink VPN"
        proto.providerConfiguration = ["wgQuickConfig": wgQuickConfig]
        return proto
    }
}

// MARK: - VPN Status Check
extension VPNManager
{

    
    func isConnectedToVPN() async -> Bool
    {
        do
        {
            let managers = try await NETunnelProviderManager.loadAllFromPreferences()
            guard let manager = managers.first else
            {
                // No VPN configuration → disconnected
                UserDefaults.standard.set(
                    SkyLinkAssets.AppKeys.UserDefaults.disconnected,
                    forKey: SkyLinkAssets.AppKeys.UserDefaults.vpnState
                )
                return false
            }

            let status = manager.connection.status

            let isConnected: Bool
            switch status
            {
            case .connected, .connecting, .reasserting:
                isConnected = true
            default:
                isConnected = false
            }

            // SAME saving mechanism you already use
            UserDefaults.standard.set(isConnected ? "connected" : "disconnected",forKey: SkyLinkAssets.AppKeys.UserDefaults.vpnState)

            return isConnected
        }
        catch
        {
            UserDefaults.standard.set(SkyLinkAssets.AppKeys.UserDefaults.disconnected,forKey: SkyLinkAssets.AppKeys.UserDefaults.vpnState)
            return false
        }
    }
   

    // MARK: - Save State Helper
    private func saveState(_ connected: Bool)
    {
        UserDefaults.standard.set(connected, forKey: SkyLinkAssets.AppKeys.UserDefaults.vpnState)

        if connected
        {
            // Do NOT override old date — only set if missing
            if UserDefaults.standard.object(forKey: SkyLinkAssets.AppKeys.UserDefaults.lastConnectedDate) == nil
            {
                UserDefaults.standard.set(Date(), forKey: SkyLinkAssets.AppKeys.UserDefaults.lastConnectedDate)
            }
        }
        else
        {
            UserDefaults.standard.removeObject(forKey: SkyLinkAssets.AppKeys.UserDefaults.lastConnectedDate)
        }
    }
    
    // Helper struct for decoding ipify JSON
    private struct IPResponse: Decodable
    {
        let ip: String
    }
}
