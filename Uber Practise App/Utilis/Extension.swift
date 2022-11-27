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
        
        // top
        if let top = top {
            print("Anchor Func from extension is getting called")
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        // left
        if let left = left {
            print("Anchor Func from extension is getting called")
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        // bottom
        if let bottom = bottom {
            print("Anchor Func from extension is getting called")
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        // right
        if let right = right {
            print("Anchor Func from extension is getting called")
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        // width
        if let width = width {
            print("Anchor Func from extension is getting called")
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        // height
        if let height = height {
            print("Anchor Func from extension is getting called")
            heightAnchor.constraint(equalToConstant: height).isActive = true
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
