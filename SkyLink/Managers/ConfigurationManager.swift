//
//  ConfigurationManager.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 10/22/25.
//

import Foundation

final class ConfigurationManager
{

    static let shared = ConfigurationManager()
    private let firebaseURL = "https://vpn-se-default-rtdb.firebaseio.com/.json"
    private init() {}

    public var freeServers: [Server] = []
    public var premiumServers: [Server] = []
    
}

//MARK: - Fetch Servers either from Firebase or Cache
extension ConfigurationManager
{
    func fetchServerFromFireBase() async throws
    {
        guard let url = URL(string: firebaseURL) else
        {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        AppLoggerManager.shared.log("Fetched raw JSON data")
        UserDefaults.standard.set(data, forKey: SkyLinkAssets.AppKeys.UserDefaults.cachedServerJSON)
    }
    
    func loadCachedServers() async throws
    {
        AppLoggerManager.shared.log("[ConfigManager] Retrieving cached server JSON")

        guard let data = UserDefaults.standard.data(forKey: SkyLinkAssets.AppKeys.UserDefaults.cachedServerJSON) else
        {
            AppLoggerManager.shared.log("[ConfigurationManager] No cached server JSON found")
            throw URLError(.fileDoesNotExist)
        }

        // Decode and store servers
        freeServers = getFreeServers(with: data)
        premiumServers = getPaidServers(with: data)

        AppLoggerManager.shared.log("[ConfigurationManager] Loaded \(freeServers.count) free servers and \(premiumServers.count) premium servers")
    }
}
//MARK: - Organize the Servers
extension ConfigurationManager
{
    private func getFreeServers(with jsonData: Data) -> [Server]
    {
        guard let decoded = try? JSONDecoder().decode(ServerDatabase.self, from: jsonData) else
        {
            print("Failed to decode server database for free servers.")
            return []
        }

        let servers = decoded.servers.flatMap
        { (_, country) in
            country.servers.compactMap
            { (_, server) in
                server.requiresSubscription == false ? server : nil
            }
        }
        return servers
    }

    private func getPaidServers(with jsonData: Data) -> [Server]
    {
        guard let decoded = try? JSONDecoder().decode(ServerDatabase.self, from: jsonData) else
        {
            print("Failed to decode server database for paid servers.")
            return []
        }

        let servers = decoded.servers.flatMap
        { (_, country) in
            country.servers.compactMap
            { (_, server) in
                server.requiresSubscription == true ? server : nil
            }
        }
        return servers
    }
}

// MARK: - Server Selection & Persistence
extension ConfigurationManager
{
    func getExistingOrSelectServer() async -> Server?
    {
        // Step 1: Try loading the existing  saved server
        if let data = UserDefaults.standard.data(forKey: "currentServer"),
           let savedServer = try? JSONDecoder().decode(Server.self, from: data)
        {
            AppLoggerManager.shared.log("[ConfigurationManager] - Loaded previously selected server: \(savedServer.name)")
            return savedServer
        }

        // Step 2: No saved server found — load servers
        do
        {
            try await loadCachedServers()
        } catch
        {
            AppLoggerManager.shared.log("Failed to load servers: \(error)")
            return nil
        }

        // Step 3: Check subscription status
        let isSubscribed = SubscriptionManager.shared.isSubcribed()

        // Step 4: Select a server from the correct pool
        let availableServers = isSubscribed ? premiumServers : freeServers
        guard let selectedServer = availableServers.randomElement() else {
            AppLoggerManager.shared.log("No servers available for selection.")
            return nil
        }

        // Step 5: Save selected server to UserDefaults
        saveSelectedServer(selectedServer)
    
        
        // Step 6: Return the selected server
        return selectedServer
    }
    
    //Called External to save the selected server into user defualts
    func saveSelectedServer(_ server: Server)
    {
        if let data = try? JSONEncoder().encode(server)
        {
            UserDefaults.standard.set(data, forKey: SkyLinkAssets.AppKeys.UserDefaults.currentServer)
            AppLoggerManager.shared.log("Saved selected server: \(server.name)")
            NotificationCenter.default.post(name: .serverDidUpdate, object: server) //post notification for other classes to respond accordingly
            
        }
    }
    
    // ConfigurationManager.swift

    func syncInitialVPNState(_ isConnected: Bool) {
        AppLoggerManager.shared.log(
            "[Config] Syncing initial VPN state = \(isConnected)"
        )

        UserDefaults.standard.set(
            isConnected,
            forKey: SkyLinkAssets.AppKeys.UserDefaults.lastConnectionState
        )

        if !isConnected {
            UserDefaults.standard.removeObject(
                forKey: SkyLinkAssets.AppKeys.UserDefaults.lastConnectedDate
            )
        }
    }
    
}
