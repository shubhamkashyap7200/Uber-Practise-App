//
//  Extension.swift
//  Uber Practise App
//
//  Created by Shubham on 11/28/22.
//

import UIKit

// MARK: - Extensions
extension UIView {
    
    // Handling Contraints
    func customAnchor(top: NSLayoutYAxisAnchor? = nil,
                left: NSLayoutXAxisAnchor? = nil, // providing default value
                bottom: NSLayoutYAxisAnchor? = nil,
                right: NSLayoutXAxisAnchor? = nil,
                paddingTop: CGFloat = 0,
                paddingLeft: CGFloat = 0,
                paddingBottom: CGFloat = 0,
                paddingRight: CGFloat = 0,
                width: CGFloat? = nil,
                height: CGFloat? = nil) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        if let top = top, let left = left, let bottom = bottom, let right = right, let width = width, let height = height {
            print("Anchor Func from extension is getting called")
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
            widthAnchor.constraint(equalToConstant: width).isActive = true
            heightAnchor.constraint(equalToConstant: height).isActive = true
            centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        }
    }
    
    // center function
    func customCenterX(inView view: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func customCenterY(inView view: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
