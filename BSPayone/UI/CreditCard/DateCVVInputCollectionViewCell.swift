//
//  DateInputCollectionViewCell.swift
//  MobilabPaymentBSPayone
//
//  Created by Robert on 18.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentUI
import UIKit

class DateCVVInputCollectionViewCell: UICollectionViewCell {
    private var date: (month: Int, year: Int)?

    private var cvv: String? {
        didSet {
            self.cvvTextField.text = self.cvv
        }
    }

    private var dateError: String? {
        didSet {
            self.dateTextField.set(hasInvalidData: self.dateError != nil)
        }
    }

    private var cvvError: String? {
        didSet {
            self.cvvTextField.set(hasInvalidData: self.cvvError != nil)
        }
    }

    private var delegate: DataPointProvidingDelegate?

    private let dateTextField = CustomTextField()
    private let cvvTextField = CustomTextField()
    private let pickerView = UIPickerView()

    private let dateTitleLabel = SubtitleLabel()
    private let cvvTitleLabel = SubtitleLabel()
    private let errorLabel = ErrorLabel()

    private var errorLabelZeroHeightConstraint: NSLayoutConstraint?

    func setup(date: (month: Int, year: Int)?, cvv: String?, dateError: String?, cvvError: String?, delegate: DataPointProvidingDelegate) {
        self.date = date
        self.cvv = cvv
        self.delegate = delegate
        self.dateError = dateError
        self.cvvError = cvvError

        self.errorLabel.text = (dateError.flatMap({ $0 + "\n" }) ?? "") + (cvvError ?? "")
        self.errorLabelZeroHeightConstraint?.isActive = self.dateError == nil && self.cvvError == nil
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sharedInit()
    }

    private func sharedInit() {
        self.setupDatePicker()
        self.setupDateTextField()
        self.setupCVVTextField()
        self.setupLabels()

        self.contentView.addSubview(self.errorLabel)
        self.contentView.addSubview(self.dateTextField)
        self.contentView.addSubview(self.cvvTextField)
        self.contentView.addSubview(self.dateTitleLabel)
        self.contentView.addSubview(self.cvvTitleLabel)

        NSLayoutConstraint.activate([
            self.dateTextField.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            self.dateTextField.trailingAnchor.constraint(equalTo: self.cvvTextField.leadingAnchor, constant: -16),
            self.dateTextField.widthAnchor.constraint(equalTo: self.cvvTextField.widthAnchor),
            self.dateTextField.heightAnchor.constraint(equalToConstant: 40),
            self.cvvTextField.centerYAnchor.constraint(equalTo: self.dateTextField.centerYAnchor),
            self.cvvTextField.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
            self.cvvTextField.heightAnchor.constraint(equalTo: self.dateTextField.heightAnchor),
            self.dateTitleLabel.leadingAnchor.constraint(equalTo: self.dateTextField.leadingAnchor),
            self.dateTitleLabel.trailingAnchor.constraint(equalTo: self.dateTextField.trailingAnchor),
            self.dateTitleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8),
            self.cvvTitleLabel.topAnchor.constraint(equalTo: self.dateTitleLabel.topAnchor),
            self.cvvTitleLabel.leadingAnchor.constraint(equalTo: self.cvvTextField.leadingAnchor),
            self.cvvTitleLabel.trailingAnchor.constraint(equalTo: self.cvvTitleLabel.trailingAnchor),
            self.dateTextField.topAnchor.constraint(equalTo: self.dateTitleLabel.bottomAnchor, constant: 8),
            self.errorLabel.leadingAnchor.constraint(equalTo: self.dateTextField.leadingAnchor),
            self.errorLabel.trailingAnchor.constraint(equalTo: self.cvvTextField.trailingAnchor),
            self.errorLabel.topAnchor.constraint(equalTo: self.dateTextField.bottomAnchor, constant: 4),
        ])

        self.errorLabelZeroHeightConstraint = self.errorLabel.heightAnchor.constraint(equalToConstant: 0)
        self.errorLabelZeroHeightConstraint?.isActive = true

        self.backgroundColor = .white
    }

    fileprivate func setupCVVTextField() {
        self.cvvTextField.translatesAutoresizingMaskIntoConstraints = false

        self.cvvTextField.placeholder = "CVV"
        self.cvvTextField.keyboardType = .numberPad

        self.cvvTextField.addTarget(self, action: #selector(self.cvvTextFieldEditingChanged), for: .editingChanged)
    }

    fileprivate func setupDateTextField() {
        self.dateTextField.translatesAutoresizingMaskIntoConstraints = false

        self.dateTextField.placeholder = "MM/YY"
        self.dateTextField.text = self.date.flatMap { String(format: "%02d/%02d", $0.month, $0.year) }

        self.dateTextField.addTarget(self, action: #selector(self.dateTextFieldBeganEditing), for: .editingDidBegin)
        self.dateTextField.addTarget(self, action: #selector(self.dateTextFieldEditingChanged), for: .editingChanged)
    }

    fileprivate func setupLabels() {
        self.cvvTitleLabel.text = "CVV"
        self.dateTitleLabel.text = "Expiration date"

        self.cvvTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.dateTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.errorLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    fileprivate func setupDatePicker() {
        self.pickerView.delegate = self
        self.pickerView.dataSource = self

        if let date = self.date {
            self.pickerView.selectRow(date.month, inComponent: 0, animated: false)
            self.pickerView.selectRow(date.year, inComponent: 1, animated: false)
        } else {
            let year = Calendar.current.component(.year, from: Date())
            pickerView.selectRow((year + 1) % Int(pow(10, floor(log10(Double(year))))), inComponent: 1, animated: false)
        }

        self.dateTextField.inputView = self.pickerView
    }

    @objc private func dateTextFieldBeganEditing() {
        if let text = self.dateTextField.text, !text.isEmpty {
            self.dateTextField.text = text
        } else {
            self.dateTextField.text = String(format: "%02d/%02d", self.pickerView.selectedRow(inComponent: 0) + 1,
                                             self.pickerView.selectedRow(inComponent: 1))
        }
    }

    @objc fileprivate func dateTextFieldEditingChanged() {
        if let parts = dateTextField.text?.split(separator: "/"), parts.count == 2, parts.allSatisfy({ Int($0) != nil }) {
            self.delegate?.didUpdate(value: String(parts[0]), for: .expirationMonth)
            self.delegate?.didUpdate(value: String(parts[1]), for: .expirationYear)
        } else {
            self.delegate?.didUpdate(value: nil, for: .expirationMonth)
            self.delegate?.didUpdate(value: nil, for: .expirationYear)
        }
    }

    @objc private func cvvTextFieldEditingChanged() {
        self.delegate?.didUpdate(value: self.cvvTextField.text, for: .cvv)
    }
}

extension DateCVVInputCollectionViewCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in _: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return 12
        case 1: return 100
        default: return 0
        }
    }

    func pickerView(_: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return String(format: "%02d", row + 1)
        default:
            return String(format: "%02d", row)
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow _: Int, inComponent _: Int) {
        self.dateTextField.text = String(format: "%02d/%02d", pickerView.selectedRow(inComponent: 0) + 1,
                                         pickerView.selectedRow(inComponent: 1))
        self.dateTextFieldEditingChanged()
    }
}
