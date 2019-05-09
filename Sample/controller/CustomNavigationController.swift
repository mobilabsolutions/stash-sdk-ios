//
//  CustomNavigationController.swift
//  Sample
//
//  Created by Rupali Ghate on 08.05.19.
//  Copyright © 2019 Rupali Ghate. All rights reserved.
//

import UIKit

class CustomNavigationController: UINavigationController {
    
    // MARK: - Properties
    
    // MARK: - Initializers
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
        self.sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.sharedInit()
    }
    
    // MARK: - Helpers
    
    private func sharedInit() {
        self.topViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIConstants.closeButtonImage, style: .plain, target: self, action: #selector(self.cancel))
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
        self.view.backgroundColor = .clear
        
        self.topViewController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationBar.backIndicatorImage = UIConstants.backButtonImage
        self.navigationBar.backIndicatorTransitionMaskImage = UIConstants.backButtonImage
    }

    
    // MARK: - Handlers
    
    @objc private func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
}
