 /// Returns all servers where requiresSubscription == false.
    func getFreeServers2() -> [Server]
    {
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
    func getPaidServers2() -> [Server]
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