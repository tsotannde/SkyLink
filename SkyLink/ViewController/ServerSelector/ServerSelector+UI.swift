//
//  ServerSelector+UI.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 11/23/25.
//

import UIKit

// MARK: - UI
extension ServerSelectionViewController
{
    internal func setBackgroundColor()
    {
        view.backgroundColor = UIColor(named: "lightGreyColor")
    }
    
    internal func createTitleLabel() -> UILabel
    {
        let label = UILabel()
        label.text = AppDesign.Text.chooseLocationKey
        label.font = AppDesign.Fonts.semiBold(ofSize: 30)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    internal func createSearchContainerView() -> UIView
    {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor(named: "whiteColor")
        container.layer.cornerRadius = 16
        container.layer.shadowColor = UIColor(named: "blackColor")?.cgColor
        container.layer.shadowOpacity = 0.8
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 8
        container.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        let searchTextField = UITextField()
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: AppDesign.Text.searchLocationKey,
            attributes: [
                .foregroundColor: UIColor(named: "greyColor") ?? .lightGray,
                .font: AppDesign.Fonts.regular(ofSize: 16)
            ]
        )
        searchTextField.font = AppDesign.Fonts.regular(ofSize: 16)
        searchTextField.textColor = UIColor(named: "blackColor")
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        
        let searchIcon = UIImageView(image: AppDesign.Images.magnifyGlass)
        searchIcon.tintColor = UIColor(named: "greyColor")
        searchIcon.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(searchTextField)
        container.addSubview(searchIcon)
        
        NSLayoutConstraint.activate([
            searchIcon.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            searchIcon.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            searchIcon.widthAnchor.constraint(equalToConstant: 16),
            searchIcon.heightAnchor.constraint(equalToConstant: 16),
            
            searchTextField.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            searchTextField.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            searchTextField.trailingAnchor.constraint(equalTo: searchIcon.leadingAnchor, constant: -12)
        ])
        
        return container
    }
    
    internal func constructUI()
    {
        titleLabel = createTitleLabel()
        searchContainerView = createSearchContainerView()
        
        view.addSubview(titleLabel)
        view.addSubview(searchContainerView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            
            searchContainerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            searchContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            searchContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }
    
    internal func setupTableView()
    {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 247/255, alpha: 1)
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CountryCell.self, forCellReuseIdentifier: "ServerViewCell")
        tableView.register(ServerCell.self, forCellReuseIdentifier: "IndividualServerCell")

        view.insertSubview(tableView, belowSubview: searchContainerView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchContainerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    internal func setupSearchField()
    {
        if let searchField = searchContainerView.subviews.compactMap({ $0 as? UITextField }).first {
            searchField.clearButtonMode = .whileEditing
            searchField.addTarget(self, action: #selector(searchTextChanged(_:)), for: .editingChanged)
            searchField.delegate = self
        }
    }
    
   
    
}

//MARK: - Keyboard and Related Functons
extension ServerSelectionViewController
{
    internal func setupTapToDismiss()
    {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc internal func dismissKeyboard()
    {
        view.endEditing(true)
    }
}
