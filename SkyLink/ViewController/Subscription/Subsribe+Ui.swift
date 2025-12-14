//
//  Subsribe+Ui.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 12/12/25.
//

import UIKit
import Lottie

//MARK: - Background Color and Nav Bar
extension SubscribeViewController
{
    internal func setBackgroundColor()
    {
           view.backgroundColor = SkyLinkAssets.Colors.Themes.primary
    }
    
    func hideNaviagationBar()
    {
        NavigationManager.shared.toggleNavigationBar(on: self.navigationController,shouldShow: false)
    }
}

//MARK: - X Button
extension SubscribeViewController
{
    static func createCloseButton() -> UIButton
    {
        let button = UIButton(type: .system)

        // SF Symbol X icon
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

        // Add lottie animation stars background inside the inner content view
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

        
        featuresStack.addArrangedSubview(createFeatureRow(icon: UIImage(named: "securityIcon"),text: "Secure your connection on public Wi-Fi"))

        featuresStack.addArrangedSubview(createFeatureRow(icon: UIImage(named: "hiddenIcon"),text: "Hide your IP and browsing activity"))

        featuresStack.addArrangedSubview(createFeatureRow(icon: UIImage(named: "speedIcon"),text: "Fast, low-latency global servers"))

        featuresStack.addArrangedSubview(createFeatureRow(icon: UIImage(named: "acessIcon"),text: "Access content from anywhere"))
        
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

        // Default selection: Yearly
        selectedTier = .yearly
        yearlyPlan.setSelected(true)
        weeklyPlan.setSelected(false)
        monthlyPlan.setSelected(false)
    }
}

//MARK: - Continue Button
extension SubscribeViewController
{
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
    func createUsrInterface()
    {
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
