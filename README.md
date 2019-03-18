[![Build Status](https://travis-ci.com/mobilabsolutions/payment-sdk-ios-open.svg?token=YveRxJtU3TcdBx4pp777&branch=master)](https://travis-ci.com/mobilabsolutions/payment-sdk-ios-open)

# iOS Payment SDK

This repository contains code providing Payment SDK API to iOS platform

To get familiar with the overall Payment SDK project please visit [Common payment wiki](https://github.com/mobilabsolutions/payment-sdk-wiki-open/wiki)

To learn more about the iOS Payment SDK architecture and flows please visit [iOS SDK Wiki](https://github.com/mobilabsolutions/payment-sdk-ios-open/wiki)

## Including the SDK in your project

There are multiple methods of including the payment SDK into your project:

### Cocoapods

TBD

### Manually

TBD

## Initializing the SDK

To use the SDK, it needs to be initialized with some configuration data. Among the data that needs to be provided are the public key as well as the backend endpoint that should be used by the 
SDK.

To connect the SDK to a given payment service provider (PSP), that PSP's module needs to be imported and initialized. The SDK is then configured with the initialized value.

```swift
import MobilabPaymentCore
import MobilabPaymentBSPayone

let configuration = MobilabPaymentConfiguration(publicKey: "PD-BS2-ABCDEXXXXXXXXXXX", endpoint: "https://payment.example.net/api/v1")
MobilabPaymentSDK.configure(configuration: configuration)

let paymentServiceProvider = MobilabPaymentBSPayone(publicKey: "PD-BS2-nF7kU7xY8ESLgflavGW9CpUv1I")
MobilabPaymentSDK.addProvider(provider: paymentServiceProvider)
```

## Registering a credit card

After the SDK is initialized, it can be used to register payment methods. To register a credit card, the `registerCreditCard` method of the registration manager is used.
Provide it with an instance of `CreditCardData`, which upon initialization also validates the credit card data.

The `CreditCardData` is provided with `BillingData`. This `BillingData` contains information about the user that is necessary for registering a credit card. Its fields are all optional and their necessity PSP-dependant.

```swift
let billingData = BillingData(country: "DE")
guard let creditCard = try? CreditCardData(cardNumber: "4111111111111111", cvv: "123",
                                        expiryMonth: 9, expiryYear: 21, holderName: "Max Mustermann", billingData: billingData)
else { fatalError("Credit card data is not valid") }

MobilabPaymentSDK.getRegisterManager().registerCreditCard(creditCardData: creditCard) { result in
    switch result {
    case let .success(alias): print("Received alias for credit card: \(alias)")
    case let .failure(error): print("Error (\(error.code)) while registering credit card")
    }
}
```

## Registering a SEPA account

To register a SEPA account, we can use the `registerSEPAAccount` method of the registration manager. Here, as is the case for the credit card data, the billing data is optional and the values that need to be provided are PSP-dependant.

```swift
let billingData = BillingData(email: "max@mustermann.de",
                                      name: "Max Mustermann",
                                      address1: "Address1",
                                      address2: "Address2",
                                      zip: "817754",
                                      city: "Cologne",
                                      state: nil,
                                      country: "Germany",
                                      phone: "1231231123",
                                      languageId: "deu")

guard let sepaData = try? SEPAData(iban: "DE75512108001245126199", bic: "COLSDE33XXX", billingData: billingData)
else { XCTFail("SEPA data should be valid"); return }

let registerManager = MobilabPaymentSDK.getRegisterManager()
registerManager.registerSEPAAccount(sepaData: sepaData) { result in
    switch result {
    case let .success(alias): print("Received alias for SEPA account: \(alias)")
    case let .failure(error): print("Error (\(error.code)) while registering SEPA account")
    }
}
```

## Using the module UI for adding a payment method

Since the PSP modules know best which data needs to be provided in which situation, it is also possible to offload the UI work for adding a payment method to them.
By calling `registerPaymentMethodUsingUI` on the registration manager, the user is shown a selection of possible payment methods types and then fields for creating payment methods of the selected type.

Typical usage of this functionality might look like this:

```swift
MobilabPaymentSDK.getRegisterManager().registerPaymentMethodUsingUI(on: self) { [weak self] result in
    switch result {
    case let .success(value):
        self?.dismiss(animated: true) {
            self?.showAlert(title: "Success", body: "Successfully registered payment method")
        }
    case let .failure(error):
        self?.showAlert(title: "Failure", body: error.errorDescription ?? "An error occurred while adding payment method")
    }
}
```