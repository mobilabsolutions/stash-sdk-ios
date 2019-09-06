//
//  NextCellEnabled.swift
//  StashCore
//
//  Created by Robert on 02.04.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import UIKit

protocol NextCellEnabled: AnyObject {
    var nextCellSwitcher: NextCellSwitcher? { get set }
    var isLastCell: Bool { get set }

    func selectCell()
}

protocol NextCellSwitcher: AnyObject {
    func switchToNextCell(from cell: UICollectionViewCell)
}
