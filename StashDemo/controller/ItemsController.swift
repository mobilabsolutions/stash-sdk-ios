//
//  ItemsController.swift
//  Demo
//
//  Created by Rupali Ghate on 08.05.19.
//  Copyright © 2019 Rupali Ghate. All rights reserved.
//

import StashCore
import UIKit

class ItemsController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: - Properties

    private let itemCellId = "itemCellId"

    private let cellHeight: CGFloat = 104

    private let items: [Item] = [Item(id: "4343D7AA-9BF2-4424-95A9-7A98CB90C6E4", title: "MobiLab", description: "t-Shirt print", picture: "imageCard", price: 15.0),
                                 Item(id: "ABE45A17-184B-47B1-99D5-02F2BAAB7B04", title: "Notebook paper", description: "quadrille Pads", picture: "imageCardNotes", price: 3.5),
                                 Item(id: "82EB1262-E38D-4CB8-A8CA-1E17E6410B15", title: "MobiLab sticker", description: "12 sticker sheet", picture: "imageCardSticker", price: 23.95),
                                 Item(id: "A3F6679E-7C4D-4A1F-9C24-C238996E6CBF", title: "MobiLab pen", description: "blue color", picture: "imageCardPen", price: 10.75),
                                 Item(id: "45B4DA02-B214-4A39-8755-2473B7FF0C5E", title: "MobiLab", description: "female T-Shirt", picture: "imageCard", price: 20)]

    private let configuration: PaymentMethodUIConfiguration
    private let toast = ToastView()

    private let cartManager = CartManager.shared

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
        self.collectionView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor, paddingTop: defaultTopPadding)
        self.setupCollectionView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
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
}

extension ItemsController: ItemCellDelegate {
    func didSelectAddOption(for item: Item) {
        DispatchQueue.global(qos: .background).sync {
            self.cartManager.addToCart(item: item) { err in
                if let err = err {
                    self.showAlert(title: "Cart Error", message: "Failed to add item to the cart.\n\(err.localizedDescription)", completion: nil)
                    return
                }
                DispatchQueue.main.async {
                    ToastView().showMessage(withText: "\(item.title) added to the cart")
                }
            }
        }
    }

    func didSelectRemoveOption(for _: Item) {}
}
