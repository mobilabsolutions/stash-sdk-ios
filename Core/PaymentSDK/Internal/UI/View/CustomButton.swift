//
//  CustomButton.swift
//  MobilabPaymentCore
//
//  Created by Robert on 02.08.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import UIKit

class CustomButton: UIButton {
    private static let defaultBorderColor = UIConstants.lightBlueGrey
    private static let defaultErrorBorderColor = UIConstants.coral
    private static let defaultPlaceholderColor = UIConstants.coolGrey
    private static let defaultBackgroundColor = UIColor.white

    private let textInsetX: CGFloat = 16
    private let rightViewInset: CGPoint = CGPoint(x: 14, y: 16)
    private let rightViewWidth: CGFloat = 9

    private var rightImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIConstants.solidArrowImage
        return view
    }()

    private var borderColor = CustomButton.defaultBorderColor {
        didSet {
            self.layer.borderColor = self.borderColor.cgColor
        }
    }

    private var errorBorderColor = CustomButton.defaultErrorBorderColor

    private var placeholderColor: UIColor = CustomButton.defaultPlaceholderColor

    private var textColor: UIColor?

    func set(hasInvalidData: Bool) {
        self.borderColor = hasInvalidData ? self.errorBorderColor : self.borderColor
    }

    func setText(text: String?, placeholder: String?) {
        if text == nil {
            self.setTitleColor(self.placeholderColor, for: .normal)
        } else {
            self.setTitleColor(self.textColor, for: .normal)
        }

        self.setTitle(text ?? placeholder, for: .normal)
    }

    func setup(borderColor: UIColor?,
               placeholderColor: UIColor?,
               textColor: UIColor?,
               backgroundColor: UIColor?,
               errorBorderColor: UIColor?,
               shouldShowArrow: Bool) {
        self.borderColor = borderColor ?? CustomButton.defaultBorderColor
        self.placeholderColor = placeholderColor ?? CustomButton.defaultPlaceholderColor
        self.textColor = textColor
        self.backgroundColor = backgroundColor ?? CustomButton.defaultBackgroundColor
        self.errorBorderColor = errorBorderColor ?? CustomButton.defaultErrorBorderColor
        self.rightImageView.isHidden = !shouldShowArrow
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sharedInit()
    }

    private func sharedInit() {
        self.layer.cornerRadius = 8
        self.layer.borderWidth = 1
        self.layer.borderColor = self.borderColor.cgColor
        self.backgroundColor = .white
        self.titleLabel?.font = UIConstants.defaultFont(of: 14)
        self.contentHorizontalAlignment = .left
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: self.textInsetX, bottom: 0, right: 0)

        self.addSubview(self.rightImageView)
        self.rightImageView.translatesAutoresizingMaskIntoConstraints = false
        self.rightImageView.anchor(top: self.topAnchor,
                                   bottom: self.bottomAnchor,
                                   trailing: self.trailingAnchor,
                                   paddingTop: self.rightViewInset.y,
                                   paddingBottom: self.rightViewInset.y,
                                   paddingRight: self.rightViewInset.x,
                                   width: self.rightViewWidth)
    }
}
