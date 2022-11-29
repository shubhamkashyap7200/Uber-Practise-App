//
//  AuthButton.swift
//  Uber Practise App
//
//  Created by Shubham on 11/29/22.
//

import UIKit

class AuthButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setTitleColor(UIColor(white: 1, alpha: 0.75), for: .normal)
        backgroundColor = .mainBlueTintColor
        layer.cornerRadius = 5
        heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
