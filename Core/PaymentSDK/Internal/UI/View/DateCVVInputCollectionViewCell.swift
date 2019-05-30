//
//  DateCVVInputCollectionViewCell.swift
//  MobilabPaymentCore
//
//  Created by Robert on 18.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import UIKit

class DateCVVInputCollectionViewCell: UICollectionViewCell, NextCellEnabled, FormFieldErrorDelegate {
    weak var nextCellSwitcher: NextCellSwitcher?

    var isLastCell: Bool = false {
        didSet {
            self.cvvTextField.returnKeyType = self.isLastCell ? .done : .continue
        }
    }

    private var date: (month: Int, year: Int)?

    private var cvv: String? {
        didSet {
            self.cvvTextField.text = self.cvv
        }
    }

    private var dateError: String? {
        didSet {
            self.dateErrorLabel.text = self.dateError
            self.dateTextField.set(hasInvalidData: self.dateError != nil)
            self.dateErrorLabelZeroHeightConstraint?.isActive = self.dateError == nil
        }
    }

    private var cvvError: String? {
        didSet {
            self.cvvErrorLabel.text = self.cvvError
            self.cvvTextField.set(hasInvalidData: self.cvvError != nil)
            self.cvvErrorLabelZeroHeightConstraint?.isActive = self.cvvError == nil
        }
    }

    private let defaultHorizontalToSuperviewOffset: CGFloat = 16
    private let fieldHeight: CGFloat = 40
    private let fieldToHeaderVerticalOffset: CGFloat = 8
    private let headerToSuperViewVerticalOffset: CGFloat = 16
    private let errorLabelVerticalOffset: CGFloat = 4
    private let errorLabelHorizontalOffset: CGFloat = 4
    private let numberOfMonths = 12
    private let numberOfYearsToShow = 20

    private var delegate: DataPointProvidingDelegate?
    private var textFieldGainFocusCallback: ((UITextField, NecessaryData) -> Void)?
    private var textFieldLoseFocusCallback: ((UITextField, NecessaryData) -> Void)?

    private let dateTextField = CustomTextField()
    private let cvvTextField = CustomTextField()
    private let pickerView = UIPickerView()

    private let dateTitleLabel = SubtitleLabel()
    private let cvvTitleLabel = SubtitleLabel()
    private let dateErrorLabel = ErrorLabel()
    private let cvvErrorLabel = ErrorLabel()

    private var dateErrorLabelZeroHeightConstraint: NSLayoutConstraint?
    private var cvvErrorLabelZeroHeightConstraint: NSLayoutConstraint?

    func setup(date: (month: Int, year: Int)?,
               cvv: String?,
               dateError: String?,
               cvvError: String?,
               textFieldGainFocusCallback: ((UITextField, NecessaryData) -> Void)? = nil,
               textFieldLoseFocusCallback: ((UITextField, NecessaryData) -> Void)? = nil,
               delegate: DataPointProvidingDelegate,
               configuration: PaymentMethodUIConfiguration) {
        self.date = date
        self.cvv = cvv
        self.delegate = delegate
        self.dateError = dateError
        self.cvvError = cvvError

        self.textFieldGainFocusCallback = textFieldGainFocusCallback
        self.textFieldLoseFocusCallback = textFieldLoseFocusCallback

        self.dateErrorLabel.text = dateError
        self.cvvErrorLabel.text = cvvError

        self.dateErrorLabelZeroHeightConstraint?.isActive = self.dateError == nil
        self.cvvErrorLabelZeroHeightConstraint?.isActive = self.cvvError == nil

        self.dateErrorLabel.uiConfiguration = configuration
        self.cvvErrorLabel.uiConfiguration = configuration

        self.dateTitleLabel.textColor = configuration.textColor
        self.cvvTitleLabel.textColor = configuration.textColor
        [dateTextField, cvvTextField].forEach {
            $0.setup(borderColor: configuration.mediumEmphasisColor,
                     placeholderColor: configuration.mediumEmphasisColor,
                     textColor: configuration.textColor,
                     backgroundColor: configuration.cellBackgroundColor,
                     errorBorderColor: configuration.errorMessageColor)
        }

        self.dateTextField.returnKeyType = .continue
        self.cvvTextField.returnKeyType = .continue

        self.dateTextField.delegate = self
        self.cvvTextField.delegate = self

        self.contentView.backgroundColor = configuration.cellBackgroundColor
    }

    func selectCell() {
        self.dateTextField.becomeFirstResponder()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sharedInit()
    }

    func setError(description: String?, forDataPoint dataPoint: NecessaryData) {
        if dataPoint == .expirationMonth || dataPoint == .expirationYear {
            self.dateError = description
        } else {
            self.cvvError = description
        }
    }

    private func sharedInit() {
        self.setupDatePicker()
        self.setupDateTextField()
        self.setupCVVTextField()
        self.setupLabels()

        self.contentView.addSubview(self.dateErrorLabel)
        self.contentView.addSubview(self.cvvErrorLabel)
        self.contentView.addSubview(self.dateTextField)
        self.contentView.addSubview(self.cvvTextField)
        self.contentView.addSubview(self.dateTitleLabel)
        self.contentView.addSubview(self.cvvTitleLabel)

        NSLayoutConstraint.activate([
            self.dateTextField.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: defaultHorizontalToSuperviewOffset),
            self.dateTextField.trailingAnchor.constraint(equalTo: self.cvvTextField.leadingAnchor, constant: -defaultHorizontalToSuperviewOffset),
            self.dateTextField.widthAnchor.constraint(equalTo: self.cvvTextField.widthAnchor),
            self.dateTextField.heightAnchor.constraint(equalToConstant: fieldHeight),
            self.cvvTextField.centerYAnchor.constraint(equalTo: self.dateTextField.centerYAnchor),
            self.cvvTextField.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -defaultHorizontalToSuperviewOffset),
            self.cvvTextField.heightAnchor.constraint(equalTo: self.dateTextField.heightAnchor),
            self.dateTitleLabel.leadingAnchor.constraint(equalTo: self.dateTextField.leadingAnchor),
            self.dateTitleLabel.trailingAnchor.constraint(equalTo: self.dateTextField.trailingAnchor),
            self.dateTitleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: headerToSuperViewVerticalOffset),
            self.cvvTitleLabel.topAnchor.constraint(equalTo: self.dateTitleLabel.topAnchor),
            self.cvvTitleLabel.leadingAnchor.constraint(equalTo: self.cvvTextField.leadingAnchor),
            self.cvvTitleLabel.trailingAnchor.constraint(equalTo: self.cvvTitleLabel.trailingAnchor),
            self.dateTextField.topAnchor.constraint(equalTo: self.dateTitleLabel.bottomAnchor, constant: fieldToHeaderVerticalOffset),
            self.dateErrorLabel.leadingAnchor.constraint(equalTo: self.dateTextField.leadingAnchor),
            self.dateErrorLabel.trailingAnchor.constraint(equalTo: self.cvvErrorLabel.leadingAnchor, constant: -errorLabelHorizontalOffset),
            self.dateErrorLabel.topAnchor.constraint(equalTo: self.dateTextField.bottomAnchor, constant: errorLabelVerticalOffset),
            self.cvvErrorLabel.leadingAnchor.constraint(equalTo: self.cvvTextField.leadingAnchor),
            self.cvvErrorLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -errorLabelHorizontalOffset),
            self.cvvErrorLabel.topAnchor.constraint(equalTo: self.cvvTextField.bottomAnchor, constant: errorLabelVerticalOffset),
        ])

        self.dateErrorLabelZeroHeightConstraint = self.dateErrorLabel.heightAnchor.constraint(equalToConstant: 0)
        self.cvvErrorLabelZeroHeightConstraint = self.cvvErrorLabel.heightAnchor.constraint(equalToConstant: 0)
        self.dateErrorLabelZeroHeightConstraint?.isActive = true
        self.cvvErrorLabelZeroHeightConstraint?.isActive = true

        self.backgroundColor = .white
    }

    fileprivate func setupCVVTextField() {
        self.cvvTextField.translatesAutoresizingMaskIntoConstraints = false

        self.cvvTextField.placeholder = "CVV/CVC"
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
        self.cvvTitleLabel.text = "CVV/CVC"
        self.dateTitleLabel.text = "Expiration date"

        self.dateErrorLabel.numberOfLines = 0
        self.cvvErrorLabel.numberOfLines = 0

        self.cvvTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.dateTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.dateErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        self.cvvErrorLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    fileprivate func setupDatePicker() {
        self.pickerView.delegate = self
        self.pickerView.dataSource = self

        if let date = self.date {
            self.pickerView.selectRow(date.month, inComponent: 0, animated: false)
            self.pickerView.selectRow(date.year, inComponent: 1, animated: false)
        } else {
            // Select next year
            self.pickerView.selectRow(1, inComponent: 1, animated: false)
        }

        self.dateTextField.inputView = self.pickerView
    }

    @objc private func dateTextFieldBeganEditing() {
        if let text = self.dateTextField.text, !text.isEmpty {
            self.dateTextField.text = text
        } else {
            let selectedYear = self.pickerView.selectedRow(inComponent: 1) + self.currentYear()
            self.dateTextField.text = String(format: "%02d/%02d", self.pickerView.selectedRow(inComponent: 0) + 1, selectedYear % 100)
            self.dateTextFieldEditingChanged()
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

    private func currentYear() -> Int {
        return Calendar(identifier: .gregorian).component(.year, from: Date())
    }
}

extension DateCVVInputCollectionViewCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in _: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return self.numberOfMonths
        case 1: return self.numberOfYearsToShow
        default: return 0
        }
    }

    func pickerView(_: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return String(format: "%02d", row + 1)
        default:
            return String(format: "%02d", self.currentYear() + row)
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow _: Int, inComponent _: Int) {
        let selectedYear = pickerView.selectedRow(inComponent: 1) + self.currentYear()
        self.dateTextField.text = String(format: "%02d/%02d", pickerView.selectedRow(inComponent: 0) + 1, selectedYear % 100)
        self.dateTextFieldEditingChanged()
    }
}

extension DateCVVInputCollectionViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.dateTextField {
            self.cvvTextField.becomeFirstResponder()
        } else {
            self.nextCellSwitcher?.switchToNextCell(from: self)
        }

        return false
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.textFieldGainFocusCallback?(textField, textField == self.dateTextField ? .expirationYear : .cvv)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.textFieldLoseFocusCallback?(textField, textField == self.dateTextField ? .expirationYear : .cvv)
    }
}
