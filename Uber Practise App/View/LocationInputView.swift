//
//  LocationInputView.swift
//  Uber Practise App
//
//  Created by Shubham on 12/5/22.
//

import UIKit

protocol LocationInputViewDelegate: AnyObject {
    func dismissLocationInputView()
    func executeSearch(query: String)
}

class LocationInputView: UIView {

    // MARK: - Properties
    
    weak var delegate: LocationInputViewDelegate?
    var user: User? {
        didSet {
            titleLabel.text = user?.fullname
        }
    }
    
    private let backButton: UIButton = { () -> UIButton in
        let button = UIButton(type: .system)
        
        var config = UIImage.SymbolConfiguration(pointSize: 10.0, weight: .bold)
        let image = UIImage(systemName: "arrow.backward", withConfiguration: config)?.withTintColor(.black, renderingMode: .alwaysOriginal)
        image?.withRenderingMode(.alwaysTemplate)
        image?.withTintColor(.black)
        
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Title Label
    private var titleLabel: UILabel = { () -> UILabel in
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.textColor = .darkGray
        return label
    }()
    
    // MARK: - Indicators
    private let startIndicatorMarkerView: UIView = { () -> UIView in
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 6.0 / 2.0
        return view
    }()

    private let linkingIndicatorMarkerView: UIView = { () -> UIView in
        let view = UIView()
        view.backgroundColor = .darkGray
        return view
    }()

    private let endIndicatorMarkerView: UIView = { () -> UIView in
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    // MARK: - Start Textfield
    private lazy var startingLocationTextField: UITextField = { () -> UITextField in
        let tf = UITextField()
        tf.placeholder = "Current Location"
        tf.backgroundColor = .systemGroupedBackground
        tf.isEnabled = false
        tf.font = UIFont.systemFont(ofSize: 14.0)
        tf.layer.cornerRadius = 5.0
        
        let paddingView = UIView()
        paddingView.setDimensions(height: 30, width: 8)
        tf.leftView = paddingView
        tf.leftViewMode = .always

        return tf
    }()
    
    // MARK: - Destination Textfield

    private lazy var destinationLocationTextField: UITextField = { () -> UITextField in
        let tf = UITextField()
        tf.placeholder = "Enter a destination"
        tf.backgroundColor = .lightGray
        tf.returnKeyType = .search
        tf.font = UIFont.systemFont(ofSize: 14.0)
        tf.layer.cornerRadius = 5.0
        tf.delegate = self
        
        let paddingView = UIView()
        paddingView.setDimensions(height: 30, width: 8)
        tf.leftView = paddingView
        tf.leftViewMode = .always
    
        return tf
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addShadow()
        addBlurToView(style: .systemUltraThinMaterialLight)
        
        
        addSubview(backButton)
        backButton.customAnchor(top: topAnchor, left: leftAnchor, paddingTop: 44.0, paddingLeft: 12.0, width: 24.0, height: 24.0)

        addSubview(titleLabel)
        titleLabel.customCenterY(inView: backButton)
        titleLabel.customCenterX(inView: self)
        
        addSubview(startingLocationTextField)
        startingLocationTextField.customAnchor(top: backButton.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 12.0, paddingLeft: 40.0, paddingRight: 40.0, height: 30.0)
        
        addSubview(destinationLocationTextField)
        destinationLocationTextField.customAnchor(top: startingLocationTextField.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 12.0, paddingLeft: 40.0, paddingRight: 40.0, height: 30.0)
        
        
        addSubview(startIndicatorMarkerView)
        startIndicatorMarkerView.customCenterY(inView: startingLocationTextField, leftAnchor: leftAnchor, paddingLeft: 20)
        startIndicatorMarkerView.setDimensions(height: 6.0, width: 6.0)
                
        addSubview(endIndicatorMarkerView)
        endIndicatorMarkerView.customCenterY(inView: destinationLocationTextField, leftAnchor: leftAnchor, paddingLeft: 20)
        endIndicatorMarkerView.setDimensions(height: 6.0, width: 6.0)
        
        addSubview(linkingIndicatorMarkerView)
        linkingIndicatorMarkerView.customCenterX(inView: startIndicatorMarkerView)
        linkingIndicatorMarkerView.customAnchor(top: startIndicatorMarkerView.bottomAnchor, bottom: endIndicatorMarkerView.topAnchor, paddingTop: 4.0, paddingBottom: 4.0, width: 0.5)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Functions

    
    // MARK: - Custom functions
    @objc func handleBackButton() {
        print("DEBUG:: Going back now")
        delegate?.dismissLocationInputView()
        destinationLocationTextField.text = ""
    }
}


// MARK: - Textfield Delegates
extension LocationInputView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let query = textField.text else { return false }
        textField.resignFirstResponder()
        
        if query != "" {
            delegate?.executeSearch(query: query)
            return true
        }
        
        return true
    }
}
