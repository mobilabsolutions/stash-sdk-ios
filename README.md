
# MobilabPayment iOS SDK 

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![Travis CI build status](https://travis-ci.com/mobilabsolutions/payment-sdk-ios-open.svg?token=YveRxJtU3TcdBx4pp777&branch=master)](https://travis-ci.com/mobilabsolutions/payment-sdk-ios-open)

Many applications need to process payments for digital or physical goods. Implementing payment functionality can be very cumbersome though: there are many payment service providers that support or don't support various types of payment methods and payment method registration and usage flows. The payment SDK simplifies the integration of payments into our applications and abstracts away a lot of the internal complexity that different payment service providers' solutions have. With the payment SDK it does not matter which payment service provider one chooses to register payment methods with - the API is standardized and works across the board. 

## Supported Payment Service Providers - PSP

- BSPayone [Credit Cards / SEPA]
- Braintree [PayPal]
- Adyen [Credit Cards / SEPA]

## Requirements

- iOS 11.3+
- Xcode 10.1+
- Swift 5.0+ / Objective-C

## Installation

We recommend using [Carthage](https://github.com/Carthage/Carthage) to integrate the MobilabPayment SDK with your project.

### Carthage

Add `github "mobilabsolutions/payment-sdk-ios-open" ~> 1.0` to your `Cartfile`, and [add the frameworks to your project](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application). Do not forget to also add the Carthage `copy-frameworks` build phase to the target.

### Manual Installation

The SDK can also be installed manually. To perform manual installation, drag the `MobilabPaymentCore` framework and the module frameworks you might want to use into the `Embdedded Binaries` section in Xcode. Depending on the modules that you want to use, you will also have to install their dependencies. The recommended option for this is using [Carthage](https://github.com/Carthage/Carthage) with the following `Cartfile` contents for installing the dependencies of the Braintree and Adyen modules:

```
github "braintree/braintree-ios-drop-in"
github "adyen/adyen-ios" ~> 2.8
```

To include these dependencies into your project, you will also have to include the Carthage copy script as a run phase for the build with the necessary installed dependencies as input files or members of an input file list. See [the sample application input file list](Sample/other/input.xcfilelist) for an example. Furthermore, all necessary dependencies should be added to the linked libraries tab in the target settings.

## Usage

### Configuring the SDK

To use the SDK, you need to initialize it with some configuration data. Among the data that needs to be provided are the public key as well as the backend endpoint that should be used by the SDK.

To connect the SDK to a given payment service provider (PSP), that PSP's module needs to be imported and initialized. Set the configuration's `integrations` to provide correct data.
```swift
import MobilabPaymentCore
import MobilabPaymentBSPayone
import MobilabPaymentBraintree

let bsPayonePSP = MobilabPaymentBSPayone()
let braintreePSP = MobilabPaymentBraintree(urlScheme: "[YOUR URL SCHEME]]")

let configuration = MobilabPaymentConfiguration(publicKey: "[YOUR MOBILAB BACKEND PUBLIC KEY]", 
                                                endpoint: "[YOUR MOBILAB BACKEND ENDPOINT]",
                                                integrations: [
                                                    PaymentProviderIntegration(paymentServiceProvider: bsPayonePSP),
                                                    PaymentProviderIntegration(paymentServiceProvider: braintreePSP)
                                                ])
MobilabPaymentSDK.initialize(configuration: configuration)
```

It is also possible to specify which PSP should be used to register which payment method type by using the `paymentMethodTypes` parameter of the `PaymentProviderIntegration` optional initializer. By default, when not specifying the specific payment method types, the PSP will be used for all types that the module supports. Note that a `fatalError` will be created when there are overlapping payment method types for different PSPs that are registered at the same time.

#### Using the SDK in test mode

The payment SDK can also be used in so-called test mode. Transactions created there are not forwarded to the production PSP but rather to whatever sandboxing mode the PSP provides.
To instruct the SDK to use test mode, manually set the `useTestMode` property on the `MobilabPaymentConfiguration` used to configure the SDK.

For example:

```swift
let configuration = MobilabPaymentConfiguration(publicKey: "[YOUR MOBILAB BACKEND PUBLIC KEY]", 
                                                endpoint: "[YOUR MOBILAB BACKEND ENDPOINT]",
                                                integrations: [PaymentProviderIntegration(paymentServiceProvider: bsPayonePSP)])
configuration.useTestMode = true

MobilabPaymentSDK.initialize(configuration: configuration)
```

## Registering payment method

To register a payment method you need an instance of the `RegistrationManager` class.

```swift
let registrationManager = MobilabPaymentSDK.getRegistrationManager()
```

As the SDK allows usage of multiple PSPs, when registering payment method you need to set a PSP you wanna utilize for that payment method.
Depending on the payment method that is used, some registration methods also require additional data to be supplied.

### Using the module UI for adding a payment method

Since the PSP modules know best which data needs to be provided in which situation, it is also possible to offload the UI work for adding a payment method to them.
By calling `registerPaymentMethodUsingUI` on the registration manager, the user is shown a selection of possible payment methods types and then fields for creating payment methods of the selected type.

_Attention_: To allow registration of PayPal payment methods, some setup work as documented in the [Registering a PayPal account](#registering-a-paypal-account) section of this page is necessary.

Typical usage of this functionality might look like this:

```swift

let registrationManager = MobilabPaymentSDK.getRegistrationManager()
registrationManager.registerPaymentMethodUsingUI(on: self) { [weak self] result in
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
let uiConfiguration = PaymentMethodUIConfiguration(backgroundColor: .white, textColor: .black, buttonColor: .black)
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

There is some more information on this in the [SDK UI Usage Tutorial](https://github.com/mobilabsolutions/payment-sdk-ios-open/wiki/SDK-UI-Usage-Tutorial) in our wiki.

### Registering a credit card

To register a credit card, the `registerCreditCard` method of the registration manager is used.
Provide it with an instance of `CreditCardData`, which upon initialization also validates the credit card data.

The `CreditCardData` is provided with `BillingData`. This `BillingData` contains information about the user that is necessary for registering a credit card. Its fields are all optional and their necessity PSP-dependant.
As with all registration methods, you also need to set PSP you wanna use to register credit card.

```swift
let name = SimpleNameProvider(firstName: "Max", lastName: "Mustermann")
let billingData = BillingData(name: name, country: "DE")
guard let creditCard = try? CreditCardData(cardNumber: "4111111111111111", cvv: "123",
                                        expiryMonth: 9, expiryYear: 21, country: "DE", billingData: billingData)
else { fatalError("Credit card data is not valid") }

let registrationManager = MobilabPaymentSDK.getRegistrationManager()
registrationManager.registerCreditCard(creditCardData: creditCard) { result in
    switch result {
    case let .success(registration): print("Received alias for credit card: \(registration.alias)")
    case let .failure(error): print("Error (\(error.description)) while registering credit card")
    }
}
```

### Registering a SEPA account

To register a SEPA account, we can use the `registerSEPAAccount` method of the registration manager. Here, as is the case for the credit card data, the billing data is optional and the values that need to be provided are PSP-dependant.

```swift
let name = SimpleNameProvider(firstName: "Max", lastName: "Mustermann")
let billingData = BillingData(email: "max@mustermann.de",
                                      name: name,
                                      address1: "Address1",
                                      address2: "Address2",
                                      zip: "817754",
                                      city: "Cologne",
                                      state: nil,
                                      country: "DE",
                                      phone: "1231231123",
                                      languageId: "deu")

guard let sepaData = try? SEPAData(iban: "DE75512108001245126199", bic: "COLSDE33XXX", billingData: billingData)
else { fatalError("SEPA data should be valid") }

let registrationManager = MobilabPaymentSDK.getRegistrationManager()
registrationManager.registerSEPAAccount(sepaData: sepaData) { result in
    switch result {
    case let .success(registration): print("Received alias for SEPA account: \(registration.alias)")
    case let .failure(error): print("Error (\(error.description)) while registering SEPA account")
    }
}
```

### Registering a PayPal account

Currently, only the Braintree PSP allows registering a PayPal account and it is only possible to register a PayPal payment method using the provided module UI.

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

## Idempotency

All calls provided by Payment SDK are idempotent. To use idempotency simply provide a unique string to any of the registration methods used.

```swift
let name = SimpleNameProvider(firstName: "Max", lastName: "Mustermann")
let billingData = BillingData(name: name, country: "DE")
guard let creditCard = try? CreditCardData(cardNumber: "4111111111111111", cvv: "123",
                                        expiryMonth: 9, expiryYear: 21, country: "DE", billingData: billingData)
else { fatalError("Credit card data is not valid") }

let registrationManager = MobilabPaymentSDK.getRegistrationManager()
registrationManager.registerCreditCard(creditCardData: creditCard, idempotencyKey: UUID().uuidString) { result in
    switch result {
    case let .success(registration): print("Received alias for credit card: \(registration.alias)")
    case let .failure(error): print("Error (\(error.description)) while registering credit card")
    }
}
```

## Demo

A demo app that demonstrate usage of all SDK features is part of this project. Run  `carthage bootstrap --platform iOS`, open `MobilabPayment.xcworkspace` in Xcode and then choose `Demo` scheme to launch it.

## Feedback

The MobilabPayment iOS SDK is in active development, we welcome your feedback!
Please use [GitHub Issues](https://github.com/mobilabsolutions/payment-sdk-ios-open/issues) to report and issues or give a feedback

### License

The MobilabPayment iOS SDK is open source and available under the TODO license. See the [LICENSE](https://github.com/mobilabsolutions/payment-sdk-ios-open/blob/master/LICENSE) file for more info.

## Documentation

To get familiar with the overall Payment SDK project please visit [Common payment wiki](https://github.com/mobilabsolutions/payment-sdk-wiki-open/wiki)
To learn more about the iOS Payment SDK architecture and flows please visit our wiki [iOS SDK Wiki](https://github.com/mobilabsolutions/payment-sdk-ios-open/wiki)

Reference documentation for each module is available in the `docs/` folder of this repository. To regenerate the reference documentation, run `./build_documentation.sh`.
