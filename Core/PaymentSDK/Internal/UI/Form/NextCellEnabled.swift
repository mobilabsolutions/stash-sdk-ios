//
//  NextCellEnabled.swift
//  MobilabPaymentCore
//
//  Created by Robert on 02.04.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import UIKit

protocol NextCellEnabled: class {
    var nextCellSwitcher: NextCellSwitcher? { get set }
    var isLastCell: Bool { get set }
    
    func selectCell()
}

protocol NextCellSwitcher: class {
    func switchToNextCell(from cell: UICollectionViewCell)
}
