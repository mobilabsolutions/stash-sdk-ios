//
//  FormCollectionViewController.swift
//  StashCore
//
//  Created by Robert on 18.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import StashCore
import UIKit

/// A base view controller for Form-like inputs
class FormCollectionViewController: UICollectionViewController, PaymentMethodDataProvider,
    UICollectionViewDelegateFlowLayout, DoneButtonUpdater {
    private let textReuseIdentifier = "textCell"
    private let pairedTextReuseIdentifier = "pairedTextCell"
    private let dateCVVCellReuseIdentifier = "dateCVVCell"
    private let countryCellReuseIdentifier = "countryCell"
    private let headerReuseIdentifier = "header"

    private let cellInset: CGFloat = 18
    private let defaultCellHeight: CGFloat = 85
    private let defaultHeaderHeight: CGFloat = 65
    private let lastCellHeightSurplus: CGFloat = 16
    private let errorCellHeightSurplus: CGFloat = 18
    private let numberOfSecondsUntilIdleFieldValidation: TimeInterval = 3

    /// The callback that should be called once the done button is pressed with valid input data present
    var didCreatePaymentMethodCompletion: ((RegistrationData) -> Void)?
    /// The delegate that updates the done button.
    var doneButtonUpdating: DoneButtonUpdating?

    private var cellModels: [FormCellModel] = []

    /// Billing data that should be filled in where appropriate
    let billingData: BillingData?

    private let configuration: PaymentMethodUIConfiguration
    private let formTitle: String

    /// A form consumer that both validates and makes use of provided data
    weak var formConsumer: FormConsumer?

    private var fieldData: [NecessaryData: PresentableValueHolding] = [:]
    private var errors: [NecessaryData: ValidationError] = [:]
    private var fieldErrorDelegates: [NecessaryData: FormFieldErrorDelegate] = [:]

    private var currentIdleFieldTimer: (timer: Timer, dataPoint: NecessaryData)?

    private weak var selectedCountryTextField: UITextField?
    private var alertBanner: AlertBanner?

    /// Create a new form view controller
    ///
    /// - Parameters:
    ///   - billingData: The billing data that should be considered and possibly pre-filled in the UI
    ///   - configuration: The UI configuration to use for customization of the UI
    ///   - formTitle: The title of the form which will be presented above the form fields
    init(billingData: BillingData?, configuration: PaymentMethodUIConfiguration, formTitle: String) {
        self.billingData = billingData
        self.configuration = configuration
        self.formTitle = formTitle

        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }

    /// Not implemented and should not be used.
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView.register(TextInputCollectionViewCell.self, forCellWithReuseIdentifier: self.textReuseIdentifier)
        self.collectionView.register(PairedTextInputCollectionViewCell.self, forCellWithReuseIdentifier: self.pairedTextReuseIdentifier)
        self.collectionView.register(DateCVVInputCollectionViewCell.self, forCellWithReuseIdentifier: self.dateCVVCellReuseIdentifier)
        self.collectionView.register(CountryInputCollectionViewCell.self, forCellWithReuseIdentifier: self.countryCellReuseIdentifier)

        self.collectionView.register(TitleHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: self.headerReuseIdentifier)

        self.collectionView.backgroundColor = self.configuration.backgroundColor
        self.collectionView.contentInsetAdjustmentBehavior = .always

        self.doneButtonUpdating?.updateDoneButton(enabled: self.isDone())
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.currentIdleFieldTimer?.timer.invalidate()
    }

    /// Set the form's cell models
    ///
    /// - Parameter cellModels: The cell models that should be used to create the form fields
    func setCellModel(cellModels: [FormCellModel]) {
        self.cellModels = cellModels
    }

    /// Present an error alert when an error occurs during payment method creation
    ///
    /// - Parameter error: The error that occurred
    func errorWhileCreatingPaymentMethod(error: StashError) {
        self.doneButtonUpdating?.updateDoneButton(enabled: self.isDone())

        if let existingBanner = self.alertBanner {
            self.close(banner: existingBanner)
        }

        let banner: AlertBanner?

        switch error {
        case .configuration:
            banner = UIViewControllerTools.showAlertBanner(on: self, title: "Configuration Error",
                                                           body: "A configuration error occurred. This should not happen. \(error.title)",
                                                           uiConfiguration: self.configuration)
        case .network:
            banner = UIViewControllerTools.showAlertBanner(on: self, title: "Network Error",
                                                           body: "An error occurred. Please retry.",
                                                           uiConfiguration: self.configuration)
        case let .temporary(error):
            let insertedErrorCode = error.thirdPartyErrorCode.flatMap { "(\($0)) " } ?? ""
            banner = UIViewControllerTools.showAlertBanner(on: self, title: "Temporary Error",
                                                           body: "A temporary error \(insertedErrorCode)occurred. \(error.title). Please retry.",
                                                           uiConfiguration: self.configuration)
        case let .validation(error):
            banner = UIViewControllerTools.showAlertBanner(on: self, title: "Validation Error",
                                                           body: "\(error.title). \(error.description)",
                                                           uiConfiguration: self.configuration)
        case let .other(error):
            let insertedErrorCode = error.thirdPartyErrorCode.flatMap { "(\($0))" } ?? ""
            banner = UIViewControllerTools.showAlertBanner(on: self, title: error.title,
                                                           body: "\(error.description) \(insertedErrorCode)",
                                                           uiConfiguration: self.configuration)
        case .userCancelled:
            // The user cancelled the action, we should dismiss ourselves
            banner = nil
            self.dismiss(animated: true, completion: nil)
        }

        self.alertBanner = banner
    }

    private func isDone(errors: [NecessaryData: ValidationError]) -> Bool {
        return self.cellModels.count == 0 ? false : self.cellModels
            .flatMap { $0.necessaryData }
            .allSatisfy { self.fieldData[$0] != nil && errors[$0] == nil }
    }

    private func isDone() -> Bool {
        return self.isDone(errors: self.errors)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return self.cellModels.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let toReturn: UICollectionViewCell & NextCellEnabled & FormFieldErrorDelegate

        let type = self.cellModels[indexPath.row].type

        switch type {
        case let .text(data):
            let cell: TextInputCollectionViewCell = collectionView.dequeueCell(reuseIdentifier: self.textReuseIdentifier, for: indexPath)
            cell.setup(text: self.fieldData[data.necessaryData]?.title,
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
            cell.setup(firstText: self.fieldData[data.firstNecessaryData]?.title,
                       firstTitle: data.firstTitle,
                       firstPlaceholder: data.firstPlaceholder,
                       firstDataType: data.firstNecessaryData,
                       secondText: self.fieldData[data.secondNecessaryData]?.title,
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
            let cell: DateCVVInputCollectionViewCell = collectionView.dequeueCell(reuseIdentifier: self.dateCVVCellReuseIdentifier, for: indexPath)

            let date: (month: Int, year: Int)?
            if let year = fieldData[.expirationYear]?.value as? Int,
                let month = fieldData[.expirationMonth]?.value as? Int {
                date = (month: month, year: year)
            } else {
                date = nil
            }

            cell.setup(date: date,
                       cvv: self.fieldData[.cvv]?.title,
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

        case .country:
            let cell: CountryInputCollectionViewCell = collectionView.dequeueCell(reuseIdentifier: self.countryCellReuseIdentifier, for: indexPath)
            cell.setup(country: self.fieldData[.country]?.value as? Country,
                       error: self.errors[.country]?.description,
                       configuration: self.configuration,
                       delegate: self)

            self.fieldErrorDelegates[.country] = cell

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

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as? TitleHeaderView
        else { fatalError("Should be able to dequeue TitleHeaderView as header supplementary vie for \(self.headerReuseIdentifier)") }

        view.title = self.formTitle
        view.configuration = self.configuration

        return view
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let isLastRow = indexPath.row == self.collectionView(collectionView, numberOfItemsInSection: indexPath.section) - 1
        var additionalHeight: CGFloat = (isLastRow ? self.lastCellHeightSurplus : 0)

        let hasError = !self.cellModels[indexPath.row].necessaryData.filter { self.errors[$0] != nil }.isEmpty
        let numberOfDataPoints = self.cellModels[indexPath.row].necessaryData.count
        // If there are multiple fields in the cell, the error will need more lines to be displayed.
        let errorSurplus = numberOfDataPoints > 1 ? 2 * self.errorCellHeightSurplus : self.errorCellHeightSurplus

        additionalHeight += hasError ? errorSurplus : 0

        return CGSize(width: self.view.frame.width - 2 * self.cellInset, height: self.defaultCellHeight + additionalHeight)
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        return 0
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, referenceSizeForHeaderInSection _: Int) -> CGSize {
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
        let newTimer = Timer.scheduledTimer(withTimeInterval: self.numberOfSecondsUntilIdleFieldValidation, repeats: false) { [weak self] _ in
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
        self.doneButtonUpdating?.updateDoneButton(enabled: self.isDone())

        if hadError != hasError {
            // We need to recompute cell heights because there is a new error
            // or an old error disappeared
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }
}

extension FormCollectionViewController: DataPointProvidingDelegate {
    func didUpdate(value: PresentableValueHolding?, for dataPoint: NecessaryData) {
        self.fieldData[dataPoint] = value
        self.updateFieldIdleTimer(for: dataPoint)

        let validationResult = self.formConsumer?.validate(data: self.fieldData)

        if self.errors[dataPoint] != nil {
            self.errors[dataPoint] = validationResult?.errors[dataPoint]
            self.fieldErrorDelegates[dataPoint]?.setError(description: self.errors[dataPoint]?.description, forDataPoint: dataPoint)
            self.collectionView.collectionViewLayout.invalidateLayout()
        }

        self.doneButtonUpdating?.updateDoneButton(enabled: self.isDone(errors: validationResult?.errors ?? self.errors))
    }
}

extension FormCollectionViewController: DoneButtonViewDelegate {
    /// Called when the done button was tapped
    func didTapDoneButton() {
        let existingBanner = self.alertBanner

        do {
            self.doneButtonUpdating?.updateDoneButton(enabled: false)
            try self.formConsumer?.consumeValues(data: self.fieldData)

            if let banner = existingBanner {
                self.close(banner: banner)
            }

        } catch let error as FormConsumerError {
            self.errors = error.errors
            self.collectionView.reloadData()
        } catch let error as StashError {
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

extension FormCollectionViewController: CountryInputPresentingDelegate {
    func presentCountryInput(countryDelegate: CountryListCollectionViewControllerDelegate) {
        // If we are currently editing a text field, the keyboard should be hidden
        self.view.endEditing(true)

        let country = self.fieldData[.country]?.value as? Country ?? Locale.current.getDeviceRegion()

        let countryViewController = CountryListCollectionViewController(country: country,
                                                                        configuration: configuration)
        countryViewController.delegate = countryDelegate
        self.navigationController?.pushViewController(countryViewController, animated: true)

        guard let index = self.cellModels.firstIndex(where: {
            if case FormCellModel.FormCellType.country = $0.type {
                return true
            }
            return false
        })
        else { return }

        self.checkPreviousCellsValidity(from: IndexPath(item: index, section: 0), dataPoint: .country)
    }
}

extension FormCollectionViewController: CountryListCollectionViewControllerDelegate {
    func didSelectCountry(country: Country) {
        self.didUpdate(value: CountryValueHolding(country: country), for: .country)
        self.selectedCountryTextField?.text = country.name
    }
}

extension FormCollectionViewController: AlertBannerDelegate {
    func close(banner: AlertBanner) {
        banner.removeFromSuperview()
    }
}
