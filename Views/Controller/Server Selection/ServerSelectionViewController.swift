//
//  ServerSelectionViewController.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 10/24/25.
//

import UIKit

final class ServerSelectionViewController: UIViewController {

    // MARK: - UI Elements
    private var titleLabel: UILabel!
    private var searchContainerView: UIView!
    private var tableView: UITableView!

    // MARK: - Data
    private var expandedCountries = Set<IndexPath>()
    private var freeCountries: [Country] = []
    private var premiumCountries: [Country] = []
    private var visibleRows: [VisibleRow] = []
    private var filteredVisibleRows: [VisibleRow] = []
    private var isSearching = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DesignSystem.AppColors.backgroundcolor
        constructUI()
        setupTableView()
        setupSearchField()
        setupTapToDismiss()

        Task { await loadData() }
    }

    private func setupTapToDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Data Loading
    private func loadData() async {
        do {
            try await ConfigurationManager.shared.loadServers()
            freeCountries = buildCountries(from: ConfigurationManager.shared.freeServers, requiresSub: false)
            premiumCountries = buildCountries(from: ConfigurationManager.shared.premiumServers, requiresSub: true)
            rebuildVisibleRows(for: nil)
            DispatchQueue.main.async { self.tableView.reloadData() }
        } catch {
            print("❌ Failed to load servers: \(error)")
        }
    }

    private func buildCountries(from servers: [Server], requiresSub: Bool) -> [Country] {
        var grouped: [String: [Server]] = [:]
        for server in servers {
            let countryName = server.country ?? "Unknown"
            grouped[countryName, default: []].append(server)
        }

        return grouped.map {
            Country(
                name: $0.key,
                requiresSubscription: requiresSub,
                servers: Dictionary(uniqueKeysWithValues: $0.value.map { ($0.name, $0) })
            )
        }.sorted { $0.name ?? "" < $1.name ?? "" }
    }

    // MARK: - Visible Rows Builder
    private func rebuildVisibleRows(for indexPath: IndexPath?) {
        visibleRows.removeAll()

        for (section, countries) in [freeCountries, premiumCountries].enumerated() {
            for (row, country) in countries.enumerated() {
                let countryIndexPath = IndexPath(row: row, section: section)
                visibleRows.append(VisibleRow(type: .country(country), section: section))
                if expandedCountries.contains(countryIndexPath) {
                    let servers = Array(country.servers.values)
                    for server in servers {
                        visibleRows.append(VisibleRow(type: .server(server), section: section))
                    }
                }
            }
        }
    }

    // MARK: - UI Construction
    private func constructUI() {
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

    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
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

    private func setupSearchField() {
        if let searchField = searchContainerView.subviews.compactMap({ $0 as? UITextField }).first {
            searchField.clearButtonMode = .whileEditing
            searchField.addTarget(self, action: #selector(searchTextChanged(_:)), for: .editingChanged)
            searchField.delegate = self
        }
    }

    @objc private func searchTextChanged(_ textField: UITextField) {
        let query = textField.text?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !query.isEmpty else {
            isSearching = false
            rebuildVisibleRows(for: nil)
            tableView.reloadData()
            return
        }

        isSearching = true
        filteredVisibleRows.removeAll()

        let allServers = ConfigurationManager.shared.freeServers + ConfigurationManager.shared.premiumServers
        var seenCountries = Set<String>()

        for server in allServers {
            if server.name.lowercased().contains(query)
                || (server.city?.lowercased().contains(query) ?? false)
                || (server.country?.lowercased().contains(query) ?? false)
                || (server.state?.lowercased().contains(query) ?? false) {

                if !seenCountries.contains(server.country ?? "Unknown") {
                    seenCountries.insert(server.country ?? "Unknown")
                    filteredVisibleRows.append(.init(type: .country(Country(name: server.country ?? "Unknown",
                                                                           requiresSubscription: server.requiresSubscription,
                                                                           servers: [:])),
                                                     section: server.requiresSubscription ? 1 : 0))
                }

                filteredVisibleRows.append(.init(type: .server(server), section: server.requiresSubscription ? 1 : 0))
            }
        }

        UIView.transition(with: tableView, duration: 0.25, options: .transitionCrossDissolve) {
            self.tableView.reloadData()
        }
    }
}

// MARK: - TableView Handling
extension ServerSelectionViewController: UITableViewDelegate, UITableViewDataSource {

    private struct VisibleRow {
        enum RowType { case country(Country), server(Server) }
        let type: RowType
        let section: Int
    }

    func numberOfSections(in tableView: UITableView) -> Int { 2 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = isSearching ? filteredVisibleRows : visibleRows
        return rows.filter { $0.section == section }.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "FREE LOCATIONS" : "PREMIUM LOCATIONS"
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = UIFont(name: "Sora-SemiBold", size: 12)
        header.textLabel?.textColor = .gray
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 80 }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rows = isSearching ? filteredVisibleRows : visibleRows
        let sectionRows = rows.filter { $0.section == indexPath.section }
        let visibleRow = sectionRows[indexPath.row]

        switch visibleRow.type {
        case .country(let country):
            let cell = tableView.dequeueReusableCell(withIdentifier: "ServerViewCell", for: indexPath) as! CountryCell
            let flag = FlagManager.shared.getCountryFlagImage(country.name ?? "") ?? UIImage(systemName: "globe")
            let model = CountryCell.ViewModel(
                flagImage: flag,
                name: country.name ?? "Unknown",
                totalCapacity: 700,
                currentPeers: 50,
                showChevron: true,
                showCrown: country.requiresSubscription,
                isExpanded: expandedCountries.contains(indexPath)
            )
            cell.configure(with: model)
            return cell

        case .server(let server):
            let cell = tableView.dequeueReusableCell(withIdentifier: "IndividualServerCell", for: indexPath) as! ServerCell
            let flag = FlagManager.shared.getCountryFlagImage(server.country ?? "") ?? UIImage(systemName: "globe")
            let model = ServerCell.ViewModel(
                flagImage: flag,
                city: server.city ?? "Unknown City",
                state: server.state ?? "Unknown",
                totalCapacity: server.capacity,
                currentPeers: server.currentCapacity,
                showCrown: server.requiresSubscription
            )
            cell.configure(with: model)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let rows = isSearching ? filteredVisibleRows : visibleRows
        let sectionRows = rows.filter { $0.section == indexPath.section }
        let visibleRow = sectionRows[indexPath.row]

        switch visibleRow.type {
        case .country(let country):
            guard let cell = tableView.cellForRow(at: indexPath) as? CountryCell else { return }

            let isExpanding = !expandedCountries.contains(indexPath)
            if isExpanding {
                expandedCountries.insert(indexPath)
            } else {
                expandedCountries.remove(indexPath)
            }
            cell.setExpanded(isExpanding)

            let servers = Array(country.servers.values)
            let section = indexPath.section

            // Get current index of this country in visibleRows
            guard let baseIndex = visibleRows.firstIndex(where: {
                if case .country(let c) = $0.type { return c.name == country.name }
                return false
            }) else { return }

            // Update visibleRows safely
            if isExpanding {
                let newRows = servers.map { VisibleRow(type: .server($0), section: section) }
                visibleRows.insert(contentsOf: newRows, at: baseIndex + 1)

                let newIndexPaths = (0..<servers.count).map {
                    IndexPath(row: indexPath.row + 1 + $0, section: section)
                }
                tableView.performBatchUpdates {
                    tableView.insertRows(at: newIndexPaths, with: .fade)
                }
            } else {
                let countToRemove = servers.count
                visibleRows.removeSubrange((baseIndex + 1)...(baseIndex + countToRemove))
                let removedIndexPaths = (0..<countToRemove).map {
                    IndexPath(row: indexPath.row + 1 + $0, section: section)
                }
                tableView.performBatchUpdates {
                    tableView.deleteRows(at: removedIndexPaths, with: .fade)
                }
            }

        case .server(let server):
            print("✅ Selected: \(server.city ?? "Unknown City"), \(server.state ?? "Unknown State") [\(server.publicIP ?? "N/A")]")

            if let data = try? JSONEncoder().encode(server)
            {
                UserDefaults.standard.set(data, forKey: "currentServer")
            }
            
    
            ConfigurationManager.shared.saveSelectedServer(server) //Save Conrrent configuration
            NotificationCenter.default.post(name: .serverDidUpdate, object: nil)//Update HomeVc SelectedServer View
            VPNManager.shared.stopTunnel() //Stop Tunnel if connected
            dismiss(animated: true)
        }
    }
}

// MARK: - UI Builders
extension ServerSelectionViewController {
    private func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.text = "Choose server location"
        label.font = UIFont(name: "Sora-SemiBold", size: 20)
        label.textColor = UIColor(named: "SkyLinkBlack")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func createSearchContainerView() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .white
        container.layer.cornerRadius = 16
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.08
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 8
        container.heightAnchor.constraint(equalToConstant: 60).isActive = true

        let searchTextField = UITextField()
        searchTextField.placeholder = "Search location"
        searchTextField.font = UIFont(name: "Sora-Regular", size: 16)
        searchTextField.textColor = UIColor(named: "Neutral500") ?? .systemGray
        searchTextField.translatesAutoresizingMaskIntoConstraints = false

        let searchIcon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        searchIcon.tintColor = UIColor(named: "Neutral500") ?? .systemGray
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
}

extension ServerSelectionViewController: UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        isSearching = false
        rebuildVisibleRows(for: nil)
        tableView.reloadData()
        return true
    }
}
