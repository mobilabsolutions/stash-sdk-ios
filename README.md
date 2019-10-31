
# Stash! iOS SDK 

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![Travis CI build status](https://travis-ci.com/mobilabsolutions/payment-sdk-ios-open.svg?token=YveRxJtU3TcdBx4pp777&branch=master)](https://travis-ci.com/mobilabsolutions/payment-sdk-ios-open)

Many applications need to process payments for digital or physical goods. Implementing payment functionality can be very cumbersome though: there are many payment service providers that support or don't support various types of payment methods and payment method registration and usage flows. The payment SDK simplifies the integration of payments into our applications and abstracts away a lot of the internal complexity that different payment service providers' solutions have. With the payment SDK it does not matter which payment service provider one chooses to register payment methods with - the API is standardized and works across the board. 

## Supported PSPs

At the moment, the Stash! iOS SDK supports the following PSPs:
- BSPayone [Credit Cards / SEPA]
- Braintree [Credit Cards / PayPal]
- Adyen [Credit Cards / SEPA]

## Requirements

To build this project, you will need to have at least the following:
- iOS 11.3+
- Xcode 10.1+
- Swift 5.0+ / Objective-C
_ Carthage

## Installation

We recommend using [Carthage](https://github.com/Carthage/Carthage) or [CocoaPods](https://cocoapods.org/) to integrate the Stash! SDK with your project.

### Carthage

Add `github "mobilabsolutions/payment-sdk-ios-open" ~> 1.0` to your `Cartfile`, and follow [Carthage building instructions](https://github.com/Carthage/Carthage#getting-started) to complete installation. The input file list for the Carthage `copy-frameworks` build phase should contain dependencies found in our [ sample application input file list](Sample/other/input.xcfilelist) so feel free to use it as an example.

### CocoaPods

Add `pod 'Stash'` to your Podfile and run `pod install`. Instead of having to import each module individually, it suffices to `import Stash` when using Cocoapods.

### Manual Installation

The SDK can also be installed manually. To perform manual installation, drag the `StashCore` framework and the module frameworks you might want to use into the `Embdedded Binaries` section in Xcode. Depending on the modules that you want to use, you will also have to install their dependencies. The recommended option for this is using [Carthage](https://github.com/Carthage/Carthage) with the following `Cartfile` contents for installing the dependencies of the Braintree and Adyen modules:

```
github "braintree/braintree-ios-drop-in" ~> 7.2.0
github "adyen/adyen-ios" ~> 2.8
```
Instructions for installing dependencies with Carthage can be found [above](#carthage)

## Usage

### Configuring the SDK

To use the SDK, you need to initialize it with some configuration data. Among the data that needs to be provided are the merchant publishable key as well as the backend endpoint that should be used by the SDK.

To connect the SDK to a given PSP, that PSP's module needs to be imported and initialized. You need to set the configuration's `integrations` to provide correct data.

```swift
import StashCore
import StashBSPayone
import StashBraintree

let bsPayonePSP = StashBSPayone()
let braintreePSP = StashBraintree(urlScheme: "[YOUR URL SCHEME]]")

let configuration = StashConfiguration(publishableKey: "[YOUR STASH BACKEND PUBLISHABLE KEY]", 
                                                endpoint: "[YOUR STASH BACKEND ENDPOINT]",
                                                integrations: [
                                                    PaymentProviderIntegration(paymentServiceProvider: bsPayonePSP),
                                                    PaymentProviderIntegration(paymentServiceProvider: braintreePSP)
                                                ])
Stash.initialize(configuration: configuration)
```

It is also possible to specify which PSP should be used to register which payment method type by using the `paymentMethodTypes` parameter of the `PaymentProviderIntegration` optional initializer. By default, when the specific payment method types are not specified, the PSP will be used for all types that the module supports. Note that a `fatalError` will be created when there are overlapping payment method types for different PSPs that are registered at the same time.

#### Using the SDK in Test Mode

The Stash! SDK can also be used in so-called test mode. The transactions created there are not forwarded to the production PSP, but rather to whatever sandboxing mode the PSP provides.
To instruct the SDK to use the test mode, set manually the `useTestMode` property on the `StashConfiguration` used to configure the SDK.

For example:

```swift
let configuration = StashConfiguration(publishableKey: "[YOUR STASH BACKEND PUBLISHABLE KEY]", 
                                                endpoint: "[YOUR STASH BACKEND ENDPOINT]",
                                                integrations: [PaymentProviderIntegration(paymentServiceProvider: bsPayonePSP)])
configuration.useTestMode = true

Stash.initialize(configuration: configuration)
```

## Registering a Payment Method

To register a payment method you need an instance of the `RegistrationManager` class.

```swift
let registrationManager = Stash.getRegistrationManager()
```

As the Stash! SDK allows the usage of multiple PSPs, when registering a payment method you need to set the PSP you want to use for that particular payment method.
Depending on the payment method that is being used, some registration methods could require additional data.

### Using the Module UI for Adding a Payment Method

Since the PSP modules know which data needs to be provided in each situation, it is also possible to offload the UI work to add a payment method to them. By calling the `registerPaymentMethodUsingUI` on the registration manager, the user is shown a selection of possible payment method types and then the fields used for creating the payment method type that was selected.

_Note_: To allow the registration of a PayPal account, some setup work, as documented in the [Registering a PayPal account](#registering-a-paypal-account) section of this page, is necessary.

The typical usage of this functionality might look like this:

```swift

let registrationManager = Stash.getRegistrationManager()
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

It is also possible to style the presented UI in a way that is compatible with the style guide of the rest of the containing application. You only need to pass along an updated `PaymentMethodUIConfiguration`:

```swift
let registrationManager = Stash.getRegistrationManager()
let uiConfiguration = PaymentMethodUIConfiguration(backgroundColor: .white, textColor: .black, buttonColor: .black)
Stash.configureUI(configuration: uiConfiguration)

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

You can find more information about this in the [SDK UI Usage Tutorial](https://github.com/mobilabsolutions/payment-sdk-ios-open/wiki/SDK-UI-Usage-Tutorial) in our Wiki.

### Credit Card Registration

To register a credit card, the `registerCreditCard` method of the registration manager is used. You should provide it with an instance of the `CreditCardData`, which upon initialization also validates the credit card data.

The `CreditCardData` is provided with the `BillingData`. This `BillingData` contains information about the user that is necessary to register a credit card. Its fields are all optional and their necessity is PSP-dependant. As with all the registration methods, you also need to set the PSP you want to use to register the credit card.

```swift
let name = SimpleNameProvider(firstName: "Max", lastName: "Mustermann")
let billingData = BillingData(name: name, country: "DE")
guard let creditCard = try? CreditCardData(cardNumber: "4111111111111111", cvv: "123",
                                        expiryMonth: 9, expiryYear: 21, country: "DE", billingData: billingData)
else { fatalError("Credit card data is not valid") }

let registrationManager = Stash.getRegistrationManager()
registrationManager.registerCreditCard(creditCardData: creditCard) { result in
    switch result {
    case let .success(registration): print("Received alias for credit card: \(registration.alias)")
    case let .failure(error): print("Error (\(error.description)) while registering credit card")
    }
}
```

### SEPA Registration

To register a SEPA account, we can use the `registerSEPAAccount` method of the registration manager. Here, as is the case of the credit card data, the billing data is optional and the values that need to be provided are PSP-dependant.

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

let registrationManager = Stash.getRegistrationManager()
registrationManager.registerSEPAAccount(sepaData: sepaData) { result in
    switch result {
    case let .success(registration): print("Received alias for SEPA account: \(registration.alias)")
    case let .failure(error): print("Error (\(error.description)) while registering SEPA account")
    }
}
```

### PayPal Account Registration

Currently, only the Braintree PSP allows registering a PayPal account and it is  possible to register a PayPal account only by using the provided module UI.

#### Setup for App Switch

The PayPal account registration flow involves switching to another app or  `SFSafariViewController`  for authentication, so you must register a URL type and configure your app to return from the app switches.

#### Register a URL Type

1. In the Xcode, click on your project in the Project Navigator and navigate to  **App Target**  >  **Info**>  **URL Types**.
2. Click on **[+]**  to add a new URL type.
3. Under the **URL Schemes**, enter your app switch return URL scheme. This scheme  **_must start with your app's Bundle ID and be dedicated to Stash app switch returns_**. For example, if the app bundle ID is  `com.your-company.Your-App`, then your URL scheme could be  `com.your-company.Your-App.stash`.

#### Update your application delegate

In your AppDelegate's  `application:didFinishLaunchingWithOptions:`  implementation, use  `setReturnURLScheme:`  with the URL type value you set above.

```swift
func application(_: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
  return StashBraintree.handleOpen(url: url, options: options)
}
```

Now you are ready to register a PayPal account.

```swift
let registrationManager = Stash.getRegistrationManager()
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

All calls provided by Payment SDK are idempotent **only if the underlying PSP is also idempotent** (Braintree is not, BS Payone and Adyen are not for credit card registration). To use idempotency simply provide a unique string to any of the manual non-UI registration methods used.

```swift
let name = SimpleNameProvider(firstName: "Max", lastName: "Mustermann")
let billingData = BillingData(name: name, country: "DE")
guard let creditCard = try? CreditCardData(cardNumber: "4111111111111111", cvv: "123",
                                        expiryMonth: 9, expiryYear: 21, country: "DE", billingData: billingData)
else { fatalError("Credit card data is not valid") }

let registrationManager = Stash.getRegistrationManager()
registrationManager.registerCreditCard(creditCardData: creditCard, idempotencyKey: UUID().uuidString) { result in
    switch result {
    case let .success(registration): print("Received alias for credit card: \(registration.alias)")
    case let .failure(error): print("Error (\(error.description)) while registering credit card")
    }
}
```

## Demo

A demo app that demonstrates the usage of all the Stash! SDK features is part of this project. Run  `carthage bootstrap --platform iOS`, open `Stash.xcworkspace` in Xcode and then choose the `StashDemo` scheme to launch it.

## Feedback

The Stash! iOS SDK is in active development, we welcome your feedback!
Please use [GitHub Issues](https://github.com/mobilabsolutions/payment-sdk-ios-open/issues) to report an issue or give a feedback.

## Documentation

To get familiar with the overall Stash! SDK project please visit [Common payment wiki](https://github.com/mobilabsolutions/payment-sdk-wiki-open/wiki).
To learn more about the Stash! iOS SDK architecture and flows please visit our [Wiki](https://github.com/mobilabsolutions/payment-sdk-ios-open/wiki)

The reference documentation for each module is available in the `docs/` folder of this repository. To regenerate the reference documentation, run `./build_documentation.sh`.
