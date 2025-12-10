//
//  SelectedServerView.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 10/22/25.
//

import UIKit

class SelectedServer: UIView
{
    private let flagImageView = UIImageView()
    private let cityStateLabel = UILabel()
    private let crownImageView = UIImageView()
    private let chevronImageView = UIImageView()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        monitorNotifications()
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    deinit
    {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK: - UI Component
extension SelectedServer
{
    private func setupUI()
    {
        backgroundColor = UIColor(named: "softWhite") //View Background Color
    
        layer.cornerRadius = 20 //Cornor Radius of the vie
        layer.shadowColor = UIColor(named: "blackColor")?.cgColor // Set the shadow color
        layer.shadowOpacity = 0.6
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 10
        
       //Add the SubViews
        addSubview(flagImageView)
        addSubview(cityStateLabel)
        addSubview(crownImageView)
        addSubview(chevronImageView)
        
        cityStateLabel.textColor = UIColor(named: "blackColor")
        
        chevronImageView.image = AppDesign.Images.chevronUp
        chevronImageView.tintColor = AppDesign.ColorScheme.Themes.primary
        chevronImageView.contentMode = .scaleAspectFit
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false

        // Add subtle pulse animation (more visible)
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.duration = 1.2
        pulse.fromValue = 1.0
        pulse.toValue = 1.25
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        chevronImageView.layer.add(pulse, forKey: "pulse")
    }

    private func setupConstraints()
    {
        flagImageView.translatesAutoresizingMaskIntoConstraints = false
        cityStateLabel.translatesAutoresizingMaskIntoConstraints = false
        crownImageView.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            flagImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            flagImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            flagImageView.widthAnchor.constraint(equalToConstant: 28),
            flagImageView.heightAnchor.constraint(equalToConstant: 28),
            
            cityStateLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            cityStateLabel.leadingAnchor.constraint(equalTo: flagImageView.trailingAnchor, constant: 16),
            cityStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: crownImageView.leadingAnchor, constant: -16),
            
            crownImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            crownImageView.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -8),
            crownImageView.widthAnchor.constraint(equalToConstant: 18),
            crownImageView.heightAnchor.constraint(equalToConstant: 18),
            
            chevronImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            chevronImageView.widthAnchor.constraint(equalToConstant: 18),
            chevronImageView.heightAnchor.constraint(equalToConstant: 18)
        ])

        // Make flag circular after setting up constraints
        flagImageView.layer.cornerRadius = 14
        flagImageView.clipsToBounds = true
    
        
        
        Task
        {
            if let server = await ConfigurationManager.shared.getExistingOrSelectServer()
            {
                let countryName = server.country ?? "Unknown"
                let city = server.city ?? "Unknown"
                let state = server.state ?? "Unknown"

                self.configure(countryName: countryName, city: city, state: state)
            }
        }
    }
}

//MARK: - Helper Functions
extension SelectedServer
{
    private func configure(countryName: String, city: String, state: String)
    {
        // Automatically fetch flag image using the FlagManager
        if let flag = FlagManager.shared.getCountryFlagImage(countryName)
        {
            flagImageView.image = flag
        }

        // Display city/state text
        cityStateLabel.text = "\(city), \(state)"

    }
}

//MARK: - Notifications
extension SelectedServer
{
   
    private func monitorNotifications()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(handleServerDidUpdate), name: .serverDidUpdate, object: nil)
    }
    
    @objc private func handleServerDidUpdate()
    {
        //Update Server Selection View
        AppLogger.shared.log("[Home] New Server Selected. Updating UI")
        Task { [weak self] in
            //Current VPN Selected
            let currentConfiguration = await ConfigurationManager.shared.getExistingOrSelectServer()
            
            let country = currentConfiguration?.country ?? "United States"
            let city = currentConfiguration?.city ?? "Invalid Configuration"
            let state = currentConfiguration?.state ?? "Contact Support"
            
            self?.configure(countryName: country, city: city, state: state)
        }
    }
}
