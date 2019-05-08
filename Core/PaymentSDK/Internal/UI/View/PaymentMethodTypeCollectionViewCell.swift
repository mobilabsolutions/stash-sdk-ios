//
//  PaymentMethodTypeCollectionViewCell.swift
//  MobilabPaymentCore
//
//  Created by Robert on 14.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import UIKit

class PaymentMethodTypeCollectionViewCell: UICollectionViewCell {
    var paymentMethodType: PaymentMethodType? {
        didSet {
            self.updateViews()
        }
    }

    var configuration: PaymentMethodUIConfiguration? {
        didSet {
            self.updateStyling()
        }
    }

    private let nameLabel = UILabel()
    private let methodImageView = UIImageView()
    private let arrowImageView = UIImageView()

    private let verticalOffset: CGFloat = 10
    private let horizontalOffset: CGFloat = 8
    private let methodImageViewVerticalOffset: CGFloat = 4
    private let methodImageViewHorizontalOffset: CGFloat = 8
    private let methodImageViewWidth: CGFloat = 42
    private let arrowImageViewWidth: CGFloat = 24

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sharedInit()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.nameLabel.text = nil
        self.methodImageView.image = nil
    }

    private func sharedInit() {
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        self.methodImageView.translatesAutoresizingMaskIntoConstraints = false

        let methodImageViewContainer = UIView()
        methodImageViewContainer.layer.cornerRadius = 2

        methodImageViewContainer.translatesAutoresizingMaskIntoConstraints = false

        methodImageViewContainer.addSubview(self.methodImageView)

        self.contentView.addSubview(self.nameLabel)
        self.contentView.addSubview(self.arrowImageView)
        self.contentView.addSubview(methodImageViewContainer)

        NSLayoutConstraint.activate([
            methodImageView.topAnchor.constraint(equalTo: methodImageViewContainer.topAnchor, constant: methodImageViewVerticalOffset),
            methodImageView.bottomAnchor.constraint(equalTo: methodImageViewContainer.bottomAnchor, constant: -methodImageViewVerticalOffset),
            methodImageView.leadingAnchor.constraint(equalTo: methodImageViewContainer.leadingAnchor, constant: methodImageViewHorizontalOffset),
            methodImageView.trailingAnchor.constraint(equalTo: methodImageViewContainer.trailingAnchor, constant: -methodImageViewHorizontalOffset),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: verticalOffset),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -verticalOffset),
            nameLabel.leadingAnchor.constraint(equalTo: methodImageViewContainer.trailingAnchor, constant: horizontalOffset),
            nameLabel.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -horizontalOffset),
            methodImageViewContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalOffset),
            methodImageViewContainer.topAnchor.constraint(equalTo: nameLabel.topAnchor),
            methodImageViewContainer.bottomAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            methodImageViewContainer.widthAnchor.constraint(equalToConstant: methodImageViewWidth),
            arrowImageView.topAnchor.constraint(equalTo: methodImageViewContainer.topAnchor),
            arrowImageView.bottomAnchor.constraint(equalTo: methodImageViewContainer.bottomAnchor),
            arrowImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2 * horizontalOffset),
            arrowImageView.widthAnchor.constraint(equalToConstant: arrowImageViewWidth),
        ])

        self.contentView.backgroundColor = .white
        self.arrowImageView.image = UIConstants.rightArrowImage
        self.arrowImageView.contentMode = .scaleAspectFit
        self.methodImageView.contentMode = .scaleAspectFill

        methodImageViewContainer.backgroundColor = UIConstants.veryLightPink

        self.layer.cornerRadius = 4
        self.layer.masksToBounds = true

        self.nameLabel.font = UIConstants.defaultFont(of: 12, type: .medium)
    }

    private func updateStyling() {
        self.nameLabel.textColor = self.configuration?.textColor ?? self.nameLabel.textColor
        self.contentView.backgroundColor = self.configuration?.cellBackgroundColor ?? self.contentView.backgroundColor
    }

    private func updateViews() {
        if let paymentMethodType = self.paymentMethodType {
            switch paymentMethodType {
            case .creditCard:
                self.nameLabel.text = "Credit Card"
                self.methodImageView.image = UIConstants.creditCardImage
            case .sepa:
                self.nameLabel.text = "SEPA"
                self.methodImageView.image = UIConstants.sepaImage
            case .payPal:
                self.nameLabel.text = "PayPal"
                self.methodImageView.image = UIConstants.paypalImage
            }
        }
    }
}
