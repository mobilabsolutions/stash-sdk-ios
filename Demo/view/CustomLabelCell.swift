//
//  CustomLabelCell.swift
//  Demo
//
//  Created by Rupali Ghate on 13.05.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentCore
import UIKit

class CustomLabelCell: UICollectionViewCell {
    // MARK- Properties

    private var configuration: PaymentMethodUIConfiguration? {
        didSet {
            self.updateStyling()
        }
    }

    private let cellInternalOffset: CGFloat = 8
    private let titleHeight: CGFloat = 22

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIConstants.defaultFont(of: 16, type: .medium)
        label.textColor = UIConstants.aquamarine
        label.text = "Credit Card"

        return label
    }()

    // MARK- Public methods

    func setup(title: String?, configuration: PaymentMethodUIConfiguration?) {
        self.titleLabel.text = title

        if let configuration = configuration {
            self.configuration = configuration
        }
    }

    // MARK- Initialzers

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }

    // MARK: - Handlers

    @objc private func handleDelete() {}

    // MARK- Helpers

    private func setupViews() {
        backgroundColor = .clear
        self.layer.borderColor = UIConstants.aquamarine.cgColor
        self.layer.borderWidth = 1

        addSubview(self.titleLabel)

        self.titleLabel.anchor(centerX: centerXAnchor, centerY: centerYAnchor,
                               height: 22)
    }

    private func updateStyling() {
        self.titleLabel.textColor = self.configuration?.textColor ?? self.titleLabel.textColor
        backgroundColor = self.configuration?.cellBackgroundColor ?? self.contentView.backgroundColor
        self.layer.borderColor = self.configuration?.textColor.cgColor ?? self.titleLabel.textColor.cgColor
    }
}
