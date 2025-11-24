//
//  SubscribeViewController.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 10/22/25.
//

import Foundation

import UIKit

class SubscribeViewController: UIViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        print("Hello Welcome")
        view.backgroundColor = .systemGray6
        
        // Title Label
        let titleLabel = UILabel()
        titleLabel.text = "Subscribe to Unlock Premium Servers"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Subscribe Button
        let subscribeButton = UIButton(type: .system)
        subscribeButton.setTitle("Subscribe Now", for: .normal)
        subscribeButton.backgroundColor = .systemRed
        subscribeButton.setTitleColor(.white, for: .normal)
        subscribeButton.layer.cornerRadius = 10
        subscribeButton.translatesAutoresizingMaskIntoConstraints = false
        subscribeButton.addTarget(self, action: #selector(subscribeButtonTapped), for: .touchUpInside)
        
        // Close Button (X)
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("✕", for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        closeButton.setTitleColor(.label, for: .normal)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        // Add subviews
        view.addSubview(titleLabel)
        view.addSubview(subscribeButton)
        view.addSubview(closeButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            subscribeButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            subscribeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subscribeButton.widthAnchor.constraint(equalToConstant: 200),
            subscribeButton.heightAnchor.constraint(equalToConstant: 50),
            
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    @objc private func subscribeButtonTapped() {
        print("Button tapped")
    }

    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}
