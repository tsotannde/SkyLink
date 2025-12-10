//
//  CountryCell.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 10/22/25.
//

import UIKit

final class CountryCell: UITableViewCell
{
   
    
    private var cardView = makeCardView()
    private var flagImageView = makeFlagImageView()
    private var nameLabel = makeLabelView()
    private var spacerView = makeSpacerView()
    private var signalImageView = makeSignalImageView()
    private var crownImageView = makeCownImageView()
    private var chevronImageView = makeChevronImageView()
    
    private var isChevronExpanded: Bool = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setBackgroundColor()
        setupLeftView()
        setupRightVie()
        
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
}

//MARK: - Configuration
extension CountryCell
{
    func configure(with model: CountryCellViewModel)
    {
        flagImageView.image = model.flagImage
        nameLabel.text = model.name
        signalImageView.image = signalImage(for: model.currentPeers, totalCapacity: model.totalCapacity)
        chevronImageView.isHidden = !model.showChevron
        crownImageView.isHidden = !model.showCrown
        isChevronExpanded = model.isExpanded
        
    }
    
    private func signalImage(for currentPeers: Int, totalCapacity: Int) -> UIImage?
    {
        // If totalCapacity is 0 or negative, treat utilization as 1.0 (fully used)
        let utilization = totalCapacity > 0 ? Double(currentPeers) / Double(totalCapacity) : 1.0
        let strength = 1.0 - utilization
        let variableStrength = max(0.0, min(strength, 1.0))
        
        let config = UIImage.SymbolConfiguration(
            paletteColors: [UIColor(named: "greenColor")!]
        )
       
        return UIImage(systemName: "cellularbars",variableValue: variableStrength,configuration: config)
    }
    
    func setExpanded(_ expanded: Bool, animated: Bool = true)
    {
        guard expanded != isChevronExpanded else { return }
        isChevronExpanded = expanded
        
        let targetTransform = CGAffineTransform(rotationAngle: expanded ? .pi / 2 : 0)
        let animations = {self.chevronImageView.transform = targetTransform }
        
        if animated {UIView.animate(withDuration: 0.25,
                                    delay: 0,usingSpringWithDamping: 0.8,initialSpringVelocity: 0.7,
                                    options: [.curveEaseInOut, .beginFromCurrentState],animations: animations)}
        else
        {
            animations()
        }
    }
}

//MARK: -  Create UI Components
extension CountryCell
{
    static private func makeCardView()->UIView
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
        
        return view
    }
    
    static private func makeFlagImageView() -> UIImageView
    {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
   
    static private func makeLabelView() -> UILabel
    {
        let label = UILabel()
        label.font = UIFont(name: DesignSystem.AppFonts.SoraSemiBold, size: 16)
        label.textColor = UIColor(named: "whiteColor")
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private static func makeSpacerView()->UIView
    {
        let view = UIView()
        view.backgroundColor = UIColor(named: "whiteColor")
        view.layer.cornerRadius = 2
        
        //Constain the bar corners
        view.layer.maskedCorners = [
            .layerMinXMinYCorner,  // top-left
            .layerMaxXMinYCorner,  // top-right
            .layerMinXMaxYCorner,  // bottom-left
            .layerMaxXMaxYCorner   // bottom-right
        ]
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 2),
            view.heightAnchor.constraint(equalToConstant: 15)
        ])
        return view
    }
    
    private static func makeSignalImageView() -> UIImageView
    {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    
    private static func makeCownImageView() -> UIImageView
    {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    
    private static func makeChevronImageView() -> UIImageView
    {
        let imageView = UIImageView()
        imageView.tintColor = UIColor(named: "whiteColor")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }

}

//MARK: - Setup and Constrain UI
extension CountryCell
{
    private func setBackgroundColor()
    {
        contentView.backgroundColor = UIColor(named: "lightGreyColor")
    }
    
    private func  setupLeftView()
    {
        contentView.addSubview(cardView)
        cardView.addSubview(flagImageView)
        cardView.addSubview(nameLabel)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
        ])
        
        NSLayoutConstraint.activate([
            flagImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            flagImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            flagImageView.widthAnchor.constraint(equalToConstant: 26),
            flagImageView.heightAnchor.constraint(equalToConstant: 26),
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: flagImageView.trailingAnchor, constant: 12),
            nameLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
        ])
    }
    
    private func setupRightVie()
    {
        let rightStack = UIStackView()
        rightStack.axis = .horizontal
        rightStack.spacing = 8
        rightStack.alignment = .center
        rightStack.translatesAutoresizingMaskIntoConstraints = false
        
        cardView.addSubview(rightStack)
        
        signalImageView.image = UIImage(systemName: DesignSystem.Images.cellularbars) // Initial Image
        chevronImageView.image = UIImage(systemName: DesignSystem.Images.chevronRight) // placeholder
        crownImageView.image = AppDesign.Images.crown //Placeholder
        
        rightStack.addArrangedSubview(signalImageView)
        rightStack.addArrangedSubview(spacerView)
        rightStack.addArrangedSubview(crownImageView)
        rightStack.addArrangedSubview(chevronImageView)

       
        NSLayoutConstraint.activate([
            rightStack.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            rightStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
        ])
        
        let constant : CGFloat = 18
        
        NSLayoutConstraint.activate([
            signalImageView.widthAnchor.constraint(equalToConstant: constant),
            signalImageView.heightAnchor.constraint(equalToConstant: constant),
            chevronImageView.widthAnchor.constraint(equalToConstant: constant),
            chevronImageView.heightAnchor.constraint(equalToConstant: constant),
            crownImageView.widthAnchor.constraint(equalToConstant: constant),
            crownImageView.heightAnchor.constraint(equalToConstant: constant),
        ])
    }
}
