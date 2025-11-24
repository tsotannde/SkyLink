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
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI()
    {
        backgroundColor = AppDesign.ColorScheme.Styling.Background.surface
        layer.cornerRadius = 20
        layer.shadowColor = (AppDesign.ColorScheme.Styling.Shadow.standard).cgColor
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 6
        
        addSubview(flagImageView)
        addSubview(cityStateLabel)
        addSubview(crownImageView)
        addSubview(chevronImageView)
        
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
        
        //Default Configuration
        configure(countryName: "United States", city: "Austin", state: "Texas")
    }

    func configure(countryName: String, city: String, state: String)
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



