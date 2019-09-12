//
//  PaymentMethodSelectionHeaderCollectionReusableView.swift
//  StashCore
//
//  Created by Robert on 21.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import UIKit

class PaymentMethodSelectionHeaderCollectionReusableView: UICollectionReusableView {
    private static let titleFontSize: CGFloat = 24
    private static let subtitleFontSize: CGFloat = 14
    private let subtitleLabelBottomOffset: CGFloat = 46
    private let subtitleLabelHorizontalOffset: CGFloat = 16
    private let titleSubtitleVerticalDistance: CGFloat = 8
    private let bottomInset: CGFloat = 14
    private let subtitleAlpha: CGFloat = 0.79

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIConstants.defaultFont(of: PaymentMethodSelectionHeaderCollectionReusableView.titleFontSize, type: .regular)
        label.textColor = .white
        label.attributedText = NSAttributedString(string: "Payment Method", attributes: [.kern: 1.9])
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIConstants.defaultFont(of: PaymentMethodSelectionHeaderCollectionReusableView.subtitleFontSize, type: .regular)
        label.textColor = .white
        label.text = "Choose a payment method"
        return label
    }()

    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.image = UIConstants.paymentSelectionIllustrationImage
        return imageView
    }()

    var configuration: PaymentMethodUIConfiguration? {
        didSet {
            self.titleLabel.textColor = configuration?.lightTextColor ?? self.titleLabel.textColor
            self.subtitleLabel.textColor = configuration?.lightTextColor.withAlphaComponent(subtitleAlpha) ?? self.subtitleLabel.textColor
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
        self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(self.backgroundImageView)
        addSubview(self.titleLabel)
        addSubview(self.subtitleLabel)

        NSLayoutConstraint.activate([
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -subtitleLabelBottomOffset),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: subtitleLabelHorizontalOffset),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -subtitleLabelHorizontalOffset),
            titleLabel.leadingAnchor.constraint(equalTo: subtitleLabel.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: subtitleLabel.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor, constant: -titleSubtitleVerticalDistance),
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.leftAnchor.constraint(equalTo: leftAnchor),
            backgroundImageView.rightAnchor.constraint(equalTo: rightAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -bottomInset),
        ])
    }
}
