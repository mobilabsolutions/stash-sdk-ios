//
//  SubtitleLabel.swift
//  StashBSPayone
//
//  Created by Robert on 21.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import UIKit

class SubtitleLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sharedInit()
    }

    private func sharedInit() {
        self.textColor = UIConstants.dark
        self.font = UIConstants.defaultFont(of: 14, type: .medium)
    }
}
