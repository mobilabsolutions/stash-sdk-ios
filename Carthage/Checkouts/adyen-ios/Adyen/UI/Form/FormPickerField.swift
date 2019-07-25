//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import Foundation
import UIKit

/// :nodoc:
public class FormPickerField: UIControl {
    public init(customInputView: UIView) {
        self.customInputView = customInputView
        super.init(frame: .zero)

        addSubview(self.titleLabel)
        addSubview(self.textField)

        self.dynamicTypeController.observeDynamicType(for: self.textField, withTextAttributes: Appearance.shared.textAttributes, textStyle: .body)

        self.configureConstraints()

        isAccessibilityElement = true
        accessibilityTraits = UIAccessibilityTraits.button
    }

    public required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIResponder

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.textField.becomeFirstResponder()

        super.touchesEnded(touches, with: event)
    }

    // MARK: - Public

    public var selectedValue: String? {
        get {
            return self.textField.text
        }

        set {
            self.textField.text = newValue
        }
    }

    public var title: String? {
        didSet {
            if let title = title {
                self.titleLabel.attributedText = NSAttributedString(string: title, attributes: Appearance.shared.formAttributes.fieldTitleAttributes)

                self.dynamicTypeController.observeDynamicType(for: self.titleLabel, withTextAttributes: Appearance.shared.formAttributes.fieldTitleAttributes, textStyle: .footnote)
            } else {
                self.titleLabel.text = self.title
            }
            accessibilityLabel = self.title
        }
    }

    // MARK: - Private

    private let customInputView: UIView

    private let dynamicTypeController = DynamicTypeController()

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 13.0)
        titleLabel.numberOfLines = 0
        titleLabel.isAccessibilityElement = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        return titleLabel
    }()

    private lazy var textField: FormPickerTextField = {
        let textField = FormPickerTextField()
        textField.defaultTextAttributes = Appearance.shared.textAttributes
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.textAlignment = .left
        textField.inputView = customInputView

        return textField
    }()

    private func configureConstraints() {
        let constraints = [
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 7),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),

            bottomAnchor.constraint(equalTo: textField.bottomAnchor, constant: 9),
        ]

        NSLayoutConstraint.activate(constraints)
    }
}

/// :nodoc:
extension FormPickerField: UITextFieldDelegate {
    public func textField(_: UITextField, shouldChangeCharactersIn _: NSRange, replacementString _: String) -> Bool {
        return false
    }
}

private class FormPickerTextField: UITextField {
    override func caretRect(for _: UITextPosition) -> CGRect {
        return CGRect.zero
    }
}
