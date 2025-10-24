//
//  KeyManager.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 10/22/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import CryptoKit

final class KeyManager
{
    static let shared = KeyManager()
    private init() {}

    private lazy var db = Firestore.firestore()
    
    func generateKeysIfNeeded(completion: ((Bool) -> Void)? = nil)
    {
        guard let userID = Auth.auth().currentUser?.uid else
        {
           
            completion?(false)
            return
        }

        // Retrieve existing keys
        let localPrivateKey = UserDefaults.standard.string(forKey: "privateKey")
        let localPublicKey = UserDefaults.standard.string(forKey: "publicKey")
        let uniqueInstallID = UserDefaults.standard.string(forKey: "uniqueInstallID")

        // Already have valid keys
        if localPrivateKey != nil && localPublicKey != nil && uniqueInstallID != nil {
            completion?(true)
            return
        }

        // Generate new keys
        let newUniqueInstallID = UUID().uuidString
        let privateKey = Curve25519.KeyAgreement.PrivateKey()
        let publicKey = privateKey.publicKey

        let privateKeyBase64 = privateKey.rawRepresentation.base64EncodedString()
        let publicKeyBase64 = publicKey.rawRepresentation.base64EncodedString()

        // Write to Firestore
        let installDoc = db.collection("users").document(userID)
            .collection("installs").document(newUniqueInstallID)

        installDoc.setData([
            "publicKey": publicKeyBase64,
            "uid": userID,
            "uniqueInstallID": newUniqueInstallID,
            "createdAt": FieldValue.serverTimestamp()
        ]) { error in
            if let error = error {
                print("Error uploading key: \(error.localizedDescription)")
                completion?(false)
                return
            }

            UserDefaults.standard.set(privateKeyBase64, forKey: "privateKey")
            UserDefaults.standard.set(publicKeyBase64, forKey: "publicKey")
            UserDefaults.standard.set(newUniqueInstallID, forKey: "uniqueInstallID")
            UserDefaults.standard.set(userID, forKey: "uid")
            completion?(true)
        }
    }

    func getPrivateKey() -> String?
    {
        return UserDefaults.standard.string(forKey: "privateKey")
    }

    #warning("Consider Deleting this function. Also Consider not storying the preivatekey since its not needed")
    func getPublicKey() -> String?
    {
        return UserDefaults.standard.string(forKey: "publicKey")
    }

}
