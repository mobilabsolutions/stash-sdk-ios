//
//  Extensions.swift
//  Demo
//
//  Created by Rupali Ghate on 20.05.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentCore
import UIKit

extension NSDecimalNumber {
    func toCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "€"
        return formatter.string(for: self) ?? ""
    }
}

extension UICollectionView {
    func reloadAsync() {
        DispatchQueue.main.async {
            self.reloadData()
        }
    }
}
