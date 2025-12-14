//
//  SkyLinkAssets.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 12/12/25.
//

import UIKit
import Lottie

//MARK: - Colors
struct SkyLinkAssets
{
    struct Colors
    {
        struct Themes
        {
            static let primary = UIColor(named: "primaryTheme")
        }
        
        struct Shadow
        {
            static let blackShadow = UIColor(named: "blackShadow")
        }
        
        static let softWhite = UIColor(named: "softWhite")
        static let redColor = UIColor(named: "redColor")
        static let blackColor = UIColor(named: "blackColor")
        static let greyColor = UIColor(named: "greyColor")
   
    }
    
    struct LottieAnimation
    {
        static let star = LottieAnimationView(name: "stars")
    }
    
    struct Images
    {
        static let xMark: UIImage? = UIImage(systemName: "xmark")
    }
}

extension SkyLinkAssets
{
    enum AppKeys
    {
        enum UserDefaults
        {
            static let suiteName = AppDesign.Configuration.groupName
            static let downloadSpeed = "downloadSpeed"
            static let uploadSpeed = "uploadSpeed"
            static let lastConnectionState = "lastConnectionState"
            static let lastConnectedDate = "lastConnectedDate"
            static let vpnState = "vpnState"
            static let currentServer = "currentServer"
            static let cachedServerJSON = "cachedServerJSON"
            
            
        }
    }
}
//MARK: - Text
extension SkyLinkAssets
{
    struct Text
    {
        
        static let noInternetKey = String(localized: "noInternetKey")
        static let noInternetMessageKey = String(localized: "noInternetMessageKey")
        
        
        struct SubscriptionPage
        {
            static let continueKey = String(localized: "continueKey")
            static let termOfUseKey = String(localized: "termOfUseKey")
            static let privacyPolicyKey = String(localized: "privacyPolicyKey")
            static let stayAnonymousOnlineKey = String(localized: "stayAnonymousOnlineKey")
            static let subTitleTextKey = String(localized: "subTitleTextKey")
            static let restoreKey = String(localized: "restoreKey")
            static let errorTitleKey = String(localized: "errorTitleKey")
            static let errorMessageKey = String(localized: "errorMessageKey")
            static let okKey = String(localized: "okKey")
            static let noPlanSelectedKey =  String(localized: "noPlanSelectedKey")
            static let selectPlanKey = String(localized: "selectPlanKey")
            static let subscriptionActiveKey = String(localized: "subscriptionActiveKey")
            static let fullAccessKey = String(localized: "fullAccessKey")
            static let purchaseCancelledKey = String(localized: "purchaseCancelledKey")
            static let userCanceledMessageKey = String(localized: "userCanceledMessageKey")
            static let purchasePendingKey = String(localized: "purchasePendingKey")
            static let purchasePendingMessageKey = String(localized: "purchasePendingMessageKey")
            static let purchaseFailedKey = String(localized: "purchaseFailedKey")
            static let purchaseFailedMessageKey = String(localized: "purchaseFailedMessageKey")
            static let startFreeTrailKey = String(localized: "startFreeTrailKey")
            static let weekKey = String(localized: "weekKey")
            static let monthKey = String(localized: "monthsKey")
            static let yearKey = String(localized: "yearKey")
            static let thenKey = String(localized: "thenKey")
            static let subscribeForKey = String(localized: "subscribeForKey")
            static let noSubscriptionFoundTitleKey = String(localized: "noSubscriptionFoundTitleKey")
            static let restoreNotFoundMessageKey = String(localized: "restoreNotFoundMessageKey")
            
            
        }
    }
   
    
}

//MARK: - URLS
extension SkyLinkAssets
{
    struct URLS
    {
        struct SubscriptionPage
        {
            static let privacyPolicy = "https://adebayosotannde.com/Legal/privacypolicy"
            static let termOfUse = "https://adebayosotannde.com/Legal/termsofuse"
    
        }
    }
   
    
}

extension SkyLinkAssets
{
    struct Alerts
    {
        static func showAlert(from viewController: UIViewController,title: String,message: String,onDismiss: (() -> Void)? = nil)
        {
            let alert = UIAlertController(title: title,message: message,preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: SkyLinkAssets.Text.SubscriptionPage.okKey,style: .default)
                { _ in
                    onDismiss?()
                })

            viewController.present(alert, animated: true)
        }
    }
   
}

//MARK: - FONTS
extension SkyLinkAssets
{
    struct Fonts
    {
        static func regular(ofSize size: CGFloat) -> UIFont
        {
            return UIFont(name: "Sora-Regualr", size: size) ?? UIFont.systemFont(ofSize: size)
        }

        static func semiBold(ofSize size: CGFloat) -> UIFont {
            return UIFont(name: "Sora-SemiBold", size: size) ?? UIFont.boldSystemFont(ofSize: size)
        }
    }
}
