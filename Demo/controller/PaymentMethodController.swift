//
//  PaymentMethodController.swift
//  Demo
//
//  Created by Rupali Ghate on 08.05.19.
//  Copyright © 2019 Rupali Ghate. All rights reserved.
//

import CoreData
import MobilabPaymentCore
import UIKit

protocol PaymentMethodControllerDelegate: class {
    func didFinishPayment(error: Error?)
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

    private let appDelegate = UIApplication.shared.delegate as! AppDelegate

    private let addPaymentMethodCellId = "addPaymentMethod"
    private let paymentMethodCellId = "paymentMethod"

    private let paymentMethodListCellHeight: CGFloat = 86
    private let addPaymentMethodCellHeight: CGFloat = 70

    private let configuration: PaymentMethodUIConfiguration

    private var shouldMakePayment: Bool
    private var amount: NSDecimalNumber
    private var registeredPaymentMethods: [(method: PaymentMethod, entity: PaymentMethodEntity)] = []
    private var selectedPaymentMethod: PaymentMethod?

    private var user = User()

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

        self.fetchPaymentMethods()
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
            let image = self.getImage(for: paymentMethod.method)
            let title = self.getName(for: paymentMethod.method.type)
            cell.setup(image: image, title: title, subTitle: paymentMethod.method.humanReadableIdentifier, shouldShowSelection: self.shouldMakePayment, configuration: nil)
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
            self.selectedPaymentMethod = self.registeredPaymentMethods[indexPath.row].method
            updateSelection(forCell: cell)
        }
    }

    // MARK: Handlers

    override func handleScreenButtonPress() {
        guard let paymentMethod = selectedPaymentMethod, let paymentMethodId = paymentMethod.paymentMethodId else { return }

        let currency = Locale.current.currencyCode ?? "EUR"
        let description = "Test Payment"
        showActivityIndicator()

        let amountInCents = self.amount.multiplying(by: 100) // ampunt in cents

        PaymentService.shared.makePayment(forPaymentMethodId: paymentMethodId, amount: amountInCents, currency: currency, description: description) { err in
            self.hideActivityIndicator()
            if let err = err {
                self.showAlert(title: "Payment Error", message: "Error occurred during payment.\n\(err)", completion: {})
                self.delegate?.didFinishPayment(error: err)
            } else {
                self.showAlert(title: "Payment Result", message: "Payment completed successfully.") {
                    self.delegate?.didFinishPayment(error: nil)
                    self.navigationController?.popViewController(animated: true)
                }
            }
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

    private func fetchPaymentMethods() {
        DispatchQueue.global(qos: .background).async {
            guard !self.user.getUserId().isEmpty else {
                DispatchQueue.main.async {
                    UIViewControllerTools.showAlert(on: self, title: "", body: "No user available")
                }
                return
            }

            self.showActivityIndicator()

            self.fetchFromDatabase(completion: { result in
                switch result {
                case let .failure(err):
                    DispatchQueue.main.async {
                        self.hideActivityIndicator()
                        UIViewControllerTools.showAlert(on: self, title: "Error", body: err.localizedDescription)
                    }
                case let .success(paymentMethods):
                    self.registeredPaymentMethods = paymentMethods
                    self.collectionView.reloadAsync()

                    PaymentService.shared.getPaymentMethods(for: self.user.userId) { result in
                        self.hideActivityIndicator()
                        switch result {
                        case let .failure(err):
                            DispatchQueue.main.async {
                                UIViewControllerTools.showAlert(on: self, title: "Error", body: err.localizedDescription)
                            }
                        case .success:
                            break
                        }
                    }
                }
            })
        }
    }

    private func fetchFromDatabase(completion: @escaping (Result<[(method: PaymentMethod, entity: PaymentMethodEntity)], Error>) -> Void) {
        let managedContext = self.appDelegate.persistentContainer.viewContext

        let fetchRequest: NSFetchRequest<PaymentMethodEntity> = PaymentMethodEntity.fetchRequest()
        var paymetMethods: [(PaymentMethod, PaymentMethodEntity)] = []

        do {
            let entities = try managedContext.fetch(fetchRequest)
            for dataEntity in entities {
                guard let data = dataEntity.details else { continue }

                let method = try JSONDecoder().decode(PaymentMethod.self, from: data)
                paymetMethods.append((method, dataEntity))
            }
        } catch let err {
            completion(.failure(err))
        }
        completion(.success(paymetMethods))
    }

    private func addNewPaymentMethod() {
        let paymentManager = PaymentService.shared
        paymentManager.addNewPaymentMethod(viewController: self) { [weak self] result in
            guard let self = self else { return }
            self.handleRegistrationResponse(result: result)
        }
    }

    private func handleRegistrationResponse(result: RegistrationResult) {
        DispatchQueue.global(qos: .background).async {
            switch result {
            case let .success(value):
                DispatchQueue.main.async {
                    let paymentMethod = PaymentMethod(type: value.paymentMethodType, alias: value.alias ?? "", extraAliasInfo: value.extraAliasInfo, userId: self.user.userId, paymentMethodId: nil)

                    PaymentService.shared.createPaymentMethod(for: self.user, paymentMethod: paymentMethod, completion: { result in
                        switch result {
                        case let .failure(err):
                            self.dismiss(animated: true) {
                                UIViewControllerTools.showAlert(on: self, title: "Payment Method", body: err.localizedDescription)
                            }
                        case let .success(paymentMethodId):
                            paymentMethod.paymentMethodId = paymentMethodId
                            self.addNewItem(for: paymentMethod, completion: { err in
                                if let err = err {
                                    UIViewControllerTools.showAlert(on: self, title: "Error", body: err.localizedDescription)
                                    return
                                }
                                self.dismiss(animated: true) {
                                    UIViewControllerTools.showAlert(on: self, title: "Success", body: "Successfully registered payment method")
                                    AliasManager.shared.save(alias: Alias(alias: value.alias ?? "No alias provided", expirationYear: nil, expirationMonth: nil, type: .unknown))
                                }
                            })
                        }
                    })
                }
            case .failure:
                break
            }
        }
    }

    private func addNewItem(for paymentMethod: PaymentMethod, completion: @escaping (Error?) -> Void) {
        DispatchQueue.main.async {
            let managedContext = self.appDelegate.persistentContainer.viewContext

            do {
                let jsonData = try JSONEncoder().encode(paymentMethod)

                let entity = PaymentMethodEntity(context: managedContext)
                entity.details = jsonData
                try managedContext.save()

                let indexPath = IndexPath(item: self.registeredPaymentMethods.count, section: 0)
                self.registeredPaymentMethods.append((paymentMethod, entity))

                self.collectionView.insertItems(at: [indexPath])

                completion(nil)
            } catch let err as NSError {
                completion(err)
            }
        }
    }

    private func getImage(for paymentMethod: PaymentMethod) -> UIImage? {
        let image: UIImage?
        switch paymentMethod.type {
        case .creditCard:
            switch paymentMethod.extraAliasInfo {
            case let .creditCard(details):
                image = details.creditCardType.image
            default:
                image = UIConstants.creditCardImage
            }
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
            return
        }

        // delete button pressed
        if indexPath.item < self.collectionView(self.collectionView, numberOfItemsInSection: indexPath.section) {
            guard let paymentMethodId = registeredPaymentMethods[indexPath.row].method.paymentMethodId else { return }

            let entity = self.registeredPaymentMethods[indexPath.row].entity

            showActivityIndicator()
            PaymentService.shared.deletePaymentMethod(for: paymentMethodId) { err in
                if let err = err {
                    self.hideActivityIndicator()
                    self.showAlert(title: "Error", message: "Error while deleting payment method.\n\(err.localizedDescription)", completion: {})
                    return
                } else {
                    self.deleteFromDatabase(entity: entity, completion: { err in
                        self.hideActivityIndicator()
                        if let err = err {
                            self.showAlert(title: "Error", message: "Error while deleting payment method.\(err.localizedDescription)", completion: {})
                            return
                        }
                        DispatchQueue.main.async {
                            self.registeredPaymentMethods.remove(at: indexPath.row)
                            self.collectionView.deleteItems(at: [indexPath])
                        }
                    })
                }
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

    private func deleteFromDatabase(entity: PaymentMethodEntity, completion: @escaping (Error?) -> Void) {
        let managedContext = self.appDelegate.persistentContainer.viewContext
        managedContext.delete(entity)
        self.appDelegate.saveContext(completion: completion)
    }
}
