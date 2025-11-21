//
//  FirebaseRequestManager.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 10/24/25.
//

import Foundation
import FirebaseFunctions

struct ServerResponse: Codable
{
    let ip: String
    let publicKey: String
    let port: Int
}

final class FirebaseRequestManager
{
    static let shared = FirebaseRequestManager()
    private init() {}
    
    private let functions = Functions.functions()
    
    /// Sends request to Firebase and returns structured server response
    func sendRequest(serverIP: String, serverPort: Int, publicKey: String) async throws -> ServerResponse
    {
        print("[FirebaseRequestManager] - Sending request to Firebase")
        do
        {
            let result = try await functions.httpsCallable("requestIPAddress").call([
                "serverIP": serverIP,
                "serverPort": serverPort,
                "publicKey": publicKey
            ])
            
            guard let data = result.data as? [String: Any] else {
                throw NSError(
                    domain: "FirebaseRequestManager",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid response format"]
                )
            }

            print("[FirebaseRequestManager] - Full Firebase Response: \(data) \n" )

            // Match keys exactly with Firebase function response
            guard let ip = data["ip"] as? String,
                  let serverPubKey = data["serverPublicKey"] as? String,
                  let port = data["port"] as? Int else {
                throw NSError(
                    domain: "FirebaseRequestManager",
                    code: -2,
                    userInfo: [NSLocalizedDescriptionKey: "Missing fields in server response"]
                )
            }

            print("[FirebaseRequestManager] -Received from Firebase — \n IP: \(ip), PubKey: \(serverPubKey), Port: \(port)")
            return ServerResponse(ip: ip, publicKey: serverPubKey, port: port)
        } catch {
            print("[FirebaseRequestManager] -Firebase error: \(error.localizedDescription)")
            throw error
        }
    }
}
