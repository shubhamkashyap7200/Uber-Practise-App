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

class SettingsController: UITableViewController {
    // MARK: - Properties
    private let user: User
    
    private lazy var userInfoHeaderView: UserInfoHeader = {
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
    func configureTableView() {
        tableView.rowHeight = 60.0
        tableView.backgroundColor = .white
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableHeaderView = userInfoHeaderView
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.barTintColor = .backgroundColor
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = .black
        navigationItem.title = "Settings"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark")?.withTintColor(.white, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(dismissButtonAction))
    }
    
    // MARK: - Selectors
    @objc func dismissButtonAction() {
        self.dismiss(animated: true, completion: nil)
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
        cell.type = type
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .black
            
        let title = UILabel()
        title.font = UIFont.systemFont(ofSize: 16.0)
        title.text = "Favorites"
        title.textColor = .white
        view.addSubview(title)
        title.customCenterY(inView: view, leftAnchor: view.leftAnchor)
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let type = LocationType(rawValue: indexPath.row) else { return }
        print("DEBUG:: Type is \(type.description)")
    }
}