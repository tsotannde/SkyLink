//
//  AccountManager.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 10/24/25.
//

import Foundation
import FirebaseAuth

final class AccountManager {
    static let shared = AccountManager()
    private init() {}

    func ensureAccountExists() async throws -> User
    {
        if let currentUser = Auth.auth().currentUser
        {
            print("Existing user found: \(currentUser.uid)")
            return currentUser
        }
        do
        {
            let authResult = try await Auth.auth().signInAnonymously()
            print("Anonymous user created: \(authResult.user.uid)")
            return authResult.user
        } catch {
            print("Failed to create anonymous user: \(error)")
            throw error
        }
    }
}
