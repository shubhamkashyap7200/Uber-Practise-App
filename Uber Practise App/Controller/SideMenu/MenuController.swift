//
//  SideMenuController.swift
//  Uber Practise App
//
//  Created by Shubham on 12/23/22.
//

import UIKit

class MenuController: UITableViewController {
    // MARK: - Properties
    
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        view.backgroundColor = .orange
        tableView.backgroundColor = .orange
    }

    // MARK: - Selectors



}
