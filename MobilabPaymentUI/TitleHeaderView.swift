//
//  TitleHeaderView.swift
//  MobilabPaymentUI
//
//  Created by Robert on 21.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import UIKit

public class TitleHeaderView: UICollectionReusableView {
    private static let defaultTextColor = UIConstants.dark

    public var title: String? {
        didSet {
            self.label.text = self.title
        }
    }

    public var configuration: PaymentMethodUIConfiguration? {
        didSet {
            self.label.textColor = self.configuration?.textColor ?? TitleHeaderView.defaultTextColor
        }
    }

    private let label = SubtitleLabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sharedInit()
    }

    private func sharedInit() {
        self.label.font = UIConstants.defaultFont(of: 24, type: .black)
        self.label.textColor = UIConstants.dark
        self.label.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(self.label)

        NSLayoutConstraint.activate([
            self.label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 18),
            self.label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -18),
            self.label.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            self.label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16),
        ])
    }
}
