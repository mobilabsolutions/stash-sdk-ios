//
//  PaymentMethodsCollectionViewController.swift
//  Demo
//
//  Created by Robert on 11.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import UIKit

class PaymentMethodsCollectionViewController: UICollectionViewController {
    private let reuseIdentifier = "aliasCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: self.collectionView.frame.size.width, height: 60)
        flowLayout.minimumLineSpacing = 2

        self.collectionView.collectionViewLayout = flowLayout

        title = "List"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.reloadData()
    }

    override func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return AliasManager.shared.aliases.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? AliasCollectionViewCell
        else { fatalError("Wrong collection view cell type for payment methods view controller") }
        cell.setup(for: AliasManager.shared.aliases[AliasManager.shared.aliases.count - 1 - indexPath.row])
        return cell
    }
}
