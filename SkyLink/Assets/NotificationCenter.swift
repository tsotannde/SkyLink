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
    static let showSubscriptionPage = Notification.Name("showSubscriptionPage")
    static let vpnConnected = Notification.Name("vpnConnected")
    static let vpnDisconnected = Notification.Name("vpnDisconnected")
    static let vpnConnecting = Notification.Name("vpnConnecting")
    static let vpnDisconnecting = Notification.Name("vpnDisconnecting")
    
    //ServerView
    static let serverDidUpdate = Notification.Name("serverDidUpdate")
}
