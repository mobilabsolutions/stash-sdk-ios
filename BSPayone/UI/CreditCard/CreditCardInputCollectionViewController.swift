//
//  CreditCardInputCollectionViewController.swift
//  MobilabPaymentBSPayone
//
//  Created by Robert on 18.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentCore
import UIKit

class CreditCardInputCollectionViewController: UICollectionViewController, PaymentMethodDataProvider,
    UICollectionViewDelegateFlowLayout {
    private let cardNumberReuseIdentifier = "cardNumberCell"
    private let textReuseIdentifier = "textCell"
    private let dateReuseIdentifier = "dateCell"
    private let doneReuseIdentifier = "doneCell"

    var didCreatePaymentMethodCompletion: ((RegistrationData) -> Void)?

    private let billingData: BillingData?
    private var fieldData: [NecessaryData: String] = [:]
    private let necessaryData: [NecessaryData] = [.cardNumber, .cvv, .holderName, .expirationMonth, .expirationYear]

    private enum CreditCardNecessaryDataCell: Int, CaseIterable {
        case nameCell = 0
        case cardNumberCell
        case dateCVVCell
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
        self.collectionView.register(CreditCardNumberInputCollectionViewCell.self, forCellWithReuseIdentifier: self.cardNumberReuseIdentifier)
        self.collectionView.register(DateCVVInputCollectionViewCell.self, forCellWithReuseIdentifier: self.dateReuseIdentifier)
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
        return CreditCardNecessaryDataCell.allCases.count + 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let necessaryDataCell = CreditCardNecessaryDataCell(rawValue: indexPath.item) {
            switch necessaryDataCell {
            case .nameCell:
                let cell: TextInputCollectionViewCell = dequeueCell(collectionView: collectionView,
                                                                    reuseIdentifier: textReuseIdentifier, for: indexPath)
                cell.setup(text: fieldData[.holderName], title: "Holder Name", dataType: .holderName, delegate: self)
                return cell
            case .cardNumberCell:
                let cell: CreditCardNumberInputCollectionViewCell = dequeueCell(collectionView: collectionView,
                                                                                reuseIdentifier: cardNumberReuseIdentifier, for: indexPath)
                cell.setup(cardNumber: fieldData[.cardNumber], delegate: self)
                return cell
            case .dateCVVCell:
                let cell: DateCVVInputCollectionViewCell = dequeueCell(collectionView: collectionView,
                                                                       reuseIdentifier: dateReuseIdentifier, for: indexPath)

                let date: (month: Int, year: Int)?
                if let year = fieldData[.expirationYear], let yearValue = Int(year),
                    let month = fieldData[.expirationMonth], let monthValue = Int(month) {
                    date = (month: monthValue, year: yearValue)
                } else {
                    date = nil
                }

                cell.setup(date: date, cvv: self.fieldData[.cvv], delegate: self)
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

extension CreditCardInputCollectionViewController: DataPointProvidingDelegate {
    func didUpdate(value: String?, for dataPoint: NecessaryData) {
        self.fieldData[dataPoint] = value?.isEmpty == false ? value : nil
        self.collectionView.reloadItems(at: [IndexPath(item: collectionView(collectionView, numberOfItemsInSection: 0) - 1, section: 0)])
    }
}

extension CreditCardInputCollectionViewController: DoneButtonCellDelegate {
    func didTapDoneButton() {
        guard let cardNumber = fieldData[.cardNumber],
            let cvv = fieldData[.cvv],
            let expiryMonthString = fieldData[.expirationMonth], let expiryMonth = Int(expiryMonthString),
            let expiryYearString = fieldData[.expirationYear], let expiryYear = Int(expiryYearString)
        else { return }

        do {
            let creditCard = try CreditCardData(cardNumber: cardNumber, cvv: cvv, expiryMonth: expiryMonth, expiryYear: expiryYear,
                                                billingData: self.billingData ?? BillingData())
            self.didCreatePaymentMethodCompletion?(creditCard)
        } catch let error as MLError {
            errorWhileCreatingPaymentMethod(error: error)
        } catch {
            showAlert(title: "Error", body: "An error occurred while adding the Credit Card: \(error.localizedDescription)")
        }
    }
}
