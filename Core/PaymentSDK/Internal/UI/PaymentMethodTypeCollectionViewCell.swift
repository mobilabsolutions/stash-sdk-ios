//
//  PaymentMethodTypeCollectionViewCell.swift
//  MobilabPaymentCore
//
//  Created by Robert on 14.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentUI
import UIKit

class PaymentMethodTypeCollectionViewCell: UICollectionViewCell {
    var paymentMethodType: PaymentMethodType? {
        didSet {
            self.updateViews()
        }
    }

    private let nameLabel = UILabel()
    private let methodImageView = UIImageView()
    private let arrowImageView = UIImageView()

    private let verticalOffset: CGFloat = 10
    private let horizontalOffset: CGFloat = 8

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
            methodImageView.topAnchor.constraint(equalTo: methodImageViewContainer.topAnchor, constant: 4),
            methodImageView.bottomAnchor.constraint(equalTo: methodImageViewContainer.bottomAnchor, constant: -4),
            methodImageView.leadingAnchor.constraint(equalTo: methodImageViewContainer.leadingAnchor, constant: 8),
            methodImageView.trailingAnchor.constraint(equalTo: methodImageViewContainer.trailingAnchor, constant: -8),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: verticalOffset),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -verticalOffset),
            nameLabel.leadingAnchor.constraint(equalTo: methodImageViewContainer.trailingAnchor, constant: horizontalOffset),
            nameLabel.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -horizontalOffset),
            methodImageViewContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalOffset),
            methodImageViewContainer.topAnchor.constraint(equalTo: nameLabel.topAnchor),
            methodImageViewContainer.bottomAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            methodImageViewContainer.widthAnchor.constraint(equalToConstant: 42),
            arrowImageView.topAnchor.constraint(equalTo: methodImageViewContainer.topAnchor),
            arrowImageView.bottomAnchor.constraint(equalTo: methodImageViewContainer.bottomAnchor),
            arrowImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2 * horizontalOffset),
            arrowImageView.widthAnchor.constraint(equalToConstant: 24),
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

    private func updateViews() {
        if let paymentMethodType = self.paymentMethodType {
            switch paymentMethodType {
            case .creditCard:
                self.nameLabel.text = "Card"
                self.methodImageView.image = UIConstants.creditCardImage
            case .sepa:
                self.nameLabel.text = "Sepa"
                self.methodImageView.image = UIConstants.sepaImage
            }
        }
    }
}
