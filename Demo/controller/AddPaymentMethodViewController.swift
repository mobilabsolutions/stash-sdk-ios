//
//  AddPaymentMethodViewController.swift
//  Demo
//
//  Created by Robert on 11.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentBSPayone
import MobilabPaymentCore
import UIKit

class AddPaymentMethodViewController: UIViewController, DataFieldDelegate {
    @IBOutlet private var paymentMethodSwitch: UISegmentedControl!
    @IBOutlet private var pspTextField: UITextField!
    @IBOutlet private var dataFieldContainer: UIView!
    @IBOutlet private var scrollView: UIScrollView!

    private var dataFields: [DataField & UIView] = [
        CreditCardDataField(), SEPADataField(), PayPalDataField(),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .always
        title = "Add"

        self.paymentMethodSwitch.addTarget(self, action: #selector(self.updateDataField), for: .valueChanged)
        self.addViewForCurrentDataField()

        self.pspTextField.isEnabled = false

        var configuration = MobilabPaymentConfiguration(publicKey: "PD-BS2-nF7kU7xY8ESLgflavGW9CpUv1I", endpoint: "https://payment-dev.mblb.net/api/v1")
        configuration.loggingEnabled = true

        MobilabPaymentSDK.configure(configuration: configuration)
        MobilabPaymentSDK.addProvider(provider: MobilabPaymentBSPayone(publicKey: "PD-BS2-nF7kU7xY8ESLgflavGW9CpUv1I"))

        NotificationCenter.default.addObserver(self, selector: #selector(self.willShowKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.willHideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tapRecognizer)
    }

    @objc private func updateDataField() {
        self.dataFieldContainer.subviews.first?.removeFromSuperview()
        self.addViewForCurrentDataField()
    }

    func addCreditCard(method: CreditCardData) {
        MobilabPaymentSDK.getRegisterManager().registerCreditCard(creditCardData: method) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case let .success(alias):
                    self?.save(alias: alias, expirationMonth: method.expiryMonth, expirationYear: method.expiryYear, type: .creditCard)
                    self?.clearInputs()
                    self?.showAlert(title: "Success", body: "Credit Card added successfully.")
                case let .failure(error): self?.showAlert(title: error.title ?? "Error",
                                                          body: error.errorDescription ?? "An error occurred when adding the credit card")
                }
            }
        }
    }

    func addSEPA(method: SEPAData) {
        MobilabPaymentSDK.getRegisterManager().registerSEPAAccount(sepaData: method) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case let .success(alias):
                    self?.save(alias: alias, expirationMonth: nil, expirationYear: nil, type: .sepa)
                    self?.clearInputs()
                    self?.showAlert(title: "Success", body: "SEPA added successfully.")
                case let .failure(error): self?.showAlert(title: error.title ?? "Error",
                                                          body: error.errorDescription ?? "An error occurred when adding the credit card")
                }
            }
        }
    }

    func addPayPal() {
        MobilabPaymentSDK.getRegisterManager().registerPayPal { _ in
        }
    }

    func showError(title: String, description: String) {
        self.showAlert(title: title, body: description)
    }

    private func save(alias: String?, expirationMonth: Int?, expirationYear: Int?, type: AliasType) {
        let aliasHolder = Alias(alias: alias, expirationYear: expirationYear, expirationMonth: expirationMonth, type: type)
        AliasManager.shared.save(alias: aliasHolder)
    }

    private func clearInputs() {
        self.dataFields[paymentMethodSwitch.selectedSegmentIndex].clearInputs()
    }

    private func addViewForCurrentDataField() {
        var field = dataFields[paymentMethodSwitch.selectedSegmentIndex]
        field.delegate = self

        field.translatesAutoresizingMaskIntoConstraints = false
        dataFieldContainer.addSubview(field)

        NSLayoutConstraint.activate([
            field.topAnchor.constraint(equalTo: dataFieldContainer.topAnchor),
            field.leftAnchor.constraint(equalTo: dataFieldContainer.leftAnchor),
            field.rightAnchor.constraint(equalTo: dataFieldContainer.rightAnchor),
            field.bottomAnchor.constraint(equalTo: dataFieldContainer.bottomAnchor),
        ])
    }

    private func showAlert(title: String, body: String) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    @objc private func willHideKeyboard(notification _: Notification) {
        self.scrollView.contentInset.bottom = 0
    }

    @objc private func willShowKeyboard(notification: Notification) {
        guard let frame = notification.userInfo?[UIWindow.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }
        self.scrollView.contentInset.bottom = frame.height
    }

    @objc private func dismissKeyboard() {
        self.view.endEditing(true)
    }
}
