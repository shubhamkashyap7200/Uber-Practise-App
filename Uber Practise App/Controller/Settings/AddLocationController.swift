//
//  AddLocationController.swift
//  Uber Practise App
//
//  Created by Shubham on 12/24/22.
//

import UIKit
import MapKit

private let reuseIdentifier = "cell"

protocol AddLocationControllerDelegate: AnyObject {
    func updateLocation(locationString: String, type: LocationType)
}

class AddLocationController: UITableViewController {
    // MARK: - Properties
    weak var delegate: AddLocationControllerDelegate?
    private let searchBar = UISearchBar()
    private let searchCompleter = MKLocalSearchCompleter()
    private var type: LocationType
    private var location: CLLocation
    private var searchResults = [MKLocalSearchCompletion]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    // MARK: - Lifecycle
    init(type: LocationType, location: CLLocation) {
        self.type = type
        self.location = location
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    
    // MARK: - Selectors
    
    
    // MARK: - Helper Functions
    
    func configureUI() {
        configureTableView()
        configureSearchBar()
        configureSearchCompleter()
    }
    func configureSearchBar() {
        searchBar.sizeToFit()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        navigationItem.largeTitleDisplayMode = .never
    }
    
    func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 60.0
    }
    
    func configureSearchCompleter() {
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        searchCompleter.region = region
        searchCompleter.delegate = self
    }
}

// MARK: - Tableview Delegates and datasource

extension AddLocationController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)
        var config = UIListContentConfiguration.cell()
        let results = searchResults[indexPath.row]
        
        config.text = results.title
        config.secondaryText = results.subtitle
        cell.contentConfiguration = config
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = searchResults[indexPath.row]
        let title = result.title
        let subtitle = result.subtitle
        let locationString = title + " " + subtitle
        let trimmedLocation = locationString.replacingOccurrences(of: ", India", with: "")
        
        delegate?.updateLocation(locationString: trimmedLocation, type: type)
    }
}

// MARK: - Searchbar Delegates

extension AddLocationController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
    }
}

// MARK: - MKLocal Search Complete Delegate

extension AddLocationController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
    }
}
