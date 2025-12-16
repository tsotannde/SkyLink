//
//  Subscriber+Setup.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 12/12/25.
//

import Foundation
import SafariServices

//MARK: - Internal Functions
extension SubscribeViewController
{
    internal func getPrices()
    {
        // Fetch subscription pricing asynchronously from StoreKit via SubscriptionManager.
        // This runs off the main thread and updates UI state only after all prices resolve.
        Task {
            do {
                // Request raw prices for each tier individually.
                // These values come directly from the App Store and may include extra precision.
                let weeklyRaw  = try await SubscriptionManager.shared.price(for: .weekly)
                let monthlyRaw = try await SubscriptionManager.shared.price(for: .monthly)
                let yearlyRaw  = try await SubscriptionManager.shared.price(for: .yearly)

                // Normalize prices to two decimal places for consistent UI presentation.
                let pricing = SubscriptionPricing(
                    weekly: (weeklyRaw * 100).rounded() / 100,
                    monthly: (monthlyRaw * 100).rounded() / 100,
                    yearly: (yearlyRaw * 100).rounded() / 100
                )

                // Update pricing on the main thread so bound UI elements can react safely.
                await MainActor.run
                {
                    self.pricing = pricing
                }

            } catch
            {
                // Pricing fetch failed:
                // Log the error for diagnostics, inform the user, and dismiss the subscription screen
                // to avoid leaving the UI in a partially loaded state.
                AppLoggerManager.shared.log("[SubscribeVC]: Failed to load prices — \(error)")

                await MainActor.run
                {
                    let title = SkyLinkAssets.Text.errorTitleKey
                    let message = SkyLinkAssets.Text.errorMessageKey
                    SkyLinkAssets.Alerts.showAlert(from: self, title: title, message: message)
                    {
                        NavigationManager.shared.dismiss(on: self.navigationController,animation: .push(direction: .right),animated: true)
                    }
                   
                    
                }
            }
        }
    }
    
    @objc internal func planTapped(_ gesture: UITapGestureRecognizer)
    {
        guard let tappedPlan = gesture.view as? SubscriptionPlan else { return }

        // Record the user's selected subscription tier.
        // This drives pricing, free-trial checks, and purchase behavior.
        selectedTier = tappedPlan.tier

        // Visually update all plan views so only the tapped plan appears selected.
        planViews.forEach
        { plan in
            plan.setSelected(plan === tappedPlan)
        }

        // Ask StoreKit whether the selected tier is eligible for a free trial.
        // Eligibility is evaluated dynamically per user and product.
        Task {
            let hasFreeTrial = await SubscriptionManager.shared.checkProductElegibilityForTrail(productID: tappedPlan.tier.productID)

            await MainActor.run
            {
                self.isElegibleForFreeTrial = hasFreeTrial

                if hasFreeTrial
                {
                    self.showFreeTrial()
                } else
                {
                    self.hideFreeTrial()
                }
            }

            // Update the continue button after eligibility is resolved
            // so title and subtitle reflect the correct purchase flow.
            await updateContinueButtonText()
        }
    }
    
    internal func checkFreeTrialEligibility()
    {
        // Query global free-trial eligibility for the current user.
        // This is used when the screen loads without a specific tier selected.
        Task {
            let eligible = await SubscriptionManager.shared.isEligibleForFreeTrial()

            await MainActor.run {
                self.isElegibleForFreeTrial = eligible

                if eligible {
                    self.showFreeTrial()
                } else {
                    self.hideFreeTrial()
                }

                // Ensure the continue button text is refreshed AFTER eligibility is known.
                Task { await self.updateContinueButtonText() }
            }
        }
    }
    
    private func showFreeTrial()
    {
        freeTrialView.setVisible(true)
        freeTrialView.setEnabled(true)
    }

    internal func hideFreeTrial()
    {
        freeTrialView.setEnabled(false)
        freeTrialView.setVisible(false)
    }
}

//MARK: - Targets / User Actions
extension SubscribeViewController
{
  internal func addTargets()
    {
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        restoreButton.addTarget(self, action: #selector(restoreButtonTapped), for: .touchUpInside)
        continueButton.addTarget(self,action: #selector(continueTapped),   for: .touchUpInside)
        privacyButton.addTarget(self, action: #selector(openPrivacyPolicy), for: .touchUpInside)
        termsButton.addTarget(self, action: #selector(openTermsOfUse), for: .touchUpInside)
        
    }
    
    @objc private func closeButtonTapped()
    {
        NavigationManager.shared.dismiss(on: self.navigationController,animation: .push(direction: .right), animated: true)
    }
    
    @objc private func restoreButtonTapped()
    {
        // Disable the restore button to prevent duplicate restore requests.
        restoreButton.isEnabled = false

        // Ask StoreKit to restore any previously purchased subscriptions for this account.
        Task {
            let restored = await SubscriptionManager.shared.restorePurchases()

            await MainActor.run
            {
                restoreButton.isEnabled = true

                if restored {
                    let title = SkyLinkAssets.Text.subscriptionActiveKey
                    let message = SkyLinkAssets.Text.fullAccessKey

                    SkyLinkAssets.Alerts.showAlert(from: self, title: title, message: message)
                    {
                        NavigationManager.shared.dismiss(on: self.navigationController,animation: .push(direction: .right),animated: true)
                    }
                } else
                {
                    let title = SkyLinkAssets.Text.noSubscriptionFoundTitleKey
                    let message = SkyLinkAssets.Text.restoreNotFoundMessageKey
                    SkyLinkAssets.Alerts.showAlert(from: self, title: title, message: message)
                }
            }
        }
    }
    
    @objc private func openPrivacyPolicy()
    {
        let site = SkyLinkAssets.URLS.SubscriptionPage.privacyPolicy
        guard let url = URL(string: site ) else { return }

        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredControlTintColor = SkyLinkAssets.Colors.Themes.primary
        safariVC.modalPresentationStyle = .pageSheet
        present(safariVC, animated: true)
    }

    @objc private func openTermsOfUse()
    {
        let url =  SkyLinkAssets.URLS.SubscriptionPage.termOfUse
        guard let url = URL(string: url) else { return }

        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredControlTintColor = SkyLinkAssets.Colors.Themes.primary
        safariVC.modalPresentationStyle = .pageSheet
        present(safariVC, animated: true)
    }
    
    @objc private func continueTapped()
    {
        // Ensure the user has selected a subscription tier before attempting purchase.
        guard let tier = selectedTier else
        {
            let title = SkyLinkAssets.Text.noPlanSelectedKey
            let message =  SkyLinkAssets.Text.selectPlanKey
            SkyLinkAssets.Alerts.showAlert(from: self, title: title, message: message)
            return
        }
        // Disable the continue button during the purchase flow to prevent double taps.
        continueButton.isEnabled = false //disable the button

        // Initiate the purchase flow for the selected tier.
        // The result reflects the final StoreKit transaction state.
        Task {
            let result = await SubscriptionManager.shared.purchase(tier: tier)

            await MainActor.run
            {
                self.continueButton.isEnabled = true

                switch result
                {
                case .success:
                    let title = SkyLinkAssets.Text.subscriptionActiveKey
                    let message =  SkyLinkAssets.Text.fullAccessKey
                    SkyLinkAssets.Alerts.showAlert(from: self, title: title, message: message)
                    {
                        NavigationManager.shared.dismiss(on: self.navigationController,animation: .push(direction: .right),animated: true)
                    }
                case .cancelled:
                    let title = SkyLinkAssets.Text.purchaseCancelledKey
                    let message = SkyLinkAssets.Text.userCanceledMessageKey
                    SkyLinkAssets.Alerts.showAlert(from: self, title: title, message: message)
                case .pending:
                    let title = SkyLinkAssets.Text.purchasePendingKey
                    let message = SkyLinkAssets.Text.purchasePendingMessageKey
                    SkyLinkAssets.Alerts.showAlert(from: self, title: title, message: message)
                case .failed:
                    let title = SkyLinkAssets.Text.purchaseFailedKey
                    let message = SkyLinkAssets.Text.purchaseFailedMessageKey
                    SkyLinkAssets.Alerts.showAlert(from: self, title: title, message: message)
                }
            }
        }
    }
}



//MARK: - Continue Button
extension SubscribeViewController
{
    struct ContinueButtonText
    {
        let title: String
        let subtitle: String
    }

    @MainActor
    internal func updateContinueButtonText() async
    {
        guard let tier = selectedTier else { return }
     
        // Treat nil eligibility as false to ensure predictable button text.
        let elegibility = isElegibleForFreeTrial ?? false
        
        // Compute the correct button title and subtitle based on tier,
        // pricing, and free-trial eligibility.
        let text = continueButtonText(tier: tier, pricing: pricing,isEligibleForFreeTrial: elegibility)

        var config = continueButton.configuration

        // Title
        config?.attributedTitle = AttributedString(
            text.title,
            attributes: AttributeContainer([
                .font: SkyLinkAssets.Fonts.semiBold(ofSize: 16)
            ])
        )

        // Subtitle
        config?.attributedSubtitle = AttributedString(
            text.subtitle,
            attributes: AttributeContainer([
                .font: SkyLinkAssets.Fonts.regular(ofSize: 13),
                .foregroundColor: SkyLinkAssets.Colors.greyColor ?? .gray
            ])
        )

        // Vertical layout spacing
        config?.titlePadding = 4
        config?.titleAlignment = .center
        continueButton.contentHorizontalAlignment = .center

        continueButton.configuration = config
    }
   
    func continueButtonText(tier: SubscriptionTier,pricing: SubscriptionPricing,isEligibleForFreeTrial: Bool) -> ContinueButtonText
    {

        let price = pricing.price(for: tier)
        let formattedPrice = String(format: "$%.2f", price)

        switch tier {

        case .weekly:
            //NO free trial for weekly
            let title = SkyLinkAssets.Text.continueKey
            let subTitle = "\(SkyLinkAssets.Text.subscribeForKey) \(formattedPrice) / \(SkyLinkAssets.Text.weekKey)"
            return ContinueButtonText(title: title ,subtitle: subTitle)

        case .monthly:
            if isEligibleForFreeTrial
            {
                let title = SkyLinkAssets.Text.startFreeTrailKey
                let subTitle = "\(SkyLinkAssets.Text.thenKey) \(formattedPrice) / \(SkyLinkAssets.Text.monthKey)"
                return ContinueButtonText(title: title ,subtitle: subTitle)
            } else
            {
                let title = SkyLinkAssets.Text.continueKey
                let subTitle = "\(SkyLinkAssets.Text.subscribeForKey) \(formattedPrice) / \(SkyLinkAssets.Text.monthKey)"
                return ContinueButtonText(title: title,subtitle: subTitle)
            }

        case .yearly:
            if isEligibleForFreeTrial
            {
                let title = SkyLinkAssets.Text.startFreeTrailKey
                let subTitle = "\(SkyLinkAssets.Text.thenKey) \(formattedPrice) / \(SkyLinkAssets.Text.yearKey)"
                return ContinueButtonText(title: title ,subtitle: subTitle)
            } else
            {
                let title = SkyLinkAssets.Text.continueKey
                let subTitle = "\(SkyLinkAssets.Text.subscribeForKey) \(formattedPrice) / \(SkyLinkAssets.Text.yearKey)"
                return ContinueButtonText(title: title,subtitle: subTitle)
            }
        }
    }
    
}
