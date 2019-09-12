//
//  PaymentMethodTypeCollectionViewCell.swift
//  StashCore
//
//  Created by Robert on 14.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
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
    private let horizontalOffset: CGFloat = 16
    private let methodImageViewVerticalOffset: CGFloat = 4
    private let methodImageViewHorizontalOffset: CGFloat = 8
    private let methodImageViewWidth: CGFloat = 48
    private let methodImageViewHeight: CGFloat = 32
    private let methodImageContainerViewWidth: CGFloat = 48
    private let methodImageContainerViewHeight: CGFloat = 32
    private let arrowImageViewWidth: CGFloat = 16
    private let shadowRadius: CGFloat = 3
    private let shadowOpacity: Float = 0.12

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
            methodImageView.centerYAnchor.constraint(equalTo: methodImageViewContainer.centerYAnchor),
            methodImageView.centerXAnchor.constraint(equalTo: methodImageViewContainer.centerXAnchor),
            methodImageView.widthAnchor.constraint(equalToConstant: methodImageViewWidth),
            methodImageView.heightAnchor.constraint(equalToConstant: methodImageViewHeight),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: verticalOffset),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -verticalOffset),
            nameLabel.leadingAnchor.constraint(equalTo: methodImageViewContainer.trailingAnchor, constant: horizontalOffset),
            nameLabel.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -horizontalOffset),
            methodImageViewContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalOffset),
            methodImageViewContainer.topAnchor.constraint(equalTo: nameLabel.topAnchor),
            methodImageViewContainer.bottomAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            methodImageViewContainer.widthAnchor.constraint(equalToConstant: methodImageContainerViewWidth),
            methodImageViewContainer.heightAnchor.constraint(equalToConstant: methodImageContainerViewHeight),
            arrowImageView.topAnchor.constraint(equalTo: methodImageViewContainer.topAnchor),
            arrowImageView.bottomAnchor.constraint(equalTo: methodImageViewContainer.bottomAnchor),
            arrowImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalOffset),
            arrowImageView.widthAnchor.constraint(equalToConstant: arrowImageViewWidth),
        ])

        self.contentView.backgroundColor = .white
        self.arrowImageView.image = UIConstants.detailsArrowImage?.withRenderingMode(.alwaysTemplate)
        self.arrowImageView.tintColor = UIConstants.clearBlue

        self.arrowImageView.contentMode = .scaleAspectFit
        self.methodImageView.contentMode = .scaleAspectFit

        methodImageViewContainer.backgroundColor = .clear

        self.contentView.layer.cornerRadius = 10
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowRadius = self.shadowRadius
        self.layer.shadowColor = self.configuration?.paymentMethodSelectionNameColor.cgColor
            ?? self.nameLabel.textColor.cgColor
        self.layer.shadowOpacity = self.shadowOpacity
        self.contentView.layer.masksToBounds = true
        self.nameLabel.font = UIConstants.defaultFont(of: 18, type: .heavy)
    }

    private func updateStyling() {
        self.nameLabel.textColor = self.configuration?.paymentMethodSelectionNameColor ?? self.nameLabel.textColor
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
                self.methodImageView.image = UIConstants.sepaWithBackgroundImage
            case .payPal:
                self.nameLabel.text = "PayPal"
                self.methodImageView.image = UIConstants.payPalWithBackgroundImage
            }
        }
    }
}
