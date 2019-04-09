//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

class PaymentDetailsViewController: CheckoutViewController {
    init(withPaymentMethod method: PaymentMethod, paymentController: PaymentController) {
        self.paymentMethod = method
        self.paymentController = paymentController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        preferredContentSize = view.bounds.size

        navigationBar.buttonType = .back(target: self, action: #selector(self.pop))

        var frame = view.bounds
        frame.origin.y = navigationBar.frame.maxY
        frame.size.height = frame.height - frame.minY
        formScrollView.frame = frame
        formScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(formScrollView)

        configureSubmitButton()
        // Let the subclasses position the submit button below the rest of their fields.
        formScrollView.addSubview(submitButton)
    }

    // MARK: - Public

    let paymentMethod: PaymentMethod
    let paymentController: PaymentController

    let formScrollView = UIScrollView(frame: .zero)
    let submitButton = UIButton(type: .custom)

    @objc func submit() {
        // Implemented by the subclasses.
    }

    // MARK: - Private

    @objc private func pop() {
        navigationController?.popViewController(animated: false)
    }

    private func configureSubmitButton() {
        self.submitButton.backgroundColor = Theme.primaryColor
        self.submitButton.setTitleColor(UIColor.white, for: UIControlState())
        self.submitButton.titleLabel?.font = Theme.standardFontRegular
        self.submitButton.setTitle("CONTINUE", for: UIControlState())
        self.submitButton.addTarget(self, action: #selector(self.submit), for: .touchUpInside)

        let frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 54.0)
        submitButton.frame = frame
        submitButton.autoresizingMask = .flexibleWidth
    }
}
