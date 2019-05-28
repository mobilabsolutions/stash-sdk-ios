//
//  ItemsController.swift
//  Demo
//
//  Created by Rupali Ghate on 08.05.19.
//  Copyright © 2019 Rupali Ghate. All rights reserved.
//

import MobilabPaymentCore
import UIKit

class ItemsController: BaseCollectionViewController {
    // MARK: - Properties

    private let itemCellId = "itemCellId"

    private let cellRadius: CGFloat = 8
    private let defaultInsetValue: CGFloat = 16
    private let sectionInsets: UIEdgeInsets

    private let cellHeight: CGFloat = 104
    private let sectionLineSpacing: CGFloat = 9

    private let items: [Item] = [Item(title: "mobiLab", description: "t-Shirt print", picture: "imageCard", price: 23.95),
                                 Item(title: "notebook paper", description: "quadrille Pads", picture: "imageCardNotes", price: 3.5),
                                 Item(title: "mobilab sticker", description: "12 sticker sheet", picture: "imageCardSticker", price: 23.95),
                                 Item(title: "mobilab pen", description: "blue color", picture: "imageCardPen", price: 23.95),
                                 Item(title: "mobilab", description: "female T-Shirt", picture: "imageCard", price: 23.95)]

    private var selectedItems: [Item] = []

    private let configuration: PaymentMethodUIConfiguration

    // MARK: - Initializers

    override init(configuration: PaymentMethodUIConfiguration) {
        self.configuration = configuration
        self.sectionInsets = UIEdgeInsets(top: 49, left: self.defaultInsetValue, bottom: self.defaultInsetValue, right: self.defaultInsetValue)

        super.init(configuration: configuration)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setTitle(title: "List of Items")
        self.collectionView.register(ItemCell.self, forCellWithReuseIdentifier: self.itemCellId)
    }

    // MARK: - Collectionview methods

    override func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return self.items.count
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width - (self.defaultInsetValue * 2)

        return CGSize(width: width, height: self.cellHeight)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ItemCell = collectionView.dequeueCell(reuseIdentifier: self.itemCellId, for: indexPath)
        cell.layer.cornerRadius = self.cellRadius
        cell.layer.masksToBounds = false

        let item = self.items[indexPath.row]
        cell.item = item
        cell.delegate = self

        return cell
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return self.sectionLineSpacing
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return self.sectionInsets
    }
}

extension ItemsController: ItemCellDelegate {
    func didSelectAddOption(for item: Item) {
        self.selectedItems.append(item)
    }
}
