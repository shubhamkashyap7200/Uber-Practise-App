//
//  ViewController.swift
//  Uber Practise App
//
//  Created by Shubham on 11/28/22.
//

import UIKit

class LoginController: UIViewController {
    // MARK: - Properties
    
    // Company label
    private let companyTitleLabel: UILabel = { () -> UILabel in
        let label = UILabel()
        label.text = "UBER"
        label.font = UIFont(name: "Avenir-Light", size: 36)
        label.textColor = UIColor(white: 1, alpha: 0.8)
        return label
    }()
    
    // Email container view // lazy means it will only be called when needed and will not hangout in memory
    private lazy var emailContainerView: UIView = { () -> UIView in
        let view = UIView().inputContainerView(withImage: "mail", textField: emailTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private lazy var passwordContainerView: UIView = { () -> UIView in
        let view = UIView().inputContainerView(withImage: "lock", textField: passwordTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    //  Textfield container view
    // Email
    private let emailTextField: UITextField = { () -> UITextField in
        return UITextField().textField(withPlaceholder: "Email", isSecureTextEntry: false)
    }()
    
    // Password
    private let passwordTextField: UITextField = { () -> UITextField in
        return UITextField().textField(withPlaceholder: "Password", isSecureTextEntry: true)
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
                
        let stack = UIStackView(arrangedSubviews: [emailContainerView, passwordContainerView])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 16
        
        view.addSubview(stack)
        stack.customAnchor(top: companyTitleLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 16, paddingRight: 16)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
}

