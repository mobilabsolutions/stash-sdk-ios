//
//  CustomBackButtonContainerViewController.swift
//  MobilabPaymentUI
//
//  Created by Robert on 21.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentCore
import MobilabPaymentUI
import UIKit

class CustomBackButtonContainerViewController: UIViewController, PaymentMethodDataProvider {
    private let doneButtonBottomOffset: CGFloat = 40
    private let doneButtonHeight: CGFloat = 40
    private let doneButtonHorizontalOffset: CGFloat = 34

    public var didCreatePaymentMethodCompletion: ((RegistrationData) -> Void)? {
        get {
            return self.viewController.didCreatePaymentMethodCompletion
        }

        set {
            self.viewController.didCreatePaymentMethodCompletion = newValue
        }
    }

    private var viewController: UIViewController & DoneButtonViewDelegate & DoneButtonUpdater & PaymentMethodDataProvider
    private let configuration: PaymentMethodUIConfiguration

    private let backButtonContainer = UIView()
    private let doneButton = DoneButtonView()

    init(viewController: UIViewController & DoneButtonViewDelegate & DoneButtonUpdater & PaymentMethodDataProvider, configuration: PaymentMethodUIConfiguration) {
        self.viewController = viewController
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
        viewController.doneButtonUpdating = self
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.doneButton.setup(delegate: self.viewController,
                              buttonEnabled: false,
                              enabledColor: self.configuration.buttonColor,
                              disabledColor: self.configuration.buttonDisabledColor,
                              textColor: self.configuration.buttonTextColor)
        self.view.backgroundColor = self.configuration.backgroundColor

        self.doneButton.translatesAutoresizingMaskIntoConstraints = false

        self.addChild(self.viewController)
        self.viewController.view.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(self.viewController.view)
        self.view.addSubview(self.doneButton)

        NSLayoutConstraint.activate([
            self.doneButton.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            self.doneButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -doneButtonBottomOffset),
            self.doneButton.heightAnchor.constraint(equalToConstant: doneButtonHeight),
            self.doneButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: doneButtonHorizontalOffset),
            viewController.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: self.doneButton.topAnchor),
            viewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])

        self.viewController.didMove(toParent: self)

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        self.view.endEditing(true)
    }

    func errorWhileCreatingPaymentMethod(error: MLError) {
        self.viewController.errorWhileCreatingPaymentMethod(error: error)
    }
}

extension CustomBackButtonContainerViewController: DoneButtonUpdating {
    func updateDoneButton(enabled: Bool) {
        self.doneButton.doneEnabled = enabled
    }
}
