//
//  Subsribe+Ui.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 12/12/25.
//

import UIKit
import Lottie

// UI-only extensions for SubscribeViewController.
// This file is responsible strictly for view construction, layout,
// and visual styling. No business logic or StoreKit behavior lives here.

//MARK: - Background Color and Nav Bar
extension SubscribeViewController
{
    // Applies the primary theme background used across the subscription screen.
    internal func setBackgroundColor()
    {
           view.backgroundColor = SkyLinkAssets.Colors.Themes.primary
    }
    
    // Hides the navigation bar to present the subscription flow
    // as a full-screen, modal-style experience.
    func hideNaviagationBar()
    {
        NavigationManager.shared.toggleNavigationBar(on: self.navigationController,shouldShow: false)
    }
}

//MARK: - X Button
extension SubscribeViewController
{
    // Creates the circular close (X) button used to dismiss the subscription screen.
    // The button is styled independently so it can be reused or repositioned easily.
    static func createCloseButton() -> UIButton
    {
        let button = UIButton(type: .system)

        // Configure the X icon using an SF Symbol with a bold weight
        // to ensure visibility against the colored background.
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        let image = SkyLinkAssets.Images.xMark?.withConfiguration(config)
        button.setImage(image, for: .normal)
        button.tintColor = SkyLinkAssets.Colors.softWhite

        // Circular background
        button.backgroundColor = SkyLinkAssets.Colors.redColor
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true

        // Size of circle button
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 32).isActive = true
        button.heightAnchor.constraint(equalToConstant: 32).isActive = true

        return button
    }
    
    // Adds the close button to the top-left corner of the screen
    // and anchors it to the safe area.
    func addXButton()
    {
        view.addSubview(closeButton)
       
        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
        ])
    }
}

//MARK: - Restore Button
extension SubscribeViewController
{
    // Creates the restore purchases button.
    // Tapping this triggers a StoreKit restore flow handled elsewhere.
    static func createRestoreButton() -> UIButton
    {
        let button = UIButton(type: .system)
        let title = SkyLinkAssets.Text.restoreKey
        button.setTitle(title, for: .normal)
        button.setTitleColor(SkyLinkAssets.Colors.softWhite, for: .normal)
        button.titleLabel?.font = SkyLinkAssets.Fonts.semiBold(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    // Positions the restore button in the top-right corner of the screen.
    func addRestoreButton()
    {
        view.addSubview(restoreButton)

        NSLayoutConstraint.activate([
            restoreButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            restoreButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10)
        ])
    }
}

//MARK: - Top Card
extension SubscribeViewController
{
    // Builds the top feature card shown on the subscription screen.
    // The outer container provides shadow, while the inner content view
    // provides rounded corners and clipping for animations.
    static func createTopCardView() -> UIView
    {
        // Outer container provides the shadow
        let container = UIView()
        container.backgroundColor = .clear
        container.translatesAutoresizingMaskIntoConstraints = false
        container.layer.masksToBounds = false

        // Subtle card shadow
        container.layer.shadowColor = SkyLinkAssets.Colors.Shadow.blackShadow?.cgColor
        container.layer.shadowOpacity = 0.8
        container.layer.shadowRadius = 12
        container.layer.shadowOffset = CGSize(width: 0, height: 6)

        // Inner view provides rounded corners + clipping
        let contentView = UIView()
        contentView.backgroundColor = SkyLinkAssets.Colors.softWhite
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
        contentView.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: container.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])

        // Decorative Lottie animation used as a subtle background accent
        // inside the top card. This animation is purely visual.
        let animationView = SkyLinkAssets.LottieAnimation.star
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.loopMode = .autoReverse
        animationView.animationSpeed = 0.4
        animationView.contentMode = .scaleAspectFill
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.alpha = 0.8

        contentView.insertSubview(animationView, at: 0)

        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: contentView.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            animationView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])

        animationView.play() // Start the Animation

        // IMPORTANT: Return the outer container so the shadow remains visible.
        return container
    }
    
    // Creates a single feature row consisting of an icon and descriptive text.
    // Used to list the benefits of subscribing.
    internal  func createFeatureRow(icon: UIImage?,text: String) -> UIStackView
    {

        let imageView = UIImageView(image: icon)
        imageView.tintColor = SkyLinkAssets.Colors.Themes.primary
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 28).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 28).isActive = true

        let label = UILabel()
        label.text = text
        label.font = SkyLinkAssets.Fonts.regular(ofSize: 14)
        label.textColor = SkyLinkAssets.Colors.blackColor
        label.numberOfLines = 0

        let row = UIStackView(arrangedSubviews: [imageView, label])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 20

        return row
    }
    
    // Populates the top card with title, subtitle, and feature rows.
    // This method assumes the top card view has already been created.
    func addContentToTopView() {

        // MARK: - Title
        let titleLabel = UILabel()
        titleLabel.text = SkyLinkAssets.Text.stayAnonymousOnlineKey
        titleLabel.font = SkyLinkAssets.Fonts.semiBold(ofSize: 25)
        titleLabel.textColor = SkyLinkAssets.Colors.blackColor
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        // MARK: - Subtitle
        let subtitleLabel = UILabel()
        subtitleLabel.text =  SkyLinkAssets.Text.subTitleTextKey
        subtitleLabel.font = SkyLinkAssets.Fonts.regular(ofSize: 13)
        subtitleLabel.textColor = SkyLinkAssets.Colors.greyColor
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        // MARK: - Features Stack
        let featuresStack = UIStackView()
        featuresStack.axis = .vertical
        featuresStack.alignment = .fill
        featuresStack.spacing = 22

        
        featuresStack.addArrangedSubview(createFeatureRow(icon: SkyLinkAssets.Images.securityIcon,text: SkyLinkAssets.Text.secureYourConnectionKey))

        featuresStack.addArrangedSubview(createFeatureRow(icon: SkyLinkAssets.Images.hiddenIcon,text:  SkyLinkAssets.Text.hideYourIPKey))

        featuresStack.addArrangedSubview(createFeatureRow(icon: SkyLinkAssets.Images.speedIcon,text:  SkyLinkAssets.Text.fastLowKey))

        featuresStack.addArrangedSubview(createFeatureRow(icon: SkyLinkAssets.Images.acessIcon,text: SkyLinkAssets.Text.accessContentKey))
        
        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: 0).isActive = true

        // MARK: - MAIN STACK
        let mainStack = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel,
            spacer, //empty space
            featuresStack
        ])

        mainStack.axis = .vertical
        mainStack.alignment = .fill
        mainStack.spacing = 25
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        let contentHost = topCardView.subviews.first ?? topCardView
        contentHost.addSubview(mainStack)

        // MARK: - Constraints
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentHost.topAnchor, constant: 28),
            mainStack.leadingAnchor.constraint(equalTo: contentHost.leadingAnchor, constant: 24),
            mainStack.trailingAnchor.constraint(equalTo: contentHost.trailingAnchor, constant: -24),
            mainStack.bottomAnchor.constraint(lessThanOrEqualTo: contentHost.bottomAnchor, constant: -10)
        ])
    }
    
    // Adds the fully constructed top card to the view hierarchy
    // and positions it between the header buttons and the free trial view.
    func addTopCard()
    {
        view.addSubview(topCardView)
        // If createTopCardView returns a shadow container, add content into its inner rounded view.
        // The inner view is the first (and only) subview.
        addContentToTopView()
        topCardView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            topCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 35),
            topCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -35),
            topCardView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 20),
            topCardView.bottomAnchor.constraint(equalTo: freeTrialView.topAnchor, constant: -20)
        ])
    }
}

//MARK: - Free Trail View
extension SubscribeViewController
{
    // Adds the free trial informational view above the subscription plans.
    // Visibility and content are managed by the main view controller.
    private func addFreeTrialView()
    {
        freeTrialView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(freeTrialView)

        NSLayoutConstraint.activate([
            freeTrialView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            freeTrialView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            freeTrialView.bottomAnchor.constraint(equalTo: plansStack.topAnchor, constant: -20)
        ])
    }
}

//MARK: - Subscription Plans
extension SubscribeViewController
{
    // Creates and lays out the selectable subscription plan views
    // (weekly, monthly, yearly) and wires up tap gestures for selection.
    internal func setupSubscriptionPlans()
    {
        let weeklyPlan = SubscriptionPlan(tier: .weekly, pricing: pricing)
        let monthlyPlan = SubscriptionPlan(tier: .monthly, pricing: pricing)
        let yearlyPlan = SubscriptionPlan(tier: .yearly, pricing: pricing)

        planViews = [weeklyPlan, monthlyPlan, yearlyPlan]

        planViews.forEach { plan in
            let tap = UITapGestureRecognizer(target: self, action: #selector(planTapped(_:)))
            plan.addGestureRecognizer(tap)
            plan.isUserInteractionEnabled = true
        }

        
        self.plansStack = UIStackView(arrangedSubviews: [weeklyPlan, monthlyPlan, yearlyPlan])
        self.plansStack.axis = .horizontal
        self.plansStack.alignment = .fill
        self.plansStack.distribution = .fillEqually
        self.plansStack.spacing = 12
        self.plansStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(self.plansStack)

        NSLayoutConstraint.activate([
            self.plansStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            self.plansStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            self.plansStack.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -20)
        ])

        // Default selection: yearly plan.
        // This is visually highlighted when the screen first loads.
        selectedTier = .yearly
        yearlyPlan.setSelected(true)
        weeklyPlan.setSelected(false)
        monthlyPlan.setSelected(false)
    }
}

//MARK: - Continue Button
extension SubscribeViewController
{
    // Creates the primary call-to-action button used to continue
    // with the selected subscription plan.
    static func createContinueButton() -> UIButton
    {
        var config = UIButton.Configuration.filled()
        config.baseForegroundColor = SkyLinkAssets.Colors.Themes.primary
        config.baseBackgroundColor = SkyLinkAssets.Colors.whiteColor
        config.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20)
        config.cornerStyle = .capsule
        config.titleAlignment = .center

        let defualtText = SkyLinkAssets.Text.continueKey
        config.attributedTitle = AttributedString(
            defualtText,
            attributes: AttributeContainer([
                .font: SkyLinkAssets.Fonts.semiBold(ofSize: 18)
            ])
        )

        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentHorizontalAlignment = .center
        return button
    }
    
    // Positions the continue button above the legal links at the bottom of the screen.
    func addContinueButton()
    {
        view.addSubview(continueButton)

        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            continueButton.bottomAnchor.constraint(equalTo: legalStack.topAnchor, constant: -10),
            continueButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
}

//MARK: - Privacy and Terms of Use Button
extension SubscribeViewController
{
    // Creates the Terms of Use button displayed at the bottom of the screen.
    static func createTermsButton() -> UIButton
    {
        let button = UIButton(type: .system)
        let title = SkyLinkAssets.Text.termOfUseKey
        button.setTitle(title, for: .normal)
        button.setTitleColor(SkyLinkAssets.Colors.softWhite, for: .normal)
        button.titleLabel?.font = SkyLinkAssets.Fonts.semiBold(ofSize: 12)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    // Creates the Privacy Policy button displayed at the bottom of the screen.
    static func createPrivacyButton() -> UIButton
    {
        let button = UIButton(type: .system)
        let title = SkyLinkAssets.Text.privacyPolicyKey
        button.setTitle(title, for: .normal)
        button.setTitleColor(SkyLinkAssets.Colors.softWhite, for: .normal)
        button.titleLabel?.font = SkyLinkAssets.Fonts.semiBold(ofSize: 12)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    // Adds and lays out the legal buttons (Terms and Privacy)
    // in a horizontal stack at the bottom of the screen.
    private func addTermsAndPrivacyButtons()
    {
          legalStack.axis = .horizontal
          legalStack.alignment = .center
          legalStack.distribution = .equalSpacing
          legalStack.spacing = 30
          legalStack.translatesAutoresizingMaskIntoConstraints = false
          view.addSubview(legalStack)
          
          legalStack.addArrangedSubview(termsButton)
          legalStack.addArrangedSubview(privacyButton)
          
          NSLayoutConstraint.activate([
              legalStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
              legalStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 10)
          ])
          
    }
}

//MARK: - CREATE the USER Interface
extension SubscribeViewController
{
    // Centralized UI construction entry point for the subscription screen.
    // This method assembles all static UI components in the correct order.
    func createUsrInterface()
    {
        // Order matters here: header controls, legal buttons, primary actions,
        // plans, free trial info, and finally the top feature card.
        //ie each view is constrinaed against each other.
        hideNaviagationBar()
        setBackgroundColor()
        addXButton()
        addRestoreButton()
        addTermsAndPrivacyButtons()
        addContinueButton()
        setupSubscriptionPlans()
        addFreeTrialView()
        addTopCard()
        
    }
}
