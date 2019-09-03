//
//  UICollectionView+Extensions.swift
//  StashCore
//
//  Created by Robert on 27.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import UIKit

extension UICollectionView {
    func dequeueCell<T: UICollectionViewCell>(reuseIdentifier: String, for indexPath: IndexPath) -> T {
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? T
        else { fatalError("Should be able to dequeue \(T.self) for \(reuseIdentifier)") }
        return cell
    }
}
