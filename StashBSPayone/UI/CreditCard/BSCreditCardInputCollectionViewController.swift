//
//  BSCreditCardInputCollectionViewController.swift
//  StashBSPayone
//
//  Created by Robert on 18.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import StashCore
import UIKit

class BSCreditCardInputCollectionViewController: FormCollectionViewController {
    private static let methodTypeImageViewWidth: CGFloat = 30
    private static let methodTypeImageViewHeight: CGFloat = 22

    private var configuration: PaymentMethodUIConfiguration?

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
        let name: SimpleNameProvider
        let cardNumber: String
        let cvv: String
        let expirationMonth: Int
        let expirationYear: Int
        let country: Country

        static func create(holderFirstNameText: String?,
                           holderLastNameText: String?,
                           cardNumberText: String?,
                           cvvText: String?,
                           expirationMonth: Int?,
                           expirationYear: Int?,
                           country: Country?) -> (CreditCardParsedData?, [NecessaryData: CreditCardValidationError]) {
            var errors: [NecessaryData: CreditCardValidationError] = [:]

            if holderFirstNameText == nil || holderFirstNameText?.isEmpty == true {
                errors[.holderFirstName] = .noData(explanation: "Please provide a valid first name")
            }

            if holderLastNameText == nil || holderLastNameText?.isEmpty == true {
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

            if expirationYear.flatMap({ $0 >= 0 }) != true {
                errors[.expirationYear] = .noData(explanation: "Please provide a valid expiration date")
            }

            if expirationMonth.flatMap({ $0 >= 0 }) != true {
                errors[.expirationMonth] = .noData(explanation: "Please provide a valid expiration date")
            }

            if let country = country {
                if country.alpha2Code.isEmpty {
                    errors[.country] = .noData(explanation: "Please provide a valid country")
                }
            } else {
                errors[.country] = .noData(explanation: "Please provide a valid country")
            }

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/yy"
            dateFormatter.calendar = Calendar(identifier: .gregorian)

            if let month = expirationMonth,
                let year = expirationYear,
                let date = dateFormatter.date(from: "\(month)/\(year)"),
                let expiration = Calendar.current.date(byAdding: .month, value: 1, to: date),
                // Verify that the credit card is not yet expired. Expiration is generally at the end of the specified month.
                expiration <= Date() {
                errors[.expirationYear] = .noData(explanation: "Please provide an expiration date in the future")
            }

            guard let holderFirstName = holderFirstNameText,
                let holderLastName = holderLastNameText,
                let cardNumber = cardNumberText, let cvv = cvvText,
                let expirationMonth = expirationMonth,
                let expirationYear = expirationYear,
                let country = country,
                errors.isEmpty
            else { return (nil, errors) }

            let name = SimpleNameProvider(firstName: holderFirstName, lastName: holderLastName)
            let parsedData = CreditCardParsedData(name: name,
                                                  cardNumber: cardNumber,
                                                  cvv: cvv,
                                                  expirationMonth: expirationMonth,
                                                  expirationYear: expirationYear,
                                                  country: country)
            return (parsedData, [:])
        }
    }

    init(billingData: BillingData?, configuration: PaymentMethodUIConfiguration) {
        super.init(billingData: billingData, configuration: configuration, formTitle: "Credit Card")

        self.configuration = configuration
        self.formConsumer = self
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
                                                                                                           width: BSCreditCardInputCollectionViewController.methodTypeImageViewWidth,
                                                                                                           height: BSCreditCardInputCollectionViewController.methodTypeImageViewHeight))
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
            FormCellModel(type: .country),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
}

extension BSCreditCardInputCollectionViewController: FormConsumer {
    func validate(data: [NecessaryData: PresentableValueHolding]) -> FormConsumerError? {
        do {
            _ = try self.createCreditCardData(data: data)
        } catch let error as FormConsumerError {
            return error
        } catch {
            // Should not happen
        }

        return nil
    }

    func consumeValues(data: [NecessaryData: PresentableValueHolding]) throws {
        guard let card = try createCreditCardData(data: data)
        else { return }
        self.didCreatePaymentMethodCompletion?(card)
    }

    private func createCreditCardData(data: [NecessaryData: PresentableValueHolding]) throws -> CreditCardData? {
        let createdData = CreditCardParsedData.create(holderFirstNameText: data[.holderFirstName]?.value as? String,
                                                      holderLastNameText: data[.holderLastName]?.value as? String,
                                                      cardNumberText: data[.cardNumber]?.value as? String,
                                                      cvvText: data[.cvv]?.value as? String,
                                                      expirationMonth: data[.expirationMonth]?.value as? Int,
                                                      expirationYear: data[.expirationYear]?.value as? Int,
                                                      country: data[.country]?.value as? Country)

        if !createdData.1.isEmpty {
            throw FormConsumerError(errors: createdData.1)
        }

        guard let parsedData = createdData.0
        else { return nil }

        do {
            let billingData = BillingData(name: parsedData.name, basedOn: self.billingData)

            let creditCard = try CreditCardData(cardNumber: parsedData.cardNumber,
                                                cvv: parsedData.cvv,
                                                expiryMonth: parsedData.expirationMonth,
                                                expiryYear: parsedData.expirationYear,
                                                country: parsedData.country.alpha2Code,
                                                billingData: billingData)

            guard creditCard.cardType.bsCardTypeIdentifier != nil
            else { throw FormConsumerError(errors: [.cardNumber: CreditCardValidationError.noKnownCreditCardProvider]) }

            return creditCard
        } catch let error as StashError {
            throw FormConsumerError(errors: [.cardNumber: CreditCardValidationError
                    .creditCardValidationFailed(message: error.description)])
        }
    }
}
