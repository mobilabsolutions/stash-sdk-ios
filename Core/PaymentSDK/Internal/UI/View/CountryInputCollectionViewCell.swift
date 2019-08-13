//
//  CountryInputCollectionViewCell.swift
//  MobilabPaymentCore
//
//  Created by Robert on 02.08.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import UIKit

class CountryInputCollectionViewCell: UICollectionViewCell, FormFieldErrorDelegate, NextCellEnabled {
    var isLastCell: Bool = false

    weak var nextCellSwitcher: NextCellSwitcher?

    private var text: String? {
        didSet {
            self.button.setText(text: self.text, placeholder: self.placeholder)
        }
    }

    private var title: String? {
        didSet {
            self.subtitleLabel.text = self.title
        }
    }

    private var placeholder: String? {
        didSet {
            self.button.setText(text: self.text, placeholder: self.placeholder)
        }
    }

    private var errorText: String? {
        didSet {
            self.button.set(hasInvalidData: self.errorText != nil)
            self.errorLabel.text = self.errorText
            self.errorLabelZeroHeightConstraint?.isActive = self.errorText == nil
        }
    }

    private let defaultHorizontalToSuperviewOffset: CGFloat = 16
    private let fieldHeight: CGFloat = 40
    private let fieldToHeaderVerticalOffset: CGFloat = 8
    private let headerToSuperViewVerticalOffset: CGFloat = 16
    private let errorLabelVerticalOffset: CGFloat = 4

    private weak var delegate: (DataPointProvidingDelegate & CountryInputPresentingDelegate)?

    private let button = CustomButton()
    private let subtitleLabel = SubtitleLabel()
    private let errorLabel = ErrorLabel()

    private var errorLabelZeroHeightConstraint: NSLayoutConstraint?

    public func setup(country: Country?,
                      error: String?,
                      configuration: PaymentMethodUIConfiguration,
                      delegate: DataPointProvidingDelegate & CountryInputPresentingDelegate) {
        self.text = country?.name
        self.title = "Country"
        self.placeholder = "Country"
        self.delegate = delegate
        self.errorText = error

        self.button.setup(borderColor: configuration.mediumEmphasisColor,
                          placeholderColor: configuration.mediumEmphasisColor,
                          textColor: configuration.textColor,
                          backgroundColor: configuration.cellBackgroundColor,
                          errorBorderColor: configuration.errorMessageColor,
                          shouldShowArrow: true)

        self.button.addTarget(self, action: #selector(self.didTapCountryButton), for: .touchUpInside)

        self.contentView.backgroundColor = configuration.cellBackgroundColor
        self.subtitleLabel.textColor = configuration.textColor

        self.errorLabel.uiConfiguration = configuration
    }

    func setError(description: String?, forDataPoint _: NecessaryData) {
        self.errorText = description
    }

    func selectCell() {
        guard self.text == nil
        else { return }

        self.delegate?.presentCountryInput(countryDelegate: self)
    }

    @objc private func didTapCountryButton() {
        self.delegate?.presentCountryInput(countryDelegate: self)
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
        self.button.translatesAutoresizingMaskIntoConstraints = false
        self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.errorLabel.translatesAutoresizingMaskIntoConstraints = false

        self.contentView.addSubview(self.button)
        self.contentView.addSubview(self.subtitleLabel)
        self.contentView.addSubview(self.errorLabel)

        NSLayoutConstraint.activate([
            self.button.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: defaultHorizontalToSuperviewOffset),
            self.button.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -defaultHorizontalToSuperviewOffset),
            self.button.heightAnchor.constraint(equalToConstant: fieldHeight),
            self.subtitleLabel.leadingAnchor.constraint(equalTo: self.button.leadingAnchor),
            self.subtitleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: headerToSuperViewVerticalOffset),
            self.subtitleLabel.trailingAnchor.constraint(equalTo: self.button.trailingAnchor),
            self.subtitleLabel.bottomAnchor.constraint(equalTo: self.button.topAnchor, constant: -fieldToHeaderVerticalOffset),
            self.errorLabel.leadingAnchor.constraint(equalTo: self.button.leadingAnchor),
            self.errorLabel.trailingAnchor.constraint(equalTo: self.button.trailingAnchor),
            self.errorLabel.topAnchor.constraint(equalTo: self.button.bottomAnchor, constant: errorLabelVerticalOffset),
        ])

        self.errorLabelZeroHeightConstraint = self.errorLabel.heightAnchor.constraint(equalToConstant: 0)
        self.errorLabelZeroHeightConstraint?.isActive = true

        self.backgroundColor = .white
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        self.delegate = nil
        self.errorText = nil
        self.placeholder = nil
        self.text = nil
    }
}

extension CountryInputCollectionViewCell: CountryListCollectionViewControllerDelegate {
    func didSelectCountry(country: Country) {
        self.text = country.name
        self.delegate?.didUpdate(value: CountryValueHolding(country: country), for: .country)
        self.nextCellSwitcher?.switchToNextCell(from: self)
    }
}
