//
//  NameInputCollectionViewCell.swift
//  MobilabPaymentCore
//
//  Created by Rupali Ghate on 25.04.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import UIKit

class PairedTextInputCollectionViewCell: UICollectionViewCell, NextCellEnabled, FormFieldErrorDelegate {
    weak var nextCellSwitcher: NextCellSwitcher?

    var isLastCell: Bool = false {
        didSet {
            self.secondTextField.returnKeyType = self.isLastCell ? .done : .continue
        }
    }

    private var firstText: String? {
        didSet {
            self.firstTextField.text = self.firstText
            self.didUpdateTextFieldText(self.firstTextField)
        }
    }

    private var secondText: String? {
        didSet {
            self.secondTextField.text = self.secondText
            self.didUpdateTextFieldText(self.secondTextField)
        }
    }

    private var firstTitle: String? {
        didSet {
            self.firstSubTitleLabel.text = self.firstTitle
        }
    }

    private var secondTitle: String? {
        didSet {
            self.secondSubTitleLabel.text = self.secondTitle
        }
    }

    private var firstPlaceholderText: String? {
        didSet {
            self.firstTextField.placeholder = self.firstPlaceholderText
        }
    }

    private var secondPlaceholderText: String? {
        didSet {
            self.secondTextField.placeholder = self.secondPlaceholderText
        }
    }

    private var firstErrorText: String? {
        didSet {
            self.firstTextField.set(hasInvalidData: self.firstErrorText != nil)
            self.errorLabel.text = (self.firstErrorText.flatMap { $0 + "\n" } ?? "") + (self.secondErrorText ?? "")
            self.errorLabelZeroHeightConstraint?.isActive = self.firstErrorText == nil && self.secondErrorText == nil
        }
    }

    private var secondErrorText: String? {
        didSet {
            self.secondTextField.set(hasInvalidData: self.secondErrorText != nil)
            self.errorLabel.text = (self.firstErrorText.flatMap { $0 + "\n" } ?? "") + (self.secondErrorText ?? "")
            self.errorLabelZeroHeightConstraint?.isActive = self.firstErrorText == nil && self.secondErrorText == nil
        }
    }

    private var firstDataType: NecessaryData? {
        didSet {
            guard let dataType = self.firstDataType
            else { return }

            switch dataType {
            case .holderFirstName, .holderLastName:
                self.firstTextField.textContentType = .name
                self.firstTextField.autocapitalizationType = .words
            default:
                self.firstTextField.textContentType = nil
                self.firstTextField.autocapitalizationType = .sentences
            }
        }
    }

    private var secondDataType: NecessaryData? {
        didSet {
            guard let dataType = self.secondDataType
            else { return }

            switch dataType {
            case .holderFirstName, .holderLastName:
                self.secondTextField.textContentType = .name
                self.secondTextField.autocapitalizationType = .words
            default:
                self.secondTextField.textContentType = nil
                self.secondTextField.autocapitalizationType = .sentences
            }
        }
    }

    private let defaultHorizontalToSuperviewOffset: CGFloat = 16
    private let fieldHeight: CGFloat = 40
    private let fieldToHeaderVerticalOffset: CGFloat = 8
    private let headerToSuperViewVerticalOffset: CGFloat = 16
    private let errorLabelVerticalOffset: CGFloat = 4

    private weak var delegate: DataPointProvidingDelegate?
    private var textFieldFocusGainCallback: ((UITextField, NecessaryData) -> Void)?
    private var textFieldUpdateCallback: ((UITextField, NecessaryData) -> Void)?

    private let firstTextField = CustomTextField()
    private let firstSubTitleLabel = SubtitleLabel()

    private let secondTextField = CustomTextField()
    private let secondSubTitleLabel = SubtitleLabel()

    private let errorLabel = ErrorLabel()

    private var errorLabelZeroHeightConstraint: NSLayoutConstraint?

    public func setup(firstText: String?,
                      firstTitle: String?,
                      firstPlaceholder: String?,
                      firstDataType: NecessaryData,
                      secondText: String?,
                      secondTitle: String?,
                      secondPlaceholder: String?,
                      secondDataType: NecessaryData,
                      textFieldFocusGainCallback: ((UITextField, NecessaryData) -> Void)? = nil,
                      textFieldUpdateCallback: ((UITextField, NecessaryData) -> Void)? = nil,
                      firstError: String?,
                      secondError: String?,
                      setupTextField: ((UITextField, NecessaryData) -> Void)? = nil,
                      configuration: PaymentMethodUIConfiguration,
                      delegate: DataPointProvidingDelegate) {
        self.textFieldFocusGainCallback = textFieldFocusGainCallback
        self.textFieldUpdateCallback = textFieldUpdateCallback
        self.firstText = firstText
        self.firstTitle = firstTitle
        self.firstPlaceholderText = firstPlaceholder
        self.firstDataType = firstDataType
        self.firstErrorText = firstError
        self.secondText = secondText
        self.secondTitle = secondTitle
        self.secondPlaceholderText = secondPlaceholder
        self.secondDataType = secondDataType
        self.secondErrorText = secondError
        self.delegate = delegate

        [firstTextField, secondTextField].forEach {
            $0.setup(borderColor: configuration.mediumEmphasisColor,
                     placeholderColor: configuration.mediumEmphasisColor,
                     textColor: configuration.textColor,
                     backgroundColor: configuration.cellBackgroundColor,
                     errorBorderColor: configuration.errorMessageColor)
        }

        self.contentView.backgroundColor = configuration.cellBackgroundColor
        self.firstSubTitleLabel.textColor = configuration.textColor
        self.secondSubTitleLabel.textColor = configuration.textColor

        setupTextField?(self.firstTextField, firstDataType)
        setupTextField?(self.secondTextField, secondDataType)

        self.firstTextField.returnKeyType = .continue
        self.firstTextField.delegate = self

        self.secondTextField.returnKeyType = .continue
        self.secondTextField.delegate = self

        self.errorLabel.text = (self.firstErrorText.flatMap { $0 + "\n" } ?? "") + (self.secondErrorText ?? "")
        self.errorLabelZeroHeightConstraint?.isActive = self.firstErrorText == nil && self.secondErrorText == nil
        self.errorLabel.uiConfiguration = configuration
    }

    func selectCell() {
        self.firstTextField.becomeFirstResponder()
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
        self.firstTextField.translatesAutoresizingMaskIntoConstraints = false
        self.firstSubTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        self.secondTextField.translatesAutoresizingMaskIntoConstraints = false
        self.secondSubTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        self.errorLabel.translatesAutoresizingMaskIntoConstraints = false

        self.contentView.addSubview(self.firstTextField)
        self.contentView.addSubview(self.firstSubTitleLabel)

        self.contentView.addSubview(self.secondTextField)
        self.contentView.addSubview(self.secondSubTitleLabel)

        self.contentView.addSubview(self.errorLabel)

        NSLayoutConstraint.activate([
            self.firstTextField.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: defaultHorizontalToSuperviewOffset),
            self.firstTextField.trailingAnchor.constraint(equalTo: self.secondTextField.leadingAnchor, constant: -defaultHorizontalToSuperviewOffset),
            self.firstTextField.widthAnchor.constraint(equalTo: self.secondTextField.widthAnchor),
            self.firstTextField.heightAnchor.constraint(equalToConstant: fieldHeight),
            self.secondTextField.centerYAnchor.constraint(equalTo: self.firstTextField.centerYAnchor),
            self.secondTextField.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -defaultHorizontalToSuperviewOffset),
            self.secondTextField.heightAnchor.constraint(equalTo: self.firstTextField.heightAnchor),
            self.firstSubTitleLabel.leadingAnchor.constraint(equalTo: self.firstTextField.leadingAnchor),
            self.firstSubTitleLabel.trailingAnchor.constraint(equalTo: self.firstTextField.trailingAnchor),
            self.firstSubTitleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: headerToSuperViewVerticalOffset),
            self.secondSubTitleLabel.topAnchor.constraint(equalTo: self.firstSubTitleLabel.topAnchor),
            self.secondSubTitleLabel.leadingAnchor.constraint(equalTo: self.secondTextField.leadingAnchor),
            self.secondSubTitleLabel.trailingAnchor.constraint(equalTo: self.secondSubTitleLabel.trailingAnchor),
            self.firstTextField.topAnchor.constraint(equalTo: self.firstSubTitleLabel.bottomAnchor, constant: fieldToHeaderVerticalOffset),
            self.errorLabel.leadingAnchor.constraint(equalTo: self.firstTextField.leadingAnchor),
            self.errorLabel.trailingAnchor.constraint(equalTo: self.secondTextField.trailingAnchor),
            self.errorLabel.topAnchor.constraint(equalTo: self.firstTextField.bottomAnchor, constant: errorLabelVerticalOffset),
        ])

        self.errorLabelZeroHeightConstraint = self.errorLabel.heightAnchor.constraint(equalToConstant: 0)
        self.errorLabelZeroHeightConstraint?.isActive = true

        self.firstTextField.addTarget(self, action: #selector(self.didUpdateTextFieldText), for: .editingChanged)
        self.firstTextField.addTarget(self, action: #selector(self.didEndEditingTextFieldText), for: .editingDidEnd)

        self.secondTextField.addTarget(self, action: #selector(self.didUpdateTextFieldText), for: .editingChanged)
        self.secondTextField.addTarget(self, action: #selector(self.didEndEditingTextFieldText), for: .editingDidEnd)

        self.backgroundColor = .white
    }

    @objc private func didUpdateTextFieldText(_ textField: UITextField) {
        guard let type = (textField == self.firstTextField ? self.firstDataType : self.secondDataType)
        else { return }

        self.textFieldUpdateCallback?(textField, type)
        self.delegate?.didUpdate(value: textField.text?.trimmingCharacters(in: .whitespaces), for: type)
    }

    @objc private func didEndEditingTextFieldText(_ textField: UITextField) {
        textField.text = textField.text?.trimmingCharacters(in: .whitespaces)
        self.didUpdateTextFieldText(textField)
    }

    public override func prepareForReuse() {
        super.prepareForReuse()

        self.delegate = nil
        self.textFieldUpdateCallback = nil
        self.firstErrorText = nil
        self.secondErrorText = nil
        self.firstPlaceholderText = nil
        self.secondPlaceholderText = nil
        self.firstText = nil
        self.secondText = nil
    }

    func setError(description: String?, forDataPoint dataPoint: NecessaryData) {
        if dataPoint == self.firstDataType {
            self.firstErrorText = description
        } else if dataPoint == self.secondDataType {
            self.secondErrorText = description
        }
    }
}

extension PairedTextInputCollectionViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.firstTextField {
            self.secondTextField.becomeFirstResponder()
        } else {
            self.nextCellSwitcher?.switchToNextCell(from: self)
        }
        return false
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let type = (textField == self.firstTextField ? self.firstDataType : self.secondDataType)
        else { return }

        self.textFieldFocusGainCallback?(textField, type)
    }
}
