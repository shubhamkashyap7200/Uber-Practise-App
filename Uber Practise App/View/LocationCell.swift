//
//  LocationCell.swift
//  Uber Practise App
//
//  Created by Shubham on 12/6/22.
//

import UIKit

class LocationCell: UITableViewCell {
    // MARK: - Properties
    let titleLabel: UILabel = { () -> UILabel in
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.text = "567 Grove Street"
        return label
    }()

    let subtitleLabel: UILabel = { () -> UILabel in
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textColor = .lightGray
        label.text = "LA - California - USA"
        return label
    }()

    
    
    // MARK: - Lifecycles
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        addBlurToView(style: .systemUltraThinMaterialLight)
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 4.0
        
        addSubview(stackView)
        stackView.customCenterY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12.0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
