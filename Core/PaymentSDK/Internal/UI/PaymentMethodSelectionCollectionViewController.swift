//
//  PaymentMethodSelectionCollectionViewController.swift
//  MobilabPaymentCore
//
//  Created by Robert on 14.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import UIKit

class PaymentMethodSelectionCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    private let reuseIdentifier = "paymentMethodTypeCell"
    private let cellHeight: CGFloat = 50
    private let minimumLineSpacing: CGFloat = 4
    private let backgroundColor = UIColor.lightGray

    var selectablePaymentMethods: [PaymentMethodType] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }

    var selectedPaymentMethodCallback: ((PaymentMethodType) -> Void)?

    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.register(PaymentMethodTypeCollectionViewCell.self, forCellWithReuseIdentifier: self.reuseIdentifier)
        self.collectionView.backgroundColor = self.backgroundColor
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return self.selectablePaymentMethods.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PaymentMethodTypeCollectionViewCell
        else { fatalError("Wrong cell type for PaymentMethodSelectionCollectionViewController. Should be PaymentMethodTypeCollectionViewCell") }

        cell.paymentMethodType = self.selectablePaymentMethods[indexPath.item]
        return cell
    }

    override func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedPaymentMethodCallback?(self.selectablePaymentMethods[indexPath.item])
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: self.cellHeight)
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        return self.minimumLineSpacing
    }
}
