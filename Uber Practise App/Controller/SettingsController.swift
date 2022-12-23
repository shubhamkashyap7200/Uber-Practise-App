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
    
    // MARK: - Lifecycle
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
