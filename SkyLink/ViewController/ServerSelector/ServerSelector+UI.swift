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
    // Sets the base background color for the Server Selection screen.
    // This establishes the neutral backdrop behind the table view and search UI.
    internal func setBackgroundColor()
    {
        view.backgroundColor = SkyLinkAssets.Colors.lightGreyColor
    }
    
    // Creates the large title label displayed at the top of the screen
    // (e.g. "Choose Location"). Styling is centralized here to keep
    // constructUI() focused on layout, not configuration.
    internal func createTitleLabel() -> UILabel
    {
        let label = UILabel()
        label.text = SkyLinkAssets.Text.chooseLocationKey
        label.font = SkyLinkAssets.Fonts.semiBold(ofSize: 30)
        label.textColor = SkyLinkAssets.Colors.blackColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    // Builds the search container that wraps the text field and search icon.
    // This view provides padding, rounded corners, and shadow so the search
    // field appears as a single, elevated component.
    internal func createSearchContainerView() -> UIView
    {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor =  SkyLinkAssets.Colors.whiteColor
        container.layer.cornerRadius = 16
        container.layer.shadowColor = SkyLinkAssets.Colors.blackColor?.cgColor
        container.layer.shadowOpacity = 0.8
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 8
        container.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        // Search text field used to filter servers by name/location.
        // Actual filtering logic is handled in the view controller, not here.
        let searchTextField = UITextField()
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: SkyLinkAssets.Text.searchLocationKey,
            attributes: [
                .foregroundColor: SkyLinkAssets.Colors.greyColor ?? .lightGray,
                .font: SkyLinkAssets.Fonts.regular(ofSize: 16)
            ]
        )
        searchTextField.font = SkyLinkAssets.Fonts.regular(ofSize: 16)
        searchTextField.textColor = SkyLinkAssets.Colors.blackColor
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        
        // Static search icon displayed on the trailing edge of the search field.
        // This is decorative and does not handle user interaction.
        let searchIcon = UIImageView(image: SkyLinkAssets.Images.magnifyGlass)
        searchIcon.tintColor = SkyLinkAssets.Colors.greyColor
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
    
    // Constructs and lays out the static, top-level UI elements for this screen.
    // This method is responsible only for view hierarchy and constraints.
    // Dynamic behavior (table updates, search filtering, expansion) is handled elsewhere.
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
    
    // Configures and lays out the table view that displays countries and servers.
    // The table view is inserted below the search container so it scrolls
    // independently while the search UI remains fixed at the top.
    internal func setupTableView()
    {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 247/255, alpha: 1)
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CountryCell.self, forCellReuseIdentifier: SkyLinkAssets.Cell.serverViewCellIdentifier)
        tableView.register(ServerCell.self, forCellReuseIdentifier: SkyLinkAssets.Cell.individualServerViewCellIdentifier)

        view.insertSubview(tableView, belowSubview: searchContainerView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchContainerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // Wires up the search text field with delegate and editing callbacks.
    // Text change events trigger filtering logic in the view controller.
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
    // Adds a tap gesture recognizer to dismiss the keyboard when the user
    // taps outside the search field.
    internal func setupTapToDismiss()
    {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // Ends editing on the view hierarchy, dismissing the keyboard if visible.
    @objc internal func dismissKeyboard()
    {
        view.endEditing(true)
    }
}
