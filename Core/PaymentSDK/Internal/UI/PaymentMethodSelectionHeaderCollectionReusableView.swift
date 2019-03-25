//
//  PaymentMethodSelectionHeaderCollectionReusableView.swift
//  MobilabPaymentCore
//
//  Created by Robert on 21.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentUI
import UIKit

class PaymentMethodSelectionHeaderCollectionReusableView: UICollectionReusableView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIConstants.defaultFont(of: 24, type: .black)
        label.textColor = UIConstants.dark
        label.text = "Payment method"
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIConstants.defaultFont(of: 14, type: .medium)
        label.textColor = UIConstants.coolGrey
        label.text = "Please choose a payment method"
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sharedInit()
    }

    private func sharedInit() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(self.titleLabel)
        addSubview(self.subtitleLabel)

        NSLayoutConstraint.activate([
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -37),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.leadingAnchor.constraint(equalTo: subtitleLabel.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: subtitleLabel.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor, constant: -6),
        ])
    }
}
