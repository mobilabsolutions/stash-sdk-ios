//
//  PaymentMethodCell.swift
//  Demo
//
//  Created by Rupali Ghate on 13.05.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import MobilabPaymentCore
import UIKit

// MARK- Protocol

protocol PaymentMethodCellDelegate: class {
    func didSelectOption(selectionEnabled: Bool, for cell: PaymentMethodCell)
}

class PaymentMethodCell: BaseCell {
    // MARK- Properties

    weak var delegate: PaymentMethodCellDelegate?

    private let cellInternalOffsetLeft: CGFloat = 24
    private let cellInternalOffsetRight: CGFloat = 16
    private let iconDimensions: (width: CGFloat, height: CGFloat) = (48, 33)
    private let buttonDimensions: (width: CGFloat, height: CGFloat) = (24, 24)
    private let titleHeight: CGFloat = 22
    private let subTitleHeight: CGFloat = 16
    private let labelVerticalPadding: CGFloat = 24

    private var configuration: PaymentMethodUIConfiguration? {
        didSet {
            self.updateStyling()
        }
    }

    private var shouldShowSelection = false {
        didSet {
            if self.shouldShowSelection {
                self.button.setImage(UIConstants.unSelectedImage, for: .normal)
            } else {
                self.button.setImage(UIConstants.deleteImage, for: .normal)
            }
        }
    }

    private let cellImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIConstants.creditCardImage
        iv.contentMode = .scaleAspectFit

        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIConstants.defaultFont(of: 16, type: .medium)
        label.textColor = UIConstants.dark
        label.text = ""

        return label
    }()

    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIConstants.defaultFont(of: 12, type: .medium)
        label.textColor = UIConstants.coolGrey
        label.text = ""
        return label
    }()

    private lazy var button: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(handleButtonAction), for: .touchUpInside)

        return button
    }()

    // MARK- Public methods

    func setup(image: UIImage?, title: String?, subTitle: String?, shouldShowSelection: Bool, configuration: PaymentMethodUIConfiguration?) {
        self.cellImageView.image = image
        self.titleLabel.text = title
        self.subTitleLabel.text = subTitle
        self.shouldShowSelection = shouldShowSelection

        if let configuration = configuration {
            self.configuration = configuration
        }
    }

    func setSelection() {
        self.button.setImage(UIConstants.selectedImage, for: .normal)
    }

    func resetSelection() {
        self.button.setImage(UIConstants.unSelectedImage, for: .normal)
    }

    // MARK- Initialzers

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupViews()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Handlers

    @objc private func handleButtonAction() {
        self.delegate?.didSelectOption(selectionEnabled: self.shouldShowSelection, for: self)
    }

    // MARK- Helpers

    private func setupViews() {
        addSubview(self.cellImageView)
        self.cellImageView.anchor(leading: leadingAnchor,
                                  centerY: self.centerYAnchor,
                                  paddingLeft: self.cellInternalOffsetLeft,
                                  width: self.iconDimensions.width, height: self.iconDimensions.height)

        addSubview(self.titleLabel)
        self.titleLabel.anchor(top: topAnchor, leading: self.cellImageView.trailingAnchor, trailing: trailingAnchor,
                               paddingTop: self.labelVerticalPadding, paddingLeft: self.cellInternalOffsetLeft, paddingRight: self.cellInternalOffsetRight,
                               height: self.titleHeight)

        addSubview(self.subTitleLabel)
        self.subTitleLabel.anchor(leading: self.cellImageView.trailingAnchor, bottom: bottomAnchor, trailing: trailingAnchor,
                                  paddingLeft: self.cellInternalOffsetLeft, paddingBottom: self.labelVerticalPadding, paddingRight: self.cellInternalOffsetRight,
                                  height: self.subTitleHeight)

        addSubview(self.button)
        self.button.anchor(trailing: trailingAnchor,
                           centerY: self.centerYAnchor,
                           paddingRight: self.cellInternalOffsetRight,
                           width: self.buttonDimensions.width, height: self.buttonDimensions.height)
    }

    private func updateStyling() {
        backgroundColor = self.configuration?.cellBackgroundColor ?? self.contentView.backgroundColor
        self.titleLabel.textColor = self.configuration?.textColor ?? self.titleLabel.textColor
        self.subTitleLabel.textColor = self.configuration?.textColor ?? self.subTitleLabel.textColor
    }
}
