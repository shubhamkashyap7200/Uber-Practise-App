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
        let view = UIView()
        
        // Adding Image View
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "mail")
//        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 25)
        imageView.alpha = 0.8
        imageView.tintColor = .white
        view.addSubview(imageView)
        imageView.customCenterY(inView: view)
        imageView.customAnchor(left: view.leftAnchor, paddingLeft: 8, width: 25)
        
        // Adding TextFieldViewr
        view.addSubview(emailTextField)
        emailTextField.customCenterY(inView: view)
        emailTextField.customAnchor(left: imageView.rightAnchor, bottom: view.bottomAnchor ,right: view.rightAnchor, paddingLeft: 8, paddingRight: 8)
        
        // Adding Separator View
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        view.addSubview(separatorView)
        separatorView.customAnchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingLeft: 8, paddingRight: 8, height: 0.75)
        
        return view
    }()
    
    //  Textfield container view
    private let emailTextField: UITextField = { () -> UITextField in
        let tf = UITextField()
        tf.borderStyle = .none
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.textColor = .white
        tf.keyboardAppearance = .dark
        tf.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        return tf
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
        
        view.addSubview(emailContainerView)
        emailContainerView.customAnchor(top: companyTitleLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 16, paddingRight: 16, height: 50)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
}

