//
//  UserInfoHeader.swift
//  Uber Practise App
//
//  Created by Shubham on 12/24/22.
//

import UIKit


class UserInfoHeader: UIView {
    // MARK: - Properties
    private let user: User

    private let profileImageView: UIImageView = { ()-> UIImageView in
        let imageView = UIImageView()
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    private lazy var fullNameLabel: UILabel = {() -> UILabel in
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.text = user.fullname
        return label
    }()
    
    private lazy var emailAddressLabel: UILabel = {() -> UILabel in
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textColor = .lightGray
        label.text = user.email
        return label
    }()

    // MARK: - Lifecycle
    init(user: User, frame: CGRect) {
        self.user = user
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(profileImageView)
        profileImageView.customAnchor(top: topAnchor, left: leftAnchor, paddingTop: 16.0 ,paddingLeft: 16.0, width: 64.0, height: 64.0)
//        profileImageView.customCenterY(inView: self, leftAnchor: leftAnchor, paddingLeft: 16.0, constant: 0.0)
        profileImageView.layer.cornerRadius = 64.0 / 2
        
        let stackView = UIStackView(arrangedSubviews: [fullNameLabel, emailAddressLabel])
        addSubview(stackView)
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 4.0
        stackView.customCenterY(inView: profileImageView, leftAnchor: profileImageView.rightAnchor, paddingLeft: 12.0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
