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
        let nameCell = FormCellModel.FormCellType.TextData(necessaryData: .holderName,
                                                           title: "Name",
                                                           placeholder: "Name",
                                                           setup: nil,
                                                           didUpdate: nil)

        let ibanCell = FormCellModel.FormCellType.TextData(necessaryData: .iban,
                                                           title: "IBAN",
                                                           placeholder: "XX123",
                                                           setup: nil,
                                                           didUpdate: { _, textField in
                                                               textField.attributedText = SEPAUtils.formattedIban(number: textField.text ?? "")
        })

        let bicCell = FormCellModel.FormCellType.TextData(necessaryData: .bic,
                                                          title: "BIC",
                                                          placeholder: "XXX",
                                                          setup: nil,
                                                          didUpdate: nil)

        super.init(billingData: billingData, configuration: configuration, cellModels: [
            FormCellModel(type: .text(nameCell)), FormCellModel(type: .text(ibanCell)), FormCellModel(type: .text(bicCell)),
        ], formTitle: "SEPA")

        self.formConsumer = self
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

        if data[.holderName] == nil || data[.holderName]?.isEmpty == true {
            errors[.holderName] = SEPAValidationError.noData(explanation: "Please provide a valid card holder name")
        }

        guard let iban = data[.iban],
            let bic = data[.bic],
            let name = data[.holderName],
            errors.isEmpty
        else { throw FormConsumerError(errors: errors) }

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
