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

        switch alias.type {
        case .creditCard:
            self.typeLabel.text = "CC"
        case .sepa:
            self.typeLabel.text = "SEPA"
        case .unknown:
            self.typeLabel.text = "Unknown"
        }

        if let month = alias.expirationMonth, let year = alias.expirationYear {
            self.expiryLabel.text = "\(month)/\(year)"
        } else {
            self.expiryLabel.text = ""
        }
    }
}
