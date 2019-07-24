//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import UIKit

internal class PreselectedPaymentMethodViewController: ShortViewController {
    // MARK: - Lifecycle

    init(paymentMethod: PaymentMethod) {
        self.paymentMethod = paymentMethod
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public

    let paymentMethod: PaymentMethod

    var payButtonTitle = "" {
        didSet {
            self.preselectedPaymentMethodView.payButton.setTitle(self.payButtonTitle, for: [])
        }
    }

    internal var changeButtonHandler: (() -> Void)? {
        didSet {
            self.configureChangeButton()
        }
    }

    internal var payButtonHandler: (() -> Void)?

    // MARK: - UIViewController

    private var preselectedPaymentMethodView: PreselectedPaymentMethodView {
        return view as! PreselectedPaymentMethodView // swiftlint:disable:this force_cast
    }

    override func loadView() {
        view = PreselectedPaymentMethodView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let view = self.preselectedPaymentMethodView
        view.paymentMethodView.imageURL = self.paymentMethod.logoURL
        view.paymentMethodView.title = self.paymentMethod.displayName
        view.paymentMethodView.accessibilityLabel = ADYLocalizedString("preselectedPaymentMethod.accessibilityLabel", self.paymentMethod.accessibilityLabel)
        view.payButton.addTarget(self, action: #selector(self.didSelectPay), for: .touchUpInside)
    }

    // MARK: - Private

    private func configureChangeButton() {
        if self.changeButtonHandler == nil {
            navigationItem.rightBarButtonItem = nil
        } else {
            let changeButtonItem = UIBarButtonItem(title: ADYLocalizedString("preselectedPaymentMethod.changeButton.title"),
                                                   style: .done,
                                                   target: self,
                                                   action: #selector(self.didSelectChange))
            changeButtonItem.accessibilityIdentifier = "change-payment-method-button"
            changeButtonItem.accessibilityLabel = ADYLocalizedString("preselectedPaymentMethod.changeButton.accessibilityLabel")
            navigationItem.rightBarButtonItem = changeButtonItem
        }
    }

    @objc private func didSelectChange() {
        self.changeButtonHandler?()
    }

    @objc private func didSelectPay() {
        self.payButtonHandler?()
    }
}

extension PreselectedPaymentMethodViewController: PaymentProcessingElement {
    func startProcessing() {
        self.preselectedPaymentMethodView.payButton.showsActivityIndicator = true
    }

    func stopProcessing() {
        self.preselectedPaymentMethodView.payButton.showsActivityIndicator = false
    }
}
