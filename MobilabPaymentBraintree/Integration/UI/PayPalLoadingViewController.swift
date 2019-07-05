//
//  PayPalLoadingViewController.swift
//  MobilabPayment
//
//  Created by Borna Beakovic on 26/03/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import MobilabPaymentCore
import UIKit

class PayPalLoadingViewController: UIViewController, PaymentMethodDataProvider {
    var didCreatePaymentMethodCompletion: ((RegistrationData) -> Void)?
    var billingData: BillingData?

    private let uiConfiguration: PaymentMethodUIConfiguration
    private let payPalImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIConstants.payPalImage
        view.contentMode = .scaleAspectFit
        return view
    }()

    private let payPalImageWidth: CGFloat = 70
    private let payPalImageTopOffset: CGFloat = 65

    init(uiConfiguration: PaymentMethodUIConfiguration) {
        self.uiConfiguration = uiConfiguration
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func errorWhileCreatingPaymentMethod(error: MobilabPaymentError) {
        if case MobilabPaymentError.userCancelled = error {
            self.dismissLoadingViewController()
        } else {
            let alert = UIAlertController(title: error.title, message: error.description, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { _ in
                self.navigationController?.popViewController(animated: true)
            }))
            present(alert, animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = self.uiConfiguration.backgroundColor
        self.addPayPalLogoView()

        self.showActivityIndicatory()

        let payPalData = PayPalPlaceholderData(billingData: billingData)
        self.didCreatePaymentMethodCompletion?(payPalData)
    }

    private func showActivityIndicatory() {
        let activityView = UIActivityIndicatorView(style: .whiteLarge)
        activityView.center = self.view.center
        activityView.color = uiConfiguration.mediumEmphasisColor

        self.view.addSubview(activityView)
        activityView.startAnimating()
    }

    private func dismissLoadingViewController() {
        // If we are not the root view controller, we want to pop. Else, we want to dismiss ourselves
        if let navigationController = self.navigationController,
            navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }

    private func addPayPalLogoView() {
        self.payPalImageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.payPalImageView)

        NSLayoutConstraint.activate([
            self.payPalImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.payPalImageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: payPalImageTopOffset),
            self.payPalImageView.widthAnchor.constraint(equalToConstant: payPalImageWidth),
        ])
    }
}
