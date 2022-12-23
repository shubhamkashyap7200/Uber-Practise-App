//
//  SideMenuController.swift
//  Uber Practise App
//
//  Created by Shubham on 12/23/22.
//

import UIKit

private let reuseIdentifier = "MenuCell"

class MenuController: UITableViewController {
    // MARK: - Properties
    private let user: User
    
    private lazy var menuHeader: CustomMenuHeader = { () -> CustomMenuHeader in
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 140.0)
        let view = CustomMenuHeader(user: user, frame: frame)
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
        
        view.backgroundColor = .white        
        configureTableView()
    }

    // MARK: - Selectors
    
    // MARK: - Helper Functions
    func configureTableView() {
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.rowHeight = 60.0
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableHeaderView = menuHeader
    }
}


extension MenuController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = "Menu Option"
        cell.contentConfiguration = content
        return cell
    }
}
