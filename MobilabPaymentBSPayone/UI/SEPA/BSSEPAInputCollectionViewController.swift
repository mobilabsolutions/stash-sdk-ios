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

        self.formConsumer = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nameCell = FormCellModel.FormCellType.PairedTextData(firstNecessaryData: .holderFirstName,
                                                                 firstTitle: "First Name",
                                                                 firstPlaceholder: "First Name",
                                                                 secondNecessaryData: .holderLastName,
                                                                 secondTitle: "Last Name",
                                                                 secondPlaceholder: "Last Name",
                                                                 setup: nil,
                                                                 didUpdate: nil)
        
        let ibanCell = FormCellModel.FormCellType.TextData(necessaryData: .iban,
                                                           title: "IBAN",
                                                           placeholder: "XX123",
                                                           setup: nil,
                                                           didFocus: nil,
                                                           didUpdate: { _, textField in
                                                            textField.attributedText = SEPAUtils.formattedIban(number: textField.text ?? "")
        })
        
        let bicCell = FormCellModel.FormCellType.TextData(necessaryData: .bic,
                                                          title: "BIC",
                                                          placeholder: "XXX",
                                                          setup: nil,
                                                          didFocus: nil,
                                                          didUpdate: nil)
        
        let countryCell = FormCellModel.FormCellType.TextData(necessaryData: .country,
                                                              title: "Country",
                                                              placeholder: "Country",
                                                              setup: nil,
                                                              didFocus:  { [weak self] textField in
                                                                self?.showCountrySelection()
            },
                                                              didUpdate: nil)
        
        setCellModel(cellModels:  [
            FormCellModel(type: .pairedText(nameCell)),
            FormCellModel(type: .text(ibanCell)),
            FormCellModel(type: .text(bicCell)),
            FormCellModel(type: .text(countryCell))
            ])

    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
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
                                         country: billingData?.country,
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
