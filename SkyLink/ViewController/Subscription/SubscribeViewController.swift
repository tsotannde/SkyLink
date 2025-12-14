//
//  SubscribeViewController.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 10/22/25.
//

import Foundation

import UIKit
import Lottie
import SafariServices

class SubscribeViewController: UIViewController
{
    //DATA
    internal var pricing: SubscriptionPricing = SubscriptionProducts.defaultPricing  //DefualtPrices
    internal var planViews: [SubscriptionPlan] = []
    internal var selectedTier: SubscriptionTier?
    internal var isElegibleForFreeTrial: Bool?
    
    //UI
    internal let closeButton = createCloseButton()
    internal let restoreButton = createRestoreButton()
    internal var topCardView = createTopCardView()
    internal let freeTrialView: FreeTrail = FreeTrail()
    internal var plansStack: UIStackView!
    internal let continueButton = createContinueButton()
    internal let legalStack = UIStackView()
    internal let termsButton = createTermsButton()
    internal let privacyButton = createPrivacyButton()
    

    override func viewDidLoad()
    {
        super.viewDidLoad()
        createUsrInterface()
        addTargets()
        
        Task
        {
            getPrices() //Update hardcoded Prices
            checkFreeTrialEligibility()
            await updateContinueButtonText()
        }

    }
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        SkyLinkAssets.LottieAnimation.star.play() // Restart the animation in the top card
    }
}




