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

    private let nameLabel = UILabel()
    private let verticalOffset: CGFloat = 5
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
    }

    private func sharedInit() {
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.nameLabel)

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: verticalOffset),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -verticalOffset),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalOffset),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalOffset),
        ])

        self.contentView.backgroundColor = .white
    }

    private func updateViews() {
        if let paymentMethodType = self.paymentMethodType {
            switch paymentMethodType {
            case .creditCard: self.nameLabel.text = "Credit Card"
            case .sepa: self.nameLabel.text = "SEPA"
            }
        }
    }
}
