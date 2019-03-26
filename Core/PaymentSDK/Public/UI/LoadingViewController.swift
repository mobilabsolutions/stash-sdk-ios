//
//  LoadingViewController.swift
//  MobilabPayment
//
//  Created by Borna Beakovic on 26/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import UIKit

public class LoadingViewController: UIViewController, PaymentMethodDataProvider {
    public var didCreatePaymentMethodCompletion: ((RegistrationData) -> Void)?

    public func errorWhileCreatingPaymentMethod(error _: MLError) {
        #warning("Handle PayPal error here")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        // self.navigationController?.navigationBar.isHidden = true

        self.showActivityIndicatory()

        let payPalData = PayPalData(nonce: nil)
        self.didCreatePaymentMethodCompletion?(payPalData)
    }

    func showActivityIndicatory() {
        let activityView = UIActivityIndicatorView(style: .whiteLarge)
        activityView.center = self.view.center

        self.view.addSubview(activityView)
        activityView.startAnimating()
    }
}
