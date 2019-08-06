//
//  CustomBackButtonContainerViewController.swift
//  StashBSPayone
//
//  Created by Robert on 21.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import UIKit

/// A view controller that contains a payment method data provider view controller. This view controller also provides a "done" button which can be controlled from the
/// contained view controller.
public class CustomBackButtonContainerViewController: UIViewController, PaymentMethodDataProvider {
    private let doneButtonBottomOffset: CGFloat = 40
    private let doneButtonHeight: CGFloat = 40
    private let doneButtonHorizontalOffset: CGFloat = 34

    /// The contained view controller's `didCreatePaymentMethodCompletion` callback
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

    private let doneButton = DoneButtonView()

    /// Create a new view controller that contains a payment method data provider.
    ///
    /// - Parameters:
    ///   - viewController: A view controller that is used for payment method data input. Must also react to done button events as provided by this view controller
    ///   - configuration: The UI configuration that should be used to style this view controller
    public init(viewController: UIViewController & DoneButtonViewDelegate & DoneButtonUpdater & PaymentMethodDataProvider, configuration: PaymentMethodUIConfiguration) {
        self.viewController = viewController
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
        viewController.doneButtonUpdating = self
    }

    /// This is not implemented and should not be called.
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Custom `viewDidLoad` to add the contained view controller to the view hiearchy
    public override func viewDidLoad() {
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

    /// Hand along errors that happen during the payment creation process to the contained view controller
    ///
    /// - Parameter error: The error that occurred
    public func errorWhileCreatingPaymentMethod(error: MobilabPaymentError) {
        self.viewController.errorWhileCreatingPaymentMethod(error: error)
    }
}

extension CustomBackButtonContainerViewController: DoneButtonUpdating {
    /// Update the done button's state
    ///
    /// - Parameter enabled: Whether or not the done button should be enabled
    public func updateDoneButton(enabled: Bool) {
        self.doneButton.doneEnabled = enabled
    }
}
