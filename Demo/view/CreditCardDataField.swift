//
//  CreditCardDataField.swift
//  Demo
//
//  Created by Robert on 11.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentCore
import UIKit

class CreditCardDataField: UIView, DataField {
    weak var delegate: DataFieldDelegate?

    private var billingDataLabel: UILabel = {
        let label = UILabel()
        label.text = "Billing Data"
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return label
    }()

    private var emailField: UITextField = {
        let field = UITextField()
        field.placeholder = "test@example.com"
        field.keyboardType = .emailAddress
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        return field
    }()

    private var creditCardDataLabel: UILabel = {
        let label = UILabel()
        label.text = "Card Data"
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return label
    }()

    private var nameField: UITextField = {
        let field = UITextField()
        field.placeholder = "Name"
        return field
    }()

    private var numberField: UITextField = {
        let field = UITextField()
        field.placeholder = "Card Number"
        return field
    }()

    private var expiryMonthField: UITextField = {
        let field = UITextField()
        field.keyboardType = .decimalPad
        field.placeholder = "MM"
        return field
    }()

    private var expiryYearField: UITextField = {
        let field = UITextField()
        field.keyboardType = .decimalPad
        field.placeholder = "YY"
        return field
    }()

    private var cvvField: UITextField = {
        let field = UITextField()
        field.keyboardType = .decimalPad
        field.placeholder = "CVV"
        return field
    }()

    private var addButton: UIButton = {
        let button = UIButton()
        button.setTitle("ADD METHOD", for: .normal)
        button.backgroundColor = UIColor(red: 95.0 / 255.0, green: 188.0 / 255.0, blue: 254.0 / 255.0, alpha: 1.0)
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(add), for: .touchUpInside)
        return button
    }()

    private var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .equalSpacing
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sharedInit()
    }

    private func sharedInit() {
        self.stackView.addArrangedSubview(self.billingDataLabel)
        self.stackView.addArrangedSubview(self.emailField)
        self.stackView.addArrangedSubview(self.creditCardDataLabel)
        self.stackView.addArrangedSubview(self.nameField)
        self.stackView.addArrangedSubview(self.numberField)
        self.stackView.addArrangedSubview(self.cvvField)

        let nestedStack = UIStackView()
        nestedStack.axis = .horizontal
        nestedStack.alignment = .top
        nestedStack.distribution = .fillEqually

        nestedStack.addArrangedSubview(expiryMonthField)
        nestedStack.addArrangedSubview(expiryYearField)

        stackView.addArrangedSubview(nestedStack)
        stackView.addArrangedSubview(addButton)

        stackView.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.leftAnchor.constraint(equalTo: self.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: self.rightAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])

        clearInputs()
    }

    func clearInputs() {
        self.nameField.text = nil
        self.numberField.text = nil
        self.cvvField.text = nil
        self.expiryYearField.text = nil
        self.expiryMonthField.text = nil
        self.emailField.text = nil
    }

    @objc private func add() {
        guard let number = numberField.text,
            let cvv = cvvField.text, let monthText = expiryMonthField.text,
            let yearText = expiryYearField.text, let month = Int(monthText), let year = Int(yearText)
        else { self.delegate?.showError(title: "Mandatory field not filled",
                                        description: "Please make sure to fill card number, CVV, and expiry month/year"); return }

        let billingData = BillingData(email: emailField.text)
        do {
            let creditCard = try CreditCardData(cardNumber: number, cvv: cvv, expiryMonth: month, expiryYear: year,
                                                holderName: nameField.text, billingData: billingData)
            self.delegate?.addCreditCard(method: creditCard)
        } catch let error as MLError {
            self.delegate?.showError(title: error.title, description: error.failureReason ?? "The card number is invalid")
        } catch {
            self.delegate?.showError(title: "Credit Card Invalid", description: "The provided number is invalid.")
        }
    }
}
