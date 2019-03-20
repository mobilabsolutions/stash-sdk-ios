//
//  TextInputCollectionViewCell.swift
//  MobilabPaymentBSPayone
//
//  Created by Robert on 18.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import UIKit

class TextInputCollectionViewCell: UICollectionViewCell {
    private var text: String? {
        didSet {
            self.textField.text = self.text
        }
    }

    private var title: String? {
        didSet {
            self.textField.placeholder = self.title
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
            case .iban:
                self.textField.textContentType = nil
                self.textField.autocapitalizationType = .allCharacters
            case .bic:
                self.textField.textContentType = nil
                self.textField.autocapitalizationType = .allCharacters
            default:
                self.textField.textContentType = nil
            }
        }
    }

    private weak var delegate: DataPointProvidingDelegate?

    private let textField = UITextField()

    func setup(text: String?, title: String?, dataType: NecessaryData, delegate: DataPointProvidingDelegate) {
        self.text = text
        self.title = title
        self.dataType = dataType
        self.delegate = delegate
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
        self.textField.borderStyle = .roundedRect

        self.contentView.addSubview(self.textField)

        NSLayoutConstraint.activate([
            self.textField.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 8),
            self.textField.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -8),
            self.textField.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
        ])

        self.textField.addTarget(self, action: #selector(self.didUpdateTextFieldText), for: .editingChanged)
        self.textField.addTarget(self, action: #selector(self.didEndEditingTextFieldText), for: .editingDidEnd)
    }

    @objc private func didUpdateTextFieldText() {
        guard let type = self.dataType
        else { return }

        self.delegate?.didUpdate(value: self.textField.text?.trimmingCharacters(in: .whitespaces), for: type)
    }

    @objc private func didEndEditingTextFieldText() {
        self.textField.text = self.textField.text?.trimmingCharacters(in: .whitespaces)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.textField.text = nil
    }
}
