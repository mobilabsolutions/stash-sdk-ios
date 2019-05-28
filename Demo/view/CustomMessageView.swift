//
//  CustomMessageView.swift
//  Demo
//
//  Created by Rupali Ghate on 22.05.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentCore
import UIKit

class CustomMessageView: UICollectionReusableView {
    // MARK: Properties
    
    private let iconDimensions: (width: CGFloat, height: CGFloat) = (120, 71)
    private let titleTopPadding: CGFloat = 24
    private let subTitleTopPadding: CGFloat = 4

    // MARK: Initializers
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIConstants.emptyCartImage

        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.font = UIConstants.defaultFont(of: 18, type: .bold)
        label.textColor = UIConstants.dark
        label.text = "No items yet"
        
        return label
    }()

    private lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIConstants.defaultFont(of: 12, type: .medium)
        label.textColor = UIConstants.coolGrey
        label.text = "Please select a new item."

        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Helpers
    
    private func setupViews() {
        addSubview(imageView)
        imageView.anchor(centerX: centerXAnchor, centerY: centerYAnchor, width: iconDimensions.width, height: iconDimensions.height)

        addSubview(titleLabel)
        titleLabel.anchor(top: imageView.bottomAnchor, centerX: centerXAnchor, paddingTop: titleTopPadding)

        addSubview(subTitleLabel)
        subTitleLabel.anchor(top: titleLabel.bottomAnchor, centerX: centerXAnchor, paddingTop: subTitleTopPadding)
    }
}
