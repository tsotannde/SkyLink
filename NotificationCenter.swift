//
//  NitificationCenter.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 10/22/25.
//


import Foundation

extension Notification.Name
{
    static let configurationDidChange = Notification.Name("configurationDidChange")
    static let internetDidConnect = Notification.Name("internetDidConnect")
    static let internetDidDisconnect = Notification.Name("internetDidDisconnect")
}


//NEW UPDATED

import Foundation

extension Notification.Name
{
    //PowerButton
    static let vpnDidConnect = Notification.Name("vpnDidConnect")
    static let vpnDidDisconnect = Notification.Name("vpnDidDisconnect")
    static let vpnIsConnecting = Notification.Name("vpnIsConnecting")
    static let vpnIsDisconnecting = Notification.Name("vpnIsDisconnecting")
    
    //ServerView
    static let serverDidUpdate = Notification.Name("serverDidUpdate")
}
