
# MobilabPayment iOS SDK 

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![Travis CI build status](https://travis-ci.com/mobilabsolutions/payment-sdk-ios-open.svg?token=YveRxJtU3TcdBx4pp777&branch=master)](https://travis-ci.com/mobilabsolutions/payment-sdk-ios-open)

Hello and welcome to MobilabPayment iOS SDK

## Supported Payment Service Providers - PSP

- BSPayone [Credit Cards / SEPA]
- Braintree [PayPal]
- Adyen [Credit Cards / SEPA]

## Requirements

- iOS 11.3+
- Xcode 10.1+
- Swift 4.2+

## Installation

We recommend using [Carthage](https://github.com/Carthage/Carthage) to integrate the MobilabPayment SDK with your project.

#### Carthage
Add `github "mobilab/mobilabpayment_ios"` to your `Cartfile`, and [add the frameworks to your project](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application).

## Usage

### Configuring the SDK

To use the SDK, you need to initialize it with some configuration data. Among the data that needs to be provided are the public key as well as the backend endpoint that should be used by the SDK.

To connect the SDK to a given payment service provider (PSP), that PSP's module needs to be imported and initialized. Use the `registerProvider` method to register PSP with the SDK.
```swift
import MobilabPaymentCore
import MobilabPaymentBSPayone

let configuration = MobilabPaymentConfiguration(publicKey: "PD-BS2-ABCDEXXXXXXXXXXX", endpoint: "https://payment.example.net/api/v1")
MobilabPaymentSDK.configure(configuration: configuration)

let bsPayonePSP = MobilabPaymentBSPayone()
MobilabPaymentSDK.registerProvider(provider: bsPayonePSP, forPaymentMethodTypes: .creditCard, .sepa)

let braintreePSP = MobilabPaymentBraintree(urlScheme: "com.mobilabsolutions.payment.Demo.paypal")
MobilabPaymentSDK.registerProvider(provider: braintreePSP, forPaymentMethodTypes: .payPal)
```

#### Using the SDK in test mode

The payment SDK can also be used in so-called test mode. Transactions created there are not forwarded to the production PSP but rather to whatever sandboxing mode the PSP provides.
To configure the SDK to use test mode, simply prepend the `test.` subdomain to your endpoint URL (if the corresponding Load Balancer has been set up). Another method to instruct the SDK to use test mode while keeping the same URL is manually setting the `useTestMode` property on the `MobilabPaymentConfiguration` used to configure the SDK.

For example:

| Test Mode | Production Mode |
| --------- | --------------- |
| https://test.payment.example.net/api/v1 | https://payment.example.net/api/v1 |

Or in code:

```swift
let configuration = MobilabPaymentConfiguration(publicKey: "PD-BS2-ABCDEXXXXXXXXXXX", endpoint: "https://payment.example.net/api/v1")
configuration.useTestMode = true

MobilabPaymentSDK.configure(configuration: configuration)
```

## Registering payment method

To register a payment method you need an instance of the `RegistrationManager` class.

```swift
let registrationManager = MobilabPaymentSDK.getRegistrationManager()
```

As the SDK allows usage of multiple PSPs, when registering payment method you need to set a PSP you wanna utilize for that payment method.
Depending on the payment method that is used, some registration methods also require additional data to be supplied.

### Registering a credit card

To register a credit card, the `registerCreditCard` method of the registration manager is used.
Provide it with an instance of `CreditCardData`, which upon initialization also validates the credit card data.

The `CreditCardData` is provided with `BillingData`. This `BillingData` contains information about the user that is necessary for registering a credit card. Its fields are all optional and their necessity PSP-dependant.
As with all registration methods, you also need to set PSP you wanna use to register credit card.

```swift
let billingData = BillingData(country: "DE")
guard let creditCard = try? CreditCardData(cardNumber: "4111111111111111", cvv: "123",
                                        expiryMonth: 9, expiryYear: 21, holderName: "Max Mustermann", billingData: billingData)
else { fatalError("Credit card data is not valid") }

let registrationManager = MobilabPaymentSDK.getRegistrationManager()
registrationManager.registerCreditCard(mobilabProvider: MobilabPaymentProvider.bsPayone, creditCardData: creditCard) { result in
    switch result {
    case let .success(registration): print("Received alias for credit card: \(registration.alias)")
    case let .failure(error): print("Error (\(error.code)) while registering credit card")
    }
}
```

### Registering a SEPA account

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

let registrationManager = MobilabPaymentSDK.getRegistrationManager()
registrationManager.registerSEPAAccount(mobilabProvider: MobilabPaymentProvider.bsPayone, sepaData: sepaData) { result in
    switch result {
    case let .success(registration): print("Received alias for SEPA account: \(registration.alias)")
    case let .failure(error): print("Error (\(error.description)) while registering SEPA account")
    }
}
```

### Registering a PayPal account

Currently, only the Braintree PSP allows registering a PayPal account.

#### Setup for app switch

PayPal account registration flow involves switching to another app or  `SFSafariViewController`  for authentication, so you must register a URL type and configure your app to return from app switches.

#### Register a URL type
1.  In Xcode, click on your project in the Project Navigator and navigate to  **App Target**  >  **Info**>  **URL Types**
2.  Click  **[+]**  to add a new URL type
3.  Under  **URL Schemes**, enter your app switch return URL scheme. This scheme  **_must start with your app's Bundle ID and be dedicated to MobilabPayment app switch returns_**. For example, if the app bundle ID is  `com.your-company.Your-App`, then your URL scheme could be  `com.your-company.Your-App.mobilab`.

#### Update your application delegate

In your AppDelegate's  `application:didFinishLaunchingWithOptions:`  implementation, use  `setReturnURLScheme:`  with the URL type value you set above.
```swift
func application(_: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
  return MobilabPaymentBraintree.handleOpen(url: url, options: options)
}
```
Now you are ready to register a PayPal account. 

```swift
let registrationManager = MobilabPaymentSDK.getRegistrationManager()
registrationManager.registerPaymentMethodUsingUI(on viewController: self, specificPaymentMethod: .payPal) { [weak self] result in
    switch result {
    case let .success(registration):
        self?.dismiss(animated: true) {
            self?.showAlert(title: "Success", body: "Successfully registered payment method")
        }
    case let .failure(error):
        self?.showAlert(title: "Failure", body: error.description)
    }
}
```

### Using the module UI for adding a payment method

Since the PSP modules know best which data needs to be provided in which situation, it is also possible to offload the UI work for adding a payment method to them.
By calling `registerPaymentMethodUsingUI` on the registration manager, the user is shown a selection of possible payment methods types and then fields for creating payment methods of the selected type.

Typical usage of this functionality might look like this:

```swift

let registrationManager = MobilabPaymentSDK.getRegistrationManager()
registrationManager.registerPaymentMethodUsingUI(on viewController: self) { [weak self] result in
    switch result {
    case let .success(registration):
        self?.dismiss(animated: true) {
            self?.showAlert(title: "Success", body: "Successfully registered payment method")
        }
    case let .failure(error):
        self?.showAlert(title: "Failure", body: error.description)
    }
}
```

It is also possible to style the presented UI in a way that is compatible with the style guide of the rest of the containing application. Simply pass along an updated `PaymentMethodUIConfiguration`:

```swift
let registrationManager = MobilabPaymentSDK.getRegistrationManager()
let uiConfiguration = PaymentMethodUIConfiguration(backgroundColor: .white, fontColor: .black, buttonColor: .black)
MobilabPaymentSDK.configureUI(configuration: uiConfiguration)

registrationManager.registerPaymentMethodUsingUI(on viewController: self) { [weak self] result in
    switch result {
    case let .success(registration):
        self?.dismiss(animated: true) {
            self?.showAlert(title: "Success", body: "Successfully registered payment method")
        }
    case let .failure(error):
        self?.showAlert(title: "Failure", body: error.description)
    }
}
```

## Demo

A demo app that demonstrate usage of all SDK features is part of this project. Run  `carthage update --platform iOS`, open `MobilabPayment.xcworkspace` in Xcode and then choose `Demo` scheme to launch it.

## Feedback

The MobilabPayment iOS SDK is in active development, we welcome your feedback!
Please use [GitHub Issues](https://github.com/mobilabsolutions/payment-sdk-ios-open/issues) to report and issues or give a feedback

### License

The MobilabPayment iOS SDK is open source and available under the TODO license. See the [LICENSE](https://github.com/mobilabsolutions/payment-sdk-ios-open/blob/master/LICENSE) file for more info.

## Documentation

To get familiar with the overall Payment SDK project please visit [Common payment wiki](https://github.com/mobilabsolutions/payment-sdk-wiki-open/wiki)
To learn more about the iOS Payment SDK architecture and flows please visit our wiki [iOS SDK Wiki](https://github.com/mobilabsolutions/payment-sdk-ios-open/wiki)

Reference documentation for each module is available in the `docs/` folder of this repository. To regenerate the reference documentation, run `./build_documentation.sh`.
