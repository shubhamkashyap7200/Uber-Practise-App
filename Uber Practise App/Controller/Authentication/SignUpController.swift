//
//  SignUpController.swift
//  Uber Practise App
//
//  Created by Shubham on 11/28/22.
//

import UIKit
import Firebase
import GeoFire
import FirebaseAuth

class SignUpController: UIViewController {
    
    // MARK: - Properties
    private var location = LocationHandler.shared.locationManager.location
    
    // Company label
    private let companyTitleLabel: UILabel = { () -> UILabel in
        let label = UILabel()
        label.text = "UBER"
        label.font = UIFont(name: "Avenir-Light", size: 36)
        label.textColor = UIColor(white: 1, alpha: 0.87)
        return label
    }()
    
    // Email container view // lazy means it will only be called when needed and will not hangout in memory
    private lazy var emailContainerView: UIView = { () -> UIView in
        let view = UIView().inputContainerView(withImage: "mail", textField: emailTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    // Full name Container view // lazy means it will only be called when needed and will not hangout in memory
    private lazy var fullnameContainerView: UIView = { () -> UIView in
        let view = UIView().inputContainerView(withImage: "person", textField: fullnameTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private lazy var passwordContainerView: UIView = { () -> UIView in
        let view = UIView().inputContainerView(withImage: "lock", textField: passwordTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private lazy var accountTypeContainerView: UIView = { () -> UIView in
        let view = UIView().inputContainerView(withImage: "person.crop.square", sc: accountTypeSegmentedControl)
        view.heightAnchor.constraint(equalToConstant: 80).isActive = true
        return view
    }()

    
    //  Textfield container view
    // Email
    private let emailTextField: UITextField = { () -> UITextField in
        return UITextField().textField(withPlaceholder: "Email", isSecureTextEntry: false)
    }()
    
    // Full name
    private let fullnameTextField: UITextField = { () -> UITextField in
        return UITextField().textField(withPlaceholder: "Full Name", isSecureTextEntry: false)
    }()
    
    // Password
    private let passwordTextField: UITextField = { () -> UITextField in
        return UITextField().textField(withPlaceholder: "Password", isSecureTextEntry: true)
    }()
    
    // login Button
    private let signUpButton: AuthButton = { () -> AuthButton in
        let button = AuthButton(type: .system)
        button.setTitle("Sign up", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    
    private let accountTypeSegmentedControl: UISegmentedControl = { () -> UISegmentedControl in
        let sc = UISegmentedControl(items: ["Rider", "Driver"])
        sc.backgroundColor = .backgroundColor
        sc.tintColor = UIColor(white: 0.87, alpha: 1.0)
        sc.selectedSegmentIndex = 0
        sc.selectedSegmentTintColor = .white
        sc.layer.borderColor = UIColor.white.withAlphaComponent(0.87).cgColor
        sc.layer.borderWidth = 0.5
        return sc
    }()
    
    // SignIn button
    private let signInButton: UIButton = { () -> UIButton in
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Already have an account?  ", attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: UIColor.lightGray
        ])
        
        attributedTitle.append(NSAttributedString(string: "Sign In", attributes: [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: UIColor.mainBlueTintColor
        ]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return button
    }()


    
    // MARK: - Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        let sharedLocationManager = LocationHandler.shared.locationManager
        print("Location is this \(sharedLocationManager?.location)")

    }
}


// MARK: - Custom Functions
extension SignUpController {
    // MARK: - Selectors
    
    // MARK: - Helper Functions
    func configureUI() {

        view.backgroundColor = .backgroundColor
        view.addSubview(companyTitleLabel)
        
        // Active programmatical auto layout
        companyTitleLabel.customAnchor(top: view.safeAreaLayoutGuide.topAnchor)
        companyTitleLabel.customCenterX(inView: view)
                
        let stack = UIStackView(arrangedSubviews: [emailContainerView, fullnameContainerView, passwordContainerView, accountTypeContainerView ,signUpButton, signInButton])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 20
        
        view.addSubview(stack)
        stack.customAnchor(top: companyTitleLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 16, paddingRight: 16)
    }
    
    @objc func handleShowSignUp() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleSignUp() {
        print("Sign up pressed")
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let fullname = fullnameTextField.text else { return }
        let accountTypeIndex = accountTypeSegmentedControl.selectedSegmentIndex
        
        print(email, password)
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            
            // If we get an error
            if let error = error {
                print("DEBUG: Error while creating user ::: \(error.localizedDescription)")
                return
            }
            
            guard let uid = result?.user.uid else { return }
            
            // Creating Data dictionary to be uploaded to firebase storage
            let values: [String : Any] = [
                "email" : email,
                "fullname" : fullname,
                "password" : password,
                "accountTypeIndex" : accountTypeIndex
            ]
            
            // MARK: - Geofire
            if accountTypeIndex == 1 {
                guard let location = self?.location else { print("DEBUG:: Location is nil from guard statement"); return }
                let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATION)
                
                geofire.setLocation(location, forKey: uid) { (error) in
                    self?.uploadUserDataAndDismiss(uid: uid, values: values)
                }
            }
            
            //
            self?.uploadUserDataAndDismiss(uid: uid, values: values)
        }
    }
    
    // MARK: - Updating the child values
    func uploadUserDataAndDismiss(uid: String, values: [String : Any]) {
        REF_USERS.child(uid).updateChildValues(values, withCompletionBlock: { (err, ref) in
            guard let controller = UIApplication.shared.keyWindow?.rootViewController as? ContainerController else { return }
            controller.configureAll()
            self.dismiss(animated: true, completion: nil)
        })
    }
}
