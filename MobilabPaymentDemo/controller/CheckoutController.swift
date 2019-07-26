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

    private let cartManager = CartManager.shared

    private var totalAmount: NSDecimalNumber = 0 {
        didSet {
            DispatchQueue.main.async {
                self.amountValueLabel.text = self.totalAmount.toCurrency()
            }
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

    private let emptyCartInfoView = EmptyCartInfoView()

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

        setTitle(title: "Check-out")

        self.setupViews()
        self.setupCollectionView()

        self.loadCartItems()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.calculateTotalAmount()
        self.collectionView.reloadAsync()
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
        self.updateScreen(isCartEmpty: self.cartManager.cartItems.count == 0)

        return self.cartManager.cartItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ItemCell = collectionView.dequeueCell(reuseIdentifier: self.cellId, for: indexPath)

        let item = self.cartManager.cartItems[indexPath.item]
        let quantity = self.cartManager.cartItems[indexPath.item].quantity
        cell.setup(with: item, quantity: quantity, shouldShowQuantity: true, configuration: nil)
        cell.delegate = self

        return cell
    }

    // MARK: Handlers

    override func handleScreenButtonPress() { // from BaseViewController
        super.handleScreenButtonPress()

        self.showPaymentMethodScreen()
    }

    // MARK: - Helpers

    private func setupViews() {
        view.addSubview(self.amountInfoContainerView)
        self.amountInfoContainerView.anchor(leading: view.leadingAnchor,
                                            bottom: availableBottomAnchor,
                                            trailing: view.trailingAnchor,
                                            paddingLeft: defaultInset,
                                            paddingBottom: defaultInset,
                                            paddingRight: defaultInset,
                                            height: self.amountViewHeight)

        self.amountInfoContainerView.addSubview(self.totalAmountLabel)
        self.totalAmountLabel.anchor(top: self.amountInfoContainerView.topAnchor, leading: self.amountInfoContainerView.leadingAnchor, bottom: self.amountInfoContainerView.bottomAnchor)

        self.amountInfoContainerView.addSubview(self.amountValueLabel)
        self.amountValueLabel.anchor(top: self.amountInfoContainerView.topAnchor, bottom: self.amountInfoContainerView.bottomAnchor, trailing: self.amountInfoContainerView.trailingAnchor)

        view.addSubview(self.collectionView)
        self.collectionView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: self.amountInfoContainerView.topAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor, paddingTop: defaultTopPadding)

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
        //toggle collectionview visibility based on if the cart is empty or not.
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

    private func calculateTotalAmount() {
        self.totalAmount = self.cartManager.cartItems.reduce(0.0) { ($1.price.multiplying(by: NSDecimalNumber(value: $1.quantity))).adding($0) }
    }

    private func loadCartItems() {
        self.cartManager.getAllCartItems { result in
            switch result {
            case .success:
                self.collectionView.reloadAsync()
                self.calculateTotalAmount()
            case let .failure(err):
                self.showAlert(title: "Cart Error", message: "Failed to load cart items.\n\(err.localizedDescription)", completion: nil)
                return
            }
        }
    }
}

extension CheckoutController: ItemCellDelegate {
    //  Delegate called when user clicks on '+' button of specific item to increase item quantity (by 1)
    func didSelectAddOption(for item: Item) {
        DispatchQueue.global(qos: .background).sync {
            // get index of matching item from cart item array
            guard let itemIndex: Int = cartManager.cartItems.firstIndex(where: { $0.id == item.id }) else {
                return
            }
            cartManager.addToCart(item: self.cartManager.cartItems[itemIndex]) { err in
                if let err = err {
                    self.showAlert(title: "Error", message: "Failed to add item in the cart.\n\(err.localizedDescription)", completion: nil)
                    return
                }
                DispatchQueue.main.sync {
                    // reload cell
                    let indexPath = IndexPath(item: itemIndex, section: 0)
                    self.collectionView.reloadItems(at: [indexPath])
                    self.totalAmount = self.totalAmount.adding(item.price)
                }
            }
        }
    }

    //  Delegate called when user clicks on '-' button of specific item to reduce its quantity (by 1)
    func didSelectRemoveOption(for item: Item) {
        DispatchQueue.global(qos: .background).sync {
            guard let itemIndex: Int = self.cartManager.cartItems.firstIndex(where: { $0.id == item.id }) else { return }
            let indexPath = IndexPath(item: itemIndex, section: 0)
            let itemQuantity = self.cartManager.cartItems[itemIndex].quantity
            let price = self.cartManager.cartItems[itemIndex].price

            // reduce item quantity by 1
            cartManager.decrementItemQuantity(item: item) { err in
                if let err = err {
                    self.showAlert(title: "Error", message: "Failed to remove item .\n\(err.localizedDescription)", completion: nil)
                    return
                }

                DispatchQueue.main.sync {
                    // if only one quantity of the item was left before reducing - remove that item from collection view and cartItems
                    if itemQuantity == 1 {
                        self.collectionView.deleteItems(at: [indexPath])
                    } else {
                        self.collectionView.reloadItems(at: [indexPath])
                    }
                    self.totalAmount = self.totalAmount.subtracting(price)
                }
            }
        }
    }
}

extension CheckoutController: PaymentMethodControllerDelegate {
    func didFinishPayment(err: Error?) {
        if let err = err {
            showAlert(title: "Payment Error", message: "Failed to make payment.\n\(err.localizedDescription)", completion: nil)
            return
        }
        // clear cart on successful payment
        self.cartManager.emptyCart { err in
            if let err = err {
                self.showAlert(title: "Cart Error", message: "Failed to clear cart.\n\(err.localizedDescription)", completion: nil)
                self.collectionView.reloadAsync()
            } else {
                self.loadCartItems()

                DispatchQueue.main.async {
                    if let mainTabBarController: MainTabBarController = self.tabBarController as? MainTabBarController {
                        // switch to item list tab once payment is done
                        mainTabBarController.selectedIndex = 0
                    }
                }
            }
        }
    }
}
