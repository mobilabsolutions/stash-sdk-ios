//
//  UICollectionView+Extensions.swift
//  MobilabPaymentCore
//
//  Created by Robert on 27.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import UIKit

extension UICollectionView {
    public func dequeueCell<T: UICollectionViewCell>(reuseIdentifier: String, for indexPath: IndexPath) -> T {
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? T
        else { fatalError("Should be able to dequeue \(T.self) for \(reuseIdentifier)") }
        return cell
    }
}