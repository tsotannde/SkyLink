//
//  ServerCell.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 10/22/25.
//

import UIKit

class ServerCell: UITableViewCell
{
    //MARK: - UIComponents
    let cardView: UIView =
    {
        let v = UIView()
        v.backgroundColor = .red
        //DesignSystem.AppColors.Themes.CardView.cardBackgroundColor
        v.layer.cornerRadius = 12
        v.layer.shadowColor = (DesignSystem.AppColors.Themes.CardView.shadowColor ?? UIColor.black).cgColor
        v.layer.shadowOpacity = 0.07
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowRadius = 6
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    let flagImageView: UIImageView =
    {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let crownImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(named: DesignSystem.Images.crown)
        return iv
    }()

    let cityStateLabel: UILabel =
    {
        let lbl = UILabel()
        lbl.font = UIFont(name: DesignSystem.AppFonts.SoraSemiBold, size: 16)
        lbl.textColor = .black
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    let signalImageView: UIImageView =
    {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setBackgroundColor()
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Setup
extension ServerCell
{
    private func setBackgroundColor()
    {
        contentView.backgroundColor = DesignSystem.AppColors.backgroundcolor
    }
    
    private func setupViews()
    {
        contentView.addSubview(cardView)
        cardView.addSubview(flagImageView)
        cardView.addSubview(cityStateLabel)
        cardView.addSubview(crownImageView)
        cardView.addSubview(signalImageView)
    }
    
    private func setupConstraints()
    {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        NSLayoutConstraint.activate([
            
        flagImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
        flagImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
        flagImageView.widthAnchor.constraint(equalToConstant: 24),
        flagImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
        NSLayoutConstraint.activate([
            cityStateLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            cityStateLabel.leadingAnchor.constraint(equalTo: flagImageView.trailingAnchor, constant: 16),
            cityStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: crownImageView.leadingAnchor, constant: -16)
            ])
        NSLayoutConstraint.activate([
            crownImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            crownImageView.trailingAnchor.constraint(equalTo: signalImageView.leadingAnchor, constant: -8),
        ])
        NSLayoutConstraint.activate([
            signalImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            signalImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
        ])
        
        let constant : CGFloat = 18
        
        NSLayoutConstraint.activate([
            signalImageView.widthAnchor.constraint(equalToConstant: constant),
            signalImageView.heightAnchor.constraint(equalToConstant: constant),
            crownImageView.widthAnchor.constraint(equalToConstant: constant),
            crownImageView.heightAnchor.constraint(equalToConstant: constant),
        ])
    }

}

//MARK: - Helpers
extension ServerCell
{
    struct ViewModel
    {
        let flagImage: UIImage?
        let city: String
        let state: String?
        let totalCapacity: Int
        let currentPeers: Int
        let showCrown: Bool
    }
    
    func configure(with viewModel: ViewModel)
    {
        flagImageView.image = viewModel.flagImage
        if let state = viewModel.state, !state.isEmpty
        {
            cityStateLabel.text = "\(viewModel.city), \(state)"
        }
        else
        {
            cityStateLabel.text = viewModel.city
        }
        signalImageView.image = signalImage(for: viewModel.currentPeers, totalCapacity: viewModel.totalCapacity)
        crownImageView.isHidden = !viewModel.showCrown
    }
    
    private func signalImage(for currentPeers: Int, totalCapacity: Int) -> UIImage?
    {
        // If totalCapacity is 0 or negative, treat utilization as 1.0 (fully used)
        let utilization = totalCapacity > 0 ? Double(currentPeers) / Double(totalCapacity) : 1.0
        let strength = 1.0 - utilization
        let variableStrength = max(0.0, min(strength, 1.0))
        
        let config = UIImage.SymbolConfiguration(
            paletteColors: [DesignSystem.AppColors.cellularBarColor ?? .systemGreen]
        )
        
        return UIImage(systemName: "cellularbars",variableValue: variableStrength,configuration: config)
    }
}

