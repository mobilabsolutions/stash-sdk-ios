//
//  PaymentMethodController.swift
//  Demo
//
//  Created by Rupali Ghate on 08.05.19.
//  Copyright © 2019 Rupali Ghate. All rights reserved.
//

import MobilabPaymentCore
import UIKit

class PaymentMethodController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: - Properties

    private enum SectionType: Int {
        case paymentMethodList = 0
        case addPaymentMethod

        var index: Int {
            return self.rawValue
        }
    }

    private let addPaymentMethodCellId = "addPaymentMethod"
    private let paymentMethodCellId = "paymentMethod"

    private lazy var paymentMethodListSectionInsets: UIEdgeInsets = self.defaultSectionInsets
    private lazy var addPaymentMethodSectionInsets: UIEdgeInsets = UIEdgeInsets(top: 10, left: self.defaultInset, bottom: self.defaultInset, right: defaultInset)

    private let paymentMethodListCellHeight: CGFloat = 86
    private let addPaymentMethodCellHeight: CGFloat = 70
    private let addPaymentMethodSectionLineSpacing: CGFloat = 18

    private let configuration: PaymentMethodUIConfiguration

    private var registeredPaymentMethods: [PaymentMethod] = []

    // MARK: - Initializers

    override init(configuration: PaymentMethodUIConfiguration) {
        self.configuration = configuration
        super.init(configuration: configuration)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setTitle(title: "Payment Methods")

        setupViews()
        setupCollectionView()
    }

    // MARK: - Collectionview methods

    func numberOfSections(in _: UICollectionView) -> Int {
        return 2
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
            cell.setup(image: image, title: title, subTitle: paymentMethod.humanReadableIdentifier, configuration: nil)
            cell.delegate = self
            toReturn = cell
        } else {
            let cell: CustomIconLabelCell = collectionView.dequeueCell(reuseIdentifier: self.addPaymentMethodCellId, for: indexPath) // PaymentSDK method
            cell.setup(title: "Add new payment method", iconImage: UIConstants.addImage, configuration: nil)
            toReturn = cell
        }
        return toReturn
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return section == SectionType.paymentMethodList.index ? self.defaultSectionLineSpacing : self.addPaymentMethodSectionLineSpacing
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == SectionType.paymentMethodList.index {
            return self.paymentMethodListSectionInsets
        }
        return self.addPaymentMethodSectionInsets
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == SectionType.addPaymentMethod.index {
            self.addNewPaymentMethod()
        }
    }

    // MARK: - Helpers
    private func setupViews() {
        view.addSubview(collectionView)
        collectionView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: availableBottomAnchor, right: view.rightAnchor,
                              paddingTop: paymentMethodListSectionInsets.top, paddingLeft: defaultInset, paddingBottom: defaultInset, paddingRight: defaultInset)
    }

    private func setupCollectionView() {
        collectionView.register(PaymentMethodCell.self, forCellWithReuseIdentifier: self.paymentMethodCellId)
        collectionView.register(CustomIconLabelCell.self, forCellWithReuseIdentifier: self.addPaymentMethodCellId)
        collectionView.delegate = self
        collectionView.dataSource = self
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
    func didSelectDeleteOption(from cell: UICollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell)
        else { return }

        if indexPath.item < self.collectionView(self.collectionView, numberOfItemsInSection: indexPath.section) {
            self.registeredPaymentMethods.remove(at: indexPath.row)
            self.collectionView.deleteItems(at: [indexPath])
        }
    }
}
