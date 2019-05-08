//
//  BSSEPAInputCollectionViewController.swift
//  MobilabPaymentBSPayone
//
//  Created by Robert on 19.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentCore
import UIKit

class BSSEPAInputCollectionViewController: FormCollectionViewController {
    private var configuration: PaymentMethodUIConfiguration?

    private var textFieldCountry: UITextField?

    private enum SEPAValidationError: ValidationError {
        case noData(explanation: String)
        case sepaValidationFailed(explanation: String)

        var description: String {
            switch self {
            case let .noData(explanation): return explanation
            case let .sepaValidationFailed(explanation): return explanation
            }
        }
    }

    init(billingData: BillingData?, configuration: PaymentMethodUIConfiguration) {
        
        super.init(billingData: billingData, configuration: configuration, formTitle: "SEPA")

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
        
        let ibanData = FormCellModel.FormCellType.TextData(necessaryData: .iban,
                                                           title: "IBAN",
                                                           placeholder: "XX123",
                                                           setup: nil,
                                                           didFocus: nil,
                                                           didUpdate: { _, textField in
                                                            textField.attributedText = SEPAUtils.formattedIban(number: textField.text ?? "")
        })
        
        let bicData = FormCellModel.FormCellType.TextData(necessaryData: .bic,
                                                          title: "BIC",
                                                          placeholder: "XXX",
                                                          setup: nil,
                                                          didFocus: nil,
                                                          didUpdate: nil)
        
        let countryData = FormCellModel.FormCellType.TextData(necessaryData: .country,
                                                              title: "Country",
                                                              placeholder: "Country",
                                                              setup: nil,
                                                              didFocus:  { [weak self] textField in
                                                                guard let newSelf = self else { return }
//                                                                self?.showCountryListing()
                                                                newSelf.showCountryListing(textField: textField)
                                                                newSelf.textFieldCountry = textField
            },
                                                              didUpdate: { _, textField in
                                                                print("Did update....")
        })
        
        setCellModel(cellModels:  [
            FormCellModel(type: .pairedText(nameData)),
            FormCellModel(type: .text(ibanData)),
            FormCellModel(type: .text(bicData)),
            FormCellModel(type: .text(countryData))
            ])

    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    private func showCountryListing() {
//        guard let uiConfiguration = configuration else {
//            fatalError("No UI Configuration")
//        }
//
//        let countryVC = CountryListCollectionViewController(configuration: uiConfiguration)
//        self.navigationController?.pushViewController(countryVC, animated: true)
//        countryVC.delegate = self
//    }
}

extension BSSEPAInputCollectionViewController: FormConsumer {
    func consumeValues(data: [NecessaryData: String]) throws {
        var errors: [NecessaryData: ValidationError] = [:]

        if data[.iban] == nil || data[.iban]?.isEmpty == true {
            errors[.iban] = SEPAValidationError.noData(explanation: "Please provide a valid IBAN")
        }

        if data[.bic] == nil || data[.bic]?.isEmpty == true {
            errors[.bic] = SEPAValidationError.noData(explanation: "Please provide a valid BIC")
        }

        if data[.holderFirstName] == nil || data[.holderFirstName]?.isEmpty == true {
            errors[.holderFirstName] = SEPAValidationError.noData(explanation: "Please provide a valid first name")
        }

        if data[.holderLastName] == nil || data[.holderLastName]?.isEmpty == true {
            errors[.holderFirstName] = SEPAValidationError.noData(explanation: "Please provide a valid last name")
        }
        
        if data[.country] == nil || data[.country]?.isEmpty == true {
            errors[.country] = SEPAValidationError.noData(explanation: "Please provide a valid country name")
        }

        guard let iban = data[.iban],
            let bic = data[.bic],
            let firstName = data[.holderFirstName],
            let lastName = data[.holderLastName],
            errors.isEmpty
        else { throw FormConsumerError(errors: errors) }

        let name = SimpleNameProvider(firstName: firstName, lastName: lastName)
        let newBillingData = BillingData(email: billingData?.email,
                                         name: name,
                                         address1: billingData?.address1,
                                         address2: billingData?.address2,
                                         zip: billingData?.zip,
                                         city: billingData?.city,
                                         state: billingData?.state,
                                         country: textFieldCountry?.text,
                                         phone: billingData?.phone,
                                         languageId: billingData?.languageId)

        do {
            let sepa = try SEPAData(iban: iban, bic: bic, billingData: newBillingData)
            self.didCreatePaymentMethodCompletion?(sepa)
        } catch let error as MobilabPaymentError {
            errors[.iban] = SEPAValidationError.sepaValidationFailed(explanation: error.description)
            throw FormConsumerError(errors: errors)
        } catch {
            UIViewControllerTools.showAlert(on: self, title: "Error",
                                            body: "An error occurred while adding SEPA: \(error.localizedDescription)")
        }
    }
}


//extension BSSEPAInputCollectionViewController: CountryListCollectionViewControllerProtocol {
//    func didSelectCountry(name: String) {
//        print("Country for BSPayone: \(name)")
//        textFieldCountry?.text = name
//    }
//}
