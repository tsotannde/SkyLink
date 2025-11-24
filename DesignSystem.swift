//
//  DesignSystem.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 10/22/25.
//

import UIKit

import UIKit

struct DesignSystem
{
    struct configuration
    {
        //static let groupName =  "group.com.adebayosotannde.SkyLink"
    }
     
    
    struct AppColors
    {
        
        struct Themes
        {
            static let primaryColor = UIColor(named: "primaryColor.")//✅
            
            struct CardView
            {
                static let cardBackgroundColor = UIColor(named: "cardBackgroundColor")//✅
                static let shadowColor = UIColor(named: "shadowColor")//✅
            }
        }

       
        static let backgroundcolor = UIColor(named: "backGround.")
       
        static let cellularBarColor = UIColor(named: "cellularBarColor")
        static let textColorBlack = UIColor(named: "textColorBlack")
        static let greySearchBarColor = UIColor(named: "greySearchBarColor")
        static let black = UIColor(named: "black.")
        static let darkGrey = UIColor(named: "darkGrey.")
        static let borderColor = UIColor(named: "borderColor.")
       
    }

    struct AppFonts {
        static let SoraRegular = "Sora-Regular"
        static let SoraSemiBold = "Sora-SemiBold"
        static let SoraBold = "Sora-Bold"
    }

    struct Images
    {
        static let cellularbars = "cellularbars"
        static let chevronRight = "chevron.right"
        static let crown = "crown"
    }
    
    enum L10n
    {
        static let goPremiumKey = String(localized:  "goPremiumKey")
        static let downloadKey = String(localized:  "downloadKey")
        static let uploadKey = String(localized:  "uploadKey")
    }
}
