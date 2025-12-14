//
//  ServerCell.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 10/22/25.
//

import UIKit

class ServerCell: UITableViewCell
{
    private let cardView =  makeCardView()
    private let flagImageView = makeFlagImageView()
    private let cityStateLabel = makeCityStateLabel()
    private let crownImageView = makeCownImageView()
    private let signalImageView = makeSignalImageView()
  

    
   
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setBackgroundColor()
        setupViews()
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
}

//MARK: - Setup
extension ServerCell
{
   
    
    private func setupViews()
    {
        
        contentView.addSubview(cardView)
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
        
        cardView.addSubview(flagImageView)
        NSLayoutConstraint.activate([
            
        flagImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
        flagImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
        flagImageView.widthAnchor.constraint(equalToConstant: 24),
        flagImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        stack.addArrangedSubview(crownImageView)
        stack.addArrangedSubview(signalImageView)
        cardView.addSubview(stack)
       
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            stack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
        ])

        cardView.addSubview(cityStateLabel)
        NSLayoutConstraint.activate([
            cityStateLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            cityStateLabel.leadingAnchor.constraint(equalTo: flagImageView.trailingAnchor, constant: 16),
            cityStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: stack.leadingAnchor, constant: -16)
            ])
        
        
        let iconSize: CGFloat = 18
        NSLayoutConstraint.activate([
            crownImageView.widthAnchor.constraint(equalToConstant: iconSize),
            crownImageView.heightAnchor.constraint(equalToConstant: iconSize),
            signalImageView.widthAnchor.constraint(equalToConstant: iconSize),
            signalImageView.heightAnchor.constraint(equalToConstant: iconSize),
        ])

        crownImageView.setContentHuggingPriority(.required, for: .horizontal)
        signalImageView.setContentHuggingPriority(.required, for: .horizontal)
        stack.setContentHuggingPriority(.required, for: .horizontal)
        cityStateLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

}

//MARK: - Helpers
extension ServerCell
{
    
    
    func configure(with viewModel: ServerViewModel)
    {
        print("[ServerCell] For \(viewModel.city) showCrown =", viewModel.showCrown)
        
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
            paletteColors: [UIColor(named: "greenColor") ?? .systemGreen]
        )
        
        return UIImage(systemName: "cellularbars",variableValue: variableStrength,configuration: config)
    }
}

//MARK: -  Create UI Components
extension ServerCell
{
    private static func makeCardView()-> UIView
    {
        let view = UIView()
        view.backgroundColor = UIColor(named: "primaryTheme")
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = false
        
        // Shadow
        view.layer.shadowColor = UIColor(named: "greyColor")?.cgColor
        view.layer.shadowOpacity = 0.8
        view.layer.shadowOffset = CGSize(width: 0, height: 5)
        view.layer.shadowRadius = 3
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }
    
    private static func makeFlagImageView() -> UIImageView
    {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    
    private static func makeCownImageView() -> UIImageView
    {
        let imageView = UIImageView()
        imageView.image = AppDesign.Images.crown
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    
    static private func makeCityStateLabel()-> UILabel
    {
        let lbl = UILabel()
        lbl.font = SkyLinkAssets.Fonts.semiBold(ofSize: 16)
        lbl.textColor = UIColor(named: "whiteColor")
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }
    
    static private func makeSignalImageView()-> UIImageView
    {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }
}

//MARK: - Setup and Constrain UI
extension ServerCell
{
    private func setBackgroundColor()
    {
            contentView.backgroundColor = UIColor(named: "lightGreyColor")
    }
    
}
