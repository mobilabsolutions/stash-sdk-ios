//
//  AdyenCreditCardInputCollectionViewController.swift
//  MobilabPaymentAdyen
//
//  Created by Robert on 18.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentCore
import UIKit

class AdyenCreditCardInputCollectionViewController: FormCollectionViewController {
    private static let methodTypeImageViewWidth: CGFloat = 30
    private static let methodTypeImageViewHeight: CGFloat = 22

    private enum CreditCardValidationError: ValidationError {
        case noData(explanation: String)
        case creditCardValidationFailed(message: String)
        case noKnownCreditCardProvider

        var description: String {
            switch self {
            case let .noData(explanation): return explanation
            case let .creditCardValidationFailed(message): return message
            case .noKnownCreditCardProvider: return "Unsupported credit card provider"
            }
        }
    }

    private struct CreditCardParsedData {
        let cardNumber: String
        let cvv: String
        let expirationMonth: Int
        let expirationYear: Int

        static func create(cardNumberText: String?,
                           cvvText: String?,
                           expirationMonthText: String?,
                           expirationYearText: String?) -> (CreditCardParsedData?, [NecessaryData: CreditCardValidationError]) {
            var errors: [NecessaryData: CreditCardValidationError] = [:]

            if cardNumberText == nil || cardNumberText?.isEmpty == true {
                errors[.cardNumber] = .noData(explanation: "Please provide your card number")
            }

            if let cvv = cvvText {
                do {
                    try CreditCardUtils.validateCVV(cvv: cvv)
                } catch {
                    errors[.cvv] = .noData(explanation: "Please provide a valid CVV")
                }
            } else {
                errors[.cvv] = .noData(explanation: "Please provide a valid CVV")
            }

            if expirationYearText.flatMap({ Int($0) }).flatMap({ $0 >= 0 }) != true {
                errors[.expirationYear] = .noData(explanation: "Please provide a valid expiration date")
            }

            if expirationMonthText.flatMap({ Int($0) }).flatMap({ $0 >= 0 }) != true {
                errors[.expirationMonth] = .noData(explanation: "Please provide a valid expiration date")
            }

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/yy"
            dateFormatter.calendar = Calendar.current

            if let month = expirationMonthText,
                let year = expirationYearText,
                let date = dateFormatter.date(from: "\(month)/\(year)"),
                let expiration = Calendar.current.date(byAdding: .month, value: 1, to: date),
                // Verify that the credit card is not yet expired. Expiration is generally at the end of the specified month.
                expiration <= Date() {
                errors[.expirationYear] = .noData(explanation: "Please provide an expiration date in the future")
            }

            guard let cardNumber = cardNumberText, let cvv = cvvText,
                let expirationMonth = expirationMonthText.flatMap({ Int($0) }),
                let expirationYear = expirationYearText.flatMap({ Int($0) }),
                errors.isEmpty
            else { return (nil, errors) }

            let parsedData = CreditCardParsedData(cardNumber: cardNumber,
                                                  cvv: cvv,
                                                  expirationMonth: expirationMonth,
                                                  expirationYear: expirationYear)
            return (parsedData, [:])
        }
    }

    init(billingData: BillingData?, configuration: PaymentMethodUIConfiguration) {
        let numberData = FormCellModel.FormCellType.TextData(necessaryData: .cardNumber,
                                                             title: "Credit card number",
                                                             placeholder: "1234",
                                                             setup: { _, textField in
                                                                 textField.rightViewMode = .always
                                                                 textField.textContentType = .creditCardNumber
                                                                 let imageView = UIImageView(frame: CGRect(x: 0,
                                                                                                           y: 0,
                                                                                                           width: AdyenCreditCardInputCollectionViewController.methodTypeImageViewWidth,
                                                                                                           height: AdyenCreditCardInputCollectionViewController.methodTypeImageViewHeight))
                                                                 imageView.contentMode = .scaleAspectFit
                                                                 textField.rightView = imageView
                                                             },
                                                             didUpdate: { _, textField in
                                                                 let imageView = textField.rightView as? UIImageView

                                                                 let possibleCardType = CreditCardUtils.cardTypeFromNumber(number: textField.text ?? "")
                                                                 let image = possibleCardType != .unknown ? possibleCardType.image : nil
                                                                 imageView?.image = image

                                                                 textField.attributedText = CreditCardUtils.formattedNumber(number: textField.text ?? "")
        })

        super.init(billingData: billingData, configuration: configuration, cellModels: [
            FormCellModel(type: .text(numberData)),
            FormCellModel(type: .dateCVV),
        ], formTitle: "Credit Card")

        self.formConsumer = self
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    override func errorWhileCreatingPaymentMethod(error: MLError) {
        UIViewControllerTools.showAlert(on: self, title: "Error",
                                        body: "Could not create credit card method: \(error.errorDescription ?? "Unknown error")")
    }
}

extension AdyenCreditCardInputCollectionViewController: FormConsumer {
    func consumeValues(data: [NecessaryData: String]) throws {
        let createdData = CreditCardParsedData.create(cardNumberText: data[.cardNumber],
                                                      cvvText: data[.cvv],
                                                      expirationMonthText: data[.expirationMonth],
                                                      expirationYearText: data[.expirationYear])

        if !createdData.1.isEmpty {
            throw FormConsumerError(errors: createdData.1)
        }

        guard let parsedData = createdData.0
        else { return }

        do {
            let creditCard = try CreditCardData(cardNumber: parsedData.cardNumber,
                                                cvv: parsedData.cvv,
                                                expiryMonth: parsedData.expirationMonth,
                                                expiryYear: parsedData.expirationYear,
                                                billingData: self.billingData ?? BillingData())

            self.didCreatePaymentMethodCompletion?(creditCard)
        } catch let error as MLError {
            throw FormConsumerError(errors: [.cardNumber: CreditCardValidationError
                    .creditCardValidationFailed(message: error.failureReason ?? "Please enter a valid credit card")])
        }
    }
}
