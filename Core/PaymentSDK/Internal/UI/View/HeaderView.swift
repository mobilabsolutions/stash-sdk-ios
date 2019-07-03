//
//  HeaderView.swift
//  MobilabPaymentCore
//
//  Created by Rupali Ghate on 03.05.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import UIKit

class HeaderView: UICollectionReusableView {
    private static let defaultTextColor = UIConstants.coolGrey

    var title: String? {
        didSet {
            self.label.text = self.title
        }
    }

    var configuration: PaymentMethodUIConfiguration? {
        didSet {
            self.label.textColor = self.configuration?.mediumEmphasisColor ?? HeaderView.defaultTextColor
            self.backgroundColor = self.configuration?.backgroundColor
        }
    }

    let label: SubtitleLabel = {
        let label = SubtitleLabel()
        label.font = UIConstants.defaultFont(of: 16, type: .medium)
        label.textColor = UIConstants.coolGrey
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    private let horizontalToSuperViewOffset: CGFloat = 18
    private let verticalToSuperViewOffset: CGFloat = 8

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sharedInit()
    }

    func sharedInit() {
        self.addSubview(self.label)

        NSLayoutConstraint.activate([
            self.label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: horizontalToSuperViewOffset),
            self.label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -horizontalToSuperViewOffset),
            self.label.topAnchor.constraint(equalTo: self.topAnchor, constant: verticalToSuperViewOffset),
            self.label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -verticalToSuperViewOffset),
        ])
    }
}
