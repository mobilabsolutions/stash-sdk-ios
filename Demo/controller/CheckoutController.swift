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

    private var totalAmount: Float = 0 {
        didSet {
            self.amountValueLabel.text = totalAmount.toCurrency()
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
        label.text = "0 €"
        
        return label
    }()

    private let amountInfoContainerView = UIView()

    private let emptyCartInfoView = CustomMessageView()

    // MARK: - Initializers
    
    override init(configuration: PaymentMethodUIConfiguration) {
        self.configuration = configuration
        super.init(configuration: configuration)

        if let mainTabBarController: MainTabBarController = self.tabBarController as? MainTabBarController {
            cartItems = mainTabBarController.cartItems
        }
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setTitle(title: "Check-out")

        setupViews()
        setupCollectionView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let mainTabBarController: MainTabBarController = self.tabBarController as? MainTabBarController {
            cartItems = mainTabBarController.cartItems
            totalAmount = cartItems.reduce(0.0) { $0 + ($1.item.price * Float($1.quantity))}
        }

        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let mainTabBarController: MainTabBarController = self.tabBarController as? MainTabBarController {
            mainTabBarController.cartItems = cartItems 
        }
    }

    // MARK: Collectionview methods
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width - (self.defaultInset * 2)
        
        return CGSize(width: width, height: self.cellHeight)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        updateScreen(isCartEmpty: cartItems.count == 0)
        return cartItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ItemCell = collectionView.dequeueCell(reuseIdentifier: cellId, for: indexPath)
        
        let item = cartItems[indexPath.item].item
        let quantity = cartItems[indexPath.item].quantity
        cell.setup(with: item, quantity: quantity, shouldShowQuantity: true, configuration: nil)
        cell.delegate = self
        
        return cell
    }
    
    // MARK: - Helpers
    private func setupViews() {
        view.addSubview(amountInfoContainerView)
        amountInfoContainerView.anchor(left: view.leftAnchor, bottom: availableBottomAnchor, right: view.rightAnchor,
                                       paddingLeft: defaultInset, paddingBottom: defaultInset, paddingRight: defaultInset,
                                       height: amountViewHeight)
        
        amountInfoContainerView.addSubview(totalAmountLabel)
        totalAmountLabel.anchor(top: amountInfoContainerView.topAnchor, left: amountInfoContainerView.leftAnchor, bottom: amountInfoContainerView.bottomAnchor)
        
        amountInfoContainerView.addSubview(amountValueLabel)
        amountValueLabel.anchor(top: amountInfoContainerView.topAnchor, bottom: amountInfoContainerView.bottomAnchor, right: amountInfoContainerView.rightAnchor)

        view.addSubview(collectionView)
        collectionView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: amountInfoContainerView.topAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: defaultSectionInsets.top, paddingLeft: defaultInset, paddingBottom: defaultInset, paddingRight: defaultInset)
        
        view.insertSubview(emptyCartInfoView, at: 0)
        emptyCartInfoView.frame = view.frame
        
        setButtonTitle(title: "CHECK-OUT")
    }

    private func setupCollectionView() {
        collectionView.register(ItemCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func updateScreen(isCartEmpty: Bool) {
        collectionView.isHidden = isCartEmpty
        amountInfoContainerView.isHidden = isCartEmpty
        setButtonVisibility(to: !isCartEmpty)
    }
}

extension CheckoutController: ItemCellDelegate {
    func didSelectAddOption(for item: Item) {
        //get index of matching item from cart item array
        guard let itemIndex: Int = cartItems.firstIndex(where: { $0.item.id == item.id } ) else {
            print("Item should be present in the cart")
            return
        }
        cartItems[itemIndex].quantity += 1
        //reload cell
        let indexPath = IndexPath(item: itemIndex, section: 0)
        collectionView.reloadItems(at: [indexPath])

        totalAmount += item.price
    }

    func didSelectRemoveOption(for item: Item) {
        //get index of matching item from cart item array
        guard let itemIndex: Int = cartItems.firstIndex(where: { $0.item.id == item.id } ) else { return }
        
        let indexPath = IndexPath(item: itemIndex, section: 0)
        let itemQuantity = cartItems[itemIndex].quantity
        let price = cartItems[itemIndex].item.price

        //if only one quantity of the item left - remove that item from collection view and cardItems
        if itemQuantity == 1 {
            cartItems.remove(at: itemIndex)
            collectionView.deleteItems(at: [indexPath])
        } else {
            cartItems[itemIndex].quantity -= 1
            collectionView.reloadItems(at: [indexPath])
        }
        totalAmount -= price
    }
}
