//
//  FormCollectionViewController.swift
//  MobilabPaymentCore
//
//  Created by Robert on 18.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import UIKit

open class FormCollectionViewController: UICollectionViewController, PaymentMethodDataProvider,
    UICollectionViewDelegateFlowLayout, DoneButtonUpdater {
    private let textReuseIdentifier = "textCell"
    private let pairedTextReuseIdentifier = "pairedTextCell"
    private let dateCVVCell = "dateCVVCell"
    private let headerReuseIdentifier = "header"

    private let cellInset: CGFloat = 18
    private let defaultCellHeight: CGFloat = 85
    private let defaultHeaderHeight: CGFloat = 65
    private let lastCellHeightSurplus: CGFloat = 16
    private let errorCellHeightSurplus: CGFloat = 18

    public var didCreatePaymentMethodCompletion: ((RegistrationData) -> Void)?
    public var doneButtonUpdating: DoneButtonUpdating?

    private var cellModels: [FormCellModel] = []

    public let billingData: BillingData?

    public var country: Country?

    private let configuration: PaymentMethodUIConfiguration
    private let formTitle: String

    public weak var formConsumer: FormConsumer?

    private var fieldData: [NecessaryData: String] = [:]
    private var errors: [NecessaryData: ValidationError] = [:]

    private weak var selectedCountryTextField: UITextField?

    public init(billingData: BillingData?, configuration: PaymentMethodUIConfiguration, formTitle: String) {
        self.billingData = billingData
        self.configuration = configuration
        self.formTitle = formTitle

        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView.register(TextInputCollectionViewCell.self, forCellWithReuseIdentifier: self.textReuseIdentifier)
        self.collectionView.register(PairedTextInputCollectionViewCell.self, forCellWithReuseIdentifier: self.pairedTextReuseIdentifier)
        self.collectionView.register(DateCVVInputCollectionViewCell.self, forCellWithReuseIdentifier: self.dateCVVCell)
        self.collectionView.register(TitleHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: self.headerReuseIdentifier)

        self.collectionView.backgroundColor = self.configuration.backgroundColor
        self.doneButtonUpdating?.updateDoneButton(enabled: self.isDone())
    }

    public func setCellModel(cellModels: [FormCellModel]) {
        self.cellModels = cellModels
    }

    public func showCountryListing(textField: UITextField) {
        let countryName = textField.text ?? ""
        let countryVC = CountryListCollectionViewController(countryName: countryName, configuration: configuration)
        countryVC.delegate = self
        self.selectedCountryTextField = textField
        self.navigationController?.pushViewController(countryVC, animated: true)
    }

    public func errorWhileCreatingPaymentMethod(error: MobilabPaymentError) {
        switch error {
        case .configuration:
            UIViewControllerTools.showAlert(on: self, title: "Configuration Error",
                                            body: "A configuration error occurred. This should not happen.")
        case .network:
            UIViewControllerTools.showAlert(on: self, title: "Network Error",
                                            body: "An error occurred. Please retry.")
        case let .temporary(error):
            let insertedErrorCode = error.thirdPartyErrorCode.flatMap { "(\($0)) " } ?? ""
            UIViewControllerTools.showAlert(on: self, title: "Temporary Error",
                                            body: "A temporary error \(insertedErrorCode)occurred. Please retry.")
        case let .userActionable(error):
            UIViewControllerTools.showAlert(on: self, title: "Error",
                                            body: "An error occurred: \(error.description)")
        case let .validation(error):
            UIViewControllerTools.showAlert(on: self, title: "Validation Error",
                                            body: error.description)
        case let .other(error):
            let insertedErrorCode = error.thirdPartyErrorCode.flatMap { "(\($0)) " } ?? ""
            UIViewControllerTools.showAlert(on: self, title: "Error",
                                            body: "An error \(insertedErrorCode)occurred.")
        }
    }

    private func isDone() -> Bool {
        return self.cellModels.count == 0 ? false : self.cellModels
            .flatMap { $0.necessaryData }
            .allSatisfy { self.fieldData[$0] != nil }
    }

    // MARK: UICollectionViewDataSource

    open override func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    open override func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return self.cellModels.count
    }

    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let toReturn: UICollectionViewCell & NextCellEnabled

        let type = self.cellModels[indexPath.row].type

        switch type {
        case let .text(data):
            let cell: TextInputCollectionViewCell = collectionView.dequeueCell(reuseIdentifier: self.textReuseIdentifier, for: indexPath)
            cell.setup(text: self.fieldData[data.necessaryData],
                       title: data.title,
                       placeholder: data.placeholder,
                       dataType: data.necessaryData,
                       textFieldFocusGainCallback: { data.didFocus?($0) },
                       textFieldUpdateCallback: { data.didUpdate?(data.necessaryData, $0) },
                       error: self.errors[data.necessaryData]?.description,
                       setupTextField: { data.setup?(data.necessaryData, $0) },
                       configuration: self.configuration,
                       delegate: self)

            toReturn = cell

        case let .pairedText(data):
            let cell: PairedTextInputCollectionViewCell = collectionView.dequeueCell(reuseIdentifier: self.pairedTextReuseIdentifier, for: indexPath)
            cell.setup(firstText: self.fieldData[data.firstNecessaryData],
                       firstTitle: data.firstTitle,
                       firstPlaceholder: data.firstPlaceholder,
                       firstDataType: data.firstNecessaryData,
                       secondText: self.fieldData[data.secondNecessaryData],
                       secondTitle: data.secondTitle,
                       secondPlaceholder: data.secondPlaceholder,
                       secondDataType: data.secondNecessaryData,
                       textFieldUpdateCallback: { data.didUpdate?(data.firstNecessaryData, $0) },
                       firstError: self.errors[data.firstNecessaryData]?.description,
                       secondError: self.errors[data.secondNecessaryData]?.description,
                       setupTextField: { data.setup?(data.firstNecessaryData, $0) },
                       configuration: self.configuration, delegate: self)

            toReturn = cell

        case .dateCVV:
            let cell: DateCVVInputCollectionViewCell = collectionView.dequeueCell(reuseIdentifier: self.dateCVVCell, for: indexPath)

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
                       delegate: self,
                       configuration: self.configuration)

            toReturn = cell
        }

        toReturn.nextCellSwitcher = self

        if indexPath.item == 0 {
            toReturn.layer.cornerRadius = 4
            toReturn.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            toReturn.layer.masksToBounds = true
        } else if indexPath.item == self.collectionView(collectionView, numberOfItemsInSection: indexPath.section) - 1 {
            toReturn.layer.cornerRadius = 4
            toReturn.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            toReturn.layer.masksToBounds = true

            toReturn.isLastCell = true
        }

        return toReturn
    }

    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as? TitleHeaderView
        else { fatalError("Should be able to dequeue TitleHeaderView as header supplementary vie for \(self.headerReuseIdentifier)") }

        view.title = self.formTitle
        view.configuration = self.configuration

        return view
    }

    public func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let isLastRow = indexPath.row == self.collectionView(collectionView, numberOfItemsInSection: indexPath.section) - 1
        var additionalHeight: CGFloat = (isLastRow ? lastCellHeightSurplus : 0)

        let hasError = self.cellModels[indexPath.row].necessaryData.contains(where: { self.errors[$0] != nil })
        additionalHeight += (hasError ? self.errorCellHeightSurplus : 0)

        return CGSize(width: self.view.frame.width - 2 * self.cellInset, height: self.defaultCellHeight + additionalHeight)
    }

    public func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        return 0
    }

    public func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, referenceSizeForHeaderInSection _: Int) -> CGSize {
        return CGSize(width: self.view.frame.width - 2 * self.cellInset, height: self.defaultHeaderHeight)
    }
}

extension FormCollectionViewController: DataPointProvidingDelegate {
    func didUpdate(value: String?, for dataPoint: NecessaryData) {
        self.fieldData[dataPoint] = value?.isEmpty == false ? value : nil
        self.errors[dataPoint] = nil
        self.doneButtonUpdating?.updateDoneButton(enabled: self.isDone())
    }
}

extension FormCollectionViewController: DoneButtonViewDelegate {
    public func didTapDoneButton() {
        do {
            try self.formConsumer?.consumeValues(data: self.fieldData)
        } catch let error as FormConsumerError {
            self.errors = error.errors
            self.collectionView.reloadData()
        } catch let error as MobilabPaymentError {
            self.errorWhileCreatingPaymentMethod(error: error)
        } catch {
            print("Error while validating: \(error). This should not happen.")
        }
    }
}

extension FormCollectionViewController: NextCellSwitcher {
    func switchToNextCell(from cell: UICollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell)
        else { return }

        if indexPath.item == self.collectionView(self.collectionView, numberOfItemsInSection: indexPath.section) - 1 {
            cell.endEditing(true)
            return
        }

        guard let nextCell = collectionView.cellForItem(at: IndexPath(item: indexPath.item + 1, section: indexPath.section)) as? NextCellEnabled
        else { return }

        nextCell.selectCell()
    }
}

extension FormCollectionViewController: CountryListCollectionViewControllerDelegate {
    func didSelectCountry(country: Country) {
        self.country = country
        self.didUpdate(value: country.alpha2Code, for: NecessaryData.country) // sending 2 digit ISO country-cod
        self.selectedCountryTextField?.text = country.name
    }
}
