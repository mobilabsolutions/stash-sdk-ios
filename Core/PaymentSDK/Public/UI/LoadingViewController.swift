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

    public func errorWhileCreatingPaymentMethod(error: MobilabPaymentError) {
        
        if error == MobilabPaymentError.psp(BraintreeError.userCancelledPayPal) {
            self.navigationController?.popViewController(animated: true)
        } else {
            let alert = UIAlertController(title: error.title, message: error.description, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
                self.navigationController?.popViewController(animated: true)
            }))
            present(alert, animated: true)
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)

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
