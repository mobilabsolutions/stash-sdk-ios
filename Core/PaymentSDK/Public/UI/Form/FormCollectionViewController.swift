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
    private let dateCVVCell = "dateCVVCell"
    private let headerReuseIdentifier = "header"

    private let cellInset: CGFloat = 18
    private let defaultCellHeight: CGFloat = 85
    private let defaultHeaderHeight: CGFloat = 65
    private let lastCellHeightSurplus: CGFloat = 16
    private let errorCellHeightSurplus: CGFloat = 18

    public var didCreatePaymentMethodCompletion: ((RegistrationData) -> Void)?
    public var doneButtonUpdating: DoneButtonUpdating?

    private let cellModels: [FormCellModel]

    public let billingData: BillingData?

    private let configuration: PaymentMethodUIConfiguration
    private let formTitle: String

    public weak var formConsumer: FormConsumer?

    private var fieldData: [NecessaryData: String] = [:]
    private var errors: [NecessaryData: ValidationError] = [:]

    public init(billingData: BillingData?, configuration: PaymentMethodUIConfiguration, cellModels: [FormCellModel], formTitle: String) {
        self.billingData = billingData
        self.configuration = configuration
        self.cellModels = cellModels
        self.formTitle = formTitle

        super.init(collectionViewLayout: UICollectionViewFlowLayout())

        if let name = billingData?.name {
            self.fieldData[.holderName] = name
        }
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView.register(TextInputCollectionViewCell.self, forCellWithReuseIdentifier: self.textReuseIdentifier)
        self.collectionView.register(DateCVVInputCollectionViewCell.self, forCellWithReuseIdentifier: self.dateCVVCell)
        self.collectionView.register(TitleHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: self.headerReuseIdentifier)

        self.collectionView.backgroundColor = self.configuration.backgroundColor
        self.doneButtonUpdating?.updateDoneButton(enabled: self.isDone())
    }

    open func errorWhileCreatingPaymentMethod(error: MobilabPaymentError) {
        UIViewControllerTools.showAlert(on: self, title: "Error",
                                        body: "An error occurred: \(error.description)")
    }

    private func isDone() -> Bool {
        return self.cellModels
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

        switch self.cellModels[indexPath.row].type {
        case let .text(data):
            let cell: TextInputCollectionViewCell = collectionView.dequeueCell(reuseIdentifier: textReuseIdentifier, for: indexPath)
            cell.setup(text: fieldData[data.necessaryData],
                       title: data.title,
                       placeholder: data.placeholder,
                       dataType: data.necessaryData,
                       textFieldUpdateCallback: { data.didUpdate?(data.necessaryData, $0) },
                       error: errors[data.necessaryData]?.description,
                       setupTextField: { data.setup?(data.necessaryData, $0) },
                       configuration: configuration,
                       delegate: self)

            toReturn = cell
        case .dateCVV:
            let cell: DateCVVInputCollectionViewCell = collectionView.dequeueCell(reuseIdentifier: dateCVVCell, for: indexPath)

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

        view.title = formTitle
        view.configuration = configuration

        return view
    }

    public func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let isLastRow = indexPath.row == self.collectionView(collectionView, numberOfItemsInSection: indexPath.section) - 1
        let hasError = cellModels[indexPath.row].necessaryData
            .contains(where: { self.errors[$0] != nil })

        let additionalHeight: CGFloat = (isLastRow ? lastCellHeightSurplus : 0) + (hasError ? errorCellHeightSurplus : 0)
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
