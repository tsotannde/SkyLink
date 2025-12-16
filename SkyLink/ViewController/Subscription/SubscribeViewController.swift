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
        // Construct and lay out the static subscription UI (cards, plans, buttons).
        // This sets up the view hierarchy only; dynamic data (pricing, eligibility)
        // is populated asynchronously after the UI is in place.
        createUsrInterface()

        // Wire up user interaction handlers (button taps, plan selection).
        addTargets()
        
        // Kick off asynchronous setup work after the UI is built:
        // - Fetch live pricing from StoreKit
        // - Check free-trial eligibility for the current user
        // - Update the continue button once required data is available
        Task
        {
            // Replace default placeholder pricing with live App Store prices.
            getPrices() //Update hardcoded Prices
            // Determine whether the current user is eligible for a free trial.
            // This may vary per account and product.
            checkFreeTrialEligibility()
            // Refresh the continue button title/subtitle once pricing and eligibility
            // information has been resolved.
            await updateContinueButtonText()
        }

    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        SkyLinkAssets.LottieAnimation.star.play() // Restart the animation in the top card
    }
}




