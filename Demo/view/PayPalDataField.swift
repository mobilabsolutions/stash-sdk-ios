//
//  PayPalDataField.swift
//  Demo
//
//  Created by Borna Beakovic on 14/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import UIKit

class PayPalDataField: UIView, DataField {
    var delegate: DataFieldDelegate?

    private var addButton: UIButton = {
        let button = UIButton()
        button.setTitle("PAYPAL", for: .normal)
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

    func clearInputs() {}

    @objc private func add() {
        self.delegate?.addPayPal()
    }
}
