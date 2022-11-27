//
//  ViewController.swift
//  Uber Practise App
//
//  Created by Shubham on 11/28/22.
//

import UIKit

class LoginController: UIViewController {
    // MARK: - Properties
    
    // Closure
    private let companyTitleLabel: UILabel = { () -> UILabel in
        let label = UILabel()
        label.text = "UBER"
        label.font = UIFont(name: "Avenir-Light", size: 36)
        label.textColor = UIColor(white: 1, alpha: 0.8)
        return label
    }()
    
    
    // MARK: - Life cycle functions

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = UIColor.init(red: 25/255, green: 25/255, blue: 25/255, alpha: 1)
        view.addSubview(companyTitleLabel)
        
        // Active programmatical auto layout
        companyTitleLabel.customAnchor(top: view.safeAreaLayoutGuide.topAnchor)
        companyTitleLabel.customCenterX(inView: view)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
}

