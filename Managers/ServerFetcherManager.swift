//
//  ServerFetcherManager.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 10/22/25.
//  Updated for async/await and improved reliability.
//

import Foundation


final class ServerFetcherManager {
    
    static let shared = ServerFetcherManager()
    private let firebaseURL = "https://vpn-se-default-rtdb.firebaseio.com/.json"
    private init() {}
    
    // MARK: - Fetch & Cache Raw JSON
    
    /// Fetches raw server JSON data from Firebase and caches it.
    func fetchServers() async throws {
        guard let url = URL(string: firebaseURL) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        print("📡 [ServerFetcher] Fetched raw JSON data size: \(data.count) bytes")
        UserDefaults.standard.set(data, forKey: "cachedServerJSON")
    }
    
    /// Retrieves cached raw JSON data.
    func getCachedJSON() -> Data?
    {
        return UserDefaults.standard.data(forKey: "cachedServerJSON")
    }
    
    // MARK: - Filtered Servers
    
    /// Returns all servers where requiresSubscription == false.
    func getFreeServers() -> [Server] {
        guard let data = getCachedJSON(),
              let decoded = try? JSONDecoder().decode(ServerDatabase.self, from: data) else {
            return []
        }
        
        let freeServers = decoded.servers.flatMap { (_, country) in
            country.servers.compactMap { (_, server) in
                country.requiresSubscription == false ? server : nil
            }
        }
        return freeServers
    }
    
    /// Returns all servers where requiresSubscription == true.
    func getPaidServers() -> [Server]
    {
        guard let data = getCachedJSON(),
              let decoded = try? JSONDecoder().decode(ServerDatabase.self, from: data) else {
            return []
        }
        
        let paidServers = decoded.servers.flatMap { (_, country) in
            country.servers.compactMap { (_, server) in
                country.requiresSubscription == true ? server : nil
            }
        }
        return paidServers
    }
}
