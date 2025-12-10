//
//  Home+UI.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 11/21/25.
//

import UIKit

//MARK: - User Interface Components
extension HomeViewController
{
    static func createGridButton() -> UIButton
    {
        let button = UIButton(type: .system)
        button.setImage(AppDesign.Images.grid, for: .normal)
        button.tintColor = UIColor(named: "darkGreyTint")
        
        // Background Color and Border Color
        button.backgroundColor = UIColor(named: "whiteColor")
        button.layer.cornerRadius = 16
        button.layer.borderColor = UIColor(named: "borderColor")?.cgColor
        button.layer.borderWidth = 1
        
        // Depth Drop Shadow for Depth
        button.layer.shadowColor = UIColor(named: "blackColor")?.cgColor
        button.layer.shadowOpacity = 0.15
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        
        return button
    }
    
    static internal func createPremiumButton() -> UIButton
    {
        let button = UIButton(type: .system)
        
        // Text setup
        var configuration = UIButton.Configuration.plain()
        var container = AttributeContainer()
        container.font = AppDesign.Fonts.semiBold(ofSize: 16)
        configuration.attributedTitle = AttributedString(AppDesign.Text.HomeViewController.goPremium, attributes: container)
        configuration.imagePadding = 8
        configuration.imagePlacement = .leading
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        button.configuration = configuration
    
        button.backgroundColor = UIColor(named: "primaryTheme")
        
        // Corner radius & shadow
        button.layer.cornerRadius = 16
        button.layer.shadowColor = UIColor(named: "blackColor")?.cgColor
        button.layer.shadowOpacity = 0.4
        button.layer.shadowRadius = 8
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        
        // Add image to left side of text
        let icon = AppDesign.Images.crown?.withRenderingMode(.alwaysOriginal)
        button.setImage(icon, for: .normal)
        button.tintColor = UIColor(named: "darkGreyTint")
        
        // Rounded Rectanger
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 174).isActive = true
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        return button
    }
    
    static func createDownloadCard()->StatCard
    {
        let card = StatCard(title: AppDesign.Text.downloadKey, unit: AppDesign.Text.speedUnit)
        return card
    }
    
    static func createUploadCard()->StatCard
    {
        let card = StatCard(title: AppDesign.Text.uploadKey, unit: AppDesign.Text.speedUnit)
       
        return card
    }
}

//MARK: - Constuct User Interface
extension HomeViewController
{
    func hideNavigationBar()
    {
        NavigationManager.shared.toggleNavigationBar(on: navigationController, animated: false, shouldShow: false)
    }
    
    func setBackgroundColor()
    {
        view.backgroundColor = UIColor(named: "primaryTheme")
    }
    
    func constructUserInterface()
    {
        addTopBar()
        addStatsSection()
        addSelectedServerSection()
        addConnectionStatusSection()
        addPowerButtonView()
    }
    
    private func addTopBar()
    {
        view.addSubview(gridButton)
        view.addSubview(premiumButton)

        gridButton.translatesAutoresizingMaskIntoConstraints = false
        premiumButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            gridButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            gridButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            gridButton.heightAnchor.constraint(equalToConstant: 48),
            gridButton.widthAnchor.constraint(equalToConstant: 48),

            premiumButton.centerYAnchor.constraint(equalTo: gridButton.centerYAnchor),
            premiumButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            premiumButton.heightAnchor.constraint(equalToConstant: 48),
            premiumButton.widthAnchor.constraint(equalToConstant: 174)
        ])
    }
    
    private func addStatsSection()
    {
        // Stack with just the two cards
        let statsStack = UIStackView(arrangedSubviews: [downloadCard, uploadCard])
        
        statsStack.axis = .horizontal
        statsStack.alignment = .fill
        statsStack.distribution = .fillEqually
        statsStack.spacing = 0
        statsStack.translatesAutoresizingMaskIntoConstraints = false
        
        
        //Shadow Color and Related Properties set here
        statsStack.layer.shadowColor = UIColor(named: "blackColor")?.cgColor // Set the shadow color
        statsStack.layer.shadowOpacity = 0.6
        statsStack.layer.shadowOffset = CGSize(width: 0, height: 4)
        statsStack.layer.shadowRadius = 10
        statsStack.layer.masksToBounds = false
        
        
        
        view.addSubview(statsStack)

        // Constraints for the stack
        NSLayoutConstraint.activate([
            statsStack.topAnchor.constraint(equalTo: gridButton.bottomAnchor, constant: 25),
            statsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            statsStack.heightAnchor.constraint(equalToConstant: 100)
        ])

        // Hairline divider OVER the stack (not arranged)
        let divider = UIView()
        divider.backgroundColor = .separator
        divider.translatesAutoresizingMaskIntoConstraints = false
        statsStack.addSubview(divider)

        let dividerThickness = 6 / UIScreen.main.scale
        NSLayoutConstraint.activate([
            divider.centerXAnchor.constraint(equalTo: statsStack.centerXAnchor),
            divider.topAnchor.constraint(equalTo: statsStack.topAnchor),
            divider.bottomAnchor.constraint(equalTo: statsStack.bottomAnchor),
            divider.widthAnchor.constraint(equalToConstant: dividerThickness)
        ])

        // Round only outer corners of the cards
        downloadCard.layer.cornerRadius = 15
        uploadCard.layer.cornerRadius = 15
        downloadCard.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        uploadCard.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        downloadCard.layer.masksToBounds = true
        uploadCard.layer.masksToBounds = true
    }
    
    private func addSelectedServerSection()
    {
        view.addSubview(selectedServerView)
        selectedServerView.translatesAutoresizingMaskIntoConstraints = false
        selectedServerView.isUserInteractionEnabled = true
        
        NSLayoutConstraint.activate([
            selectedServerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            selectedServerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            selectedServerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            selectedServerView.heightAnchor.constraint(equalToConstant: 55)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectedServerTapped))
           selectedServerView.addGestureRecognizer(tapGesture)
    }
    
    private func addConnectionStatusSection()
    {
        view.addSubview(connectionStatusView)
        connectionStatusView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            connectionStatusView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            connectionStatusView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            connectionStatusView.bottomAnchor.constraint(equalTo: selectedServerView.topAnchor, constant: -25)
        ])
    }

    private func addPowerButtonView()
    {
        view.addSubview(powerButtonView)
        powerButtonView.translatesAutoresizingMaskIntoConstraints = false
        powerButtonView.isUserInteractionEnabled = true

        // Restore last known connection state or check current VPN status
        let wasConnected = UserDefaults.standard.bool(forKey: AppDesign.AppKeys.UserDefaults.lastConnectionState)
        powerButtonView.setState(wasConnected ? .connected : .disconnected)
        
        NSLayoutConstraint.activate([
            powerButtonView.centerXAnchor.constraint(equalTo: connectionStatusView.centerXAnchor),
            powerButtonView.bottomAnchor.constraint(equalTo: connectionStatusView.topAnchor, constant: -80),
            powerButtonView.widthAnchor.constraint(equalToConstant: 80),
            powerButtonView.heightAnchor.constraint(equalToConstant: 80),
        ])

        // Gesture for Power Button
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(powerButtonTapped))
        powerButtonView.addGestureRecognizer(tapGesture)
    }
}
