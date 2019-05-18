//
//  AlertBanner.swift
//  MobilabPaymentCore
//
//  Created by Robert on 17.05.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import UIKit

class AlertBanner: UIView {
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIConstants.alertImage
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    var title: String? {
        get {
            return self.titleLabel.text
        }

        set {
            self.titleLabel.text = newValue
        }
    }

    var subtitle: String? {
        get {
            return self.subtitleLabel.text
        }

        set {
            self.subtitleLabel.text = newValue
        }
    }

    private let configuration: PaymentMethodUIConfiguration

    init(title: String, subtitle: String, configuration: PaymentMethodUIConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        self.sharedInit()
        self.titleLabel.text = title
        self.subtitleLabel.text = subtitle
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func sharedInit() {
        self.backgroundColor = self.configuration.errorMessageColor

        self.titleLabel.font = UIConstants.defaultFont(of: 14, type: .black)
        self.subtitleLabel.font = UIConstants.defaultFont(of: 12, type: .medium)

        self.titleLabel.textColor = self.configuration.errorMessageTextColor
        self.subtitleLabel.textColor = self.configuration.errorMessageTextColor

        self.titleLabel.numberOfLines = 0
        self.subtitleLabel.numberOfLines = 0

        self.addSubviews()
    }

    private func addSubviews() {
        self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(self.iconImageView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.subtitleLabel)

        NSLayoutConstraint.activate([
            self.iconImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.iconImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
            self.iconImageView.heightAnchor.constraint(equalToConstant: 24),
            self.iconImageView.widthAnchor.constraint(equalTo: self.iconImageView.heightAnchor),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.iconImageView.trailingAnchor, constant: 16),
            self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),

            self.subtitleLabel.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            self.subtitleLabel.trailingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor),
            self.subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 1),
        ])
    }
}
