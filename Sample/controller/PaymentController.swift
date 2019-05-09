//
//  PaymentController.swift
//  Sample
//
//  Created by Rupali Ghate on 08.05.19.
//  Copyright © 2019 Rupali Ghate. All rights reserved.
//

import UIKit

class PaymentController: BaseCollectionViewController {
    
    // MARK: - Properties
    
    private let configuration: UIConfiguration

    // MARK: - Initializers
    
    init(configuration: UIConfiguration) {
        self.configuration = configuration
        super.init(configuration: configuration, title: "Payment Methods")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.backgroundColor = configuration.backgroundColor
    }
    
    // MARK: - Helpers
    
}
