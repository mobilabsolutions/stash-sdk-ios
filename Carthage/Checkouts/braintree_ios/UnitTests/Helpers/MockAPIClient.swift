import BraintreeCore

class MockAPIClient: BTAPIClient {
    var lastPOSTPath = ""
    var lastPOSTParameters = [:] as [AnyHashable: Any]?
    var lastPOSTAPIClientHTTPType: BTAPIClientHTTPType?
    var lastGETPath = ""
    var lastGETParameters = [:] as [String: String]?
    var lastGETAPIClientHTTPType: BTAPIClientHTTPType?
    var postedAnalyticsEvents: [String] = []

    @objc var cannedConfigurationResponseBody: BTJSON?
    @objc var cannedConfigurationResponseError: NSError?

    var cannedResponseError: NSError?
    var cannedHTTPURLResponse: HTTPURLResponse?
    var cannedResponseBody: BTJSON?
    var cannedMetadata: BTClientMetadata?

    var fetchedPaymentMethods = false
    var fetchPaymentMethodsSorting = false

    override func get(_ path: String, parameters: [String: String]?, completion completionBlock: ((BTJSON?, HTTPURLResponse?, Error?) -> Void)? = nil) {
        self.get(path, parameters: parameters, httpType: .gateway, completion: completionBlock)
    }

    override func post(_ path: String, parameters: [AnyHashable: Any]?, completion completionBlock: ((BTJSON?, HTTPURLResponse?, Error?) -> Void)? = nil) {
        self.post(path, parameters: parameters, httpType: .gateway, completion: completionBlock)
    }

    override func get(_ path: String, parameters: [String: String]?, httpType: BTAPIClientHTTPType, completion completionBlock: ((BTJSON?, HTTPURLResponse?, Error?) -> Void)? = nil) {
        self.lastGETPath = path
        self.lastGETParameters = parameters
        self.lastGETAPIClientHTTPType = httpType

        guard let completionBlock = completionBlock else {
            return
        }
        completionBlock(self.cannedResponseBody, self.cannedHTTPURLResponse, self.cannedResponseError)
    }

    override func post(_ path: String, parameters: [AnyHashable: Any]?, httpType: BTAPIClientHTTPType, completion completionBlock: ((BTJSON?, HTTPURLResponse?, Error?) -> Void)? = nil) {
        self.lastPOSTPath = path
        self.lastPOSTParameters = parameters
        self.lastPOSTAPIClientHTTPType = httpType

        guard let completionBlock = completionBlock else {
            return
        }
        completionBlock(self.cannedResponseBody, self.cannedHTTPURLResponse, self.cannedResponseError)
    }

    override func fetchOrReturnRemoteConfiguration(_ completionBlock: @escaping (BTConfiguration?, Error?) -> Void) {
        guard let responseBody = cannedConfigurationResponseBody else {
            completionBlock(nil, self.cannedConfigurationResponseError)
            return
        }
        completionBlock(BTConfiguration(json: responseBody), self.cannedConfigurationResponseError)
    }

    override func fetchPaymentMethodNonces(_ completion: @escaping ([BTPaymentMethodNonce]?, Error?) -> Void) {
        self.fetchedPaymentMethods = true
        self.fetchPaymentMethodsSorting = false
        completion([], nil)
    }

    override func fetchPaymentMethodNonces(_: Bool, completion: @escaping ([BTPaymentMethodNonce]?, Error?) -> Void) {
        self.fetchedPaymentMethods = true
        self.fetchPaymentMethodsSorting = false
        completion([], nil)
    }

    /// BTAPIClient gets copied by other classes like BTPayPalDriver, BTVenmoDriver, etc.
    /// This copy causes MockAPIClient to lose its stubbed data (canned responses), so the
    /// workaround for tests is to stub copyWithSource:integration: to *not* copy itself
    override func copy(with _: BTClientMetadataSourceType, integration _: BTClientMetadataIntegrationType) -> Self {
        return self
    }

    override func sendAnalyticsEvent(_ name: String) {
        self.postedAnalyticsEvents.append(name)
    }

    func didFetchPaymentMethods(sorted: Bool) -> Bool {
        return self.fetchedPaymentMethods && self.fetchPaymentMethodsSorting == sorted
    }

    override var metadata: BTClientMetadata {
        if let cannedMetadata = cannedMetadata {
            return cannedMetadata
        } else {
            self.cannedMetadata = BTClientMetadata()
            return self.cannedMetadata!
        }
    }
}
