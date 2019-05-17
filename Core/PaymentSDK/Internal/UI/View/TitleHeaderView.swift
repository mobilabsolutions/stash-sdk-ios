//
//  TitleHeaderView.swift
//  MobilabPaymentCore
//
//  Created by Robert on 21.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import UIKit

class TitleHeaderView: HeaderView {
    private static let defaultTextColor = UIConstants.dark

    override var title: String? {
        didSet {
            self.label.text = self.title
        }
    }

    override var configuration: PaymentMethodUIConfiguration? {
        didSet {
            self.label.textColor = self.configuration?.textColor ?? TitleHeaderView.defaultTextColor
            self.backgroundColor = self.configuration?.backgroundColor
        }
    }

    private let horizontalToSuperViewOffset: CGFloat = 18
    private let verticalToSuperViewOffset: CGFloat = 16

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sharedInit()
    }

    override func sharedInit() {
        super.sharedInit()
        
        self.label.font = UIConstants.defaultFont(of: 24, type: .black)
        self.label.textColor = UIConstants.dark
    }
}
