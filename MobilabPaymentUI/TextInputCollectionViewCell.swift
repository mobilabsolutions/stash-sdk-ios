//
//  TextInputCollectionViewCell.swift
//  MobilabPaymentBSPayone
//
//  Created by Robert on 18.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import UIKit

public class TextInputCollectionViewCell: UICollectionViewCell {
    private var text: String? {
        didSet {
            self.textField.text = text
            self.didUpdateTextFieldText()
        }
    }

    private var title: String? {
        didSet {
            self.subtitleLabel.text = self.title
        }
    }

    private var placeholder: String? {
        didSet {
            self.textField.placeholder = self.placeholder
        }
    }

    private var errorText: String? {
        didSet {
            self.textField.set(hasInvalidData: self.errorText != nil)
            self.errorLabel.text = errorText
            self.errorLabelZeroHeightConstraint?.isActive = self.errorText == nil
        }
    }

    private var dataType: NecessaryData? {
        didSet {
            guard let dataType = self.dataType
            else { return }

            switch dataType {
            case .holderName:
                self.textField.textContentType = .name
                self.textField.autocapitalizationType = .words
            case .cardNumber:
                self.textField.textContentType = .creditCardNumber
                self.textField.autocapitalizationType = .allCharacters
            case .iban:
                self.textField.textContentType = nil
                self.textField.autocapitalizationType = .allCharacters
            case .bic:
                self.textField.textContentType = nil
                self.textField.autocapitalizationType = .allCharacters
            default:
                self.textField.textContentType = nil
                self.textField.autocapitalizationType = .sentences
            }
        }
    }

    private let defaultHorizontalToSuperviewOffset: CGFloat = 16
    private let fieldHeight: CGFloat = 40
    private let fieldToHeaderVerticalOffset: CGFloat = 8
    private let headerToSuperViewVerticalOffset: CGFloat = 16
    private let errorLabelVerticalOffset: CGFloat = 4

    private weak var delegate: DataPointProvidingDelegate?
    private var textFieldUpdateCallback: ((UITextField) -> Void)?

    private let textField = CustomTextField()
    private let subtitleLabel = SubtitleLabel()
    private let errorLabel = ErrorLabel()

    private var errorLabelZeroHeightConstraint: NSLayoutConstraint?

    public func setup(text: String?,
                      title: String?,
                      placeholder: String?,
                      dataType: NecessaryData,
                      textFieldUpdateCallback: ((UITextField) -> Void)? = nil,
                      error: String?,
                      setupTextField: ((UITextField) -> Void)? = nil,
                      configuration: PaymentMethodUIConfiguration,
                      delegate: DataPointProvidingDelegate) {
        self.textFieldUpdateCallback = textFieldUpdateCallback
        self.text = text
        self.title = title
        self.placeholder = placeholder
        self.dataType = dataType
        self.delegate = delegate
        self.errorText = error

        self.textField.setup(borderColor: configuration.mediumEmphasisColor,
                             placeholderColor: configuration.mediumEmphasisColor,
                             textColor: configuration.textColor, backgroundColor: configuration.cellBackgroundColor)

        self.contentView.backgroundColor = configuration.cellBackgroundColor
        self.subtitleLabel.textColor = configuration.textColor

        setupTextField?(self.textField)
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
        self.textField.translatesAutoresizingMaskIntoConstraints = false
        self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.errorLabel.translatesAutoresizingMaskIntoConstraints = false

        self.contentView.addSubview(self.textField)
        self.contentView.addSubview(self.subtitleLabel)
        self.contentView.addSubview(self.errorLabel)

        NSLayoutConstraint.activate([
            self.textField.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: defaultHorizontalToSuperviewOffset),
            self.textField.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -defaultHorizontalToSuperviewOffset),
            self.textField.heightAnchor.constraint(equalToConstant: fieldHeight),
            self.subtitleLabel.leadingAnchor.constraint(equalTo: self.textField.leadingAnchor),
            self.subtitleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: headerToSuperViewVerticalOffset),
            self.subtitleLabel.trailingAnchor.constraint(equalTo: self.textField.trailingAnchor),
            self.subtitleLabel.bottomAnchor.constraint(equalTo: self.textField.topAnchor, constant: -fieldToHeaderVerticalOffset),
            self.errorLabel.leadingAnchor.constraint(equalTo: self.textField.leadingAnchor),
            self.errorLabel.trailingAnchor.constraint(equalTo: self.textField.trailingAnchor),
            self.errorLabel.topAnchor.constraint(equalTo: self.textField.bottomAnchor, constant: errorLabelVerticalOffset),
        ])

        self.errorLabelZeroHeightConstraint = self.errorLabel.heightAnchor.constraint(equalToConstant: 0)
        self.errorLabelZeroHeightConstraint?.isActive = true

        self.textField.addTarget(self, action: #selector(self.didUpdateTextFieldText), for: .editingChanged)
        self.textField.addTarget(self, action: #selector(self.didEndEditingTextFieldText), for: .editingDidEnd)

        self.backgroundColor = .white
    }

    @objc private func didUpdateTextFieldText() {
        self.textFieldUpdateCallback?(self.textField)

        guard let type = self.dataType
        else { return }

        self.delegate?.didUpdate(value: self.textField.text?.trimmingCharacters(in: .whitespaces), for: type)
    }

    @objc private func didEndEditingTextFieldText() {
        self.textField.text = self.textField.text?.trimmingCharacters(in: .whitespaces)
        self.didUpdateTextFieldText()
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        self.delegate = nil
        self.textFieldUpdateCallback = nil
        self.errorText = nil
        self.placeholder = nil
        self.text = nil
    }
}
