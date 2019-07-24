//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import Foundation

class PersonalDetailsSection: OpenInvoiceFormSection {
    // MARK: - Internal

    var personalDetails: OpenInvoicePersonalDetails?

    init(personalDetails: OpenInvoicePersonalDetails?, genderSelectItems: [PaymentDetail.SelectItem]?, requiresDateOfBirth: Bool, textFieldDelegate: FormTextFieldDelegate) {
        self.personalDetails = personalDetails
        self.textFieldDelegate = textFieldDelegate
        self.genderSelectItems = genderSelectItems
        self.requiresDateOfBirth = requiresDateOfBirth
        super.init()

        let values = genderSelectItems?.map { $0.name }
        self.localizedGenderValues = values?.map { ADYLocalizedString("openInvoice.gender.\($0.lowercased())", $0) }

        title = ADYLocalizedString("openInvoice.personalDetailsSection.title")
    }

    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupSSNFlow() {
        self.isSSNFlow = true
        addFormElement(self.staticPersonalDetails)
        addFormElement(self.telephoneField)
        addFormElement(self.emailField)

        self.staticPersonalDetails.text = self.personalDetails?.fullName()
        self.telephoneField.text = self.personalDetails?.telephoneNumber
        self.emailField.text = self.personalDetails?.shopperEmail
    }

    func setupNormalFlow(shouldShowSSNField: Bool) {
        addFormElement(self.firstNameField)
        addFormElement(self.lastNameField)

        if self.genderSelectItems != nil {
            addFormElement(self.genderField)
        }

        if self.requiresDateOfBirth {
            addFormElement(self.dateOfBirthField)
        }

        addFormElement(self.telephoneField)
        addFormElement(self.emailField)

        if shouldShowSSNField {
            addFormElement(self.socialSecurityNumberField)
        }

        self.telephoneField.text = self.personalDetails?.telephoneNumber
        self.emailField.text = self.personalDetails?.shopperEmail
    }

    func filledPersonalDetails() -> OpenInvoicePersonalDetails? {
        self.personalDetails?.telephoneNumber = self.telephoneField.text
        self.personalDetails?.shopperEmail = self.emailField.text

        if self.isSSNFlow == false {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd"

            self.personalDetails?.socialSecurityNumber = self.socialSecurityNumberField.text
            self.personalDetails?.firstName = self.firstNameField.text
            self.personalDetails?.lastName = self.lastNameField.text
            self.personalDetails?.dateOfBirth = dateFormatter.string(from: self.dateOfBirthField.date)

            if let selected = genderField.selectedValue, let index = localizedGenderValues?.firstIndex(of: selected) {
                self.personalDetails?.gender = self.genderSelectItems?[index].identifier
            }
        }

        return self.personalDetails
    }

    // MARK: - Private

    private weak var textFieldDelegate: FormTextFieldDelegate?

    private var genderSelectItems: [PaymentDetail.SelectItem]?
    private var isSSNFlow = false
    private var localizedGenderValues: [String]?
    private var requiresDateOfBirth: Bool

    private lazy var staticPersonalDetails = FormLabel()

    private lazy var socialSecurityNumberField: FormTextField = {
        let ssnField = FormTextField()
        ssnField.validator = OpenInvoiceNameValidator()
        ssnField.title = ADYLocalizedString("openInvoice.ssnSection.title")
        ssnField.placeholder = ADYLocalizedString("openInvoice.ssnSection.title")
        ssnField.accessibilityIdentifier = "social-security-number-field"
        ssnField.keyboardType = .numberPad
        ssnField.delegate = textFieldDelegate
        ssnField.clearButtonMode = .never
        return ssnField
    }()

    private lazy var firstNameField: FormTextField = {
        let nameField = FormTextField()
        nameField.delegate = textFieldDelegate
        nameField.validator = OpenInvoiceNameValidator()
        nameField.title = ADYLocalizedString("openInvoice.firstNameField.title")
        nameField.placeholder = ADYLocalizedString("openInvoice.firstNameField.placeholder")
        nameField.accessibilityIdentifier = "first-name-field"
        nameField.autocapitalizationType = .words
        nameField.nextResponderInChain = lastNameField

        return nameField
    }()

    private lazy var lastNameField: FormTextField = {
        let nameField = FormTextField()
        nameField.delegate = textFieldDelegate
        nameField.validator = OpenInvoiceNameValidator()
        nameField.title = ADYLocalizedString("openInvoice.lastNameField.title")
        nameField.placeholder = ADYLocalizedString("openInvoice.lastNameField.placeholder")
        nameField.accessibilityIdentifier = "last-name-field"
        nameField.autocapitalizationType = .words
        nameField.nextResponderInChain = genderField

        return nameField
    }()

    private lazy var genderField: FormSelectField = {
        let selectField = FormSelectField(values: localizedGenderValues ?? [])
        selectField.title = ADYLocalizedString("openInvoice.genderField")
        selectField.accessibilityIdentifier = "gender-field"

        return selectField
    }()

    private lazy var dateOfBirthField: FormDateField = {
        let dateField = FormDateField()
        dateField.title = ADYLocalizedString("openInvoice.dateOfBirthField")
        dateField.accessibilityIdentifier = "date-field"

        return dateField
    }()

    private lazy var telephoneField: FormTextField = {
        let phoneField = FormTextField()
        phoneField.delegate = textFieldDelegate
        phoneField.validator = OpenInvoiceTelephoneNumberValidator()
        phoneField.title = ADYLocalizedString("openInvoice.telephoneNumber.title")
        phoneField.placeholder = ADYLocalizedString("openInvoice.telephoneNumber.placeholder")
        phoneField.accessibilityIdentifier = "telephone-number-field"
        phoneField.keyboardType = .phonePad

        if isSSNFlow {
            phoneField.nextResponderInChain = emailField
        }

        return phoneField
    }()

    private lazy var emailField: FormTextField = {
        let emailField = FormTextField()
        emailField.delegate = textFieldDelegate
        emailField.validator = OpenInvoiceEmailValidator()
        emailField.title = ADYLocalizedString("openInvoice.email.title")
        emailField.placeholder = ADYLocalizedString("openInvoice.email.placeholder")
        emailField.accessibilityIdentifier = "email-field"
        emailField.keyboardType = .emailAddress

        return emailField
    }()
}
