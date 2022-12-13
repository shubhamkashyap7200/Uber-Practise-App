//
//  RideActionView.swift
//  Uber Practise App
//
//  Created by Shubham on 12/13/22.
//

import Foundation
import UIKit

protocol RideActionViewDelegate: AnyObject {
    func uploadTrip()
}

class RideActionView: UIView {
    // MARK: - Properties
    weak var delegate: RideActionViewDelegate?
//    var rideActionViewData: SearchQueryResult? {
//        didSet {
//            titleLabel.text = rideActionViewData?.name[]
//            addressLabel.text = rideActionViewData?.address[0]
//        }
//    }

    var titleLabel: UILabel = { ()-> UILabel in
        let label = UILabel()
        label.textColor = .black
        label.text = "Title Label"
        label.font = UIFont.systemFont(ofSize: 18.0)
        label.textAlignment = .center
        return label
    }()
    
    var addressLabel: UILabel = { ()-> UILabel in
        let label = UILabel()
        label.textColor = .darkGray
        label.text = "Address Label, Faridkot, Punjab"
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var infoView: UIView = { () -> UIView in
        let view = UIView()
        view.backgroundColor = .black
        let label = UILabel()
        label.font = .systemFont(ofSize: 30)
        label.textColor = .white
        label.text = "X"
        view.addSubview(label)
        label.customCenterX(inView: view)
        label.customCenterY(inView: view)
        
        return view
    }()
    
    private let infoLabel: UILabel = { () -> UILabel in
        let label = UILabel()
        label.font = .systemFont(ofSize: 18.0)
        label.textColor = .black
        label.textAlignment = .center
        label.text = "UBER X"
        return label
    }()
    
    private let actionButton: UIButton = { () -> UIButton in
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.setTitle("CONFIRM UBERX", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16.0)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleConfirmAction), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        backgroundColor = .white
        addBlurToView(style: .systemUltraThinMaterialLight)
        addShadow()

        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, addressLabel])
        stackView.axis = .vertical
        stackView.spacing = 4.0
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.customCenterX(inView: self)
        stackView.customAnchor(top: topAnchor, left: safeAreaLayoutGuide.leftAnchor, right: safeAreaLayoutGuide.rightAnchor, paddingTop: 14.0, paddingLeft: 16.0, paddingRight: 16.0)
        
        addSubview(infoView)
        infoView.customCenterX(inView: self)
        infoView.customAnchor(top: stackView.bottomAnchor, paddingTop: 16.0, width: 60.0, height: 60.0)
        infoView.layer.cornerRadius = 60 / 2
        
        
        addSubview(infoLabel)
        infoLabel.customCenterX(inView: self)
        infoLabel.customAnchor(top: infoView.bottomAnchor, paddingTop: 6.0)
        
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        addSubview(separatorView)
        separatorView.customCenterX(inView: self)
        separatorView.customAnchor(top: infoLabel.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 16.0, paddingLeft: 20.0, paddingRight: 20.0, height: 0.75)
        
        
        addSubview(actionButton)
        actionButton.customAnchor(left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor,paddingTop: 16.0, paddingLeft: 20.0, paddingBottom: 20.0, paddingRight: 20.0, height: 60.0)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Custom Functions

extension RideActionView {
     @objc func handleConfirmAction() {
        print("DEBUG:: CONFIRM PRESSED")
         delegate?.uploadTrip()
    }
}

