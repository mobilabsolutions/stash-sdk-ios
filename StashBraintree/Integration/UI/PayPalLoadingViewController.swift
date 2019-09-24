//
//  PayPalLoadingViewController.swift
//  StashBraintree
//
//  Created by Borna Beakovic on 26/03/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import StashCore
import UIKit

class PayPalLoadingViewController: UIViewController, PaymentMethodDataProvider {
    var didCreatePaymentMethodCompletion: ((RegistrationData) -> Void)?
    var billingData: BillingData?

    private let uiConfiguration: PaymentMethodUIConfiguration
    private let payPalImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIConstants.payPalLogoNoTextImage
        view.contentMode = .scaleAspectFit
        return view
    }()

    private let payPalLoaderImageView: UIImageView = {
        let view = UIImageView(image: UIConstants.payPalActivityIndicatorImage)
        view.contentMode = .scaleAspectFit
        return view
    }()

    private let payPalImageWidth: CGFloat = 48
    private let payPalLoaderWidth: CGFloat = 101
    private let animationDuration: Double = 0.7

    init(uiConfiguration: PaymentMethodUIConfiguration) {
        self.uiConfiguration = uiConfiguration
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func errorWhileCreatingPaymentMethod(error: StashError) {
        self.stopAnimatingLoadingView()

        if case StashError.userCancelled = error {
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

        self.showActivityIndicator()

        let payPalData = PayPalPlaceholderData(billingData: billingData)
        self.didCreatePaymentMethodCompletion?(payPalData)
        self.title = "PAYMENT METHOD"
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.stopAnimatingLoadingView()
    }

    private func showActivityIndicator() {
        self.payPalLoaderImageView.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(self.payPalLoaderImageView)

        NSLayoutConstraint.activate([
            self.payPalLoaderImageView.centerXAnchor.constraint(equalTo: self.payPalImageView.centerXAnchor),
            self.payPalLoaderImageView.centerYAnchor.constraint(equalTo: self.payPalImageView.centerYAnchor),
            self.payPalLoaderImageView.widthAnchor.constraint(equalToConstant: payPalLoaderWidth),
            self.payPalLoaderImageView.heightAnchor.constraint(equalTo: self.payPalLoaderImageView.widthAnchor),
        ])

        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.isCumulative = true
        animation.toValue = NSNumber(value: 2 * Double.pi)
        animation.duration = self.animationDuration
        animation.repeatCount = .infinity

        self.payPalLoaderImageView.layer.add(animation, forKey: "transform.rotation.z")
    }

    private func stopAnimatingLoadingView() {
        self.payPalLoaderImageView.layer.removeAllAnimations()
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
            self.payPalImageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.payPalImageView.widthAnchor.constraint(equalToConstant: payPalImageWidth),
            self.payPalImageView.heightAnchor.constraint(equalTo: self.payPalImageView.widthAnchor),
        ])
    }
}
