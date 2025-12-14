import UIKit

enum VPNState: String {
    case connected
    case disconnected
    case connecting
    case disconnecting
}

struct AppDesign
{
    struct Configuration
    {
        // TODO: align with your existing app group identifier
        //static let groupName: String = "group.com.skylink"
        static let groupName: String = "group.com.adebayosotannde.SkyLink"
    }
    
    enum AppKeys
    {
        enum UserDefaults
        {
            static let suiteName = AppDesign.Configuration.groupName
           // static let isConnected = "isConnected"
            static let downloadSpeed = "downloadSpeed"
            static let uploadSpeed = "uploadSpeed"
            static let lastConnectionState = "lastConnectionState"
            static let lastConnectedDate = "lastConnectedDate"
            static let vpnState = "vpnState"
            static let currentServer = "currentServer"
            static let cachedServerJSON = "cachedServerJSON"
            
            
        }
    }
    struct Images
    {
        static let grid: UIImage? = UIImage(systemName: "square.grid.2x2")
        static let crown: UIImage? = UIImage(named: "crown")
        static let downloadArrow: UIImage? = UIImage(systemName: "arrow.down")
        static let uploadArrow: UIImage? = UIImage(systemName: "arrow.up")
        static let chevronUp: UIImage? = UIImage(systemName: "chevron.up")
        static let magnifyGlass: UIImage? = UIImage(systemName: "magnifyingglass")
        static let checkMark: UIImage? = UIImage(systemName: "checkmark")
//        static let xMark: UIImage? = UIImage(systemName: "xmark")
        static let cellularbars = "cellularbars"
        static let chevronRight = "chevron.right"
       
        
    }
    
    struct ColorScheme
    {
        struct Styling
        {
            struct Background
            {
                static let surface: UIColor = .white
            }
            
            struct Tint
            {
                static let secondary: UIColor = .darkGrey
                static let statIcon: UIColor = .systemGreen
                static let primaryText: UIColor = .white
            }
            struct Border {
                static let subtle: UIColor = UIColor(white: 0.9, alpha: 1)
            }
            struct Shadow
            {
                static let standard: UIColor = .black
            }
        }
        
        struct App
        {
            static let background: UIColor = UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1.0)
        }
        
        struct Themes
        {
            static let primary: UIColor = UIColor(red: 0.2588, green: 0.6471, blue: 0.9608, alpha: 1.0)
        }
        
        struct TextColors
        {
            struct PrimaryTheme
            {
                static let text: UIColor = .white
                static let secondaryText: UIColor = .secondaryLabel
            }
        }
        
        
    }
    
    enum Text
    {
        struct HomeViewController
        {
            static let goPremium = String(localized:  "goPremiumKey")
        }
        
        
        static let downloadKey = String(localized:  "downloadKey")
        static let uploadKey = String(localized:  "uploadKey")
        static let speedUnit = String(localized: "speedUnitKey")
        static let connectedKey = String(localized: "connectedKey")
        static let disconnectedKey = String(localized: "disconnectedKey")
        static let connectingKey = String(localized: "connectingKey")
        static let disconnectingKey = String(localized: "disconnectingKey")
        static let noInternetKey = String(localized: "noInternetKey")
        static let noInternetMessageKey = String(localized: "noInternetMessageKey")
        static let retryKey = String(localized: "retryKey")
        static let chooseLocationKey = String(localized: "chooseLocationKey")
        static let searchLocationKey = String(localized: "searchLocationKey")
       
       
        static let restoreKey = String(localized: "restoreKey")
        
        
    
        
    }
}


