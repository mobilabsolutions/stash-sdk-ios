//
//  CustomIconLabelCell.swift
//  Demo
//
//  Created by Rupali Ghate on 13.05.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import StashCore
import UIKit

class CustomIconLabelCell: BaseCell {
    // MARK- Properties

    private let cellInternalOffset: CGFloat = 16
    private let titleHeight: CGFloat = 22
    private let iconDimensions: (width: CGFloat, height: CGFloat) = (24, 24)

    private var configuration: PaymentMethodUIConfiguration? {
        didSet {
            self.updateStyling()
        }
    }

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit

        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIConstants.defaultFont(of: 16, type: .medium)
        label.textColor = UIConstants.aquamarine
        label.text = ""

        return label
    }()

    // MARK- Public methods

    func setup(title: String?, iconImage: UIImage?, configuration: PaymentMethodUIConfiguration?) {
        self.titleLabel.text = title

        if let iconImage = iconImage {
            self.iconImageView.image = iconImage
        }

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

    // MARK- Helpers

    private func setupViews() {
        addSubview(self.iconImageView)
        self.iconImageView.anchor(leading: leadingAnchor, centerY: centerYAnchor,
                                  paddingLeft: self.cellInternalOffset,
                                  width: self.iconDimensions.width, height: self.iconDimensions.height)

        addSubview(self.titleLabel)
        self.titleLabel.anchor(leading: self.iconImageView.trailingAnchor, centerY: centerYAnchor,
                               paddingLeft: self.cellInternalOffset,
                               height: self.titleHeight)
    }

    private func updateStyling() {
        self.backgroundColor = self.configuration?.cellBackgroundColor ?? self.contentView.backgroundColor
        self.titleLabel.textColor = self.configuration?.textColor ?? self.titleLabel.textColor
    }
}
