//
//  SearchView.swift
//  MobilabPaymentCore
//
//  Created by Rupali Ghate on 06.05.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import UIKit

// MARK: - Protocol

protocol SearchViewDelegate: class {
    func didCancelSearch()
}

class SearchView: UIView {
    // MARK: - Properties

    weak var delegate: SearchViewDelegate?

    private var text: String? {
        didSet {
            self.textField.text = self.text
        }
    }

    private var placeholder: String? {
        didSet {
            self.textField.placeholder = self.placeholder
        }
    }

    private let defaultHorizontalToSuperviewOffset: CGFloat = 16
    private let defaultInterItemOffset: CGFloat = 4
    private let imageDimension: (width: CGFloat, height: CGFloat) = (24, 24)
    private let fieldHeight: CGFloat = 40
    private let buttonWidth: CGFloat = 24

    private var textFieldFocusGainCallback: ((UITextField) -> Void)?
    private var textFieldUpdateCallback: ((UITextField) -> Void)?

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIConstants.searchImage
        iv.contentMode = .scaleAspectFit

        return iv
    }()

    private let textField: CustomTextField = {
        let textField = CustomTextField()
        textField.clearButtonMode = .always
        return textField
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.setImage(UIConstants.closeButtonImage, for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()

    // MARK: - initializer

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.accessibilityIdentifier = "SearchView"

        self.sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sharedInit()
    }

    // MARK: - private methods

    private func sharedInit() {
        addSubview(self.imageView)
        self.imageView.anchor(left: leftAnchor,
                              centerY: centerYAnchor,
                              paddingLeft: self.defaultHorizontalToSuperviewOffset + self.defaultHorizontalToSuperviewOffset,
                              width: self.imageDimension.width, height: self.imageDimension.height)

        addSubview(self.textField)
        self.textField.anchor(left: self.imageView.rightAnchor,
                              centerY: centerYAnchor,
                              paddingLeft: self.defaultInterItemOffset,
                              height: self.fieldHeight)

        addSubview(self.cancelButton)
        self.cancelButton.anchor(left: self.textField.rightAnchor,
                                 right: rightAnchor,
                                 centerY: centerYAnchor,
                                 paddingLeft: self.defaultInterItemOffset,
                                 paddingRight: self.defaultHorizontalToSuperviewOffset,
                                 width: self.buttonWidth, height: self.fieldHeight)
        self.cancelButton.isHidden = true

        self.textField.addTarget(self, action: #selector(self.didUpdateTextFieldText), for: .editingChanged)
        self.textField.addTarget(self, action: #selector(self.didEndEditingTextFieldText), for: .editingDidEnd)
        self.textField.addTarget(self, action: #selector(self.textFieldReceivedFocus), for: .editingDidBegin)

        self.backgroundColor = .white
    }

    // MARK: - textfield handlers

    @objc private func textFieldReceivedFocus() {
        self.cancelButton.isHidden = false
        self.textFieldFocusGainCallback?(self.textField)
    }

    @objc private func didUpdateTextFieldText() {
        self.textFieldUpdateCallback?(self.textField)
    }

    @objc private func didEndEditingTextFieldText() {
        self.textField.text = self.textField.text?.trimmingCharacters(in: .whitespaces)
        self.didUpdateTextFieldText()
    }

    // MARK: - button handler

    @objc private func handleCancel() {
        self.cancelButton.isHidden = true
        self.textField.resignFirstResponder()

        self.delegate?.didCancelSearch()
    }

    // MARK: - public methods

    public func setup(text: String?,
                      borderColor: UIColor?,
                      placeholder: String?,
                      textFieldFocusGainCallback: ((UITextField) -> Void)? = nil,
                      textFieldUpdateCallback: ((UITextField) -> Void)? = nil,
                      configuration: PaymentMethodUIConfiguration) {
        self.textFieldFocusGainCallback = textFieldFocusGainCallback
        self.textFieldUpdateCallback = textFieldUpdateCallback
        self.text = text
        self.placeholder = placeholder

        self.textField.setup(borderColor: borderColor,
                             placeholderColor: configuration.mediumEmphasisColor,
                             textColor: configuration.textColor,
                             backgroundColor: configuration.cellBackgroundColor,
                             errorBorderColor: configuration.errorMessageColor)

        self.backgroundColor = configuration.cellBackgroundColor

        self.textField.returnKeyType = .search
        self.textField.delegate = self
    }

    public func clear() {
        self.textField.text = ""
    }
}

extension SearchView: UITextFieldDelegate {
    func textFieldShouldReturn(_: UITextField) -> Bool {
        self.textField.resignFirstResponder()
        return false
    }

    func textFieldShouldClear(_: UITextField) -> Bool {
        self.delegate?.didCancelSearch()
        return true
    }
}
