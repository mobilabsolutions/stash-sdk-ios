//
//  BraintreeCreditCardInputCollectionViewController.swift
//  MobilabPaymentBraintree
//
//  Created by Biju Parvathy on 08.08.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import MobilabPaymentCore
import UIKit

class BraintreeCreditCardInputCollectionViewController: FormCollectionViewController {
    private static let methodTypeImageViewWidth: CGFloat = 30
    private static let methodTypeImageViewHeight: CGFloat = 22

    init(billingData: BillingData?, configuration: PaymentMethodUIConfiguration) {
        super.init(billingData: billingData, configuration: configuration, formTitle: "Credit Card")
        self.formConsumer = self
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let nameData = FormCellModel.FormCellType.PairedTextData(firstNecessaryData: .holderFirstName,
                                                                 firstTitle: "First Name",
                                                                 firstPlaceholder: "First Name",
                                                                 secondNecessaryData: .holderLastName,
                                                                 secondTitle: "Last Name",
                                                                 secondPlaceholder: "Last Name",
                                                                 setup: nil,
                                                                 didUpdate: nil)

        let numberData = FormCellModel.FormCellType.TextData(necessaryData: .cardNumber,
                                                             title: "Credit Card Number",
                                                             placeholder: "1234",
                                                             setup: { _, textField in
                                                                 textField.rightViewMode = .always
                                                                 textField.textContentType = .creditCardNumber
                                                                 let imageView = UIImageView(frame: CGRect(x: 0,
                                                                                                           y: 0,
                                                                                                           width: BraintreeCreditCardInputCollectionViewController.methodTypeImageViewWidth,
                                                                                                           height: BraintreeCreditCardInputCollectionViewController.methodTypeImageViewHeight))
                                                                 imageView.contentMode = .scaleAspectFit
                                                                 textField.rightView = imageView
                                                             },
                                                             didFocus: nil,
                                                             didUpdate: { _, textField in
                                                                 let imageView = textField.rightView as? UIImageView

                                                                 let possibleCardType = CreditCardUtils.cardTypeFromNumber(number: textField.text ?? "")
                                                                 let image = possibleCardType != .unknown ? possibleCardType.image : nil
                                                                 imageView?.image = image

                                                                 textField.attributedText = CreditCardUtils.formattedNumber(number: textField.text ?? "")
        })

        setCellModel(cellModels: [
            FormCellModel(type: .pairedText(nameData)),
            FormCellModel(type: .text(numberData)),
            FormCellModel(type: .dateCVV),
        ])
    }

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
        let holderName: NameProviding

        static func create(cardNumberText: String?,
                           cvvText: String?,
                           expirationMonthText: String?,
                           expirationYearText: String?,
                           holderFirstName: String?,
                           holderLastName: String?) -> (CreditCardParsedData?, [NecessaryData: CreditCardValidationError]) {
            var errors: [NecessaryData: CreditCardValidationError] = [:]

            if holderFirstName == nil || holderFirstName?.isEmpty == true {
                errors[.holderFirstName] = .noData(explanation: "Please provide a valid first name")
            }

            if holderLastName == nil || holderLastName?.isEmpty == true {
                errors[.holderLastName] = .noData(explanation: "Please provide a valid last name")
            }

            if let cardNumber = cardNumberText, cardNumber.isEmpty == false {
                do {
                    try CreditCardUtils.validateCreditCardNumber(cardNumber: cardNumber)
                } catch {
                    errors[.cardNumber] = .noData(explanation: "Please provide a valid card number")
                }
            } else {
                errors[.cardNumber] = .noData(explanation: "Please provide a valid card number")
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
            dateFormatter.calendar = Calendar(identifier: .gregorian)

            if let month = expirationMonthText,
                let year = expirationYearText,
                let date = dateFormatter.date(from: "\(month)/\(year)"),
                let expiration = Calendar.current.date(byAdding: .month, value: 1, to: date),
                // Verify that the credit card is not yet expired. Expiration is generally at the end of the specified month.
                expiration <= Date() {
                errors[.expirationYear] = .noData(explanation: "Please provide an expiration date in the future")
            }

            guard let cardNumber = cardNumberText,
                let cvv = cvvText,
                let expirationMonth = expirationMonthText.flatMap({ Int($0) }),
                let expirationYear = expirationYearText.flatMap({ Int($0) }),
                let firstName = holderFirstName,
                let lastName = holderLastName,
                errors.isEmpty
            else { return (nil, errors) }

            let parsedData = CreditCardParsedData(cardNumber: cardNumber,
                                                  cvv: cvv,
                                                  expirationMonth: expirationMonth,
                                                  expirationYear: expirationYear,
                                                  holderName: SimpleNameProvider(firstName: firstName, lastName: lastName))
            return (parsedData, [:])
        }
    }
}

extension BraintreeCreditCardInputCollectionViewController: FormConsumer {
    func consumeValues(data: [NecessaryData: String]) throws {
        guard let creditCard = try createCreditCardData(from: data)
        else { return }
        self.didCreatePaymentMethodCompletion?(creditCard)
    }

    func validate(data: [NecessaryData: String]) -> FormConsumerError? {
        do {
            _ = try self.createCreditCardData(from: data)
        } catch let error as FormConsumerError {
            return error
        } catch {
            // Should not happen
        }
        return nil
    }

    private func createCreditCardData(from data: [NecessaryData: String]) throws -> CreditCardData? {
        let createdData = CreditCardParsedData.create(cardNumberText: data[.cardNumber],
                                                      cvvText: data[.cvv],
                                                      expirationMonthText: data[.expirationMonth],
                                                      expirationYearText: data[.expirationYear],
                                                      holderFirstName: data[.holderFirstName],
                                                      holderLastName: data[.holderLastName])

        if !createdData.1.isEmpty {
            throw FormConsumerError(errors: createdData.1)
        }

        guard let parsedData = createdData.0
        else { return nil }

        let billingData = BillingData(name: parsedData.holderName, basedOn: self.billingData)

        do {
            let creditCard = try CreditCardData(cardNumber: parsedData.cardNumber,
                                                cvv: parsedData.cvv,
                                                expiryMonth: parsedData.expirationMonth,
                                                expiryYear: parsedData.expirationYear, country: nil,
                                                billingData: billingData)

            return creditCard
        } catch let error as MobilabPaymentError {
            throw FormConsumerError(errors: [.cardNumber: CreditCardValidationError
                    .creditCardValidationFailed(message: error.description)])
        }
    }
}
