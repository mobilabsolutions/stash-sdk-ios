//
//  BSCreditCardInputCollectionViewController.swift
//  MobilabPaymentBSPayone
//
//  Created by Robert on 18.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentCore
import UIKit

class BSCreditCardInputCollectionViewController: FormCollectionViewController {
    private static let methodTypeImageViewWidth: CGFloat = 30
    private static let methodTypeImageViewHeight: CGFloat = 22
    
    private var configuration: PaymentMethodUIConfiguration?
    
    private var textFieldCountry: UITextField?
    
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
        let country: String

        static func create(holderFirstNameText: String?,
                           holderLastNameText: String?,
                           cardNumberText: String?,
                           cvvText: String?,
                           expirationMonthText: String?,
                           expirationYearText: String?,
                           countryText: String?) -> (CreditCardParsedData?, [NecessaryData: CreditCardValidationError]) {
            var errors: [NecessaryData: CreditCardValidationError] = [:]

            if holderFirstNameText == nil || holderFirstNameText?.isEmpty == true {
                errors[.holderFirstName] = .noData(explanation: "Please provide a valid first name")
            }

            if holderLastNameText == nil || holderLastNameText?.isEmpty == true {
                errors[.holderLastName] = .noData(explanation: "Please provide a valid last name")
            }

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
            
            if countryText == nil {
                errors[.country] = .noData(explanation: "Please provide country")
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

            guard let holderFirstName = holderFirstNameText,
                let holderLastName = holderLastNameText,
                let cardNumber = cardNumberText, let cvv = cvvText,
                let expirationMonth = expirationMonthText.flatMap({ Int($0) }),
                let expirationYear = expirationYearText.flatMap({ Int($0) }),
                let country = countryText,
                errors.isEmpty
            else { return (nil, errors) }

            let name = SimpleNameProvider(firstName: holderFirstName, lastName: holderLastName)
            let parsedData = CreditCardParsedData(name: name,
                                                  cardNumber: cardNumber,
                                                  cvv: cvv,
                                                  expirationMonth: expirationMonth,
                                                  expirationYear: expirationYear, country: country)
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
                                                             title: "Credit card number",
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
        

        let countryData = FormCellModel.FormCellType.TextData(necessaryData: .country,
                                                                   title: "Country",
                                                                   placeholder: "Country",
                                                                   setup: nil,
                                                                   didFocus: { [weak self] textField in
                                                                    guard let newSelf = self else { return }
                                                                    newSelf.showCountryListing(textField: textField)
                                                                    self?.textFieldCountry = textField
            },
                                                                   didUpdate: nil)
        setCellModel(cellModels: [
            FormCellModel(type: .pairedText(nameData)),
            FormCellModel(type: .text(numberData)),
            FormCellModel(type: .dateCVV),
            FormCellModel(type: .text(countryData))
            ])
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
//    private func showCountryListing() {
//        guard let uiConfiguration = configuration else {
//            fatalError("No UI Configuration")
//        }
//
////        let countryVC = CountryListCollectionViewController(configuration: uiConfiguration)
//        self.navigationController?.pushViewController(countryVC, animated: true)
//        countryVC.delegate = self
//    }
}

extension BSCreditCardInputCollectionViewController: FormConsumer {
    func consumeValues(data: [NecessaryData: String]) throws {
        let createdData = CreditCardParsedData.create(holderFirstNameText: data[.holderFirstName],
                                                      holderLastNameText: data[.holderLastName],
                                                      cardNumberText: data[.cardNumber],
                                                      cvvText: data[.cvv],
                                                      expirationMonthText: data[.expirationMonth],
                                                      expirationYearText: data[.expirationYear],
                                                      countryText: textFieldCountry?.text)

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
                                                holderName: parsedData.name.fullName,
                                                country: textFieldCountry?.text,
                                                billingData: self.billingData ?? BillingData())

            guard creditCard.cardType.bsCardTypeIdentifier != nil
            else { throw FormConsumerError(errors: [.cardNumber: CreditCardValidationError.noKnownCreditCardProvider]) }

            self.didCreatePaymentMethodCompletion?(creditCard)
        } catch let error as MobilabPaymentError {
            throw FormConsumerError(errors: [.cardNumber: CreditCardValidationError
                    .creditCardValidationFailed(message: error.description)])
        }
    }
}
//
//extension BSCreditCardInputCollectionViewController: CountryListCollectionViewControllerProtocol {
//    func didSelectCountry(name: String) {
//        print("Country for Credit card: \(name)")
//        textFieldCountry?.text = name
//    }
//}
