//
//  PaymentMethodController.swift
//  Demo
//
//  Created by Rupali Ghate on 08.05.19.
//  Copyright © 2019 Rupali Ghate. All rights reserved.
//

import MobilabPaymentCore
import UIKit

class PaymentMethodController: BaseCollectionViewController {
    // MARK: - Properties

    private enum SectionType: Int {
        case PaymentMethodList = 0
        case AddPaymentMethod

        var index: Int {
            return self.rawValue
        }
    }

    private let addPaymentMethodCellId = "addPaymentMethod"
    private let paymentMethodCellId = "paymentMethod"

    private let cellRadius: CGFloat = 8
    private let defaultInsetValue: CGFloat = 16
    private let paymentMethodListSectionInsets: UIEdgeInsets
    private let addPaymentMethodSectionInsets: UIEdgeInsets

    private let paymentMethodListCellHeight: CGFloat = 86
    private let addPaymentMethodCellHeight: CGFloat = 55
    private let paymentMethodListSectionLineSpacing: CGFloat = 8
    private let addPaymentMethodSectionLineSpacing: CGFloat = 18

    private let configuration: PaymentMethodUIConfiguration

    private var registeredPaymentMethods: [PaymentMethod] = []

    // MARK: - Initializers

    override init(configuration: PaymentMethodUIConfiguration) {
        self.configuration = configuration

        self.paymentMethodListSectionInsets = UIEdgeInsets(top: 42, left: self.defaultInsetValue, bottom: 8, right: self.defaultInsetValue)
        self.addPaymentMethodSectionInsets = UIEdgeInsets(top: 10, left: self.defaultInsetValue, bottom: self.defaultInsetValue, right: self.defaultInsetValue)

        super.init(configuration: configuration)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setTitle(title: "Payment Methods")

        self.collectionView.register(PaymentMethodCell.self, forCellWithReuseIdentifier: self.paymentMethodCellId)
        self.collectionView.register(CustomLabelCell.self, forCellWithReuseIdentifier: self.addPaymentMethodCellId)
    }

    // MARK: - Collectionview methods

    override func numberOfSections(in _: UICollectionView) -> Int {
        return 2
    }

    override func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == SectionType.PaymentMethodList.index ? self.registeredPaymentMethods.count : 1
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width - (self.defaultInsetValue * 2)

        return indexPath.section == SectionType.PaymentMethodList.index ? CGSize(width: width, height: self.paymentMethodListCellHeight) :
            CGSize(width: width, height: self.addPaymentMethodCellHeight)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let toReturn: UICollectionViewCell

        if indexPath.section == SectionType.PaymentMethodList.index {
            let cell: PaymentMethodCell = collectionView.dequeueCell(reuseIdentifier: self.paymentMethodCellId, for: indexPath) // PaymentSDK method
            let paymentMethod = self.registeredPaymentMethods[indexPath.row]
            let cellImage = self.getImage(for: paymentMethod.type)
            cell.setup(image: cellImage, title: paymentMethod.type.rawValue, subTitle: paymentMethod.humanReadableIdentifier)
            cell.delegate = self
            toReturn = cell
        } else {
            let cell: CustomLabelCell = collectionView.dequeueCell(reuseIdentifier: self.addPaymentMethodCellId, for: indexPath) // PaymentSDK method
            cell.setup(title: "Add new payment method", configuration: nil)
            toReturn = cell
        }
        toReturn.layer.cornerRadius = self.cellRadius
        toReturn.layer.masksToBounds = false

        return toReturn
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return section == SectionType.PaymentMethodList.index ? self.paymentMethodListSectionLineSpacing : self.addPaymentMethodSectionLineSpacing
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == SectionType.PaymentMethodList.index {
            return self.paymentMethodListSectionInsets
        }
        return self.addPaymentMethodSectionInsets
    }

    override func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)

        if indexPath.section == SectionType.AddPaymentMethod.index {
            self.addNewPaymentMethod()
        }
    }

    // MARK: - Helpers

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
                let readableDetails = (value.paymentMethodType == .creditCard && value.humanReadableIdentifier != nil) ?
                    self.formatCardDetails(cardNumber: value.humanReadableIdentifier!) : value.humanReadableIdentifier

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

    #warning("should include card expiry date as well")
    private func formatCardDetails(cardNumber: String) -> String? {
        let formattedDetails = cardNumber.count < 4 ? cardNumber : String(cardNumber.suffix(4))
        return "X-" + formattedDetails + " \u{2022} " // "\u{2022}" for  bullet symbol
    }

    private func addNewItem(for paymentMethod: PaymentMethod) {
        self.registeredPaymentMethods.insert(paymentMethod, at: 0)
        let indexPath = IndexPath(item: 0, section: 0)
        self.collectionView.insertItems(at: [indexPath])
    }

    private func getImage(for type: PaymentMethodType) -> UIImage? {
        var image: UIImage?
        switch type {
        case .creditCard:
            image = UIConstants.creditCardImage
        case .payPal:
            image = UIConstants.payPalImage
        case .sepa:
            image = UIConstants.sepaImage
        }
        return image
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
