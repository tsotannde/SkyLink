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

                await MainActor.run {
                    self.pricing = pricing
                }

                AppLoggerManager.shared.log("[SubscribeVC]: Prices loaded successfully \(pricing)")
            } catch {
                AppLoggerManager.shared.log(
                    "[SubscribeVC]: Failed to load subscription prices. Error: \(error)"
                )
            }
        }
    }
    
    
    
}

//MARK: - Targets / User Actions
extension SubscribeViewController
{
  internal func addTargets()
    {
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
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
        // Placeholder for restore action
    }
    
    @objc private func openPrivacyPolicy()
    {
        let site = SkyLinkAssets.URLS.SubscriptionPage.privacyPolicy
        guard let url = URL(string: site ) else { return }

        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredControlTintColor = UIColor(named: "primaryTheme")
        safariVC.modalPresentationStyle = .pageSheet

        present(safariVC, animated: true)
    }

    @objc private func openTermsOfUse()
    {
        let url =  SkyLinkAssets.URLS.SubscriptionPage.termOfUse
        guard let url = URL(string: url) else { return }

        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredControlTintColor = UIColor(named: "primaryTheme")
        safariVC.modalPresentationStyle = .pageSheet

        present(safariVC, animated: true)
    }
    
    @objc private func continueTapped()
    {
        guard let tier = selectedTier else {
            print("No subscription tier selected")
            return
        }

        continueButton.isEnabled = false

        Task {
            let result = await SubscriptionManager.shared.purchase(tier: tier)

            await MainActor.run
            {
                self.continueButton.isEnabled = true

                switch result
                {
                case .success:
                    self.showAlert(title: "Subscription Active",message: "You now have full access to SkyLink VPN.")
                    {
                        NavigationManager.shared.dismiss(on: self.navigationController,animation: .push(direction: .right),animated: true)
                       
                    }

                case .cancelled:
                    self.showAlert(title: "Purchase Cancelled",message: "No changes were made.")

                case .pending:
                    self.showAlert(title: "Purchase Pending",message: "Your purchase is pending approval.")

                case .failed:
                    self.showAlert(title: "Purchase Pending",message: "Your purchase is pending approval.")
                }
            }
        }
    }
    
    private func showAlert(title: String,message: String,onDismiss: (() -> Void)? = nil)
    {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default)
            { _ in
                onDismiss?()
            }
        )

        present(alert, animated: true)
    }
    
    
}

//MARK: - Plan Selection
extension SubscribeViewController
{
    @objc internal func planTapped(_ gesture: UITapGestureRecognizer)
    {
        guard let tappedPlan = gesture.view as? SubscriptionPlan else { return }

        selectedTier = tappedPlan.tier

        planViews.forEach { plan in
            plan.setSelected(plan === tappedPlan)
        }

        Task {
            // Ask Apple if tier has a free trial
            let hasFreeTrial = await SubscriptionManager.shared.checkProductElegibilityForTrail(productID: tappedPlan.tier.productID)

            await MainActor.run
            {
                self.isElegibleForFreeTrial = hasFreeTrial

                if hasFreeTrial {
                    self.showFreeTrial()
                } else {
                    self.hideFreeTrial()
                }
            }

            await updateContinueButtonText()
        }
    }
}

//MARK: - Free Trail Functions
extension SubscribeViewController
{
  
    internal func checkFreeTrialEligibility()
    {
        Task
        {
            
             isElegibleForFreeTrial = await SubscriptionManager.shared.isEligibleForFreeTrial()

            await MainActor.run
            {
                if isElegibleForFreeTrial == true
                {
                    self.showFreeTrial()
                }
                else
                {
                    self.hideFreeTrial()
                }
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
     
        let elegibility = isElegibleForFreeTrial ?? false
        
        let text = continueButtonText(tier: tier, pricing: pricing,isEligibleForFreeTrial: elegibility)

        var config = continueButton.configuration

        // Title
        config?.attributedTitle = AttributedString(
            text.title,
            attributes: AttributeContainer([
                .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
            ])
        )

        // Subtitle THIS WAS MISSING
        config?.attributedSubtitle = AttributedString(
            text.subtitle,
            attributes: AttributeContainer([
                .font: UIFont.systemFont(ofSize: 13, weight: .regular),
                .foregroundColor: UIColor(named: "secondaryTextColor") ?? .gray
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
            return ContinueButtonText(
                title: "Continue",
                subtitle: "Subscribe for \(formattedPrice) / week"
            )

        case .monthly:
            if isEligibleForFreeTrial {
                return ContinueButtonText(
                    title: "Start Free Trial",
                    subtitle: "Then \(formattedPrice) / month"
                )
            } else {
                return ContinueButtonText(
                    title: "Continue",
                    subtitle: "Subscribe for \(formattedPrice) / month"
                )
            }

        case .yearly:
            if isEligibleForFreeTrial {
                return ContinueButtonText(
                    title: "Start Free Trial",
                    subtitle: "Then \(formattedPrice) / year"
                )
            } else {
                return ContinueButtonText(
                    title: "Continue",
                    subtitle: "Subscribe for \(formattedPrice) / year"
                )
            }
        }
    }
    
}
