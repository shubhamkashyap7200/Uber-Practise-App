//
//  ViewController.swift
//  Uber Practise App
//
//  Created by Shubham on 11/28/22.
//

import UIKit
import Firebase
import GoogleMaps
import FirebaseAuth

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
    
    // login Button
    private let loginButton: AuthButton = { () -> AuthButton in
        let button = AuthButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleLoginLogic), for: .touchUpInside)
        return button
    }()
    
    // Signup button
    private let signupButton: UIButton = { () -> UIButton in
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account?  ", attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: UIColor.lightGray
        ])
        
        attributedTitle.append(NSAttributedString(string: "Sign up", attributes: [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: UIColor.mainBlueTintColor
        ]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Life cycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        configureUI()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
}

// MARK: - Custom Functions
extension LoginController {
    
    // MARK: - Selectors
    @objc func handleShowSignUp() {
        print("Attempting to push controller")
        let controller = SignUpController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleLoginLogic() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                print("DEBUG: Error while signing the user ::: \(error)")
                return
            }
            
            print("Succesfully signed the user in")
            
            DispatchQueue.main.async {
                let controller = ContainerController()
                controller.configureAll()
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Helper Functions
    func configureUI() {
        configureNavigationBar()

        view.backgroundColor = .backgroundColor
        view.addSubview(companyTitleLabel)
        
        // Active programmatical auto layout
        companyTitleLabel.customAnchor(top: view.safeAreaLayoutGuide.topAnchor)
        companyTitleLabel.customCenterX(inView: view)
                
        let stack = UIStackView(arrangedSubviews: [emailContainerView, passwordContainerView, loginButton, signupButton])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 20
        
        view.addSubview(stack)
        stack.customAnchor(top: companyTitleLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 16, paddingRight: 16)
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
    }
    
    
}
