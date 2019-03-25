//
//  CreditCardInputCollectionViewController.swift
//  MobilabPaymentBSPayone
//
//  Created by Robert on 18.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentCore
import MobilabPaymentUI
import UIKit

class CreditCardInputCollectionViewController: UICollectionViewController, PaymentMethodDataProvider,
    UICollectionViewDelegateFlowLayout, DoneButtonUpdater {
    private let cardNumberReuseIdentifier = "cardNumberCell"
    private let textReuseIdentifier = "textCell"
    private let dateReuseIdentifier = "dateCell"
    private let headerReuseIdentifier = "header"

    private let cellInset: CGFloat = 18

    var didCreatePaymentMethodCompletion: ((RegistrationData) -> Void)?
    var doneButtonUpdating: DoneButtonUpdating?

    private let billingData: BillingData?
    private var fieldData: [NecessaryData: String] = [:]

    private enum ValidationError: CustomStringConvertible {
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

    private var errors: [NecessaryData: ValidationError] = [:]

    private enum CreditCardNecessaryDataCell: Int, CaseIterable {
        case nameCell = 0
        case cardNumberCell
        case dateCVVCell

        var necessaryData: [NecessaryData] {
            switch self {
            case .nameCell: return [.holderName]
            case .cardNumberCell: return [.cardNumber]
            case .dateCVVCell: return [.expirationMonth, .expirationYear, .cvv]
            }
        }
    }

    private struct CreditCardParsedData {
        let holderName: String
        let cardNumber: String
        let cvv: String
        let expirationMonth: Int
        let expirationYear: Int

        static func create(holderNameText: String?,
                           cardNumberText: String?,
                           cvvText: String?,
                           expirationMonthText: String?,
                           expirationYearText: String?) -> (CreditCardParsedData?, [(NecessaryData, ValidationError)]) {
            var errors: [(NecessaryData, ValidationError)] = []

            if holderNameText == nil || holderNameText?.isEmpty == true {
                errors.append((.holderName, .noData(explanation: "Please provide the card holder name")))
            }

            if cardNumberText == nil || cardNumberText?.isEmpty == true {
                errors.append((.cardNumber, .noData(explanation: "Please provide your card number")))
            }

            if cvvText == nil || cvvText.flatMap({ Int($0) }) == nil {
                errors.append((.cvv, .noData(explanation: "Please provide a valid CVV")))
            }

            if expirationMonthText.flatMap({ Int($0) }).flatMap({ $0 >= 0 }) != true {
                errors.append((.expirationMonth, .noData(explanation: "Please provide a valid expiration date")))
            }

            if expirationYearText.flatMap({ Int($0) }).flatMap({ $0 >= 0 }) != true {
                errors.append((.expirationYear, .noData(explanation: "Please provide a valid expiration date")))
            }

            guard let holderName = holderNameText,
                let cardNumber = cardNumberText, let cvv = cvvText,
                let expirationMonth = expirationMonthText.flatMap({ Int($0) }),
                let expirationYear = expirationYearText.flatMap({ Int($0) }),
                errors.isEmpty
            else { return (nil, errors) }

            let parsedData = CreditCardParsedData(holderName: holderName,
                                                  cardNumber: cardNumber,
                                                  cvv: cvv,
                                                  expirationMonth: expirationMonth,
                                                  expirationYear: expirationYear)
            return (parsedData, [])
        }
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
        self.collectionView.register(TextInputCollectionViewCell.self, forCellWithReuseIdentifier: self.cardNumberReuseIdentifier)
        self.collectionView.register(DateCVVInputCollectionViewCell.self, forCellWithReuseIdentifier: self.dateReuseIdentifier)
        self.collectionView.register(TitleHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: self.headerReuseIdentifier)

        self.collectionView.backgroundColor = UIConstants.iceBlue
        self.doneButtonUpdating?.updateDoneButton(enabled: self.isDone())
    }

    func errorWhileCreatingPaymentMethod(error: MLError) {
        UIViewControllerTools.showAlert(on: self, title: "Error",
                                        body: "Could not create credit card method: \(error.errorDescription ?? "Unknown error")")
    }

    private func isDone() -> Bool {
        return CreditCardNecessaryDataCell.allCases
            .flatMap { $0.necessaryData }
            .allSatisfy { self.fieldData[$0] != nil }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return CreditCardNecessaryDataCell.allCases.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let necessaryDataCell = CreditCardNecessaryDataCell(rawValue: indexPath.item)
        else { fatalError("Index path does not correspond to any necessary data item") }

        let toReturn: UICollectionViewCell

        switch necessaryDataCell {
        case .nameCell:
            let cell: TextInputCollectionViewCell = dequeueCell(collectionView: collectionView,
                                                                reuseIdentifier: textReuseIdentifier, for: indexPath)
            cell.setup(text: fieldData[.holderName], title: "Cardholder name", placeholder: "Name", dataType: .holderName, error: errors[.holderName]?.description, delegate: self)
            toReturn = cell
        case .cardNumberCell:
            let cell: TextInputCollectionViewCell = dequeueCell(collectionView: collectionView,
                                                                reuseIdentifier: cardNumberReuseIdentifier, for: indexPath)
            cell.setup(text: fieldData[.cardNumber], title: "Credit card number", placeholder: "1234", dataType: .cardNumber, textFieldUpdateCallback: { textField in
                textField.attributedText = CreditCardUtils.formattedNumber(number: textField.text ?? "")
            }, error: errors[.cardNumber]?.description, delegate: self)
            toReturn = cell
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

            cell.setup(date: date,
                       cvv: self.fieldData[.cvv],
                       dateError: self.errors[.expirationMonth]?.description ?? self.errors[.expirationYear]?.description,
                       cvvError: self.errors[.cvv]?.description,
                       delegate: self)
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

    private func dequeueCell<T: UICollectionViewCell>(collectionView: UICollectionView,
                                                      reuseIdentifier: String, for indexPath: IndexPath) -> T {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? T
        else { fatalError("Should be able to dequeue \(T.self) for \(reuseIdentifier)") }
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as? TitleHeaderView
        else { fatalError("Should be able to dequeue TitleHeaderView as header supplementary vie for \(self.headerReuseIdentifier)") }

        view.title = "Credit Card"

        return view
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let isLastRow = indexPath.row == self.collectionView(collectionView, numberOfItemsInSection: indexPath.section) - 1
        let hasError = CreditCardNecessaryDataCell(rawValue: indexPath.row)?.necessaryData.contains(where: { self.errors[$0] != nil }) ?? false

        let additionalHeight: CGFloat = (isLastRow ? 16 : 0) + (hasError ? 18 : 0)
        return CGSize(width: self.view.frame.width - 2 * self.cellInset, height: 85 + additionalHeight)
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        return 0
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, referenceSizeForHeaderInSection _: Int) -> CGSize {
        return CGSize(width: self.view.frame.width - 2 * self.cellInset, height: 65)
    }
}

extension CreditCardInputCollectionViewController: DataPointProvidingDelegate {
    func didUpdate(value: String?, for dataPoint: NecessaryData) {
        self.fieldData[dataPoint] = value?.isEmpty == false ? value : nil
        self.errors[dataPoint] = nil
        self.doneButtonUpdating?.updateDoneButton(enabled: self.isDone())
    }
}

extension CreditCardInputCollectionViewController: DoneButtonViewDelegate {
    func didTapDoneButton() {
        let createdData = CreditCardParsedData.create(holderNameText: fieldData[.holderName],
                                                      cardNumberText: fieldData[.cardNumber],
                                                      cvvText: fieldData[.cvv],
                                                      expirationMonthText: fieldData[.expirationMonth],
                                                      expirationYearText: fieldData[.expirationYear])

        if !createdData.1.isEmpty {
            createdData.1.forEach({
                self.errors[$0.0] = $0.1
            })

            self.collectionView.reloadData()
        }

        guard let parsedData = createdData.0
        else { return }

        do {
            let creditCard = try CreditCardData(cardNumber: parsedData.cardNumber,
                                                cvv: parsedData.cvv,
                                                expiryMonth: parsedData.expirationMonth,
                                                expiryYear: parsedData.expirationYear,
                                                holderName: parsedData.holderName,
                                                billingData: self.billingData ?? BillingData())

            guard creditCard.cardType.bsCardTypeIdentifier != nil
            else { self.errors[.cardNumber] = .noKnownCreditCardProvider; return }

            self.didCreatePaymentMethodCompletion?(creditCard)
        } catch let error as MLError {
            self.errors[.cardNumber] = .creditCardValidationFailed(message: error.failureReason ?? "Please enter a valid credit card")
            self.collectionView.reloadData()
        } catch {
            UIViewControllerTools.showAlert(on: self, title: "Error",
                                            body: "An error occurred while adding the Credit Card: \(error.localizedDescription)")
        }
    }
}
