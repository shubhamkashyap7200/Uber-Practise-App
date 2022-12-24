//
//  SettingsController.swift
//  Uber Practise App
//
//  Created by Shubham on 12/24/22.
//

import UIKit

private let reuseIdentifier = "LocationCell"

enum LocationType: Int, CaseIterable, CustomStringConvertible {
    var description: String {
        switch self {
        case .home:
            return "Home"
        case .work:
            return "Work"
        }
    }
    
    var subtitle: String {
        switch self {
        case .home:
            return "Add home"
        case .work:
            return "Add work"
        }
    }
    
    case home
    case work
}

protocol SettingsControllerDelegate: AnyObject {
    func updateUser(_ controller: SettingsController)
}

class SettingsController: UITableViewController {
    // MARK: - Properties
    weak var delegate: SettingsControllerDelegate?
    var user: User
    var userInfoUpdated: Bool = false
    private let locationManager = LocationHandler.shared.locationManager
    
    private lazy var userInfoHeaderView: UserInfoHeader = { () -> UserInfoHeader in
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 100)
        let view = UserInfoHeader(user: user, frame: view.frame)
        return view
    }()
    
    // MARK: - Lifecycle
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        configureNavigationBar()
    }

    // MARK: - Helper Functions
    func locationText(forType type: LocationType) -> String {
        switch type {
        case .home:
            return user.homeLocation ?? type.subtitle
        case .work:
            return user.workLocation ?? type.subtitle
        }
    }
    
    func configureTableView() {
        tableView.rowHeight = 60.0
        tableView.backgroundColor = .white
        tableView.tableHeaderView = userInfoHeaderView
        tableView.tableFooterView = UIView()
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.barTintColor = .backgroundColor
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barStyle = .black
        navigationItem.title = "Settings"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark")?.withTintColor(.white, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(dismissButtonAction))
    }
    
    // MARK: - Selectors
    @objc func dismissButtonAction() {
        if userInfoUpdated {
            delegate?.updateUser(self)
        }

        dismiss(animated: true, completion: nil)
    }

}

// MARK: - Tableview delegates and datsource

extension SettingsController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LocationType.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! LocationCell
        guard let type = LocationType(rawValue: indexPath.row) else { return cell }
        cell.titleLabel.text = type.description
        cell.subtitleLabel.text = locationText(forType: type)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .backgroundColor
        
        let title = UILabel()
        title.font = UIFont.systemFont(ofSize: 16.0)
        title.text = "Favorites"
        title.textColor = .white
        view.addSubview(title)
        title.customCenterY(inView: view, leftAnchor: view.leftAnchor, paddingLeft: 16.0)
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let type = LocationType(rawValue: indexPath.row) else { return }
        guard let location = locationManager?.location else { return }
        
        let controller = AddLocationController(type: type, location: location)
        controller.modalPresentationStyle = .fullScreen
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - AddLocationControllerDelegate

extension SettingsController: AddLocationControllerDelegate {
    func updateLocation(locationString: String, type: LocationType) {
        PassengerService.shared.saveLocation(locationString: locationString, type: type) { (err, ref) in
            if let err = err {
                print("DEBUG:: Error while saving location is :: \(err.localizedDescription)")
                return
            }
            
            self.navigationController?.popViewController(animated: true)
            self.userInfoUpdated = true
            
            switch type {
            case .home:
                self.user.homeLocation = locationString
            case .work:
                self.user.workLocation = locationString
            }
            
            self.tableView.reloadData()
        }
    }
}
