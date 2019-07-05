//
//  BSSEPAInputCollectionViewController.swift
//  MobilabPaymentBSPayone
//
//  Created by Robert on 19.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import MobilabPaymentCore
import UIKit

class BSSEPAInputCollectionViewController: FormCollectionViewController {
    private var configuration: PaymentMethodUIConfiguration?

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

        self.parent?.navigationItem.title = ""
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

        let countryData = FormCellModel.FormCellType.TextData(necessaryData: .country,
                                                              title: "Country",
                                                              placeholder: "Country",
                                                              setup: nil,
                                                              didFocus: { [weak self] textField in
                                                                  guard let self = self else { return }
                                                                  self.showCountryListing(textField: textField, on: self)
                                                              },
                                                              didUpdate: nil)

        setCellModel(cellModels: [
            FormCellModel(type: .pairedText(nameData)),
            FormCellModel(type: .text(ibanData)),
            FormCellModel(type: .text(countryData)),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BSSEPAInputCollectionViewController: FormConsumer {
    func validate(data: [NecessaryData: String]) -> FormConsumerError? {
        var errors: [NecessaryData: ValidationError] = [:]

        if let iban = data[.iban], iban.isEmpty == false {
            do {
                try SEPAUtils.validateIBAN(iban: iban)
            } catch {
                errors[.iban] = SEPAValidationError.noData(explanation: "Please provide a valid IBAN")
            }
        } else {
            errors[.iban] = SEPAValidationError.noData(explanation: "Please provide a valid IBAN")
        }

        if data[.holderFirstName] == nil || data[.holderFirstName]?.isEmpty == true {
            errors[.holderFirstName] = SEPAValidationError.noData(explanation: "Please provide a valid first name")
        }

        if data[.holderLastName] == nil || data[.holderLastName]?.isEmpty == true {
            errors[.holderLastName] = SEPAValidationError.noData(explanation: "Please provide a valid last name")
        }

        if data[.country] == nil || data[.country]?.isEmpty == true {
            errors[.country] = SEPAValidationError.noData(explanation: "Please provide a valid country")
        }

        return errors.isEmpty ? nil : FormConsumerError(errors: errors)
    }

    func consumeValues(data: [NecessaryData: String]) throws {
        if let validationError = validate(data: data) {
            throw validationError
        }

        guard let iban = data[.iban],
            let firstName = data[.holderFirstName],
            let lastName = data[.holderLastName],
            let countryCode = self.country?.alpha2Code
        else { throw FormConsumerError(errors: [:]) }

        let name = SimpleNameProvider(firstName: firstName, lastName: lastName)
        let newBillingData = BillingData(email: billingData?.email,
                                         name: name,
                                         address1: billingData?.address1,
                                         address2: billingData?.address2,
                                         zip: billingData?.zip,
                                         city: billingData?.city,
                                         state: billingData?.state,
                                         country: countryCode,
                                         phone: billingData?.phone,
                                         languageId: billingData?.languageId)

        do {
            let sepa = try SEPAData(iban: iban, bic: nil, billingData: newBillingData)
            self.didCreatePaymentMethodCompletion?(sepa)
        } catch let error as MobilabPaymentError {
            let errors = [NecessaryData.iban: SEPAValidationError.sepaValidationFailed(explanation: error.description)]
            throw FormConsumerError(errors: errors)
        } catch {
            UIViewControllerTools.showAlert(on: self, title: "Error",
                                            body: "An error occurred while adding SEPA: \(error.localizedDescription)")
        }
    }
}
