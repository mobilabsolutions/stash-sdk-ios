//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import UIKit

internal class OpenInvoiceFormViewController: FormViewController {
    // MARK: - FormViewController

    override func pay() {
        super.pay()

        var separateDeliveryAddress: Bool?

        if self.hasSeparateDeliveryAddressDetails {
            separateDeliveryAddress = self.separateDeliveryAddressView.isSelected
        }

        self.completion?(Input(personalDetails: self.personalDetailsSection.filledPersonalDetails(),
                               deliveryAddress: self.deliveryAddressSection.filledAddress(),
                               billingAddress: self.billingAddressSection.filledAddress(),
                               separateDeliveryAddress: separateDeliveryAddress))
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()

        if self.isSSNLookupAvailable {
            formView.addFormElement(self.socialSecurityNumberSection)
        } else {
            self.configurePersonalDetailsSection()
            self.configureBillingAddressSection()
            self.configureSeparateAddressView()
            self.configureDeliveryAddressSection()
            self.configureConsentViewSection()
        }

        formView.payButton.isEnabled = true
        formView.payButton.addTarget(self, action: #selector(self.pay), for: .touchUpInside)

        formView.addFooterElement(self.moreInformationButton)
        self.updateValidity()
    }

    // MARK: - Internal

    struct Input {
        var personalDetails: OpenInvoicePersonalDetails?
        var deliveryAddress: OpenInvoiceAddress?
        var billingAddress: OpenInvoiceAddress?
        var separateDeliveryAddress: Bool?
    }

    var completion: Completion<Input>?

    var personalDetailsVisibility = PaymentDetail.Configuration.FieldVisibility.editable
    var billingAddressVisibility = PaymentDetail.Configuration.FieldVisibility.editable
    var deliveryAddressVisibility = PaymentDetail.Configuration.FieldVisibility.editable

    var personalDetails: OpenInvoicePersonalDetails?
    var deliveryAddress: OpenInvoiceAddress?
    var billingAddress: OpenInvoiceAddress?
    var paymentSession: PaymentSession?

    lazy var personalDetailsSection: PersonalDetailsSection = {
        var genderSelectItems: [PaymentDetail.SelectItem]?
        var requiresDateOfBirth = false

        if case let .fieldSet(details)? = paymentMethod?.details.personalDetails?.inputType {
            if case let .select(items)? = details.gender?.inputType {
                genderSelectItems = items
            }

            requiresDateOfBirth = details.dateOfBirth != nil
        }

        return PersonalDetailsSection(personalDetails: personalDetails,
                                      genderSelectItems: genderSelectItems,
                                      requiresDateOfBirth: requiresDateOfBirth,
                                      textFieldDelegate: self)
    }()

    lazy var billingAddressSection: AddressFormSection = {
        guard case let .address(details)? = paymentMethod?.details.billingAddress?.inputType,
            case let .select(items)? = details.country?.inputType else {
            return AddressFormSection(address: billingAddress, type: .billing, countrySelectItems: [], textFieldDelegate: self)
        }

        return AddressFormSection(address: billingAddress, type: .billing, countrySelectItems: items, textFieldDelegate: self)
    }()

    lazy var deliveryAddressSection: AddressFormSection = {
        guard case let .address(details)? = paymentMethod?.details.deliveryAddress?.inputType,
            case let .select(items)? = details.country?.inputType else {
            return AddressFormSection(address: billingAddress, type: .delivery, countrySelectItems: [], textFieldDelegate: self)
        }

        return AddressFormSection(address: billingAddress, type: .delivery, countrySelectItems: items, textFieldDelegate: self)
    }()

    lazy var socialSecurityNumberSection = SocialSecurityNumberSection { [weak self] ssn in
        self?.lookupSSN(ssn: ssn)
    }

    lazy var consentSection = ConsentFormSection(paymentMethodType: paymentMethod?.type ?? "") { [weak self] in
        self?.updateValidity()
    }

    var paymentMethod: PaymentMethod? {
        didSet {
            guard let paymentMethod = paymentMethod else {
                return
            }

            // If we have ssn lookup url
            if paymentMethod.configuration?["shopperInfoSSNLookupUrl"] != nil {
                self.isSSNLookupAvailable = true
                self.personalDetailsVisibility = .hidden
                self.billingAddressVisibility = .hidden
                self.deliveryAddressVisibility = .hidden
            } else {
                let details = paymentMethod.details
                personalDetailsVisibility = details.personalDetails?.configuration.fieldVisibility ?? .editable
                billingAddressVisibility = details.billingAddress?.configuration.fieldVisibility ?? .editable
                deliveryAddressVisibility = details.deliveryAddress?.configuration.fieldVisibility ?? .editable
            }
        }
    }

    // MARK: - Private

    private var isSSNLookupAvailable = false

    private var hasConsentField: Bool {
        return self.paymentMethod?.details.consent != nil
    }

    private var hasSeparateDeliveryAddressDetails: Bool {
        return self.paymentMethod?.details.separateDeliveryAddress != nil
    }

    private var shouldShowSSNField: Bool {
        if case let .fieldSet(details)? = paymentMethod?.details.personalDetails?.inputType {
            let isCountryWithSSN = ["FI", "NO", "DK", "SE"].contains(paymentSession?.payment.countryCode)
            return details.socialSecurityNumber != nil && isSSNLookupAvailable == false && isCountryWithSSN
        }

        return false
    }

    private lazy var separateDeliveryAddressView: FormConsentView = {
        let view = FormConsentView()
        view.title = ADYLocalizedString("openInvoice.separateDeliveryAddressField.title")
        view.isSelected = false
        view.accessibilityIdentifier = "separate-delivery-address-button"
        view.onValueChanged = { [weak self] isOn in
            self?.configureSeparateDeliveryAddress(isHidden: !isOn)
            self?.updateValidity()
        }
        configureSeparateDeliveryAddress(isHidden: !view.isSelected)
        return view
    }()

    private lazy var moreInformationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(ADYLocalizedString("openInvoice.moreInformationButton.title"), for: .normal)
        button.addTarget(self, action: #selector(didTouchMoreInformationButton), for: .touchUpInside)
        return button
    }()

    @objc private func didTouchMoreInformationButton() {
        let countryCode = paymentSession?.payment.countryCode == "DE" ? "de" : "en"
        if let url = URL(string: "https://cdn.klarna.com/1.0/shared/content/legal/terms/2/\(countryCode)_de/invoice?fee=0") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    private func configureSeparateDeliveryAddress(isHidden: Bool) {
        self.deliveryAddressSection.isHidden = isHidden
    }

    private func configureBillingAddressSection() {
        formView.addFormElement(self.billingAddressSection)
        self.billingAddressSection.setup(visibility: self.billingAddressVisibility)
    }

    private func configureSeparateAddressView() {
        if self.hasSeparateDeliveryAddressDetails {
            formView.addFormElement(self.separateDeliveryAddressView)
        }
    }

    private func configureDeliveryAddressSection() {
        formView.addFormElement(self.deliveryAddressSection)
        self.deliveryAddressSection.setup(visibility: self.deliveryAddressVisibility)
    }

    private func configureConsentViewSection() {
        if self.hasConsentField {
            formView.addFormElement(self.consentSection)
        }
    }

    private func configurePersonalDetailsSection() {
        switch self.personalDetailsVisibility {
        case .editable:
            formView.addFormElement(self.personalDetailsSection)
            self.personalDetailsSection.setupNormalFlow(shouldShowSSNField: self.shouldShowSSNField)
        default: break
        }
    }

    private func updateValidity() {
        isValid = self.personalDetailsSection.isValid() && self.billingAddressSection.isValid() && self.deliveryAddressSection.isValid()

        if self.isSSNLookupAvailable {
            isValid = isValid && self.socialSecurityNumberSection.isValid()
        }

        if self.hasConsentField {
            isValid = isValid && self.consentSection.isValid()
        }
    }

    private func lookupSSN(ssn: String) {
        guard let paymentMethod = paymentMethod, let paymentSession = paymentSession else { return }

        let request = KlarnaSSNLookupRequest(shopperSSN: ssn, paymentSession: paymentSession, paymentMethod: paymentMethod)

        socialSecurityNumberSection.activityIndicator.startAnimating()

        APIClient().perform(request) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case let .failure(error):
                    print(error.localizedDescription)
                case let .success(response):
                    self?.setupSSNExtraInformationFlow(with: ssn, response: response)
                }

                self?.socialSecurityNumberSection.activityIndicator.stopAnimating()
            }
        }
    }

    private func setupSSNExtraInformationFlow(with ssn: String, response: KlarnaSSNLookupResponse) {
        self.billingAddressSection.address = response.address

        self.personalDetailsSection.personalDetails?.firstName = response.name?.firstName
        self.personalDetailsSection.personalDetails?.lastName = response.name?.lastName
        self.personalDetailsSection.personalDetails?.socialSecurityNumber = ssn

        self.personalDetailsSection.setupSSNFlow()

        formView.addFormElement(self.personalDetailsSection)

        if self.hasSeparateDeliveryAddressDetails {
            self.deliveryAddressSection.setup(visibility: .editable)
            formView.addFormElement(self.separateDeliveryAddressView)
            formView.addFormElement(self.deliveryAddressSection)
        }

        self.updateValidity()
    }
}

extension OpenInvoiceFormViewController: FormTextFieldDelegate {
    func valueChanged(_: FormTextField) {
        self.updateValidity()
    }
}
