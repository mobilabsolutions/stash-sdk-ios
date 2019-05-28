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
    private let numberOfSecondsUntilIdleFieldValidation: TimeInterval = 3

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
    private var fieldErrorDelegates: [NecessaryData: FormFieldErrorDelegate] = [:]

    private var currentIdleFieldTimer: (timer: Timer, dataPoint: NecessaryData)?

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
        self.collectionView.contentInsetAdjustmentBehavior = .always

        self.doneButtonUpdating?.updateDoneButton(enabled: self.isDone())
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.currentIdleFieldTimer?.timer.invalidate()
    }

    public func setCellModel(cellModels: [FormCellModel]) {
        self.cellModels = cellModels
    }

    public func showCountryListing(textField: UITextField, on viewController: UIViewController) {
        var countryName = textField.text ?? ""
        // get device locale if textfield is empty
        if countryName.isEmpty {
            let deviceCountry = Locale.current.getDeviceRegion()
            countryName = deviceCountry?.name ?? ""
        }
        let countryVC = CountryListCollectionViewController(countryName: countryName, configuration: configuration)
        countryVC.delegate = self
        self.selectedCountryTextField = textField
        viewController.navigationController?.pushViewController(countryVC, animated: true)
    }

    public func errorWhileCreatingPaymentMethod(error: MobilabPaymentError) {
        switch error {
        case .configuration:
            UIViewControllerTools.showAlertBanner(on: self, title: "Configuration Error",
                                                  body: "A configuration error occurred. This should not happen.",
                                                  uiConfiguration: self.configuration)
        case .network:
            UIViewControllerTools.showAlertBanner(on: self, title: "Network Error",
                                                  body: "An error occurred. Please retry.",
                                                  uiConfiguration: self.configuration)
        case let .temporary(error):
            let insertedErrorCode = error.thirdPartyErrorCode.flatMap { "(\($0)) " } ?? ""
            UIViewControllerTools.showAlertBanner(on: self, title: "Temporary Error",
                                                  body: "A temporary error \(insertedErrorCode)occurred. Please retry.",
                                                  uiConfiguration: self.configuration)
        case let .validation(error):
            UIViewControllerTools.showAlertBanner(on: self, title: "Validation Error",
                                                  body: error.description,
                                                  uiConfiguration: self.configuration)
        case let .other(error):
            let insertedErrorCode = error.thirdPartyErrorCode.flatMap { "(\($0))" } ?? ""
            UIViewControllerTools.showAlertBanner(on: self, title: "Error",
                                                  body: "An error occurred: \(error.description) \(insertedErrorCode)",
                                                  uiConfiguration: self.configuration)
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
        let toReturn: UICollectionViewCell & NextCellEnabled & FormFieldErrorDelegate

        let type = self.cellModels[indexPath.row].type

        switch type {
        case let .text(data):
            let cell: TextInputCollectionViewCell = collectionView.dequeueCell(reuseIdentifier: self.textReuseIdentifier, for: indexPath)
            cell.setup(text: self.fieldData[data.necessaryData],
                       title: data.title,
                       placeholder: data.placeholder,
                       dataType: data.necessaryData,
                       textFieldGainFocusCallback: { [weak self] field, dataPoint in
                           self?.checkPreviousCellsValidity(from: indexPath, dataPoint: dataPoint)
                           self?.updateFieldIdleTimer(for: dataPoint)
                           data.didFocus?(field)
                       },
                       textFieldLoseFocusCallback: { [weak self] in self?.formFieldDidLoseFocus(for: $1) },
                       textFieldUpdateCallback: { field, dataPoint in data.didUpdate?(dataPoint, field) },
                       error: self.errors[data.necessaryData]?.description,
                       setupTextField: { data.setup?($1, $0) },
                       configuration: self.configuration,
                       delegate: self)

            self.fieldErrorDelegates[data.necessaryData] = cell

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
                       textFieldGainFocusCallback: { [weak self] _, dataPoint in
                           self?.updateFieldIdleTimer(for: dataPoint)
                           self?.checkPreviousCellsValidity(from: indexPath,
                                                            dataPoint: dataPoint)

                       },
                       textFieldLoseFocusCallback: { [weak self] in self?.formFieldDidLoseFocus(for: $1) },
                       textFieldUpdateCallback: { field, dataPoint in data.didUpdate?(dataPoint, field) },
                       firstError: self.errors[data.firstNecessaryData]?.description,
                       secondError: self.errors[data.secondNecessaryData]?.description,
                       setupTextField: { field, dataPoint in data.setup?(dataPoint, field) },
                       configuration: self.configuration, delegate: self)

            self.fieldErrorDelegates[data.firstNecessaryData] = cell
            self.fieldErrorDelegates[data.secondNecessaryData] = cell

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
                       textFieldGainFocusCallback: { [weak self] _, dataPoint in
                           self?.updateFieldIdleTimer(for: dataPoint)
                           self?.checkPreviousCellsValidity(from: indexPath,
                                                            dataPoint: dataPoint)
                       },
                       textFieldLoseFocusCallback: { [weak self] in self?.formFieldDidLoseFocus(for: $1) },
                       delegate: self,
                       configuration: self.configuration)

            self.fieldErrorDelegates[.cvv] = cell
            self.fieldErrorDelegates[.expirationYear] = cell
            self.fieldErrorDelegates[.expirationMonth] = cell

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

        let numberOfErrors = self.cellModels[indexPath.row].necessaryData.filter({ self.errors[$0] != nil }).count
        additionalHeight += CGFloat(numberOfErrors) * self.errorCellHeightSurplus

        return CGSize(width: self.view.frame.width - 2 * self.cellInset, height: self.defaultCellHeight + additionalHeight)
    }

    public func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        return 0
    }

    public func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, referenceSizeForHeaderInSection _: Int) -> CGSize {
        return CGSize(width: self.view.frame.width - 2 * self.cellInset - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right,
                      height: self.defaultHeaderHeight)
    }

    private func checkPreviousCellsValidity(from indexPath: IndexPath, dataPoint: NecessaryData) {
        let validationResult = self.formConsumer?.validate(data: self.fieldData)

        var previousValuesInCurrentCell: [NecessaryData: Int] = [:]

        for previousDataPoint in self.cellModels[indexPath.item].necessaryData {
            guard dataPoint != previousDataPoint
            else { break }
            previousValuesInCurrentCell[previousDataPoint] = indexPath.item
        }

        let valuesToConsider = self.cellModels[0..<indexPath.item].enumerated().reduce([NecessaryData: Int]()) { dict, value in
            var dict = dict
            value.element.necessaryData.forEach { dict[$0] = value.offset }
            return dict
        }.merging(previousValuesInCurrentCell) { _, new in new }

        let newErrors = validationResult?.errors.filter { valuesToConsider[$0.key] != nil }
        self.errors = self.errors.merging(newErrors ?? [:], uniquingKeysWith: { _, new in new })

        for (dataPoint, error) in self.errors {
            self.fieldErrorDelegates[dataPoint]?.setError(description: error.description, forDataPoint: dataPoint)
        }

        self.collectionView.collectionViewLayout.invalidateLayout()
    }

    private func updateFieldIdleTimer(for dataPoint: NecessaryData) {
        let newTimer = Timer.scheduledTimer(withTimeInterval: numberOfSecondsUntilIdleFieldValidation, repeats: false) { [weak self] _ in
            self?.updateErrorForSingleDataPoint(dataPoint: dataPoint)
        }

        self.currentIdleFieldTimer?.timer.invalidate()
        self.currentIdleFieldTimer = (newTimer, dataPoint)
    }

    private func formFieldDidLoseFocus(for dataPoint: NecessaryData) {
        self.currentIdleFieldTimer?.timer.invalidate()
        self.currentIdleFieldTimer = nil
        self.updateErrorForSingleDataPoint(dataPoint: dataPoint)
    }

    private func updateErrorForSingleDataPoint(dataPoint: NecessaryData) {
        let validationResult = self.formConsumer?.validate(data: self.fieldData)

        let hadError = self.errors[dataPoint] != nil
        let hasError = validationResult?.errors[dataPoint] != nil

        self.errors[dataPoint] = validationResult?.errors[dataPoint]
        self.fieldErrorDelegates[dataPoint]?.setError(description: validationResult?.errors[dataPoint]?.description, forDataPoint: dataPoint)

        if hadError != hasError {
            // We need to recompute cell heights because there is a new error
            // or an old error disappeared
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }
}

extension FormCollectionViewController: DataPointProvidingDelegate {
    func didUpdate(value: String?, for dataPoint: NecessaryData) {
        self.fieldData[dataPoint] = value?.isEmpty == false ? value : nil
        self.updateFieldIdleTimer(for: dataPoint)

        if self.errors[dataPoint] != nil {
            let validationResult = self.formConsumer?.validate(data: self.fieldData)

            self.errors[dataPoint] = validationResult?.errors[dataPoint]
            self.fieldErrorDelegates[dataPoint]?.setError(description: errors[dataPoint]?.description, forDataPoint: dataPoint)
            self.collectionView.collectionViewLayout.invalidateLayout()
        }

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
        self.selectedCountryTextField?.text = country.name
    }
}

extension FormCollectionViewController: AlertBannerDelegate {
    func close(banner: AlertBanner) {
        banner.removeFromSuperview()
    }
}
