//
//  PaymentMethodController.swift
//  Demo
//
//  Created by Rupali Ghate on 08.05.19.
//  Copyright © 2019 Rupali Ghate. All rights reserved.
//

import MobilabPaymentCore
import UIKit

protocol PaymentMethodControllerDelegate: class {
    #warning("Use proper response code once merchant backend is integrated")
    func didFinishPayment(with result: Error?)
}

class PaymentMethodController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: - Properties

    weak var delegate: PaymentMethodControllerDelegate?

    private enum SectionType: Int {
        case paymentMethodList = 0
        case addPaymentMethod

        var index: Int {
            return self.rawValue
        }
    }

    private let addPaymentMethodCellId = "addPaymentMethod"
    private let paymentMethodCellId = "paymentMethod"

    private let paymentMethodListCellHeight: CGFloat = 86
    private let addPaymentMethodCellHeight: CGFloat = 70

    private let configuration: PaymentMethodUIConfiguration

    private var shouldMakePayment: Bool
    private var amount: NSDecimalNumber
    private var registeredPaymentMethods: [PaymentMethod] = []

    // MARK: - Initializers

    override init(configuration: PaymentMethodUIConfiguration) {
        self.configuration = configuration
        self.shouldMakePayment = false
        self.amount = 0
        super.init(configuration: configuration)
    }

    init(withPaymentOption shouldMakePayment: Bool, amount: NSDecimalNumber, configuration: PaymentMethodUIConfiguration) {
        self.shouldMakePayment = shouldMakePayment
        self.amount = amount
        self.configuration = configuration
        super.init(configuration: configuration)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let mainTabBarController: MainTabBarController = self.tabBarController as? MainTabBarController {
            self.registeredPaymentMethods = mainTabBarController.paymentMethods
        }

        self.setupViews()
        self.setupCollectionView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let mainTabBarController: MainTabBarController = self.tabBarController as? MainTabBarController {
            mainTabBarController.paymentMethods = self.registeredPaymentMethods
        }
    }

    // MARK: - Collectionview methods

    func numberOfSections(in _: UICollectionView) -> Int {
        return self.shouldMakePayment ? 1 : 2
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == SectionType.paymentMethodList.index ? self.registeredPaymentMethods.count : 1
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width - (self.defaultInset * 2)

        return indexPath.section == SectionType.paymentMethodList.index ? CGSize(width: width, height: self.paymentMethodListCellHeight) :
            CGSize(width: width, height: self.addPaymentMethodCellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let toReturn: UICollectionViewCell

        if indexPath.section == SectionType.paymentMethodList.index {
            let cell: PaymentMethodCell = collectionView.dequeueCell(reuseIdentifier: self.paymentMethodCellId, for: indexPath) // PaymentSDK method
            let paymentMethod = self.registeredPaymentMethods[indexPath.row]
            let image = self.getImage(for: paymentMethod.type)
            let title = self.getName(for: paymentMethod.type)
            cell.setup(image: image, title: title, subTitle: paymentMethod.humanReadableIdentifier, shouldShowSelection: self.shouldMakePayment, configuration: nil)
            cell.delegate = self
            toReturn = cell
        } else {
            let cell: CustomIconLabelCell = collectionView.dequeueCell(reuseIdentifier: self.addPaymentMethodCellId, for: indexPath) // PaymentSDK method
            cell.setup(title: "Add new payment method", iconImage: UIConstants.addImage, configuration: nil)
            toReturn = cell
        }
        return toReturn
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == SectionType.addPaymentMethod.index {
            self.addNewPaymentMethod()
        } else if self.shouldMakePayment, let cell = collectionView.cellForItem(at: indexPath) as? PaymentMethodCell {
            updateSelection(forCell: cell)
        }
    }

    // MARK: Handlers

    override func handleScreenButtonSelection() {
        showAlert(title: "Payment Result", message: "Payment completed successfully.") {
            self.delegate?.didFinishPayment(with: nil)
            self.navigationController?.popViewController(animated: true)
        }
    }

    // MARK: - Helpers

    private func setupViews() {
        let title = self.shouldMakePayment == true ? "Select Payment Method" : "Payment Methods"
        setTitle(title: title)

        setButtonVisibility(to: self.shouldMakePayment)
        if self.shouldMakePayment {
            setButtonTitle(title: "PAY \(self.amount.toCurrency())")
            // keep 'pay' button disabled initially
            setButtonInteraction(to: false)
        }
        view.addSubview(self.collectionView)
        self.collectionView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: availableBottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor,
                                   paddingTop: defaultTopPadding)
    }

    private func setupCollectionView() {
        self.collectionView.register(PaymentMethodCell.self, forCellWithReuseIdentifier: self.paymentMethodCellId)
        self.collectionView.register(CustomIconLabelCell.self, forCellWithReuseIdentifier: self.addPaymentMethodCellId)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }

    private func addNewPaymentMethod() {
        let paymentManager = PaymentMethodManager.shared
        paymentManager.addNewPaymentMethod(viewController: self) { [weak self] result in
            guard let self = self else { return }
            self.handleRegistrationResponse(result: result)
        }
    }

    private func handleRegistrationResponse(result: RegistrationResult) {
        switch result {
        case let .success(value):
            DispatchQueue.main.async {
                let readableDetails: String

                switch value.extraAliasInfo {
                case let .creditCard(details):
                    readableDetails = self.formatCardDetails(extra: details)
                case let .sepa(details):
                    readableDetails = details.maskedIban
                case let .payPal(details):
                    readableDetails = details.email ?? ""
                }

                let paymentMethod = PaymentMethod(type: value.paymentMethodType, alias: value.alias, humanReadableIdentifier: readableDetails)
                self.addNewItem(for: paymentMethod)

                self.dismiss(animated: true) {
                    UIViewControllerTools.showAlert(on: self, title: "Success", body: "Successfully registered payment method")
                }
            }
            AliasManager.shared.save(alias: Alias(alias: value.alias ?? "No alias provided", expirationYear: nil, expirationMonth: nil, type: .unknown))
        case .failure:
            break
        }
    }

    private func formatCardDetails(extra: PaymentMethodAlias.CreditCardExtraInfo) -> String {
        return extra.creditCardMask + " • \(extra.expiryMonth)/\(extra.expiryYear)"
    }

    private func addNewItem(for paymentMethod: PaymentMethod) {
        self.registeredPaymentMethods.insert(paymentMethod, at: 0)
        let indexPath = IndexPath(item: 0, section: 0)
        self.collectionView.insertItems(at: [indexPath])
    }

    private func getImage(for type: PaymentMethodType) -> UIImage? {
        let image: UIImage?
        switch type {
        case .creditCard:
            image = UIConstants.maestroImage
        case .payPal:
            image = UIConstants.payPalImage
        case .sepa:
            image = UIConstants.sepaImage
        }
        return image
    }

    private func getName(for type: PaymentMethodType) -> String {
        switch type {
        case .creditCard:
            return "Credit Card"
        case .payPal:
            return "PayPal"
        case .sepa:
            return "SEPA"
        }
    }
}

extension PaymentMethodController: PaymentMethodCellDelegate {
    func didSelectOption(selectionEnabled: Bool, for cell: PaymentMethodCell) {
        guard let indexPath = collectionView.indexPath(for: cell)
        else { return }

        if selectionEnabled {
            self.updateSelection(forCell: cell)

        } else {
            if indexPath.item < self.collectionView(self.collectionView, numberOfItemsInSection: indexPath.section) {
                self.registeredPaymentMethods.remove(at: indexPath.row)
                self.collectionView.deleteItems(at: [indexPath])
            }
        }
    }

    // MARK: - Helpers

    private func updateSelection(forCell currentCell: PaymentMethodCell) {
        DispatchQueue.main.async {
            self.collectionView.performBatchUpdates({
                self.collectionView.visibleCells.forEach { cell in
                    // reset selection of all collectionview cells
                    if let cell = cell as? PaymentMethodCell {
                        cell.resetSelection()
                    }
                }
            }, completion: { _ in
                // show selection for selected cell
                currentCell.setSelection()
                // enable 'Pay' button since the payment method is selected
                self.setButtonInteraction(to: true)
            })
        }
    }
}
