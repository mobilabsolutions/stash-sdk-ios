//
//  ItemsController.swift
//  Demo
//
//  Created by Rupali Ghate on 08.05.19.
//  Copyright © 2019 Rupali Ghate. All rights reserved.
//

import MobilabPaymentCore
import UIKit

class ItemsController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: - Properties

    private let itemCellId = "itemCellId"

    private let cellHeight: CGFloat = 104

    private let items: [Item] = [Item(title: "mobiLab", description: "t-Shirt print", picture: "imageCard", price: 23.95),
                                 Item(title: "notebook paper", description: "quadrille Pads", picture: "imageCardNotes", price: 3.5),
                                 Item(title: "mobilab sticker", description: "12 sticker sheet", picture: "imageCardSticker", price: 23.95),
                                 Item(title: "mobilab pen", description: "blue color", picture: "imageCardPen", price: 23.95),
                                 Item(title: "mobilab", description: "female T-Shirt", picture: "imageCard", price: 23.95)]

    private let configuration: PaymentMethodUIConfiguration

    private let toast = ToastView()

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

        setTitle(title: "List of Items")

        view.addSubview(self.collectionView)
        self.collectionView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor)
        self.setupCollectionView()
    }

    private func setupCollectionView() {
        self.collectionView.register(ItemCell.self, forCellWithReuseIdentifier: self.itemCellId)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }

    // MARK: - Collectionview methods

    func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return self.items.count
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width - (self.defaultInset * 2)

        return CGSize(width: width, height: self.cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ItemCell = collectionView.dequeueCell(reuseIdentifier: self.itemCellId, for: indexPath)
        let item = self.items[indexPath.row]
        cell.setup(with: item, configuration: nil)
        cell.delegate = self

        return cell
    }

    // MARK: Helpers

    private func addSelectedItem(item: Item) {
        if let tabbarController: MainTabBarController = self.tabBarController as? MainTabBarController {
            guard let itemIndex = tabbarController.cartItems.firstIndex(where: { $0.item.id == item.id }) else {
                tabbarController.cartItems.insert((1, item), at: 0)
                return
            }
            tabbarController.cartItems[itemIndex].quantity += 1
        }
    }
}

extension ItemsController: ItemCellDelegate {
    func didSelectAddOption(for item: Item) {
        self.addSelectedItem(item: item)

        DispatchQueue.main.async {
            ToastView().showMessage(withText: "\(item.title.capitalized) added to the cart")
        }
    }

    func didSelectRemoveOption(for _: Item) {}
}
