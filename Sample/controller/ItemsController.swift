//
//  ItemsController.swift
//  Sample
//
//  Created by Rupali Ghate on 08.05.19.
//  Copyright © 2019 Rupali Ghate. All rights reserved.
//

import MobilabPaymentCore
import UIKit

class ItemsController: BaseCollectionViewController {
    // MARK: - Properties

    // MARK: - Initializers

    override init(configuration: PaymentMethodUIConfiguration) {
        super.init(configuration: configuration)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setTitle(title: "List of Items")
    }

    // MARK: - Helpers
}
