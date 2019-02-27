[![Build Status](https://travis-ci.com/mobilabsolutions/payment-sdk-ios-open.svg?token=YveRxJtU3TcdBx4pp777&branch=master)](https://travis-ci.com/mobilabsolutions/payment-sdk-ios-open)
# iOS Payment SDK

This repository contains code providing Payment SDK API to iOS platform

To get familiar with the overall Payment SDK project please visit [Common payment wiki](https://github.com/mobilabsolutions/payment-sdk-wiki-open/wiki)

To learn more about the iOS Payment SDK architecture and flows please visit [iOS SDK Wiki](https://github.com/mobilabsolutions/payment-sdk-ios-open/wiki)

To set up the build on your machine you need to add certain variables to your `local.properties` file. Since these
contain private keys and other confidential data, please ask the project PO for access to them.

This repository contains multiple modules:
* `lib` - Core library module exposing SDK APIs, facilitating high level flows, and handling communication with Payment Backend
* `app` - Sample application using the payment SDK
* `*-integration` - Various PSP integration modules (Implementation in progress)

A normal use case for a third party developer would be to include `lib` and a specific integration module, i.e. `stripe-integration`

The follwoing integration and usage steps are pre-modularization and as such expect only `lib` module to be included in the project. This
read me will be updated to reflect changes once the integration modules are implemented completely.

#### Including the SDK in your project
TBD Repository serving the artefacts

`implementation com.mobilabsolutions.payment:lib:0.9.5`

#### Initializing the SDK

... Coming soon
