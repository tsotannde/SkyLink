//
//  Server.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 10/23/25.
//


struct Server: Codable, Identifiable
{
    var id: String { name }
    let name: String
    let nickname: String?
    let location: String?
    let country: String?
    let state: String?
    let city: String?
    let publicIP: String?
    let osVersion: String?
    let requiresSubscription: Bool
    let capacity: Int
    let currentCapacity: Int
    let lastUpdated: String
    let allowNewConnection: Bool?
    let port: Int?
}
