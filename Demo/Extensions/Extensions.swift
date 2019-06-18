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

extension UIViewController {
    func showAlert(title: String, message: String, completion: (() -> Void)?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: { _ in
                completion?()

            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension PaymentMethodAlias.ExtraAliasInfo {
    func formatToReadableDetails() -> String {
        let readableDetails: String

        switch self {
        case let .creditCard(details):
            readableDetails = self.formatCardDetails(extra: details)
        case let .sepa(details):
            readableDetails = details.maskedIban
        case let .payPal(details):
            readableDetails = details.email ?? ""
        }
        return readableDetails
    }

    private func formatCardDetails(extra: PaymentMethodAlias.CreditCardExtraInfo) -> String {
        return extra.creditCardMask + " • \(extra.expiryMonth)/\(extra.expiryYear)"
    }
}
