//
//  SubscriptionPlanView.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 12/11/25.
//

import UIKit

final class SubscriptionPlan: UIView
{
    //View Components
    private let discountBadge = UILabel()
    private let selectionOverlay = UIView()
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    private let selectionCircle = UIView()
    private let checkmarkImageView = UIImageView()
    
    //Data
    public let tier: SubscriptionTier
    private let pricing: SubscriptionPricing
    private let price: Double
    private var isSelectedPlan = false

    // MARK: - INIT
    init(tier: SubscriptionTier, pricing: SubscriptionPricing)
    {
        self.tier = tier
        self.pricing = pricing
        self.price = pricing.price(for: tier)
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview()
    {
        super.didMoveToSuperview()
        positionDiscountBadge()
    }
    
}

//MARK: - UI Components and Setup
extension SubscriptionPlan
{
    private func stylePlanView()
    {
        backgroundColor = UIColor(named: "whiteColor")
        layer.cornerRadius = 20
        layer.masksToBounds = false // allows the save x% to flow outside the view
        
        // Border for structure (light grey, like mockups)
        layer.borderWidth = 1
        layer.borderColor = UIColor(named: "borderColor")?.cgColor
        
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 160).isActive = true //Height

        // Inner selection overlay (for strong visibility on blue background)
        selectionOverlay.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.04)
        selectionOverlay.layer.cornerRadius = 18
        selectionOverlay.alpha = 0
        selectionOverlay.translatesAutoresizingMaskIntoConstraints = false
        addSubview(selectionOverlay)

        NSLayoutConstraint.activate([
            selectionOverlay.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            selectionOverlay.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            selectionOverlay.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            selectionOverlay.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
        ])

        sendSubviewToBack(selectionOverlay)
    }
    
    private func positionDiscountBadge()
    {
        guard superview != nil else { return }
        guard let discount = calculatedDiscountText() else { return }

        discountBadge.text = discount
        discountBadge.font = AppDesign.Fonts.semiBold(ofSize: 12)
        discountBadge.textColor = .white
        discountBadge.backgroundColor = UIColor(named: "purpleColor")
        discountBadge.textAlignment = .center
        discountBadge.layer.cornerRadius = 10
        discountBadge.clipsToBounds = true
        discountBadge.translatesAutoresizingMaskIntoConstraints = false

        superview?.addSubview(discountBadge)

        NSLayoutConstraint.activate([
            discountBadge.bottomAnchor.constraint(equalTo: topAnchor, constant: 11),
            discountBadge.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 8),
            discountBadge.heightAnchor.constraint(equalToConstant: 22),
            discountBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 70)
        ])
    }

    private func addTitle()
    {
        titleLabel.text = tier.title
        titleLabel.font = AppDesign.Fonts.semiBold(ofSize: 18)
        titleLabel.textColor = UIColor(named: "blackColor")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    private func addSeparatorLine() {
        let line = UIView()
        line.backgroundColor = UIColor(named: "softWhite")
        line.translatesAutoresizingMaskIntoConstraints = false
        addSubview(line)

        NSLayoutConstraint.activate([
            line.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            line.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            line.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            line.heightAnchor.constraint(equalToConstant: 1.7)
        ])
    }
    
    private func addPriceText() {
        priceLabel.text = String(format: "$%.2f", price)
        priceLabel.font = AppDesign.Fonts.regular(ofSize: 16)
        priceLabel.textColor = UIColor(named: "blackColor")
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(priceLabel)

        NSLayoutConstraint.activate([
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 45),
            priceLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    private func createCheckMarkView()->UIImageView
    {
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        let image = AppDesign.Images.checkMark?.withConfiguration(config)
    
        let iv = UIImageView(image: image)
        iv.tintColor = .white
        iv.alpha = 0
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }
  
    private func addSelectionCircle() {

        let circleSize: CGFloat = 16

        selectionCircle.layer.cornerRadius = circleSize / 2
        selectionCircle.layer.borderWidth = 1
        selectionCircle.layer.borderColor = UIColor(named: "blackColor")?.cgColor
        //UIColor(white: 0.85, alpha: 1).cgColor
        selectionCircle.backgroundColor = .clear
        selectionCircle.translatesAutoresizingMaskIntoConstraints = false
        addSubview(selectionCircle)

        NSLayoutConstraint.activate([
            selectionCircle.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            selectionCircle.centerXAnchor.constraint(equalTo: centerXAnchor),
            selectionCircle.widthAnchor.constraint(equalToConstant: circleSize),
            selectionCircle.heightAnchor.constraint(equalToConstant: circleSize)
        ])

        //Configure checkmarkImageView (the SAME instance you toggle)
        let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
        checkmarkImageView.image = UIImage(systemName: "checkmark", withConfiguration: config)
        checkmarkImageView.tintColor = .white
        checkmarkImageView.alpha = 0
        checkmarkImageView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false

        selectionCircle.addSubview(checkmarkImageView)

        NSLayoutConstraint.activate([
            checkmarkImageView.centerXAnchor.constraint(equalTo: selectionCircle.centerXAnchor),
            checkmarkImageView.centerYAnchor.constraint(equalTo: selectionCircle.centerYAnchor)
        ])
    }
    
    private func setupView()
    {
        stylePlanView()
        addTitle()
        addSeparatorLine()
        addPriceText()
        addSelectionCircle()
    }
}

//MARK: - Functions
extension SubscriptionPlan
{
    func calculatedDiscountText() -> String?
    {
        switch tier {
        case .monthly:
            let weeklyTotal = pricing.weekly * 4
            let savings = 1 - (pricing.monthly / weeklyTotal)
            return "SAVE \(Int(savings * 100))%"
            
        case .yearly:
            let monthlyTotal = pricing.monthly * 12
            let savings = 1 - (pricing.yearly / monthlyTotal)
            return "SAVE \(Int(savings * 100))%"
            
        default:
            return nil
        }
    }

    func setSelected(_ selected: Bool) {
        isSelectedPlan = selected

        if selected {
            // Visual state
            layer.borderWidth = 3
            layer.borderColor = UIColor(named: "purpleColor")?.cgColor
            selectionOverlay.alpha = 1

            selectionCircle.backgroundColor = .systemBlue
            selectionCircle.layer.borderColor = UIColor.systemBlue.cgColor

            // Prepare checkmark for animation
            checkmarkImageView.alpha = 0
            checkmarkImageView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)

            UIView.animate(
                withDuration: 0.8,
                delay: 0,
                usingSpringWithDamping: 0.6,
                initialSpringVelocity: 0.8,
                options: [.allowUserInteraction]
            ) {
                self.checkmarkImageView.alpha = 1
                self.checkmarkImageView.transform = .identity
            }

        } else {
            layer.borderWidth = 1
            layer.borderColor = UIColor(named: "borderColor")?.cgColor
            selectionOverlay.alpha = 0

            selectionCircle.backgroundColor = .clear
            selectionCircle.layer.borderColor = UIColor(white: 0.85, alpha: 1).cgColor

            UIView.animate(withDuration: 0.2) {
                self.checkmarkImageView.alpha = 0
                self.checkmarkImageView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            }
        }
    }
}

enum SubscriptionTier
{
    case weekly
    case monthly
    case yearly

    var title: String {
        switch self {
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        }
    }

    var productID: String
    {
        switch self
        {
        case .weekly: return "com.skylink.weekly"
        case .monthly: return "com.skylink.monthly"
        case .yearly: return "com.skylink.yearly"
        }
    }
}



struct SubscriptionPricing
{
    let weekly: Double
    let monthly: Double
    let yearly: Double
}

extension SubscriptionPricing {
    func price(for tier: SubscriptionTier) -> Double {
        switch tier {
        case .weekly:
            return weekly
        case .monthly:
            return monthly
        case .yearly:
            return yearly
        }
    }
}
