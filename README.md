<p align="center">
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Swift-5.9_5.10_5.11-orange?style=for-the-badge&logo=swift" />
  <img src="https://img.shields.io/badge/Platforms-iOS_15+-blue?style=for-the-badge&logo=apple" />
  <img src="https://img.shields.io/badge/NetworkExtension-WireGuard-purple?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Firebase-Realtime_Database_|_Auth-yellow?style=for-the-badge&logo=firebase" />
</p>


<h2 align="center">SkyLinkVPN</h2>
<h4 align="center">A modern, lightweight iOS VPN client powered by WireGuard, Swift Concurrency, and Firebase.</h4>


🚀 Features
```swift
🛜 Full WireGuard Implementation
	•	Builds WireGuard config dynamically
	•	Uses Firebase Function requestIPAddress
	•	Retrieves assigned IP, server public key, and port
	•	Injects configuration into NETunnelProviderManager
	•	Uses Swift Concurrency for connect/disconnect flow

🔐 Cryptography
	•	Secure Curve25519 key generation
	•	Public/private key stored safely in App Group container
	•	Public key synced to Firestore under:
```
```swift
users/{uid}/installs/{installID}
```


☁️ Server Management

Server list is loaded from Firebase Realtime Database:
```swift
{
  "servers": {
    "USA": {
      "requiresSubscription": false,
      "servers": { ... }
    }
  }
}
```

SkyLinkVPN automatically:
	•	Separates free & premium servers
	•	Picks a default server on first launch
	•	Stores user preference
	•	Caches server DB in App Groups

📊 Real-Time Stats
	•	Live bandwidth monitoring (download/upload)
	•	Stats polled via shared App Group JSON
	•	Dynamic, animated UI components
	•	Smooth transitions between connection states

🌐 Subscription-Ready

Architecture already includes:
	•	SubscriptionManager
	•	premium server filtering
	•	AccountManager integration
(Payments not yet enabled)

⸻

## 🧱 Architecture Overview
```swift
SkyLinkVPN  
├── Managers/  
│   ├── VPNManager  
│   ├── ConfigurationManager  
│   ├── ServerFetcherManager  
│   ├── KeyManager  
│   ├── FirebaseRequestManager  
│   ├── SubscriptionManager  
│   └── AccountManager  
│
├── Models/  
│   ├── Server  
│   ├── Country  
│   └── ServerDatabase  
│
├── UI/  
│   ├── PowerButtonView  
│   ├── StatCard  
│   ├── SelectedServerView  
│   └── ConnectionStatusView  
│
└── Controllers/  
    ├── SplashViewController  
    └── HomeViewController
```
⸻

📦 Installation (Developer Build)

1. Clone the Repository

git clone https://github.com/tsotannde/SkyLinkVPN.git

2. Open Xcode Project

SkyLinkVPN.xcodeproj

3. Configure App Groups

Enable the following App Group on both:
	•	The main app target
	•	The Network Extension target

Example:

group.com.yourcompany.SkyLinkVPN

4. Firebase Setup

SkyLinkVPN uses:
	•	Firebase Auth (anonymous)
	•	Firebase Firestore
	•	Firebase Realtime Database
	•	Firebase Cloud Functions

Steps:
	1.	Create Firebase project
	2.	Add iOS app
	3.	Download GoogleService-Info.plist
	4.	Add to Xcode project
	5.	Enable anonymous sign-in
	6.	Add Realtime Database JSON
	7.	Deploy requestIPAddress Cloud Function

⸻

🧑‍💻 Usage (High-Level Flow)

Start the VPN
```swift
VPNManager.shared.startVPN { result in
    switch result {
    case .success:
        print("VPN connected!")
    case .failure(let error):
        print("Failed to connect:", error)
    }
}
```
Stop the VPN
```swift
VPNManager.shared.stopVPN()
```
Load Servers
```swift
ServerFetcherManager.shared.fetchServers { result in
    print(result)
}
```
Read Stats From App Group
```swift
let stats = Stats.readFromSharedContainer()
print(stats.download, stats.upload)
```

⸻

🎨 UI Components (Preview)
```swift
Power Button
	•	Pulses when connected
	•	Spinner when connecting
	•	Color transitions for states

StatCard
	•	Live download/upload speeds
	•	Animated text updates

SelectedServerView
	•	Auto flag loader
	•	Dynamic country/city display
```
⸻

🧪 Logging
```swift
Logging is handled through internal debug utilities.

Enable verbose logs:

Logger.level = .debug
```

⸻
👨‍💻 Author

MIT License - Adebayo Sotannde
SkyLinkVPN – WireGuard iOS Client


