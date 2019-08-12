//
//  AdyenSEPAInputCollectionViewController.swift
//  MobilabPaymentAdyen
//
//  Created by Robert on 19.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import MobilabPaymentCore
import UIKit

class AdyenSEPAInputCollectionViewController: FormCollectionViewController {
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

        setCellModel(cellModels: [
            FormCellModel(type: .pairedText(nameCell)),
            FormCellModel(type: .text(ibanCell)),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AdyenSEPAInputCollectionViewController: FormConsumer {
    func validate(data: [NecessaryData: PresentableValueHolding]) -> FormConsumerError? {
        var errors: [NecessaryData: ValidationError] = [:]

        if let iban = data[.iban]?.value as? String, iban.isEmpty == false {
            do {
                try SEPAUtils.validateIBAN(iban: iban)
            } catch {
                errors[.iban] = SEPAValidationError.noData(explanation: "Please provide a valid IBAN")
            }
        } else {
            errors[.iban] = SEPAValidationError.noData(explanation: "Please provide a valid IBAN")
        }

        if data[.holderFirstName] == nil {
            errors[.holderFirstName] = SEPAValidationError.noData(explanation: "Please provide a valid first name")
        }

        if data[.holderLastName] == nil {
            errors[.holderLastName] = SEPAValidationError.noData(explanation: "Please provide a valid last name")
        }

        return errors.isEmpty ? nil : FormConsumerError(errors: errors)
    }

    func consumeValues(data: [NecessaryData: PresentableValueHolding]) throws {
        if let validationError = validate(data: data) {
            throw validationError
        }

        guard let iban = data[.iban]?.value as? String,
            let firstName = data[.holderFirstName]?.value as? String,
            let lastName = data[.holderLastName]?.value as? String
        else { return }

        let newBillingData = BillingData(email: billingData?.email,
                                         name: SimpleNameProvider(firstName: firstName, lastName: lastName),
                                         address1: billingData?.address1,
                                         address2: billingData?.address2,
                                         zip: billingData?.zip,
                                         city: billingData?.city,
                                         state: billingData?.state,
                                         country: billingData?.country,
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
