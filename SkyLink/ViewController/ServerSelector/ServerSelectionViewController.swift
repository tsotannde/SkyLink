//
//  ServerSelectionViewController.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 10/24/25.
//

import UIKit

// ServerSelectionViewController
// ------------------------------------
// This view controller presents a searchable, expandable list of VPN servers
// grouped by country and split into Free and Premium sections.
//
// Responsibilities:
// - Load cached server data and build display models
// - Render countries and servers in a single flattened table view
// - Handle expansion/collapse of country rows
// - Enforce premium gating before server selection
// - Persist the selected server and trigger VPN reconfiguration
//
// This controller orchestrates UI + user decisions only.
// Networking, persistence, and VPN behavior are delegated to managers.

final class ServerSelectionViewController: UIViewController
{

    // UI elements are declared as implicitly unwrapped optionals
    // because they are constructed programmatically during viewDidLoad.
    // MARK: - UI Elements
    internal var titleLabel: UILabel!
    internal var searchContainerView: UIView!
    internal var tableView: UITableView!

    // State and data backing the table view.
    // These collections are mutated as servers load, expand/collapse,
    // and search filtering is applied.
    // MARK: - Data

    // Tracks which country rows are currently expanded.
    // IndexPaths are used to align with table view sections and rows.
    internal var expandedCountries = Set<IndexPath>()

    internal var freeCountries: [Country] = []
    internal var premiumCountries: [Country] = []

    // Flattened representation of the table view contents.
    // Countries and their servers are represented in a single array
    // so insertion and deletion animations remain predictable.
    internal var visibleRows: [VisibleRow] = []

    // Alternate flattened data source used when the user is searching.
    // This bypasses expansion state and renders only matching results.
    internal var filteredVisibleRows: [VisibleRow] = []

    // Indicates whether the table view should render filtered search results
    // instead of the full expandable country/server list.
    internal var isSearching = false

    // Initial setup:
    // - Build static UI
    // - Configure table view and search handling
    // - Load cached server data asynchronously
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

    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let rows = isSearching ? filteredVisibleRows : visibleRows
        return rows.filter { $0.section == section }.count
    }

    internal func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        let freeLocationText = SkyLinkAssets.Text.freeLocationKey
        let premiumLocationText = SkyLinkAssets.Text.premiumLocationKey
        return section == 0 ? freeLocationText : premiumLocationText
    }

    internal func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = SkyLinkAssets.Fonts.semiBold(ofSize: 15)
        header.textLabel?.textColor = SkyLinkAssets.Colors.blackColor
    }

    internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 80 }

    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let rows = isSearching ? filteredVisibleRows : visibleRows
        let sectionRows = rows.filter { $0.section == indexPath.section }
        let visibleRow = sectionRows[indexPath.row]

        switch visibleRow.type
        {
        case .country(let country):
            
            let cell = tableView.dequeueReusableCell(withIdentifier: SkyLinkAssets.Cell.serverViewCellIdentifier, for: indexPath) as! CountryCell
            let flag = FlagManager.shared.getCountryFlagImage(country.name ?? SkyLinkAssets.Text.unknownKey) ?? SkyLinkAssets.Images.globe
            
            let model = CountryCellViewModel(
                flagImage: flag,
                name: country.name ?? SkyLinkAssets.Text.unknownKey,
                totalCapacity: 700,
                currentPeers: 50,
                showChevron: true,
                showCrown: country.requiresSubscription,
                isExpanded: expandedCountries.contains(indexPath))
          
            cell.configure(with: model)
            return cell

        case .server(let server):
            
            let cell = tableView.dequeueReusableCell(withIdentifier: SkyLinkAssets.Cell.individualServerViewCellIdentifier, for: indexPath) as! ServerCell
            let flag = FlagManager.shared.getCountryFlagImage(server.country ?? SkyLinkAssets.Text.unknownKey) ?? SkyLinkAssets.Images.globe
            
            let model = ServerViewModel(
                flagImage: flag,
                city: server.city ?? SkyLinkAssets.Text.errorTitleKey,
                state: server.state ?? SkyLinkAssets.Text.errorTitleKey,
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

        switch visibleRow.type
        {
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
            if isExpanding
            {
                let newRows = servers.map { VisibleRow(type: .server($0), section: section) }
                visibleRows.insert(contentsOf: newRows, at: baseIndex + 1)

                let newIndexPaths = (0..<servers.count).map
                {
                    IndexPath(row: indexPath.row + 1 + $0, section: section)
                }
                tableView.performBatchUpdates
                {
                    tableView.insertRows(at: newIndexPaths, with: .fade)
                }
            } else
            {
                let countToRemove = servers.count
                visibleRows.removeSubrange((baseIndex + 1)...(baseIndex + countToRemove))
                let removedIndexPaths = (0..<countToRemove).map
                {
                    IndexPath(row: indexPath.row + 1 + $0, section: section)
                }
                tableView.performBatchUpdates
                {
                    tableView.deleteRows(at: removedIndexPaths, with: .fade)
                }
            }

        case .server(let server):
            // User selected an individual server row.
            // This is the single decision point where a server switch can occur.
            let isSubscribed = SubscriptionManager.shared.isSubscribed()
    
            // Premium gating:
            // If the server requires a subscription and the user is not subscribed,
            // redirect to the subscription flow and abort the selection.
            if server.requiresSubscription && !isSubscribed
            {
                NotificationCenter.default.post(name: .showSubscriptionPage, object: nil)
                dismiss(animated: true)
                return
            }
            // Persist the selected server locally so it can be restored on app relaunch.
            if let data = try? JSONEncoder().encode(server)
            {
                UserDefaults.standard.set(data, forKey: SkyLinkAssets.AppKeys.UserDefaults.currentServer)
            }
            
            // Save the selected server to the app configuration layer.
            // This becomes the new source of truth for future connections.
            ConfigurationManager.shared.saveSelectedServer(server) //Save Conrrent configuration
            NotificationCenter.default.post(name: .serverDidUpdate, object: nil)//Update HomeVc SelectedServer View
            // Stop the current VPN tunnel (if active) so it can reconnect
            // using the newly selected server configuration.
            VPNManager.shared.stopTunnel() //Stop Tunnel if connected
            dismiss(animated: true)
        }
    }
}

// MARK: - UI Builders
extension ServerSelectionViewController: UITextFieldDelegate
{
    internal func textFieldShouldClear(_ textField: UITextField) -> Bool
    {
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
    internal func loadData() async
    {
        // Attempt to load cached servers first for fast UI rendering.
        // Network fetch is treated as a fallback if local data is unavailable.
        do {
            try await ConfigurationManager.shared.loadCachedServers()
            freeCountries = buildCountries(from: ConfigurationManager.shared.freeServers, requiresSub: false)
            premiumCountries = buildCountries(from: ConfigurationManager.shared.premiumServers, requiresSub: true)
            rebuildVisibleRows(for: nil)
            DispatchQueue.main.async { self.tableView.reloadData() }
        }
        // Cache load failed:
        // Log the failure, attempt a remote fetch, then dismiss as a temporary fallback.
        // This prevents the UI from entering an inconsistent state.
        catch
        {
            try? await ConfigurationManager.shared.fetchServerFromFireBase() //STEP 1: Fetch Live Server List from Firebase
            self.dismiss(animated: true) //STEP 2: Dismiss the View (Temporary Fix)
            //STEP 3: TODO: Implement Spinner icon while fetching and using the data in the UI
        }
    }
    
    internal func buildCountries(from servers: [Server], requiresSub: Bool) -> [Country]
    {
        var grouped: [String: [Server]] = [:]
        for server in servers {
            let countryName = server.country ?? SkyLinkAssets.Text.unknownKey
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
        // Rebuilds the flat list of rows displayed by the table view.
        // This flattens countries and their expanded servers into a single array
        // that preserves section ordering and expansion state.
        visibleRows.removeAll()

        for (section, countries) in [freeCountries, premiumCountries].enumerated()
        {
            for (row, country) in countries.enumerated()
            {
                let countryIndexPath = IndexPath(row: row, section: section)
                visibleRows.append(VisibleRow(type: .country(country), section: section))
                // If the country is expanded, append its servers directly after the country row.
                if expandedCountries.contains(countryIndexPath)
                {
                    let servers = Array(country.servers.values)
                    for server in servers
                    {
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
    @objc internal func searchTextChanged(_ textField: UITextField)
    {
        let query = textField.text?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) ?? SkyLinkAssets.Text.unknownKey
        guard !query.isEmpty else
        {
            isSearching = false
            rebuildVisibleRows(for: nil)
            tableView.reloadData()
            return
        }

        // Enter search mode:
        // Results are rebuilt from all servers (free + premium)
        // and rendered as a flat filtered list.
        isSearching = true
        filteredVisibleRows.removeAll()

        let allServers = ConfigurationManager.shared.freeServers + ConfigurationManager.shared.premiumServers
        var seenCountries = Set<String>()

        // Build a filtered list that includes:
        // - One country header per matching country
        // - All matching servers under that country
        for server in allServers
        {
            if server.name.lowercased().contains(query)
                || (server.city?.lowercased().contains(query) ?? false)
                || (server.country?.lowercased().contains(query) ?? false)
                || (server.state?.lowercased().contains(query) ?? false)
            {

                if !seenCountries.contains(server.country ?? SkyLinkAssets.Text.unknownKey)
                {
                    seenCountries.insert(server.country ?? SkyLinkAssets.Text.unknownKey)
                    filteredVisibleRows.append(.init(type: .country(Country(name: server.country ?? SkyLinkAssets.Text.unknownKey,
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
