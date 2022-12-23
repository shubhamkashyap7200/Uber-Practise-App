//
//  SettingsController.swift
//  Uber Practise App
//
//  Created by Shubham on 12/24/22.
//

import UIKit

private let reuseIdentifier = "LocationCell"

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
