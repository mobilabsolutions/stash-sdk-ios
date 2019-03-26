import XCTest

@objc class MockAppSwitchDelegate: NSObject, BTAppSwitchDelegate {
    var willPerformAppSwitchExpectation: XCTestExpectation?
    var didPerformAppSwitchExpectation: XCTestExpectation?
    var willProcessAppSwitchExpectation: XCTestExpectation?
    var appContextWillSwitchExpectation: XCTestExpectation?
    var appContextDidReturnExpectation: XCTestExpectation?
    // XCTestExpectations verify that delegates callbacks are made; the below bools verify that they are NOT made
    var willPerformAppSwitchCalled = false
    var didPerformAppSwitchCalled = false
    var willProcessAppSwitchCalled = false
    var appContextWillSwitchCalled = false
    var appContextDidReturnCalled = false
    var lastAppSwitcher: AnyObject?

    override init() {}

    init(willPerform: XCTestExpectation?, didPerform: XCTestExpectation?) {
        self.willPerformAppSwitchExpectation = willPerform
        self.didPerformAppSwitchExpectation = didPerform
    }

    @objc func appSwitcherWillPerformAppSwitch(_ appSwitcher: Any) {
        self.lastAppSwitcher = appSwitcher as AnyObject?
        self.willPerformAppSwitchExpectation?.fulfill()
        self.willPerformAppSwitchCalled = true
    }

    @objc func appSwitcher(_ appSwitcher: Any, didPerformSwitchTo _: BTAppSwitchTarget) {
        self.lastAppSwitcher = appSwitcher as AnyObject?
        self.didPerformAppSwitchExpectation?.fulfill()
        self.didPerformAppSwitchCalled = true
    }

    @objc func appSwitcherWillProcessPaymentInfo(_ appSwitcher: Any) {
        self.lastAppSwitcher = appSwitcher as AnyObject?
        self.willProcessAppSwitchExpectation?.fulfill()
        self.willProcessAppSwitchCalled = true
    }

    @objc func appContextWillSwitch(_ appSwitcher: Any) {
        self.lastAppSwitcher = appSwitcher as AnyObject?
        self.appContextWillSwitchExpectation?.fulfill()
        self.appContextWillSwitchCalled = true
    }

    @objc func appContextDidReturn(_ appSwitcher: Any) {
        self.lastAppSwitcher = appSwitcher as AnyObject?
        self.appContextDidReturnExpectation?.fulfill()
        self.appContextDidReturnCalled = true
    }
}

@objc class MockViewControllerPresentationDelegate: NSObject, BTViewControllerPresentingDelegate {
    var requestsPresentationOfViewControllerExpectation: XCTestExpectation?
    var requestsDismissalOfViewControllerExpectation: XCTestExpectation?
    var lastViewController: UIViewController?
    var lastPaymentDriver: AnyObject?

    func paymentDriver(_ driver: Any, requestsDismissalOf viewController: UIViewController) {
        self.lastPaymentDriver = driver as AnyObject?
        self.lastViewController = viewController
        self.requestsDismissalOfViewControllerExpectation?.fulfill()
    }

    func paymentDriver(_ driver: Any, requestsPresentationOf viewController: UIViewController) {
        self.lastPaymentDriver = driver as AnyObject?
        self.lastViewController = viewController
        self.requestsPresentationOfViewControllerExpectation?.fulfill()
    }
}

@objc class MockLocalPaymentRequestDelegate: NSObject, BTLocalPaymentRequestDelegate {
    var paymentId: String?
    var idExpectation: XCTestExpectation?

    func localPaymentStarted(_: BTLocalPaymentRequest, paymentId: String, start: @escaping () -> Void) {
        self.paymentId = paymentId
        self.idExpectation?.fulfill()
        start()
    }
}

@objc class MockPayPalApprovalHandlerDelegate: NSObject, BTPayPalApprovalHandler {
    var handleApprovalExpectation: XCTestExpectation?
    var url: NSURL?
    var cancel: Bool = false

    func handleApproval(_: PPOTRequest, paypalApprovalDelegate delegate: BTPayPalApprovalDelegate) {
        if self.cancel {
            delegate.onApprovalCancel()
        } else {
            delegate.onApprovalComplete(self.url! as URL)
        }
        self.handleApprovalExpectation?.fulfill()
    }
}
