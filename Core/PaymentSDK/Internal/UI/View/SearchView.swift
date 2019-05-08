//
//  SearchView.swift
//  MobilabPaymentCore
//
//  Created by Rupali Ghate on 06.05.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import UIKit

protocol SearchViewDelegate: class {
    func didCancelSearch()
}

class SearchView: UIView {
    weak var delegate: SearchViewDelegate?
    
    private var text: String? {
        didSet {
            self.textField.text = text
//            self.didUpdateTextFieldText()
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
    private let buttonWidth: CGFloat = 70
    
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
        textField.setup(borderColor: .clear, placeholderColor: nil, textColor: nil, backgroundColor: nil)
        
        return textField
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        button.backgroundColor = .gray
        return button
    }()
    
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
                             textColor: configuration.textColor, backgroundColor: configuration.cellBackgroundColor)
        
        self.backgroundColor = configuration.cellBackgroundColor

        self.textField.returnKeyType = .search
        textField.delegate = self
    }
    
    public func clear() {
        textField.text = ""
    }
    
    // MARK: - initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sharedInit()
    }
    
    // MARK: - private methods

    private func sharedInit() {
        addSubview(imageView)
        imageView.anchor(top: nil, left: leftAnchor,
                         bottom: nil, right: nil, paddingTop: 0,
                         paddingLeft: defaultHorizontalToSuperviewOffset + defaultHorizontalToSuperviewOffset,
                         paddingBottom: 0, paddingRight: 0,
                         width: imageDimension.width, height: imageDimension.height)
        imageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(textField)
        textField.anchor(top: nil, left: imageView.rightAnchor,
                         bottom: nil, right: nil,
                         paddingTop: 0, paddingLeft: defaultInterItemOffset,
                         paddingBottom: 0, paddingRight: 0,
                         width: 0, height: fieldHeight)
        textField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(cancelButton)
        cancelButton.anchor(top: nil, left: textField.rightAnchor,
                            bottom: nil, right: rightAnchor,
                            paddingTop: 0, paddingLeft: defaultInterItemOffset,
                            paddingBottom: 0, paddingRight: defaultHorizontalToSuperviewOffset,
                            width: buttonWidth, height: fieldHeight)
        cancelButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        cancelButton.isHidden = true
        
        self.textField.addTarget(self, action: #selector(self.didUpdateTextFieldText), for: .editingChanged)
        self.textField.addTarget(self, action: #selector(self.didEndEditingTextFieldText), for: .editingDidEnd)
        self.textField.addTarget(self, action: #selector(self.textFieldReceivedFocus), for: .editingDidBegin)
        
        self.backgroundColor = .white
    }
    
    // MARK: - textfield handlers

    @objc private func textFieldReceivedFocus() {
        cancelButton.isHidden = false
        textFieldFocusGainCallback?(self.textField)
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
        print("cancelled..")
        cancelButton.isHidden = true
        textField.resignFirstResponder()
        
        delegate?.didCancelSearch()
    }
}

extension SearchView: UITextFieldDelegate {
    func textFieldShouldReturn(_: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        delegate?.didCancelSearch()

        return true 
    }
}


