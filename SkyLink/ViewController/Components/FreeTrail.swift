//
//  SubscribeViewController.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 11/11/25.
//

import UIKit

final class FreeTrail: UIView
{

    // MARK: - UI
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let toggleSwitch = UISwitch()

    // MARK: - Callback
    var onToggleChanged: ((Bool) -> Void)?

    // MARK: - Init
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

   

    

   
}
// MARK: - Setup
extension FreeTrail
{
    private func setupContainer() {
        containerView.backgroundColor = UIColor.white.withAlphaComponent(0.18)
    
        containerView.layer.cornerRadius = 16
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor

        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.08
        containerView.layer.shadowRadius = 12
        containerView.layer.shadowOffset = CGSize(width: 0, height: 6)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        addSubview(containerView)
    }

    private func setupLabel()
    {
        titleLabel.text = "You won’t be charged today"
      
        titleLabel.font = SkyLinkAssets.Fonts.semiBold(ofSize: 16)
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        titleLabel.numberOfLines = 1
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
    }

    private func setupToggle() {
        toggleSwitch.isOn = true
        toggleSwitch.isOn = true
        toggleSwitch.isEnabled = false
        toggleSwitch.onTintColor = UIColor.systemGreen
        toggleSwitch.addTarget(self, action: #selector(toggleChanged), for: .valueChanged)
        toggleSwitch.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(toggleSwitch)
    }

    private func setupConstraints()
    {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            containerView.heightAnchor.constraint(equalToConstant: 56),

            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),

            toggleSwitch.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            toggleSwitch.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: toggleSwitch.leadingAnchor, constant: -12)
        ])
    }
    
    private func setupView()
    {
        setupContainer()
        setupLabel()
        setupToggle()
        setupConstraints()
    }
}

extension FreeTrail
{
    // MARK: - Action
    @objc private func toggleChanged() {
        onToggleChanged?(toggleSwitch.isOn)
    }

    // MARK: - Public
    func setEnabled(_ enabled: Bool)
    {
        toggleSwitch.setOn(enabled, animated: true)
    }

    func setVisible(_ visible: Bool, animated: Bool = true) {
        let changes = {
            self.alpha = visible ? 1 : 0
            self.transform = visible
                ? .identity
                : CGAffineTransform(translationX: 0, y: -8)
        }

        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: changes)
        } else {
            changes()
        }
    }
}
