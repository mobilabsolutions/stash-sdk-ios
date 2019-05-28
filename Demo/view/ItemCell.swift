//
//  ItemCell.swift
//  Demo
//
//  Created by Rupali Ghate on 20.05.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentCore
import UIKit

// MARK- Protocol

protocol ItemCellDelegate: class {
    func didSelectAddOption(for item: Item)
}

class ItemCell: BaseCell {
    // MARK- Properties

    weak var delegate: ItemCellDelegate?

    var item: Item? {
        didSet {
            guard let item = item else { return }

            if let imageName = item.picture {
                self.itemImageView.image = UIImage(named: imageName)
            }
            self.titleLabel.text = item.title.capitalized
            self.descriptionLabel.text = item.description?.capitalized
            self.priceLabel.text = item.price.toCurrency()
        }
    }

    private var configuration: PaymentMethodUIConfiguration? {
        didSet {
            guard let configuration = configuration else { return }
            self.updateStyling(configuration: configuration)
        }
    }

    private let defaultCellInternalOffset: CGFloat = 8
    private let cellInternalOffsetRight: CGFloat = 16
    private let itemImageDimensions: (width: CGFloat, height: CGFloat) = (81, 88)
    private let deleteButtonDimentions: (width: CGFloat, height: CGFloat) = (24, 24)
    private let titleHeight: CGFloat = 22
    private let subTitleHeight: CGFloat = 16
    private let priceHeight: CGFloat = 22

    private let titleTopPadding: CGFloat = 15
    private let subTitleTopPadding: CGFloat = 36
    private let priceBottomPadding: CGFloat = 16

    lazy var imageContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIConstants.iceBlue
        view.layer.cornerRadius = cornerRadius
        view.layer.masksToBounds = false

        return view
    }()

    private let itemImageView: UIImageView = {
        let iv = UIImageView()
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

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIConstants.defaultFont(of: 12, type: .medium)
        label.textColor = UIConstants.coolGrey
        label.text = ""

        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIConstants.defaultFont(of: 16, type: .medium)
        label.textColor = UIConstants.aquamarine
        label.text = ""

        return label
    }()

    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.setImage(UIConstants.addImage, for: .normal)
        button.addTarget(self, action: #selector(handleAdd), for: .touchUpInside)

        return button
    }()

    // MARK- Initialzers

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupViews()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Handlers

    @objc private func handleAdd() {
        self.delegate?.didSelectAddOption(for: self.item!)
    }

    // MARK- Helpers

    private func setupViews() {
        addSubview(self.imageContainerView)
        self.imageContainerView.anchor(left: leftAnchor,
                                       centerY: self.centerYAnchor,
                                       paddingLeft: self.defaultCellInternalOffset,
                                       width: self.itemImageDimensions.width, height: self.itemImageDimensions.height)

        self.imageContainerView.addSubview(self.itemImageView)
        self.itemImageView.anchor(top: self.imageContainerView.topAnchor,
                                  left: self.imageContainerView.leftAnchor,
                                  bottom: self.imageContainerView.bottomAnchor,
                                  right: self.imageContainerView.rightAnchor,
                                  centerX: self.imageContainerView.centerXAnchor,
                                  centerY: self.imageContainerView.centerYAnchor)

        addSubview(self.addButton)
        self.addButton.anchor(right: rightAnchor,
                              centerY: self.centerYAnchor,
                              paddingRight: self.cellInternalOffsetRight,
                              width: self.deleteButtonDimentions.width, height: self.deleteButtonDimentions.height)

        addSubview(self.titleLabel)
        self.titleLabel.anchor(top: topAnchor, left: self.imageContainerView.rightAnchor, right: self.addButton.leftAnchor,
                               paddingTop: self.titleTopPadding, paddingLeft: self.defaultCellInternalOffset, paddingRight: self.defaultCellInternalOffset,
                               height: self.titleHeight)

        addSubview(self.descriptionLabel)
        self.descriptionLabel.anchor(top: topAnchor, left: self.imageContainerView.rightAnchor, right: self.addButton.leftAnchor,
                                     paddingTop: self.subTitleTopPadding, paddingLeft: self.defaultCellInternalOffset, paddingRight: self.defaultCellInternalOffset,
                                     height: self.subTitleHeight)

        addSubview(self.priceLabel)
        self.priceLabel.anchor(left: self.imageContainerView.rightAnchor, bottom: bottomAnchor, right: self.addButton.leftAnchor,
                               paddingLeft: self.defaultCellInternalOffset, paddingBottom: self.priceBottomPadding, paddingRight: self.defaultCellInternalOffset,
                               height: self.priceHeight)
    }

    private func updateStyling(configuration _: PaymentMethodUIConfiguration) {
        self.backgroundColor = self.configuration?.cellBackgroundColor ?? self.backgroundColor
        self.titleLabel.textColor = self.configuration?.textColor ?? self.titleLabel.textColor
        self.descriptionLabel.textColor = self.configuration?.textColor ?? self.descriptionLabel.textColor
        self.priceLabel.textColor = self.configuration?.buttonColor ?? self.priceLabel.textColor
        self.imageContainerView.backgroundColor = self.configuration?.backgroundColor ?? self.imageContainerView.backgroundColor
    }
}
