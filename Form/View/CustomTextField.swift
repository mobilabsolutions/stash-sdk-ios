//
//  CustomTextField.swift
//  StashBSPayone
//
//  Created by Robert on 21.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {
    private static let defaultBorderColor = UIConstants.lightBlueGrey
    private static let defaultErrorBorderColor = UIConstants.coral
    private static let defaultPlaceholderColor = UIConstants.coolGrey
    private static let defaultBackgroundColor = UIColor.white

    private let textInsetX: CGFloat = 16
    private let rightViewInset: CGPoint = CGPoint(x: 8, y: 10)
    private let rightViewWidth: CGFloat = 40

    private var borderColor = CustomTextField.defaultBorderColor {
        didSet {
            self.layer.borderColor = self.borderColor.cgColor
        }
    }

    private var errorBorderColor = CustomTextField.defaultErrorBorderColor
    private var providedBorderColor = CustomTextField.defaultBorderColor

    private var placeholderColor: UIColor? = CustomTextField.defaultPlaceholderColor {
        didSet {
            self.updateAttributedPlaceholder(placeholder: self.placeholder)
        }
    }

    override var placeholder: String? {
        get {
            return self.attributedPlaceholder?.string
        }

        set {
            self.updateAttributedPlaceholder(placeholder: newValue)
        }
    }

    func set(hasInvalidData: Bool) {
        self.borderColor = hasInvalidData ? self.errorBorderColor : self.providedBorderColor
    }

    func setup(borderColor: UIColor?, placeholderColor: UIColor?, textColor: UIColor?, backgroundColor: UIColor?, errorBorderColor: UIColor?) {
        self.providedBorderColor = borderColor ?? CustomTextField.defaultBorderColor
        self.borderColor = self.providedBorderColor
        self.placeholderColor = placeholderColor ?? CustomTextField.defaultPlaceholderColor
        self.textColor = textColor
        self.backgroundColor = backgroundColor ?? CustomTextField.defaultBackgroundColor
        self.errorBorderColor = errorBorderColor ?? CustomTextField.defaultErrorBorderColor
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sharedInit()
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return CGRect(x: rect.minX + self.textInsetX, y: rect.minY, width: rect.width - self.textInsetX, height: rect.height)
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return self.editingRect(forBounds: bounds)
    }

    private func sharedInit() {
        self.layer.cornerRadius = 8
        self.layer.borderWidth = 1
        self.layer.borderColor = self.borderColor.cgColor
        self.backgroundColor = .white
        self.font = UIConstants.defaultFont(of: 14)
    }

    private func updateAttributedPlaceholder(placeholder: String?) {
        self.attributedPlaceholder = placeholder.flatMap {
            NSAttributedString(string: $0, attributes: [.foregroundColor: placeholderColor ?? CustomTextField.defaultPlaceholderColor])
        }
    }

    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.maxX - self.rightViewInset.x - self.rightViewWidth,
                      y: self.rightViewInset.y, width: self.rightViewWidth, height: bounds.height - 2 * self.rightViewInset.y)
    }
}
