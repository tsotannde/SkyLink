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

//MARK: - Text
extension SkyLinkAssets
{
    struct Text
    {
        struct SubscriptionPage
        {
            static let continueKey = String(localized: "continueKey")
            static let termOfUseKey = String(localized: "termOfUseKey")
            static let privacyPolicyKey = String(localized: "privacyPolicyKey")
            static let stayAnonymousOnlineKey = String(localized: "stayAnonymousOnlineKey")
            static let subTitleTextKey = String(localized: "subTitleTextKey")
            static let restoreKey = String(localized: "restoreKey")
            
        
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
