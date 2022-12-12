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
    
    func customCenterY(inView view: UIView, leftAnchor: NSLayoutXAxisAnchor? = nil, paddingLeft: CGFloat = 0.0 ,constant: CGFloat = 0.0) {
        self.translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant).isActive = true
        
        if let left = leftAnchor {
            customAnchor(left: left, paddingLeft: paddingLeft)
        }
    }
    
    func inputContainerView(withImage imageString: String, textField: UITextField? = nil, sc: UISegmentedControl? = nil) -> UIView {
        let view = UIView()
        
        // Adding Image View
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: imageString)
        // imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 25)
        imageView.alpha = 0.8
        imageView.tintColor = .white
        view.addSubview(imageView)
        
        // Adding TextFieldView
        if let textField = textField {
            imageView.customCenterY(inView: view)
            imageView.customAnchor(left: view.leftAnchor, paddingLeft: 16, width: 23)

            view.addSubview(textField)
            textField.customCenterY(inView: view)
            textField.customAnchor(left: imageView.rightAnchor, bottom: view.bottomAnchor ,right: view.rightAnchor, paddingLeft: 8, paddingRight: 8)
        }
        
        // Adding the segmented controller
        if let sc = sc {
            imageView.customAnchor(top: view.topAnchor, left: view.leftAnchor, paddingTop: -8 ,paddingLeft: 8, width: 24, height: 24)
            
            view.addSubview(sc)
            sc.customAnchor(left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 8, paddingRight: 8)
            sc.customCenterY(inView: view, constant: 16)
        }
        
        // Adding Separator View
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        view.addSubview(separatorView)
        separatorView.customAnchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingLeft: 8, paddingRight: 8, height: 0.75)
        
        return view
    }
    
    
    func setDimensions(height: CGFloat, width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    // MARK: - Add blur to view
    
    func addBlurToView(style: UIBlurEffect.Style) {
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.layer.masksToBounds = true
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.isUserInteractionEnabled = true
        addSubview(blurEffectView)
    }
    
    func addShadow() {
        layer.shadowRadius = 15.0
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0.1, height: 0.1)
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
}


extension UITextField {
    func textField(withPlaceholder placeholder: String, isSecureTextEntry: Bool) -> UITextField {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.textColor = .white
        tf.keyboardAppearance = .dark
        tf.isSecureTextEntry = isSecureTextEntry
        tf.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        return tf
    }
}

extension UIColor {
    static func rbg(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor.init(red: red/255, green: green/255, blue: blue/255, alpha: 1.0)
    }
    
    static let backgroundColor = UIColor.rbg(red: 25, green: 25, blue: 25)
    static let mainBlueTintColor = UIColor.rbg(red: 17, green: 154, blue: 237)
}
