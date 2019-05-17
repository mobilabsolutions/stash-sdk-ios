//
//  AliasCollectionViewCell.swift
//  Demo
//
//  Created by Robert on 11.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import UIKit

class AliasCollectionViewCell: UICollectionViewCell {
    @IBOutlet private var aliasLabel: UILabel!
    @IBOutlet private var typeLabel: UILabel!
    @IBOutlet private var expiryLabel: UILabel!

    func setup(for alias: Alias) {
        self.aliasLabel.text = alias.alias

        let typeLabelText: String

        switch alias.type {
        case .creditCard:
            typeLabelText = "CC"
        case .sepa:
            typeLabelText = "SEPA"
        case .payPal:
            typeLabelText = "PayPal"
        case .unknown:
            typeLabelText = "Unknown"
        }

        if let humanReadable = alias.humanReadableId {
            self.typeLabel.text = typeLabelText + " (\(humanReadable))"
        } else {
            self.typeLabel.text = typeLabelText
        }

        if let month = alias.expirationMonth, let year = alias.expirationYear {
            self.expiryLabel.text = "\(month)/\(year)"
        } else {
            self.expiryLabel.text = ""
        }
    }
}
