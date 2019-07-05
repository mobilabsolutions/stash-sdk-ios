//
//  UIView+Extensions.swift
//  MobilabPaymentCore
//
//  Created by Rupali Ghate on 07.05.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import UIKit

public extension UIView {
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                left: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                right: NSLayoutXAxisAnchor? = nil,
                centerX: NSLayoutXAxisAnchor? = nil,
                centerY: NSLayoutYAxisAnchor? = nil,
                paddingTop: CGFloat = 0,
                paddingLeft: CGFloat = 0,
                paddingBottom: CGFloat = 0,
                paddingRight: CGFloat = 0,
                width: CGFloat? = nil,
                height: CGFloat? = nil,
                heightAnchor: NSLayoutDimension? = nil,
                widthAnchor: NSLayoutDimension? = nil) {
        self.translatesAutoresizingMaskIntoConstraints = false

        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }

        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }

        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }

        if let right = right {
            self.rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }

        if let centerX = centerX {
            self.centerXAnchor.constraint(equalTo: centerX).isActive = true
        }

        if let centerY = centerY {
            self.centerYAnchor.constraint(equalTo: centerY).isActive = true
        }

        if let width = width {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }

        if let height = height {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }

        if let heightAnchor = heightAnchor {
            self.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        }

        if let widthAnchor = widthAnchor {
            self.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        }
    }
}
