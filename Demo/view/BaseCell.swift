//
//  BaseCell.swift
//  Demo
//
//  Created by Rupali Ghate on 21.05.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import UIKit

class BaseCell: UICollectionViewCell {
    let cornerRadius: CGFloat = 8

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white

        layer.masksToBounds = false
        layer.cornerRadius = self.cornerRadius

        layer.shadowColor = UIColor(white: 0, alpha: 0.05).cgColor
        layer.shadowRadius = 0
        layer.shadowOpacity = 0.6
        layer.shadowOffset = CGSize(width: 0, height: 1)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
