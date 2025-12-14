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
        Task {
            AppLoggerManager.shared.log("[SubscribeVC]: Fetching subscription prices")
            do {
                let weeklyRaw  = try await SubscriptionManager.shared.price(for: .weekly)
                let monthlyRaw = try await SubscriptionManager.shared.price(for: .monthly)
                let yearlyRaw  = try await SubscriptionManager.shared.price(for: .yearly)

                // normalize to 2 decimal places
                let pricing = SubscriptionPricing(
                    weekly: (weeklyRaw * 100).rounded() / 100,
                    monthly: (monthlyRaw * 100).rounded() / 100,
                    yearly: (yearlyRaw * 100).rounded() / 100
                )

                print("pricing: \(pricing)")

                await MainActor.run
                {
                    self.pricing = pricing
                    AppLoggerManager.shared.log("[SubscribeVC]: Prices applied to UI")
                }

                AppLoggerManager.shared.log("[SubscribeVC]: Prices loaded successfully \(pricing)")
            } catch
            {
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

        selectedTier = tappedPlan.tier
        AppLoggerManager.shared.log("[SubscribeVC]: Plan selected — \(tappedPlan.tier)")

        planViews.forEach
        { plan in
            plan.setSelected(plan === tappedPlan)
        }

        Task {
            AppLoggerManager.shared.log("[SubscribeVC]: Checking free-trial eligibility for product \(tappedPlan.tier.productID)")
            // Ask Apple if tier has a free trial
            let hasFreeTrial = await SubscriptionManager.shared.checkProductElegibilityForTrail(productID: tappedPlan.tier.productID)

            await MainActor.run
            {
                AppLoggerManager.shared.log("[SubscribeVC]: Free-trial eligible for selected tier \(tappedPlan.tier): \(hasFreeTrial)")
                self.isElegibleForFreeTrial = hasFreeTrial

                if hasFreeTrial
                {
                    self.showFreeTrial()
                } else
                {
                    self.hideFreeTrial()
                }
            }

            await updateContinueButtonText()
        }
    }
    
    internal func checkFreeTrialEligibility()
    {
        Task {
            AppLoggerManager.shared.log("[SubscribeVC]: Checking global free-trial eligibility")

            let eligible = await SubscriptionManager.shared.isEligibleForFreeTrial()

            await MainActor.run {
                self.isElegibleForFreeTrial = eligible

                AppLoggerManager.shared.log("[SubscribeVC]: Global free-trial eligibility result: \(eligible)")

                if eligible {
                    self.showFreeTrial()
                } else {
                    self.hideFreeTrial()
                }

                // IMPORTANT: update button AFTER eligibility is known
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
        AppLoggerManager.shared.log("[SubscribeVC]: Restore tapped")
        restoreButton.isEnabled = false

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
        guard let tier = selectedTier else
        {
            let title = SkyLinkAssets.Text.noPlanSelectedKey
            let message =  SkyLinkAssets.Text.selectPlanKey
            SkyLinkAssets.Alerts.showAlert(from: self, title: title, message: message)
            return
        }
        AppLoggerManager.shared.log("[SubscribeVC]: Continue tapped for tier \(tier)")
        continueButton.isEnabled = false //disable the button

        Task {
            let result = await SubscriptionManager.shared.purchase(tier: tier)

            await MainActor.run
            {
                self.continueButton.isEnabled = true

                switch result
                {
                case .success:
                    AppLoggerManager.shared.log("[SubscribeVC]: Purchase success for tier \(tier)")
                    let title = SkyLinkAssets.Text.subscriptionActiveKey
                    let message =  SkyLinkAssets.Text.fullAccessKey
                    SkyLinkAssets.Alerts.showAlert(from: self, title: title, message: message)
                    {
                        NavigationManager.shared.dismiss(on: self.navigationController,animation: .push(direction: .right),animated: true)
                    }
                case .cancelled:
                    AppLoggerManager.shared.log("[SubscribeVC]: Purchase cancelled by user for tier \(tier)")
                    let title = SkyLinkAssets.Text.purchaseCancelledKey
                    let message = SkyLinkAssets.Text.userCanceledMessageKey
                    SkyLinkAssets.Alerts.showAlert(from: self, title: title, message: message)
                case .pending:
                    AppLoggerManager.shared.log("[SubscribeVC]: Purchase pending for tier \(tier)")
                    let title = SkyLinkAssets.Text.purchasePendingKey
                    let message = SkyLinkAssets.Text.purchasePendingMessageKey
                    SkyLinkAssets.Alerts.showAlert(from: self, title: title, message: message)
                case .failed:
                    AppLoggerManager.shared.log("[SubscribeVC]: Purchase failed for tier \(tier)")
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
        AppLoggerManager.shared.log("[SubscribeVC]: Updating Continue button for tier \(tier), freeTrialEligible=\(isElegibleForFreeTrial ?? false)")
     
        let elegibility = isElegibleForFreeTrial ?? false
        
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
