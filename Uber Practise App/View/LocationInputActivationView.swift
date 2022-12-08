//
//  LocationInputActivationView.swift
//  Uber Practise App
//
//  Created by Shubham on 12/5/22.
//

import UIKit

protocol LocationInputActivationViewDelegate: AnyObject {
    func presentLocationInputView()
}

class LocationInputActivationView: UIView {
    // MARK: - Properties
    weak var delegate: LocationInputActivationViewDelegate?
    
    // MARK: - Custom View
    private let customIndicatorMarkerView: UIView = { () -> UIView in
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    // MARK: - Company Name
    private let placeHolderLabel: UILabel = { () -> UILabel in
        let label = UILabel()
        label.text = "Where to?"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .darkGray
        return label
    }()

    
    
    // MARK: - Life Cycles
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        backgroundColor = .white
        addShadow()
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
        
        addBlurToView(style: .systemUltraThinMaterialLight)
        
        addSubview(customIndicatorMarkerView)
        customIndicatorMarkerView.customCenterY(inView: self, leftAnchor: leftAnchor, paddingLeft: 16.0)
        customIndicatorMarkerView.setDimensions(height: 6.0, width: 6.0)
        
        addSubview(placeHolderLabel)
        placeHolderLabel.customCenterY(inView: self, leftAnchor: customIndicatorMarkerView.rightAnchor, paddingLeft: 20.0)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(presentLocationInputView))
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Custom Functions
    @objc func presentLocationInputView() {
        delegate?.presentLocationInputView()
    }
}

