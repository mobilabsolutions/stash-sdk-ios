//
//  ErrorLabel.swift
//  MobilabPaymentUI
//
//  Created by Robert on 25.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import UIKit

public class ErrorLabel: UILabel {
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
        self.textColor = UIConstants.coral
        self.numberOfLines = 0
    }
}
