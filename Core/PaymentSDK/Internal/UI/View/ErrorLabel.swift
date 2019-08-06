//
//  ErrorLabel.swift
//  StashCore
//
//  Created by Robert on 25.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import UIKit

class ErrorLabel: UILabel {
    var uiConfiguration: PaymentMethodUIConfiguration? {
        didSet {
            self.textColor = uiConfiguration?.errorMessageColor ?? UIConstants.coral
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sharedInit()
    }

    private func sharedInit() {
        self.font = UIConstants.defaultFont(of: 12, type: .medium)
        self.textColor = self.uiConfiguration?.errorMessageColor ?? UIConstants.coral
        self.numberOfLines = 0
    }
}
