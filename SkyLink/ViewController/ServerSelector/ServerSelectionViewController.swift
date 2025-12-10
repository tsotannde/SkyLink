//
//  ServerSelectionViewController.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 10/24/25.
//

import UIKit

final class ServerSelectionViewController: UIViewController {

    // MARK: - UI Elements
    internal var titleLabel: UILabel!
    internal var searchContainerView: UIView!
    internal var tableView: UITableView!

    // MARK: - Data
    internal var expandedCountries = Set<IndexPath>()
    internal var freeCountries: [Country] = []
    internal var premiumCountries: [Country] = []
    internal var visibleRows: [VisibleRow] = []
    internal var filteredVisibleRows: [VisibleRow] = []
    internal var isSearching = false

    // MARK: - Lifecycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setBackgroundColor()
        constructUI()
        setupTableView()
        setupSearchField()
        setupTapToDismiss()

        Task { await loadData() }
    }
}

// MARK: - TableView Handling
extension ServerSelectionViewController: UITableViewDelegate, UITableViewDataSource
{

    internal struct VisibleRow
    {
        enum RowType { case country(Country), server(Server) }
        let type: RowType
        let section: Int
    }

    internal func numberOfSections(in tableView: UITableView) -> Int { 2 }

    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = isSearching ? filteredVisibleRows : visibleRows
        return rows.filter { $0.section == section }.count
    }

    internal func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        section == 0 ? "FREE LOCATIONS" : "PREMIUM LOCATIONS"
    }

    internal func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = UIFont(name: "Sora-SemiBold", size: 15)
        header.textLabel?.textColor = .black
    }

    internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 80 }

    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rows = isSearching ? filteredVisibleRows : visibleRows
        let sectionRows = rows.filter { $0.section == indexPath.section }
        let visibleRow = sectionRows[indexPath.row]

        switch visibleRow.type {
        case .country(let country):
            let cell = tableView.dequeueReusableCell(withIdentifier: "ServerViewCell", for: indexPath) as! CountryCell
            let flag = FlagManager.shared.getCountryFlagImage(country.name ?? "") ?? UIImage(systemName: "globe")
            let model = CountryCellViewModel(
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
            let model = ServerViewModel(
                flagImage: flag,
                city: server.city ?? "Unknown City",
                state: server.state ?? "Unknown",
                totalCapacity: server.capacity,
                currentPeers: server.currentCapacity,
                showCrown: server.requiresSubscription,
               
            )
            cell.configure(with: model)
            return cell
        }
    }

    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
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

            // Correctly match the exact visible row the user tapped
            let rowsInSection = visibleRows.enumerated().filter { $0.element.section == indexPath.section }
            let flatIndex = rowsInSection[indexPath.row].offset
            let baseIndex = flatIndex

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
            print("Selected: \(server.city ?? "Unknown City"), \(server.state ?? "Unknown State") [\(server.publicIP ?? "N/A")]")

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

extension ServerSelectionViewController: UITextFieldDelegate
{
    internal func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        isSearching = false
        rebuildVisibleRows(for: nil)
        tableView.reloadData()
        return true
    }
}

//MARK: - Helper Functions
extension ServerSelectionViewController
{
    
    /// Asynchronously loads the list of servers from the configuration manager, groups them by country for free and premium categories,
    /// rebuilds the visible rows for display in the table view, and reloads the table view on the main thread.
    /// If loading the servers fails, prints an error to the console.
    internal func loadData() async
    {
        do {
            AppLogger.shared.log("[Server Selector] Loading Servers...")
            try await ConfigurationManager.shared.loadCachedServers()
            freeCountries = buildCountries(from: ConfigurationManager.shared.freeServers, requiresSub: false)
            premiumCountries = buildCountries(from: ConfigurationManager.shared.premiumServers, requiresSub: true)
            rebuildVisibleRows(for: nil)
            DispatchQueue.main.async { self.tableView.reloadData() }
            AppLogger.shared.log("[Server Selector] Loaded Saved Servers Successfully.")
        }catch
        {
            //If Above fails
            print("Failed to load servers: \(error)")
            AppLogger.shared.log("[Server Selector] Failed to Load Server. Contact Support")
            AppLogger.shared.log("Error Message: \(error)")
            try? await ConfigurationManager.shared.fetchServerFromFireBase() //STEP 1: Fetch Live Server List from Firebase
            self.dismiss(animated: true) //STEP 2: Dismiss the View (Temporary Fix)
            //STEP 3: TODO: Implement Spinner icon while fetching and using the data in the UI
        }
    }
    
    internal func buildCountries(from servers: [Server], requiresSub: Bool) -> [Country]
    {
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
}

//MARK: - Table View Helper Functions
extension ServerSelectionViewController
{
    internal func rebuildVisibleRows(for indexPath: IndexPath?)
    {
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

}

//MARK: - Seach Bar Function
extension ServerSelectionViewController
{
    @objc internal func searchTextChanged(_ textField: UITextField) {
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
