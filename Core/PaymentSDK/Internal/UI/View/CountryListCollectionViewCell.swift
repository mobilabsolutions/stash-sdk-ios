//
//  CountryListCollectionViewCell.swift
//  MobilabPaymentCore
//
//  Created by Rupali Ghate on 02.05.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import UIKit

class CountryListCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties

    var countryName: String? {
        didSet {
            self.nameLabel.text = self.countryName
        }
    }

    var configuration: PaymentMethodUIConfiguration? {
        didSet {
            self.updateStyling()
        }
    }

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIConstants.defaultFont(of: 14, type: .medium)
        label.textAlignment = .left

        return label
    }()

    private let verticalOffset: CGFloat = 10
    private let horizontalOffset: CGFloat = 16

    // MARK: - Initializers

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

    // MARK: - Helpers

    private func sharedInit() {
        self.contentView.addSubview(self.nameLabel)

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: verticalOffset),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -verticalOffset),
            nameLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: horizontalOffset),
            nameLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -horizontalOffset),
        ])
    }

    private func updateStyling() {
        self.nameLabel.textColor = self.configuration?.textColor ?? self.nameLabel.textColor
        self.contentView.backgroundColor = self.configuration?.cellBackgroundColor ?? self.contentView.backgroundColor
    }
}
