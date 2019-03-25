//
//  CustomTextField.swift
//  MobilabPaymentBSPayone
//
//  Created by Robert on 21.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import UIKit

public class CustomTextField: UITextField {
    private static let defaultBorderColor = UIConstants.lightBlueGrey
    private static let errorBorderColor = UIConstants.coral

    private let textInsetX: CGFloat = 16

    private var borderColor = CustomTextField.defaultBorderColor {
        didSet {
            self.layer.borderColor = self.borderColor.cgColor
        }
    }

    public override var placeholder: String? {
        get {
            return self.attributedPlaceholder?.string
        }

        set {
            self.attributedPlaceholder = newValue.flatMap { NSAttributedString(string: $0, attributes: [.foregroundColor: UIConstants.coolGrey]) }
        }
    }

    public func set(hasInvalidData: Bool) {
        self.borderColor = hasInvalidData ? CustomTextField.errorBorderColor : CustomTextField.defaultBorderColor
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sharedInit()
    }

    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return CGRect(x: rect.minX + self.textInsetX, y: rect.minY, width: rect.width - self.textInsetX, height: rect.height)
    }

    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        return self.editingRect(forBounds: bounds)
    }

    private func sharedInit() {
        self.layer.cornerRadius = 8
        self.layer.borderWidth = 1
        self.layer.borderColor = self.borderColor.cgColor
        self.backgroundColor = .white
        self.font = UIConstants.defaultFont(of: 14)
    }
}
