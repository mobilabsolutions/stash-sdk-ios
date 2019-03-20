//
//  SEPAInputCollectionViewController.swift
//  MobilabPaymentBSPayone
//
//  Created by Robert on 19.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentCore
import UIKit

class SEPAInputCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, PaymentMethodDataProvider {
    private let cardNumberReuseIdentifier = "cardNumberCell"
    private let textReuseIdentifier = "textCell"
    private let dateReuseIdentifier = "dateCell"
    private let doneReuseIdentifier = "doneCell"

    var didCreatePaymentMethodCompletion: ((RegistrationData) -> Void)?

    private let billingData: BillingData?
    private var fieldData: [NecessaryData: String] = [:]
    private let necessaryData: [NecessaryData] = [.holderName, .iban, .bic]

    private enum SEPANecessaryDataCell: Int, CaseIterable {
        case nameCell = 0
        case ibanCell
        case bicCell
    }

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
        self.collectionView.register(DoneButtonCollectionViewCell.self, forCellWithReuseIdentifier: self.doneReuseIdentifier)

        self.collectionView.backgroundColor = UIColor.white
    }

    func errorWhileCreatingPaymentMethod(error: MLError) {
        showAlert(title: "Error", body: "Could not create SEPA method: \(error.errorDescription ?? "Unknown error")")
    }

    private func isDone() -> Bool {
        return self.necessaryData.allSatisfy { self.fieldData[$0] != nil }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return SEPANecessaryDataCell.allCases.count + 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let necessaryDataCell = SEPANecessaryDataCell(rawValue: indexPath.item) {
            switch necessaryDataCell {
            case .nameCell:
                let cell: TextInputCollectionViewCell = dequeueCell(collectionView: collectionView,
                                                                    reuseIdentifier: textReuseIdentifier, for: indexPath)
                cell.setup(text: fieldData[.holderName], title: "Holder Name", dataType: .holderName, delegate: self)
                return cell
            case .ibanCell:
                let cell: TextInputCollectionViewCell = dequeueCell(collectionView: collectionView,
                                                                    reuseIdentifier: textReuseIdentifier, for: indexPath)
                cell.setup(text: fieldData[.iban], title: "IBAN", dataType: .iban, delegate: self)
                return cell
            case .bicCell:
                let cell: TextInputCollectionViewCell = dequeueCell(collectionView: collectionView,
                                                                    reuseIdentifier: textReuseIdentifier, for: indexPath)
                cell.setup(text: fieldData[.bic], title: "BIC", dataType: .bic, delegate: self)
                return cell
            }
        }

        let cell: DoneButtonCollectionViewCell = dequeueCell(collectionView: collectionView, reuseIdentifier: doneReuseIdentifier, for: indexPath)
        cell.setup(delegate: self, buttonEnabled: isDone())
        return cell
    }

    private func dequeueCell<T: UICollectionViewCell>(collectionView: UICollectionView,
                                                      reuseIdentifier: String, for indexPath: IndexPath) -> T {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? T
        else { fatalError("Should be able to dequeue \(T.self) for \(reuseIdentifier)") }
        return cell
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 50)
    }
}

extension SEPAInputCollectionViewController: DataPointProvidingDelegate {
    func didUpdate(value: String?, for dataPoint: NecessaryData) {
        self.fieldData[dataPoint] = value?.isEmpty == false ? value : nil
        self.collectionView.reloadItems(at: [IndexPath(item: collectionView(collectionView, numberOfItemsInSection: 0) - 1, section: 0)])
    }
}

extension SEPAInputCollectionViewController: DoneButtonCellDelegate {
    func didTapDoneButton() {
        #warning("Errors should be handled gracefully here")
        guard let iban = fieldData[.iban],
            let bic = fieldData[.bic],
            let name = fieldData[.holderName]
        else { return }

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
            errorWhileCreatingPaymentMethod(error: error)
        } catch {
            showAlert(title: "Error", body: "An error occurred while adding SEPA: \(error.localizedDescription)")
        }
    }
}
