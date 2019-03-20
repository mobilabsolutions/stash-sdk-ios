//
//  CreditCardNumberInputCollectionViewCell.swift
//  MobilabPaymentBSPayone
//
//  Created by Robert on 18.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentCore
import UIKit

class CreditCardNumberInputCollectionViewCell: UICollectionViewCell {
    private var cardNumber: String? {
        didSet {
            self.numberTextField.text = cardNumber
            self.numberTextFieldValueChanged()
        }
    }

    private weak var delegate: DataPointProvidingDelegate?

    private let numberTextField = UITextField()

    func setup(cardNumber: String?, delegate: DataPointProvidingDelegate) {
        self.cardNumber = cardNumber
        self.delegate = delegate
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
        self.numberTextField.addTarget(self, action: #selector(self.numberTextFieldValueChanged), for: .editingChanged)
        self.numberTextField.translatesAutoresizingMaskIntoConstraints = false
        self.numberTextField.keyboardType = .numberPad
        self.numberTextField.placeholder = "Credit Card Number"

        self.numberTextField.textContentType = .creditCardNumber

        self.numberTextField.borderStyle = .roundedRect

        self.contentView.addSubview(self.numberTextField)

        NSLayoutConstraint.activate([
            self.numberTextField.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 8),
            self.numberTextField.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -8),
            self.numberTextField.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
        ])
    }

    @objc private func numberTextFieldValueChanged() {
        if let text = self.numberTextField.text {
            self.numberTextField.attributedText = CreditCardUtils.formattedNumber(number: text)
            self.delegate?.didUpdate(value: text, for: .cardNumber)
        } else {
            self.numberTextField.attributedText = nil
            self.delegate?.didUpdate(value: nil, for: .cardNumber)
        }
    }
}
