//
//  SEPAInputCollectionViewController.swift
//  MobilabPaymentBSPayone
//
//  Created by Robert on 19.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentCore
import MobilabPaymentUI
import UIKit

class SEPAInputCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout,
    PaymentMethodDataProvider, DoneButtonUpdater {
    private let textReuseIdentifier = "textCell"
    private let headerReuseIdentifier = "header"

    private let cellInset: CGFloat = 18
    private let defaultCellHeight: CGFloat = 85
    private let defaultHeaderHeight: CGFloat = 65
    private let lastCellHeightSurplus: CGFloat = 16
    private let errorCellHeightSurplus: CGFloat = 18

    var didCreatePaymentMethodCompletion: ((RegistrationData) -> Void)?
    var doneButtonUpdating: DoneButtonUpdating?

    private let billingData: BillingData?
    private var fieldData: [NecessaryData: String] = [:]

    private enum SEPANecessaryDataCell: Int, CaseIterable {
        case nameCell = 0
        case ibanCell
        case bicCell

        var necessaryData: [NecessaryData] {
            switch self {
            case .nameCell: return [.holderName]
            case .ibanCell: return [.iban]
            case .bicCell: return [.bic]
            }
        }
    }

    private enum ValidationError: CustomStringConvertible {
        case noData(explanation: String)
        case sepaValidationFailed(explanation: String)

        var description: String {
            switch self {
            case let .noData(explanation): return explanation
            case let .sepaValidationFailed(explanation): return explanation
            }
        }
    }

    private var errors: [NecessaryData: ValidationError] = [:]

    init(billingData: BillingData?) {
        self.billingData = billingData
        super.init(collectionViewLayout: UICollectionViewFlowLayout())

        if let name = billingData?.name {
            self.fieldData[.holderName] = name
        }
    }

    required init?(coder aDecoder: NSCoder) {
        self.billingData = nil
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView.register(TextInputCollectionViewCell.self, forCellWithReuseIdentifier: self.textReuseIdentifier)
        self.collectionView.register(TitleHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: self.headerReuseIdentifier)

        self.collectionView.backgroundColor = UIConstants.iceBlue
        self.doneButtonUpdating?.updateDoneButton(enabled: self.isDone())
    }

    func errorWhileCreatingPaymentMethod(error: MLError) {
        UIViewControllerTools.showAlert(on: self, title: "Error",
                                        body: "Could not create SEPA method: \(error.errorDescription ?? "Unknown error")")
    }

    private func isDone() -> Bool {
        return SEPANecessaryDataCell.allCases
            .flatMap { $0.necessaryData }
            .allSatisfy { self.fieldData[$0] != nil }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return SEPANecessaryDataCell.allCases.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let necessaryDataCell = SEPANecessaryDataCell(rawValue: indexPath.item)
        else { fatalError("Index path does not correspond to any necessary data item") }

        let toReturn: UICollectionViewCell

        switch necessaryDataCell {
        case .nameCell:
            let cell: TextInputCollectionViewCell = collectionView.dequeueCell(reuseIdentifier: textReuseIdentifier, for: indexPath)
            cell.setup(text: fieldData[.holderName], title: "Name", placeholder: "Name", dataType: .holderName,
                       error: errors[.holderName]?.description, delegate: self)

            toReturn = cell
        case .ibanCell:
            let cell: TextInputCollectionViewCell = collectionView.dequeueCell(reuseIdentifier: textReuseIdentifier, for: indexPath)
            cell.setup(text: fieldData[.iban], title: "IBAN", placeholder: "XX123", dataType: .iban, textFieldUpdateCallback: { textField in
                textField.attributedText = SEPAUtils.formattedIban(number: textField.text ?? "")
            }, error: errors[.iban]?.description, delegate: self)
            toReturn = cell
        case .bicCell:
            let cell: TextInputCollectionViewCell = collectionView.dequeueCell(reuseIdentifier: textReuseIdentifier, for: indexPath)
            cell.setup(text: fieldData[.bic], title: "BIC", placeholder: "XXX", dataType: .bic, error: errors[.bic]?.description, delegate: self)

            toReturn = cell
        }

        if indexPath.item == 0 {
            toReturn.layer.cornerRadius = 4
            toReturn.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            toReturn.layer.masksToBounds = true
        } else if indexPath.item == self.collectionView(collectionView, numberOfItemsInSection: indexPath.section) - 1 {
            toReturn.layer.cornerRadius = 4
            toReturn.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            toReturn.layer.masksToBounds = true
        }

        return toReturn
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as? TitleHeaderView
        else { fatalError("Should be able to dequeue TitleHeaderView as header supplementary vie for \(self.headerReuseIdentifier)") }

        view.title = "Sepa"

        return view
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let isLastRow = indexPath.row == self.collectionView(collectionView, numberOfItemsInSection: indexPath.section) - 1
        let isError = SEPANecessaryDataCell(rawValue: indexPath.row)?.necessaryData
            .contains(where: { self.errors[$0] != nil }) ?? false

        let additionalHeight: CGFloat = (isLastRow ? lastCellHeightSurplus : 0) + (isError ? errorCellHeightSurplus : 0)
        return CGSize(width: self.view.frame.width - 2 * self.cellInset, height: self.defaultCellHeight + additionalHeight)
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        return 0
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, referenceSizeForHeaderInSection _: Int) -> CGSize {
        return CGSize(width: self.view.frame.width - 2 * self.cellInset, height: self.defaultHeaderHeight)
    }
}

extension SEPAInputCollectionViewController: DataPointProvidingDelegate {
    func didUpdate(value: String?, for dataPoint: NecessaryData) {
        self.fieldData[dataPoint] = value?.isEmpty == false ? value : nil
        self.doneButtonUpdating?.updateDoneButton(enabled: self.isDone())
        self.errors[dataPoint] = nil
    }
}

extension SEPAInputCollectionViewController: DoneButtonViewDelegate {
    func didTapDoneButton() {
        self.errors = [:]

        if self.fieldData[.iban] == nil || self.fieldData[.iban]?.isEmpty == true {
            errors[.iban] = .noData(explanation: "Please provide a valid IBAN")
        }

        if self.fieldData[.bic] == nil || self.fieldData[.bic]?.isEmpty == true {
            errors[.bic] = .noData(explanation: "Please provide a valid BIC")
        }

        if self.fieldData[.holderName] == nil || self.fieldData[.holderName]?.isEmpty == true {
            errors[.holderName] = .noData(explanation: "Please provide a valid card holder name")
        }

        guard let iban = fieldData[.iban],
            let bic = fieldData[.bic],
            let name = fieldData[.holderName],
            errors.isEmpty
        else { self.collectionView.reloadData(); return }

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
        } catch let error as MLError {
            errors[.iban] = .sepaValidationFailed(explanation: error.failureReason ?? "Please provide a valid IBAN")
            collectionView.reloadData()
        } catch {
            UIViewControllerTools.showAlert(on: self, title: "Error",
                                            body: "An error occurred while adding SEPA: \(error.localizedDescription)")
        }
    }
}
