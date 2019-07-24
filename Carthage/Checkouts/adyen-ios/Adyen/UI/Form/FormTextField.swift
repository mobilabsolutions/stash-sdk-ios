//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import Foundation
import UIKit

/// :nodoc:
public protocol FormTextFieldDelegate: class {
    func valueChanged(_ formTextField: FormTextField)
}

/// :nodoc:
open class FormTextField: UIView {
    public init() {
        super.init(frame: .zero)

        self.textField.delegate = self

        backgroundColor = UIColor.clear

        addSubview(self.titleLabel)
        addSubview(self.textField)
        addSubview(self.accessoryContainer)

        self.dynamicTypeController.observeDynamicType(for: self.textField, withTextAttributes: Appearance.shared.textAttributes, textStyle: .body)

        self.configureConstraints()
    }

    public required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Open

    open override var accessibilityIdentifier: String? {
        get {
            return textField.accessibilityIdentifier
        }

        set {
            textField.accessibilityIdentifier = newValue
        }
    }

    open override func becomeFirstResponder() -> Bool {
        return self.textField.becomeFirstResponder()
    }

    // MARK: - Public

    public weak var delegate: FormTextFieldDelegate?

    /// The title to display above the text field.
    public var title: String? {
        didSet {
            if let title = title {
                self.titleLabel.attributedText = NSAttributedString(string: title, attributes: Appearance.shared.formAttributes.fieldTitleAttributes)
                self.dynamicTypeController.observeDynamicType(for: self.titleLabel, withTextAttributes: Appearance.shared.formAttributes.fieldTitleAttributes, textStyle: .footnote)
            } else {
                self.titleLabel.text = self.title
            }
            self.textField.accessibilityLabel = self.title
        }
    }

    public var accessoryView: UIView? {
        didSet {
            if let accessoryView = accessoryView {
                accessoryView.translatesAutoresizingMaskIntoConstraints = false
                self.accessoryContainer.addSubview(accessoryView)
                self.accessoryWidthConstraint?.constant = accessoryView.bounds.width + 10

                let constraints = [
                    accessoryView.centerYAnchor.constraint(equalTo: accessoryContainer.centerYAnchor),
                    accessoryView.trailingAnchor.constraint(equalTo: accessoryContainer.trailingAnchor),
                    accessoryView.widthAnchor.constraint(equalToConstant: accessoryView.bounds.width),
                    accessoryView.heightAnchor.constraint(equalToConstant: accessoryView.bounds.height),
                ]

                NSLayoutConstraint.activate(constraints)

            } else if let removedView = oldValue {
                removedView.removeFromSuperview()
                self.accessoryWidthConstraint?.constant = 0
            }
        }
    }

    public var validatedValue: String? {
        guard let text = text else {
            return nil
        }

        if let validator = validator {
            return validator.isValid(text) ? text : nil
        }

        return text
    }

    public var validator: Validator?
    public var nextResponderInChain: UIResponder?

    // MARK: - Private

    private let dynamicTypeController = DynamicTypeController()

    private var accessoryWidthConstraint: NSLayoutConstraint?

    private let invalidTextColor: UIColor? = Appearance.shared.formAttributes.invalidTextColor
    private let validTextColor: UIColor? = Appearance.shared.textAttributes[.foregroundColor] as? UIColor

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.isAccessibilityElement = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        return titleLabel
    }()

    private lazy var accessoryContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.defaultTextAttributes = Appearance.shared.textAttributes
        textField.clearButtonMode = .whileEditing
        textField.autocorrectionType = .no
        textField.translatesAutoresizingMaskIntoConstraints = false

        return textField
    }()

    private func configureConstraints() {
        self.accessoryWidthConstraint = NSLayoutConstraint(item: self.accessoryContainer, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)

        let constraints = [
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 7),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),

            accessoryContainer.leadingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 0),
            accessoryContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            accessoryContainer.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            accessoryWidthConstraint!,

            bottomAnchor.constraint(equalTo: textField.bottomAnchor, constant: 9),
        ]
        NSLayoutConstraint.activate(constraints)
    }

    private func updateTextColor() {
        if self.textField.isEditing {
            self.textField.textColor = self.validTextColor
        } else {
            self.textField.textColor = (self.validatedValue != nil) ? self.validTextColor : self.invalidTextColor
        }
    }
}

// MARK: - UITextField Properties

/// :nodoc:
public extension FormTextField {
    var text: String? {
        get {
            return self.textField.text
        }

        set {
            let attributes = Appearance.shared.textAttributes

            if let unwrappedNewValue = newValue, let formatted = validator?.format(unwrappedNewValue) {
                self.textField.attributedText = NSAttributedString(string: formatted, attributes: attributes)
            } else {
                self.textField.attributedText = NSAttributedString(string: newValue ?? "", attributes: attributes)
            }

            self.delegate?.valueChanged(self)
        }
    }

    var placeholder: String? {
        get {
            return self.textField.placeholder
        }

        set {
            let attributes = Appearance.shared.formAttributes.placeholderAttributes
            self.textField.attributedPlaceholder = NSAttributedString(string: newValue ?? "", attributes: attributes)
        }
    }

    var autocapitalizationType: UITextAutocapitalizationType {
        get {
            return self.textField.autocapitalizationType
        }
        set {
            self.textField.autocapitalizationType = newValue
        }
    }

    var keyboardType: UIKeyboardType {
        get {
            return self.textField.keyboardType
        }
        set {
            self.textField.keyboardType = newValue
        }
    }

    var clearButtonMode: UITextField.ViewMode {
        get {
            return self.textField.clearButtonMode
        }
        set {
            self.textField.clearButtonMode = newValue
        }
    }
}

/// :nodoc:
extension FormTextField: UITextFieldDelegate {
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.textColor = self.validTextColor
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text, let validator = validator else {
            return
        }

        let valid = validator.isValid(text)
        textField.textColor = valid ? self.validTextColor : self.invalidTextColor

        if !valid {
            if #available(iOS 10.0, *) {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.warning)
            }
        }
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            textField.text = ""
            self.delegate?.valueChanged(self)
            return false
        }

        let newText = (text as NSString).replacingCharacters(in: range, with: string)
        let isDeleting = (string.count == 0 && range.length == 1)
        guard let validator = validator, !isDeleting else {
            textField.text = newText
            self.delegate?.valueChanged(self)
            return false
        }

        if validator.isMaxLength(text) {
            return false
        }

        let formatted = validator.format(newText)
        textField.text = formatted
        self.delegate?.valueChanged(self)

        if validator.isMaxLength(newText) {
            self.nextResponderInChain?.becomeFirstResponder()
        }

        return false
    }

    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = ""
        self.delegate?.valueChanged(self)
        return false
    }
}
