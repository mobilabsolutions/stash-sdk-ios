//
//  CheckoutController.swift
//  Demo
//
//  Created by Rupali Ghate on 08.05.19.
//  Copyright © 2019 Rupali Ghate. All rights reserved.
//

import MobilabPaymentCore
import UIKit

class CheckoutController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: - Properties

    private let cellId = "cellId"

    private let cellHeight: CGFloat = 104
    private let amountViewHeight: CGFloat = 32

    private let configuration: PaymentMethodUIConfiguration
    private var cartItems = [(quantity: Int, item: Item)]()

    private var totalAmount: NSDecimalNumber = 0 {
        didSet {
            self.amountValueLabel.text = self.totalAmount.toCurrency()
        }
    }

    private lazy var totalAmountLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIConstants.defaultFont(of: 18, type: .bold)
        label.textColor = UIConstants.dark
        label.text = "Total Amount"

        return label
    }()

    private lazy var amountValueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = UIConstants.defaultFont(of: 24, type: .black)
        label.textColor = UIConstants.aquamarine
        label.text = NSDecimalNumber(integerLiteral: 0).toCurrency()

        return label
    }()

    private let amountInfoContainerView = UIView()

    private let emptyCartInfoView = CustomMessageView()

    // MARK: - Initializers

    override init(configuration: PaymentMethodUIConfiguration) {
        self.configuration = configuration
        super.init(configuration: configuration)

        if let mainTabBarController: MainTabBarController = self.tabBarController as? MainTabBarController {
            self.cartItems = mainTabBarController.cartItems
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setTitle(title: "Check-out")

        self.setupViews()
        self.setupCollectionView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let mainTabBarController: MainTabBarController = self.tabBarController as? MainTabBarController {
            self.cartItems = mainTabBarController.cartItems
            self.totalAmount = self.cartItems.reduce(0.0) { ($1.item.price.multiplying(by: NSDecimalNumber(value: $1.quantity))).adding($0)
            }
        }

        self.collectionView.reloadAsync()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let mainTabBarController: MainTabBarController = self.tabBarController as? MainTabBarController {
            mainTabBarController.cartItems = self.cartItems
        }
    }

    // MARK: Collectionview methods

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let width = view.frame.width - (self.defaultInset * 2)

        return CGSize(width: width, height: self.cellHeight)
    }

    func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        self.updateScreen(isCartEmpty: self.cartItems.count == 0)
        return self.cartItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ItemCell = collectionView.dequeueCell(reuseIdentifier: self.cellId, for: indexPath)

        let item = self.cartItems[indexPath.item].item
        let quantity = self.cartItems[indexPath.item].quantity
        cell.setup(with: item, quantity: quantity, shouldShowQuantity: true, configuration: nil)
        cell.delegate = self

        return cell
    }

    // MARK: Handlers

    override func handleScreenButtonSelection() {
        self.showPaymentMethodScreen()
    }

    // MARK: - Helpers

    private func setupViews() {
        view.addSubview(self.amountInfoContainerView)
        self.amountInfoContainerView.anchor(left: view.leftAnchor, bottom: availableBottomAnchor, right: view.rightAnchor,
                                            paddingLeft: defaultInset, paddingBottom: defaultInset, paddingRight: defaultInset,
                                            height: self.amountViewHeight)

        self.amountInfoContainerView.addSubview(self.totalAmountLabel)
        self.totalAmountLabel.anchor(top: self.amountInfoContainerView.topAnchor, left: self.amountInfoContainerView.leftAnchor, bottom: self.amountInfoContainerView.bottomAnchor)

        self.amountInfoContainerView.addSubview(self.amountValueLabel)
        self.amountValueLabel.anchor(top: self.amountInfoContainerView.topAnchor, bottom: self.amountInfoContainerView.bottomAnchor, right: self.amountInfoContainerView.rightAnchor)

        view.addSubview(self.collectionView)
        self.collectionView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: availableBottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: defaultTopPadding)

        view.insertSubview(self.emptyCartInfoView, at: 0)
        self.emptyCartInfoView.frame = view.frame

        setButtonTitle(title: "CHECK-OUT")
    }

    private func setupCollectionView() {
        self.collectionView.register(ItemCell.self, forCellWithReuseIdentifier: self.cellId)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }

    private func updateScreen(isCartEmpty: Bool) {
        self.collectionView.isHidden = isCartEmpty
        self.amountInfoContainerView.isHidden = isCartEmpty
        setButtonVisibility(to: !isCartEmpty)
    }

    private func showPaymentMethodScreen() {
        let paymentMethodController = PaymentMethodController(withPaymentOption: true, amount: totalAmount, configuration: configuration)
        self.navigationController?.pushViewController(paymentMethodController, animated: true)
        self.tabBarController?.tabBar.isHidden = true
        paymentMethodController.delegate = self
    }
}

extension CheckoutController: ItemCellDelegate {
    func didSelectAddOption(for item: Item) {
        // get index of matching item from cart item array
        guard let itemIndex: Int = cartItems.firstIndex(where: { $0.item.id == item.id }) else {
            print("Item should be present in the cart")
            return
        }
        self.cartItems[itemIndex].quantity += 1
        // reload cell
        let indexPath = IndexPath(item: itemIndex, section: 0)
        collectionView.reloadItems(at: [indexPath])

        self.totalAmount = self.totalAmount.adding(item.price)
    }

    func didSelectRemoveOption(for item: Item) {
        // get index of matching item from cart item array
        guard let itemIndex: Int = cartItems.firstIndex(where: { $0.item.id == item.id }) else { return }

        let indexPath = IndexPath(item: itemIndex, section: 0)
        let itemQuantity = self.cartItems[itemIndex].quantity
        let price = self.cartItems[itemIndex].item.price

        // if only one quantity of the item left - remove that item from collection view and cardItems
        if itemQuantity == 1 {
            self.cartItems.remove(at: itemIndex)
            self.collectionView.deleteItems(at: [indexPath])
        } else {
            self.cartItems[itemIndex].quantity -= 1
            self.collectionView.reloadItems(at: [indexPath])
        }
        self.totalAmount = self.totalAmount.subtracting(price)
    }
}

extension CheckoutController: PaymentMethodControllerDelegate {
    func didFinishPayment(with result: Error?) {
        if let error = result {
            print(error)
        } else {
            if let mainTabBarController: MainTabBarController = self.tabBarController as? MainTabBarController {
                // switch to item list tab once payment is done
                mainTabBarController.selectedIndex = 0
                mainTabBarController.cartItems.removeAll()
            }
            self.totalAmount = 0
            self.collectionView.reloadAsync()
        }
    }
}
