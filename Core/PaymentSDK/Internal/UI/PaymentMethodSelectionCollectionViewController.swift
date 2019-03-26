//
//  PaymentMethodSelectionCollectionViewController.swift
//  MobilabPaymentCore
//
//  Created by Robert on 14.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentUI
import UIKit

class PaymentMethodSelectionCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    private let reuseIdentifier = "paymentMethodTypeCell"
    private let headerReuseIdentifier = "header"

    private let cellHeight: CGFloat = 48
    private let minimumLineSpacing: CGFloat = 8
    private let backgroundColor = UIConstants.iceBlue
    private let cellInset: CGFloat = 16
    private let headerHeight: CGFloat = 195

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
        self.collectionView.register(PaymentMethodSelectionHeaderCollectionReusableView.self,
                                     forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: self.headerReuseIdentifier)

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
        return CGSize(width: self.view.frame.width - 2 * self.cellInset, height: self.cellHeight)
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        return self.minimumLineSpacing
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: self.headerReuseIdentifier, for: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, referenceSizeForHeaderInSection _: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: self.headerHeight)
    }
}
