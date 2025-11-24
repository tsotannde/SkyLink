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
    private init() {}

    public var freeServers: [Server] = []
    public var premiumServers: [Server] = []

    func loadServers() async throws
    {
        guard let data = ServerFetcherManager.shared.getCachedJSON() else
        {
            print("No cached JSON found. Ensure fetchServers() was called before loading servers.")
            return
        }

        freeServers = getFreeServers(with: data)
        premiumServers = getPaidServers(with: data)

        print("Loaded \(freeServers.count) free servers and \(premiumServers.count) premium servers.")
    }

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
                country.requiresSubscription == false ? server : nil
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
                country.requiresSubscription == true ? server : nil
            }
        }
        return servers
    }
    
    func getOrSelectServer() async -> Server?
    {
        // Step 1: Try loading an existing saved server
        if let data = UserDefaults.standard.data(forKey: "currentServer"),
           let savedServer = try? JSONDecoder().decode(Server.self, from: data)
        {
            print("[ConfigurationManager] - Loaded previously selected server: \(savedServer.name)")
            return savedServer
        }

        // Step 2: No saved server found — load servers
        do
        {
            try await loadServers()
        } catch
        {
            print("Failed to load servers: \(error)")
            return nil
        }

        // Step 3: Check subscription status
        let isSubscribed = SubscriptionManager.shared.isSubcribed()

        // Step 4: Select a server from the correct pool
        let availableServers = isSubscribed ? premiumServers : freeServers
        guard let selectedServer = availableServers.randomElement() else {
            print("No servers available for selection.")
            return nil
        }

        // Step 5: Save selected server to UserDefaults
        if let data = try? JSONEncoder().encode(selectedServer)
        {
            UserDefaults.standard.set(data, forKey: "currentServer")
            print("Saved new selected server: \(selectedServer.name)")
        }

        // Step 6: Return the selected server
        return selectedServer
    }
    
    func saveSelectedServer(_ server: Server) {
        if let data = try? JSONEncoder().encode(server) {
            UserDefaults.standard.set(data, forKey: "currentServer")
            print("✅ Saved selected server: \(server.name)")
            
         
                NotificationCenter.default.post(name: .serverDidUpdate, object: server)
            
        }
    }
}
