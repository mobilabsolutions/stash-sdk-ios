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
    private let closeButton = UIButton()
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
    private weak var delegate: AlertBannerDelegate?

    init(title: String, subtitle: String, configuration: PaymentMethodUIConfiguration, delegate: AlertBannerDelegate) {
        self.configuration = configuration
        super.init(frame: .zero)
        self.sharedInit()
        self.titleLabel.text = title
        self.subtitleLabel.text = subtitle
        self.delegate = delegate
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

        self.closeButton.setImage(UIConstants.crossImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.closeButton.tintColor = self.configuration.errorMessageTextColor
        self.closeButton.addTarget(self, action: #selector(self.close), for: .touchUpInside)

        self.addSubviews()
    }

    private func addSubviews() {
        self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.closeButton.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(self.iconImageView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.subtitleLabel)
        self.addSubview(self.closeButton)

        NSLayoutConstraint.activate([
            self.iconImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.iconImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
            self.iconImageView.heightAnchor.constraint(equalToConstant: 24),
            self.iconImageView.widthAnchor.constraint(equalTo: self.iconImageView.heightAnchor),

            self.closeButton.topAnchor.constraint(equalTo: self.iconImageView.topAnchor),
            self.closeButton.heightAnchor.constraint(equalTo: self.iconImageView.heightAnchor),
            self.closeButton.widthAnchor.constraint(equalTo: self.iconImageView.widthAnchor),
            self.closeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.iconImageView.trailingAnchor, constant: 16),
            self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.closeButton.trailingAnchor, constant: -15),

            self.subtitleLabel.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            self.subtitleLabel.trailingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor),
            self.subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 1),
            self.subtitleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16),
        ])
    }

    @objc private func close() {
        self.delegate?.close(banner: self)
    }
}

protocol AlertBannerDelegate: class {
    func close(banner: AlertBanner)
}
