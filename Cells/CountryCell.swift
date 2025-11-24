//
//  CountryCell.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 10/22/25.
//


import UIKit

final class CountryCell: UITableViewCell
{
    private var isChevronExpanded: Bool = false
    
    // MARK: - CardView Component
    private let cardView: UIView =
    {
        let view = UIView()
        view.backgroundColor = DesignSystem.AppColors.Themes.CardView.cardBackgroundColor
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = false
       
       // Shadow
        view.layer.shadowColor = (DesignSystem.AppColors.Themes.CardView.shadowColor ?? UIColor.black).cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 10
        
        return view
    }()

    //MARK: - Left  Components
    private let flagImageView: UIImageView =
    {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let nameLabel: UILabel =
    {
        let label = UILabel()
        label.font = UIFont(name: DesignSystem.AppFonts.SoraSemiBold, size: 16)
        label.textColor = .black
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: - Right Components
    private let rightStack: UIStackView =
    {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let spacerView: UIView =
    {
        let view = UIView()
        view.backgroundColor = .gray
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 1),
            view.heightAnchor.constraint(equalToConstant: 12)
        ])
        return view
    }()
    
    private let signalImageView: UIImageView =
    {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let crownImageView: UIImageView =
    {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let chevronImageView: UIImageView =
    {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // MARK: - Init
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

// MARK: -
extension CountryCell
{
    private func setBackgroundColor()
    {
        contentView.backgroundColor = DesignSystem.AppColors.backgroundcolor
    }
    
    private func setupViews()
    {
        
        contentView.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false

        cardView.addSubview(flagImageView)
        cardView.addSubview(nameLabel)
        cardView.addSubview(rightStack)
        
        signalImageView.image = UIImage(systemName: DesignSystem.Images.cellularbars) // Initial Image
        chevronImageView.image = UIImage(systemName: DesignSystem.Images.chevronRight) // placeholder
        crownImageView.image = UIImage(named: DesignSystem.Images.crown) // placeholder

        rightStack.addArrangedSubview(signalImageView)
        rightStack.addArrangedSubview(spacerView)
        rightStack.addArrangedSubview(crownImageView)
        rightStack.addArrangedSubview(chevronImageView)
    }
    
    private func setupConstraints()
    {
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
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: rightStack.leadingAnchor, constant: -12),
        ])

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

//MARK: -
extension CountryCell
{
    struct ViewModel
    {
        let flagImage: UIImage?
        let name: String
        let totalCapacity: Int
        let currentPeers: Int
        let showChevron: Bool
        let showCrown: Bool
        let isExpanded: Bool
    }

    func configure(with model: ViewModel)
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
            paletteColors: [DesignSystem.AppColors.cellularBarColor ?? .systemGreen]
        )
        
        return UIImage(systemName: "cellularbars",variableValue: variableStrength,configuration: config)
    }
}

//MARK: -
extension CountryCell
{
    
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

