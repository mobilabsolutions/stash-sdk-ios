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
    public var billingData: BillingData?

    public func errorWhileCreatingPaymentMethod(error: MobilabPaymentError) {
        if case MobilabPaymentError.userActionable = error {
            self.navigationController?.popViewController(animated: true)
        } else {
            let alert = UIAlertController(title: error.title, message: error.description, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { _ in
                self.navigationController?.popViewController(animated: true)
            }))
            present(alert, animated: true)
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIConstants.iceBlue

        self.showActivityIndicatory()

        let payPalData = PayPalPlaceholderData(billingData: billingData)
        self.didCreatePaymentMethodCompletion?(payPalData)
    }

    func showActivityIndicatory() {
        let activityView = UIActivityIndicatorView(style: .whiteLarge)
        activityView.center = self.view.center

        self.view.addSubview(activityView)
        activityView.startAnimating()
    }
}
