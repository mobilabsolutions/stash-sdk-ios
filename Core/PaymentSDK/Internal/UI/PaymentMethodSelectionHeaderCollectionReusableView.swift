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
    private static let titleFontSize: CGFloat = 24
    private static let subtitleFontSize: CGFloat = 14
    private let subtitleLabelBottomOffset: CGFloat = 37
    private let subtitleLabelHorizontalOffset: CGFloat = 16
    private let titleSubtitleVerticalDistance: CGFloat = 6

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIConstants.defaultFont(of: PaymentMethodSelectionHeaderCollectionReusableView.titleFontSize, type: .black)
        label.textColor = UIConstants.dark
        label.text = "Payment method"
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIConstants.defaultFont(of: PaymentMethodSelectionHeaderCollectionReusableView.subtitleFontSize, type: .medium)
        label.textColor = UIConstants.coolGrey
        label.text = "Please choose a payment method"
        return label
    }()

    var configuration: PaymentMethodUIConfiguration? {
        didSet {
            self.titleLabel.textColor = configuration?.textColor ?? self.titleLabel.textColor
            self.subtitleLabel.textColor = configuration?.mediumEmphasisColor ?? self.subtitleLabel.textColor
        }
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
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(self.titleLabel)
        addSubview(self.subtitleLabel)

        NSLayoutConstraint.activate([
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -subtitleLabelBottomOffset),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: subtitleLabelHorizontalOffset),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -subtitleLabelHorizontalOffset),
            titleLabel.leadingAnchor.constraint(equalTo: subtitleLabel.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: subtitleLabel.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor, constant: -titleSubtitleVerticalDistance),
        ])
    }
}
