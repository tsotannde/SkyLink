//
//  Country.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 10/23/25.
//

struct Country: Codable, Identifiable
{
    var id: String
    { 
        name ?? SkyLinkAssets.Text.unknownKey
    }
    let name: String?
    let requiresSubscription: Bool
    let servers: [String: Server]
}
