import UIKit
import XCTest

class BTLocalPayment_UnitTests: XCTestCase {
    let tempClientToken = "eyJ2ZXJzaW9uIjoyLCJhdXRob3JpemF0aW9uRmluZ2VycHJpbnQiOiI3ODJhZmFlNDJlZTNiNTA4NWUxNmMzYjhkZTY3OGQxNTJhODFlYzk5MTBmZDNhY2YyYWU4MzA2OGI4NzE4YWZhfGNyZWF0ZWRfYXQ9MjAxNS0wOC0yMFQwMjoxMTo1Ni4yMTY1NDEwNjErMDAwMFx1MDAyNmN1c3RvbWVyX2lkPTM3OTU5QTE5LThCMjktNDVBNC1CNTA3LTRFQUNBM0VBOEM4Nlx1MDAyNm1lcmNoYW50X2lkPWRjcHNweTJicndkanIzcW5cdTAwMjZwdWJsaWNfa2V5PTl3d3J6cWszdnIzdDRuYzgiLCJjb25maWdVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvZGNwc3B5MmJyd2RqcjNxbi9jbGllbnRfYXBpL3YxL2NvbmZpZ3VyYXRpb24iLCJjaGFsbGVuZ2VzIjpbXSwiZW52aXJvbm1lbnQiOiJzYW5kYm94IiwiY2xpZW50QXBpVXJsIjoiaHR0cHM6Ly9hcGkuc2FuZGJveC5icmFpbnRyZWVnYXRld2F5LmNvbTo0NDMvbWVyY2hhbnRzL2RjcHNweTJicndkanIzcW4vY2xpZW50X2FwaSIsImFzc2V0c1VybCI6Imh0dHBzOi8vYXNzZXRzLmJyYWludHJlZWdhdGV3YXkuY29tIiwiYXV0aFVybCI6Imh0dHBzOi8vYXV0aC52ZW5tby5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIiwiYW5hbHl0aWNzIjp7InVybCI6Imh0dHBzOi8vY2xpZW50LWFuYWx5dGljcy5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIn0sInRocmVlRFNlY3VyZUVuYWJsZWQiOnRydWUsInRocmVlRFNlY3VyZSI6eyJsb29rdXBVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvZGNwc3B5MmJyd2RqcjNxbi90aHJlZV9kX3NlY3VyZS9sb29rdXAifSwicGF5cGFsRW5hYmxlZCI6dHJ1ZSwicGF5cGFsIjp7ImRpc3BsYXlOYW1lIjoiQWNtZSBXaWRnZXRzLCBMdGQuIChTYW5kYm94KSIsImNsaWVudElkIjpudWxsLCJwcml2YWN5VXJsIjoiaHR0cDovL2V4YW1wbGUuY29tL3BwIiwidXNlckFncmVlbWVudFVybCI6Imh0dHA6Ly9leGFtcGxlLmNvbS90b3MiLCJiYXNlVXJsIjoiaHR0cHM6Ly9hc3NldHMuYnJhaW50cmVlZ2F0ZXdheS5jb20iLCJhc3NldHNVcmwiOiJodHRwczovL2NoZWNrb3V0LnBheXBhbC5jb20iLCJkaXJlY3RCYXNlVXJsIjpudWxsLCJhbGxvd0h0dHAiOnRydWUsImVudmlyb25tZW50Tm9OZXR3b3JrIjp0cnVlLCJlbnZpcm9ubWVudCI6Im9mZmxpbmUiLCJ1bnZldHRlZE1lcmNoYW50IjpmYWxzZSwiYnJhaW50cmVlQ2xpZW50SWQiOiJtYXN0ZXJjbGllbnQzIiwiYmlsbGluZ0FncmVlbWVudHNFbmFibGVkIjpmYWxzZSwibWVyY2hhbnRBY2NvdW50SWQiOiJzdGNoMm5mZGZ3c3p5dHc1IiwiY3VycmVuY3lJc29Db2RlIjoiVVNEIn0sImNvaW5iYXNlRW5hYmxlZCI6dHJ1ZSwiY29pbmJhc2UiOnsiY2xpZW50SWQiOiIxMWQyNzIyOWJhNThiNTZkN2UzYzAxYTA1MjdmNGQ1YjQ0NmQ0ZjY4NDgxN2NiNjIzZDI1NWI1NzNhZGRjNTliIiwibWVyY2hhbnRBY2NvdW50IjoiY29pbmJhc2UtZGV2ZWxvcG1lbnQtbWVyY2hhbnRAZ2V0YnJhaW50cmVlLmNvbSIsInNjb3BlcyI6ImF1dGhvcml6YXRpb25zOmJyYWludHJlZSB1c2VyIiwicmVkaXJlY3RVcmwiOiJodHRwczovL2Fzc2V0cy5icmFpbnRyZWVnYXRld2F5LmNvbS9jb2luYmFzZS9vYXV0aC9yZWRpcmVjdC1sYW5kaW5nLmh0bWwiLCJlbnZpcm9ubWVudCI6Im1vY2sifSwibWVyY2hhbnRJZCI6ImRjcHNweTJicndkanIzcW4iLCJ2ZW5tbyI6Im9mZmxpbmUiLCJhcHBsZVBheSI6eyJzdGF0dXMiOiJtb2NrIiwiY291bnRyeUNvZGUiOiJVUyIsImN1cnJlbmN5Q29kZSI6IlVTRCIsIm1lcmNoYW50SWRlbnRpZmllciI6Im1lcmNoYW50LmNvbS5icmFpbnRyZWVwYXltZW50cy5zYW5kYm94LkJyYWludHJlZS1EZW1vIiwic3VwcG9ydGVkTmV0d29ya3MiOlsidmlzYSIsIm1hc3RlcmNhcmQiLCJhbWV4Il19fQ=="
    var mockAPIClient: MockAPIClient!
    var observers: [NSObjectProtocol] = []
    var localPaymentRequest: BTLocalPaymentRequest!
    var mockLocalPaymentRequestDelegate = MockLocalPaymentRequestDelegate()

    override func setUp() {
        super.setUp()
        self.localPaymentRequest = BTLocalPaymentRequest()
        self.localPaymentRequest.amount = "10"
        self.localPaymentRequest.paymentType = "ideal"
        self.mockAPIClient = MockAPIClient(authorization: self.tempClientToken)!
        self.localPaymentRequest.localPaymentFlowDelegate = self.mockLocalPaymentRequestDelegate
    }

    override func tearDown() {
        for observer in self.observers { NotificationCenter.default.removeObserver(observer) }
        super.tearDown()
    }

    func testStartPayment_returnsErrorWhenLocalPaymentsNotEnabled() {
        let viewControllerPresentingDelegate = MockViewControllerPresentationDelegate()

        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["paypalEnabled": false])
        let driver = BTPaymentFlowDriver(apiClient: mockAPIClient)
        driver.viewControllerPresentingDelegate = viewControllerPresentingDelegate
        let expectation = self.expectation(description: "Start payment fails with error")

        driver.startPaymentFlow(self.localPaymentRequest) { _, error in
            guard let error = error as NSError? else { return }
            XCTAssertEqual(error.domain, BTPaymentFlowDriverErrorDomain)
            XCTAssertEqual(error.code, BTPaymentFlowDriverErrorType.disabled.rawValue)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testStartPayment_returnsErrorWhenAmountIsNil() {
        let viewControllerPresentingDelegate = MockViewControllerPresentationDelegate()

        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["paypalEnabled": true])
        let driver = BTPaymentFlowDriver(apiClient: mockAPIClient)
        driver.viewControllerPresentingDelegate = viewControllerPresentingDelegate
        let expectation = self.expectation(description: "Start payment fails with error")

        self.localPaymentRequest.amount = nil

        driver.startPaymentFlow(self.localPaymentRequest) { _, error in
            guard let error = error as NSError? else { return }
            XCTAssertEqual(error.domain, BTPaymentFlowDriverErrorDomain)
            XCTAssertEqual(error.code, BTPaymentFlowDriverErrorType.integration.rawValue)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testStartPayment_returnsErrorWhenPaymentTypeIsNil() {
        let viewControllerPresentingDelegate = MockViewControllerPresentationDelegate()

        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["paypalEnabled": true])
        let driver = BTPaymentFlowDriver(apiClient: mockAPIClient)
        driver.viewControllerPresentingDelegate = viewControllerPresentingDelegate
        let expectation = self.expectation(description: "Start payment fails with error")

        self.localPaymentRequest.paymentType = nil

        driver.startPaymentFlow(self.localPaymentRequest) { _, error in
            guard let error = error as NSError? else { return }
            XCTAssertEqual(error.domain, BTPaymentFlowDriverErrorDomain)
            XCTAssertEqual(error.code, BTPaymentFlowDriverErrorType.integration.rawValue)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testStartPayment_returnsErrorWhenLocalPaymentDelegateIsNil() {
        let viewControllerPresentingDelegate = MockViewControllerPresentationDelegate()

        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["paypalEnabled": true])
        let driver = BTPaymentFlowDriver(apiClient: mockAPIClient)
        driver.viewControllerPresentingDelegate = viewControllerPresentingDelegate
        let expectation = self.expectation(description: "Start payment fails with error")

        self.localPaymentRequest.localPaymentFlowDelegate = nil

        driver.startPaymentFlow(self.localPaymentRequest) { _, error in
            guard let error = error as NSError? else { return }
            XCTAssertEqual(error.domain, BTPaymentFlowDriverErrorDomain)
            XCTAssertEqual(error.code, BTPaymentFlowDriverErrorType.integration.rawValue)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testStartPayment_postsAllCreationParameters() {
        let viewControllerPresentingDelegate = MockViewControllerPresentationDelegate()

        viewControllerPresentingDelegate.requestsPresentationOfViewControllerExpectation = self.expectation(description: "Delegate received requestsPresentationOfViewController")

        self.mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["paypalEnabled": true])

        let driver = BTPaymentFlowDriver(apiClient: mockAPIClient)
        driver.viewControllerPresentingDelegate = viewControllerPresentingDelegate
        self.mockAPIClient.cannedResponseBody = BTJSON(value: ["paymentResource": [
            "redirectUrl": "https://www.somebankurl.com",
            "paymentToken": "123aaa-123-543-777",
        ]])

        self.localPaymentRequest.merchantAccountId = "customer-nl-merchant-account"
        self.localPaymentRequest.paymentType = "ideal"
        self.localPaymentRequest.currencyCode = "EUR"
        self.localPaymentRequest.amount = "1.01"
        self.localPaymentRequest.givenName = "Linh"
        self.localPaymentRequest.surname = "Ngo"
        self.localPaymentRequest.phone = "639847934"
        self.localPaymentRequest.address = BTPostalAddress()
        self.localPaymentRequest.address!.countryCodeAlpha2 = "NL"
        self.localPaymentRequest.address!.region = "CA"
        self.localPaymentRequest.address!.postalCode = "2585 GJ"
        self.localPaymentRequest.address!.streetAddress = "836486 of 22321 Park Lake"
        self.localPaymentRequest.address!.extendedAddress = "#102"
        self.localPaymentRequest.address!.locality = "Den Haag"
        self.localPaymentRequest.email = "lingo-buyer@paypal.com"
        self.localPaymentRequest.isShippingAddressRequired = true
        driver.startPaymentFlow(self.localPaymentRequest) { _, _ in
        }

        waitForExpectations(timeout: 4, handler: nil)

        XCTAssertEqual(self.mockAPIClient.lastPOSTParameters!["merchant_account_id"] as? String, "customer-nl-merchant-account")
        XCTAssertEqual(self.mockAPIClient.lastPOSTParameters!["funding_source"] as? String, "ideal")
        XCTAssertEqual(self.mockAPIClient.lastPOSTParameters!["currency_iso_code"] as? String, "EUR")
        XCTAssertEqual(self.mockAPIClient.lastPOSTParameters!["amount"] as? String, "1.01")
        XCTAssertEqual(self.mockAPIClient.lastPOSTParameters!["first_name"] as? String, "Linh")
        XCTAssertEqual(self.mockAPIClient.lastPOSTParameters!["last_name"] as? String, "Ngo")
        XCTAssertEqual(self.mockAPIClient.lastPOSTParameters!["phone"] as? String, "639847934")
        XCTAssertEqual(self.mockAPIClient.lastPOSTParameters!["payer_email"] as? String, "lingo-buyer@paypal.com")
        XCTAssertEqual(self.mockAPIClient.lastPOSTParameters!["line1"] as? String, "836486 of 22321 Park Lake")
        XCTAssertEqual(self.mockAPIClient.lastPOSTParameters!["line2"] as? String, "#102")
        XCTAssertEqual(self.mockAPIClient.lastPOSTParameters!["city"] as? String, "Den Haag")
        XCTAssertEqual(self.mockAPIClient.lastPOSTParameters!["state"] as? String, "CA")
        XCTAssertEqual(self.mockAPIClient.lastPOSTParameters!["postal_code"] as? String, "2585 GJ")
        XCTAssertEqual(self.mockAPIClient.lastPOSTParameters!["country_code"] as? String, "NL")

        guard let experienceProfile = self.mockAPIClient.lastPOSTParameters!["experience_profile"] as? [String: AnyObject] else {
            XCTFail()
            return
        }
        XCTAssertFalse(experienceProfile["no_shipping"] as! Bool)
    }

    func testStartPayment_displaysSafariViewControllerWhenAvailable() {
        let viewControllerPresentingDelegate = MockViewControllerPresentationDelegate()

        viewControllerPresentingDelegate.requestsPresentationOfViewControllerExpectation = self.expectation(description: "Delegate received requestsPresentationOfViewController")

        self.mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["paypalEnabled": true])

        let driver = BTPaymentFlowDriver(apiClient: mockAPIClient)
        driver.viewControllerPresentingDelegate = viewControllerPresentingDelegate
        self.mockAPIClient.cannedResponseBody = BTJSON(value: ["paymentResource": [
            "redirectUrl": "https://www.somebankurl.com",
            "paymentToken": "123aaa-123-543-777",
        ]])

        driver.startPaymentFlow(self.localPaymentRequest) { _, _ in
        }

        waitForExpectations(timeout: 4, handler: nil)
    }

    func testStartPayment_returnsErrorWhenRedirectUrlIsMissing() {
        let viewControllerPresentingDelegate = MockViewControllerPresentationDelegate()

        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["paypalEnabled": true])

        let driver = BTPaymentFlowDriver(apiClient: mockAPIClient)
        driver.viewControllerPresentingDelegate = viewControllerPresentingDelegate
        self.mockAPIClient.cannedResponseBody = BTJSON(value: ["paymentResource": [
            "paymentToken": "123aaa-123-543-777",
        ]])
        let expectation = self.expectation(description: "Start payment fails with error")

        driver.startPaymentFlow(self.localPaymentRequest) { _, error in
            guard let error = error as NSError? else { return }
            XCTAssertEqual(error.domain, BTPaymentFlowDriverErrorDomain)
            XCTAssertEqual(error.code, BTPaymentFlowDriverErrorType.appSwitchFailed.rawValue)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 4, handler: nil)
    }

    func testStartPayment_returnsErrorWhenPaymentTokenIsMissing() {
        let viewControllerPresentingDelegate = MockViewControllerPresentationDelegate()

        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["paypalEnabled": true])

        let driver = BTPaymentFlowDriver(apiClient: mockAPIClient)
        driver.viewControllerPresentingDelegate = viewControllerPresentingDelegate
        self.mockAPIClient.cannedResponseBody = BTJSON(value: ["paymentResource": [
            "redirectUrl": "https://www.somebankurl.com",
        ]])
        let expectation = self.expectation(description: "Start payment fails with error")

        driver.startPaymentFlow(self.localPaymentRequest) { _, error in
            guard let error = error as NSError? else { return }
            XCTAssertEqual(error.domain, BTPaymentFlowDriverErrorDomain)
            XCTAssertEqual(error.code, BTPaymentFlowDriverErrorType.appSwitchFailed.rawValue)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 4, handler: nil)
    }

    func testStartPayment_returnsPaymentId_inDelegateCallback() {
        self.mockLocalPaymentRequestDelegate.idExpectation = self.expectation(description: "Received payment ID")

        let viewControllerPresentingDelegate = MockViewControllerPresentationDelegate()

        viewControllerPresentingDelegate.requestsPresentationOfViewControllerExpectation = self.expectation(description: "Delegate received requestsPresentationOfViewController")

        self.mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["paypalEnabled": true])

        let driver = BTPaymentFlowDriver(apiClient: mockAPIClient)
        driver.viewControllerPresentingDelegate = viewControllerPresentingDelegate
        self.mockAPIClient.cannedResponseBody = BTJSON(value: ["paymentResource": [
            "redirectUrl": "https://www.somebankurl.com",
            "paymentToken": "123aaa-123-543-abv",
        ]])

        driver.startPaymentFlow(self.localPaymentRequest) { _, _ in
        }

        waitForExpectations(timeout: 4, handler: nil)

        XCTAssertEqual(self.mockLocalPaymentRequestDelegate.paymentId, "123aaa-123-543-abv")
    }

    func testStartPayment_success_sendsAnalyticsEvents() {
        let viewControllerPresentingDelegate = MockViewControllerPresentationDelegate()

        viewControllerPresentingDelegate.requestsPresentationOfViewControllerExpectation = self.expectation(description: "Delegate received requestsPresentationOfViewController")

        self.mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["paypalEnabled": true])

        let driver = BTPaymentFlowDriver(apiClient: mockAPIClient)
        driver.viewControllerPresentingDelegate = viewControllerPresentingDelegate
        self.mockAPIClient.cannedResponseBody = BTJSON(value: ["paymentResource": [
            "redirectUrl": "https://www.somebankurl.com",
            "paymentToken": "123aaa-123-543-777",
        ]])

        driver.startPaymentFlow(self.localPaymentRequest) { _, _ in
        }

        waitForExpectations(timeout: 4, handler: nil)
        XCTAssertTrue(self.mockAPIClient.postedAnalyticsEvents.contains("ios.ideal.local-payment.start-payment.selected"))
        XCTAssertTrue(self.mockAPIClient.postedAnalyticsEvents.contains("ios.ideal.local-payment.webswitch.initiate.succeeded"))
    }

    func testStartPayment_failure_sendsAnalyticsEvents() {
        let viewControllerPresentingDelegate = MockViewControllerPresentationDelegate()

        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["paypalEnabled": true])

        let driver = BTPaymentFlowDriver(apiClient: mockAPIClient)
        driver.viewControllerPresentingDelegate = viewControllerPresentingDelegate
        self.mockAPIClient.cannedResponseError = NSError(domain: "BTError", code: 500, userInfo: nil)

        let expectation = self.expectation(description: "Start payment expectation")
        driver.startPaymentFlow(self.localPaymentRequest) { _, _ in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 4, handler: nil)
        XCTAssertTrue(self.mockAPIClient.postedAnalyticsEvents.contains("ios.ideal.local-payment.start-payment.selected"))
        XCTAssertTrue(self.mockAPIClient.postedAnalyticsEvents.contains("ios.ideal.local-payment.start-payment.failed"))
    }

    func testStartPayment_makesDelegateCallbacks_forContextSwitchEvents() {
        self.mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["paypalEnabled": true])

        let viewControllerPresentingDelegate = MockViewControllerPresentationDelegate()
        viewControllerPresentingDelegate.requestsPresentationOfViewControllerExpectation = self.expectation(description: "Delegate received requestsPresentationOfViewController")

        let driver = BTPaymentFlowDriver(apiClient: mockAPIClient)
        driver.viewControllerPresentingDelegate = viewControllerPresentingDelegate
        let appSwitchDelegate = MockAppSwitchDelegate()
        driver.appSwitchDelegate = appSwitchDelegate

        self.mockAPIClient.cannedResponseBody = BTJSON(value: ["paymentResource": [
            "redirectUrl": "https://www.somebankurl.com",
            "paymentToken": "123aaa-123-543-777",
        ]])

        var paymentFinishedExpectation: XCTestExpectation?
        driver.startPaymentFlow(self.localPaymentRequest) { _, _ in
            paymentFinishedExpectation!.fulfill()
        }

        paymentFinishedExpectation = self.expectation(description: "Payment finished expectation")
        BTPaymentFlowDriver.handleAppSwitchReturn(URL(string: "http://unused.example.com")!)

        waitForExpectations(timeout: 2, handler: nil)

        XCTAssertTrue(appSwitchDelegate.appContextWillSwitchCalled)
        XCTAssertTrue(appSwitchDelegate.appContextDidReturnCalled)
    }

    func testStartPayment_successfulResult_callsCompletionBlock() {
        self.mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["paypalEnabled": true])

        let viewControllerPresentingDelegate = MockViewControllerPresentationDelegate()
        viewControllerPresentingDelegate.requestsPresentationOfViewControllerExpectation = self.expectation(description: "Delegate received requestsPresentationOfViewController")

        let driver = BTPaymentFlowDriver(apiClient: mockAPIClient)
        driver.viewControllerPresentingDelegate = viewControllerPresentingDelegate
        let appSwitchDelegate = MockAppSwitchDelegate()
        driver.appSwitchDelegate = appSwitchDelegate

        self.mockAPIClient.cannedResponseBody = BTJSON(value: ["paymentResource": [
            "redirectUrl": "https://www.somebankurl.com",
            "paymentToken": "123aaa-123-543-777",
        ]])

        var paymentFinishedExpectation: XCTestExpectation?
        driver.startPaymentFlow(self.localPaymentRequest) { result, error in
            XCTAssertNil(error)
            XCTAssertNotNil(result)
            guard let localPaymentResult = result as! BTLocalPaymentResult? else { return }

            XCTAssertEqual(localPaymentResult.clientMetadataId, "89d377ae78244447a3f78ada7d01b270")
            XCTAssertEqual(localPaymentResult.type, "PayPalAccount")
            XCTAssertEqual(localPaymentResult.payerId, "PCKXQCZ6J3YXU")
            XCTAssertEqual(localPaymentResult.nonce, "f689056d-aee1-421e-9d10-f2c9b34d4d6f")
            paymentFinishedExpectation!.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)

        let responseBody = [
            "paypalAccounts": [[
                "consumed": false,
                "description": "PayPal",
                "details": [
                    "correlationId": "89d377ae78244447a3f78ada7d01b270",
                    "payerInfo": [
                        "countryCode": "NL",
                        "email": "lingo-buyer@paypal.com",
                        "firstName": "Linh",
                        "lastName": "Ngo",
                        "payerId": "PCKXQCZ6J3YXU",
                        "shippingAddress": [
                            "city": "Den Haag",
                            "countryCode": "NL",
                            "line1": "836486 of 22321 Park Lake",
                            "postalCode": "2585 GJ",
                            "recipientName": "Linh Ngo",
                            "state": "",
                        ],
                    ],
                ],
                "nonce": "f689056d-aee1-421e-9d10-f2c9b34d4d6f",
                "type": "PayPalAccount",
            ]],
        ] as [String: Any]

        mockAPIClient.cannedResponseBody = BTJSON(value: responseBody)

        paymentFinishedExpectation = self.expectation(description: "Payment finished expectation")
        BTPaymentFlowDriver.handleAppSwitchReturn(URL(string: "com.braintreepayments.demo.payments://x-callback-url/braintree/local-payment/success?PayerID=PCKXQCZ6J3YXU&paymentId=PAY-79C90584AX7152104LNY4OCY&token=EC-0A351828G20802249")!)

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testStartPayment_cancelResult_callsCompletionBlock() {
        self.mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["paypalEnabled": true])

        let viewControllerPresentingDelegate = MockViewControllerPresentationDelegate()
        viewControllerPresentingDelegate.requestsPresentationOfViewControllerExpectation = self.expectation(description: "Delegate received requestsPresentationOfViewController")

        let driver = BTPaymentFlowDriver(apiClient: mockAPIClient)
        driver.viewControllerPresentingDelegate = viewControllerPresentingDelegate
        let appSwitchDelegate = MockAppSwitchDelegate()
        driver.appSwitchDelegate = appSwitchDelegate

        self.mockAPIClient.cannedResponseBody = BTJSON(value: ["paymentResource": [
            "redirectUrl": "https://www.somebankurl.com",
            "paymentToken": "123aaa-123-543-777",
        ]])

        var paymentFinishedExpectation: XCTestExpectation?
        driver.startPaymentFlow(self.localPaymentRequest) { _, error in
            guard let error = error as NSError? else { return }
            XCTAssertEqual(error.domain, BTPaymentFlowDriverErrorDomain)
            XCTAssertEqual(error.code, BTPaymentFlowDriverErrorType.canceled.rawValue)
            paymentFinishedExpectation!.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)

        paymentFinishedExpectation = self.expectation(description: "Payment finished expectation")
        BTPaymentFlowDriver.handleAppSwitchReturn(URL(string: "com.braintreepayments.demo.payments://x-callback-url/braintree/local-payment/cancel?paymentId=PAY-79C90584AX7152104LNY4OCY")!)

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testStartPayment_callsCompletionBlock_withError_tokenizationFailure() {
        self.mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["paypalEnabled": true])

        let viewControllerPresentingDelegate = MockViewControllerPresentationDelegate()
        viewControllerPresentingDelegate.requestsPresentationOfViewControllerExpectation = self.expectation(description: "Delegate received requestsPresentationOfViewController")

        let driver = BTPaymentFlowDriver(apiClient: mockAPIClient)
        driver.viewControllerPresentingDelegate = viewControllerPresentingDelegate
        let appSwitchDelegate = MockAppSwitchDelegate()
        driver.appSwitchDelegate = appSwitchDelegate

        self.mockAPIClient.cannedResponseBody = BTJSON(value: ["paymentResource": [
            "redirectUrl": "https://www.somebankurl.com",
            "paymentToken": "123aaa-123-543-777",
        ]])

        var paymentFinishedExpectation: XCTestExpectation?
        driver.startPaymentFlow(self.localPaymentRequest) { result, error in
            XCTAssertNotNil(error)
            XCTAssertNil(result)
            paymentFinishedExpectation!.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)

        self.mockAPIClient.cannedResponseError = NSError(domain: "BTError", code: 500, userInfo: nil)

        paymentFinishedExpectation = self.expectation(description: "Payment finished expectation")
        BTPaymentFlowDriver.handleAppSwitchReturn(URL(string: "com.braintreepayments.demo.payments://x-callback-url/braintree/local-payment/success?PayerID=PCKXQCZ6J3YXU&paymentId=PAY-79C90584AX7152104LNY4OCY&token=EC-0A351828G20802249")!)

        waitForExpectations(timeout: 2, handler: nil)
    }
}
