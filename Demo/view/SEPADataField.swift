//
//  SEPADataField.swift
//  Demo
//
//  Created by Robert on 11.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentBSPayone
import MobilabPaymentCore
import UIKit

class SEPADataField: UIView, DataField {
    var delegate: DataFieldDelegate?

    private var billingDataLabel: UILabel = {
        let label = UILabel()
        label.text = "Billing Data"
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return label
    }()

    private var nameField: UITextField = {
        let field = UITextField()
        field.placeholder = "Name"
        return field
    }()

    private var streetField: UITextField = {
        let field = UITextField()
        field.placeholder = "Street and Nr"
        return field
    }()

    private var zipField: UITextField = {
        let field = UITextField()
        field.placeholder = "Zip"
        return field
    }()

    private var cityField: UITextField = {
        let field = UITextField()
        field.placeholder = "City"
        return field
    }()

    private var countryField: UITextField = {
        let field = UITextField()
        field.placeholder = "Country (e.g. DE)"
        return field
    }()

    private var sepaDataLabel: UILabel = {
        let label = UILabel()
        label.text = "SEPA Data"
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return label
    }()

    private var ibanField: UITextField = {
        let field = UITextField()
        field.placeholder = "IBAN"
        field.autocapitalizationType = .allCharacters
        return field
    }()

    private var bicField: UITextField = {
        let field = UITextField()
        field.placeholder = "BIC"
        field.autocapitalizationType = .allCharacters
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
        self.stackView.addArrangedSubview(self.nameField)
        self.stackView.addArrangedSubview(self.streetField)
        self.stackView.addArrangedSubview(self.zipField)
        self.stackView.addArrangedSubview(self.cityField)
        self.stackView.addArrangedSubview(self.countryField)
        self.stackView.addArrangedSubview(self.sepaDataLabel)
        self.stackView.addArrangedSubview(self.ibanField)
        self.stackView.addArrangedSubview(self.bicField)

        self.stackView.addArrangedSubview(self.addButton)

        self.stackView.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(self.stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.leftAnchor.constraint(equalTo: self.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: self.rightAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])

        self.clearInputs()
    }

    func clearInputs() {
        self.ibanField.text = nil
        self.bicField.text = nil
        self.nameField.text = nil
        self.countryField.text = nil
        self.zipField.text = nil
        self.streetField.text = nil
        self.cityField.text = nil
    }

    @objc private func add() {
        guard let iban = ibanField.text?.replacingOccurrences(of: " ", with: ""),
            let bic = bicField.text,
            !iban.isEmpty, !bic.isEmpty
        else { self.delegate?.showError(title: "Mandatory field not filled", description: "Please make sure to fill the IBAN and BIC fields"); return }

        let billingData = BillingData(name: nameField.text, address1: streetField.text,
                                      zip: zipField.text, city: cityField.text,
                                      country: countryField.text, languageId: Locale.current.languageCode)

        do {
            let sepa = try SEPAData(iban: iban, bic: bic, billingData: billingData)
            self.delegate?.addSEPA(method: sepa)
        } catch let error as MobilabPaymentError {
            self.delegate?.showError(title: error.title, description: error.description)
        } catch {
            self.delegate?.showError(title: "IBAN invalid", description: "The provided IBAN is not valid.")
        }
    }
}
