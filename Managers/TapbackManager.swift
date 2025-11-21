//
//  TapbackManager.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 10/22/25.
//

import Foundation

import UIKit

final class TapbackManager {
    static let shared = TapbackManager()
    private init() {}

    /// Triggers a haptic feedback if enabled in user defaults.
    func performTapFeedback() {
        let hapticsEnabled = UserDefaults.standard.bool(forKey: "hapticsEnabled")
        guard hapticsEnabled else {
            print("⚙️ Tapback disabled in settings.")
            return
        }

        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        print("💥 Tapback performed.")
    }

    /// Enables or disables haptics globally.
    func setHapticsEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: "hapticsEnabled")
    }

    /// Returns whether haptics are currently enabled.
    func isHapticsEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: "hapticsEnabled")
    }
}
