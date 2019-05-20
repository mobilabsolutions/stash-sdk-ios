//
//  PaymentMethodCell.swift
//  Demo
//
//  Created by Rupali Ghate on 13.05.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentCore
import UIKit

// MARK- Protocol

protocol PaymentMethodCellDelegate: class {
    func didSelectDeleteOption(from cell: UICollectionViewCell)
}

class PaymentMethodCell: UICollectionViewCell {
    // MARK- Properties

    var delegate: PaymentMethodCellDelegate?

    private let cellInternalOffsetLeft: CGFloat = 8
    private let cellInternalOffsetRight: CGFloat = 16
    private let iconDimentions: (width: CGFloat, height: CGFloat) = (46, 30)
    private let deleteButtonDimentions: (width: CGFloat, height: CGFloat) = (24, 24)
    private let titleHeight: CGFloat = 22
    private let subTitleHeight: CGFloat = 16
    private let labelVerticalPadding: CGFloat = 24
    private let labelHorizontalPadding: CGFloat = 70

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

    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIConstants.deleteImage, for: .normal)
        button.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)

        return button
    }()

    // MARK- Public methods

    func setup(image: UIImage?, title: String?, subTitle: String?) {
        self.cellImageView.image = image
        self.titleLabel.text = title
        self.subTitleLabel.text = subTitle
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

    @objc private func handleDelete() {
        self.delegate?.didSelectDeleteOption(from: self)
    }

    // MARK- Helpers

    private func setupViews() {
        backgroundColor = .white

        addSubview(self.cellImageView)
        self.cellImageView.anchor(left: leftAnchor,
                                  centerY: self.centerYAnchor,
                                  paddingLeft: self.cellInternalOffsetLeft,
                                  width: self.iconDimentions.width, height: self.iconDimentions.height)

        addSubview(self.titleLabel)
        self.titleLabel.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor,
                               paddingTop: self.labelVerticalPadding, paddingLeft: self.labelHorizontalPadding, paddingRight: self.cellInternalOffsetRight,
                               height: self.titleHeight)

        addSubview(self.subTitleLabel)
        self.subTitleLabel.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor,
                                  paddingLeft: self.labelHorizontalPadding, paddingBottom: self.labelVerticalPadding, paddingRight: self.cellInternalOffsetRight,
                                  height: self.subTitleHeight)

        addSubview(self.deleteButton)
        self.deleteButton.anchor(right: rightAnchor,
                                 centerY: self.centerYAnchor,
                                 paddingRight: self.cellInternalOffsetRight,
                                 width: self.deleteButtonDimentions.width, height: self.deleteButtonDimentions.height)
    }
}
