//
//  AppDelegate.swift
//  NEWVPN
//
//  Created by Developer on 10/6/25.
//

import UIKit
import FirebaseCore
import FirebaseAuth


@main
class AppDelegate: UIResponder, UIApplicationDelegate
{
    // Minimal AppDelegate:
    // Firebase is configured here at startup.
    // iOS default lifecycle behavior is acceptable since no overrides are needed.
    private let configureFirebase: Void =
    {
        InternetManager.shared.startMonitoring()
        FirebaseApp.configure() //Configure Firebase
    }()
}
