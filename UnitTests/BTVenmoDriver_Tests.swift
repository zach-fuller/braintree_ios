import UIKit
import XCTest

class FakeApplication {
    var lastOpenURL : NSURL? = nil
    var openURLWasCalled : Bool = false
    var cannedOpenURLSuccess : Bool = true
    var cannedCanOpenURL : Bool = true

    @objc func openURL(url: NSURL) -> Bool {
        lastOpenURL = url
        openURLWasCalled = true
        return cannedOpenURLSuccess
    }

    @objc func canOpenURL(url: NSURL) -> Bool {
        return cannedCanOpenURL
    }
}

class FakeBundle : NSBundle {
    override func objectForInfoDictionaryKey(key: String) -> AnyObject? {
        return "An App";
    }
}

class BTVenmoDriver_Tests: XCTestCase {
    var mockAPIClient : MockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
    var observers : [NSObjectProtocol] = []
    
    let ValidClientToken = "eyJ2ZXJzaW9uIjoyLCJhdXRob3JpemF0aW9uRmluZ2VycHJpbnQiOiI3ODJhZmFlNDJlZTNiNTA4NWUxNmMzYjhkZTY3OGQxNTJhODFlYzk5MTBmZDNhY2YyYWU4MzA2OGI4NzE4YWZhfGNyZWF0ZWRfYXQ9MjAxNS0wOC0yMFQwMjoxMTo1Ni4yMTY1NDEwNjErMDAwMFx1MDAyNmN1c3RvbWVyX2lkPTM3OTU5QTE5LThCMjktNDVBNC1CNTA3LTRFQUNBM0VBOEM4Nlx1MDAyNm1lcmNoYW50X2lkPWRjcHNweTJicndkanIzcW5cdTAwMjZwdWJsaWNfa2V5PTl3d3J6cWszdnIzdDRuYzgiLCJjb25maWdVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvZGNwc3B5MmJyd2RqcjNxbi9jbGllbnRfYXBpL3YxL2NvbmZpZ3VyYXRpb24iLCJjaGFsbGVuZ2VzIjpbXSwiZW52aXJvbm1lbnQiOiJzYW5kYm94IiwiY2xpZW50QXBpVXJsIjoiaHR0cHM6Ly9hcGkuc2FuZGJveC5icmFpbnRyZWVnYXRld2F5LmNvbTo0NDMvbWVyY2hhbnRzL2RjcHNweTJicndkanIzcW4vY2xpZW50X2FwaSIsImFzc2V0c1VybCI6Imh0dHBzOi8vYXNzZXRzLmJyYWludHJlZWdhdGV3YXkuY29tIiwiYXV0aFVybCI6Imh0dHBzOi8vYXV0aC52ZW5tby5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIiwiYW5hbHl0aWNzIjp7InVybCI6Imh0dHBzOi8vY2xpZW50LWFuYWx5dGljcy5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIn0sInRocmVlRFNlY3VyZUVuYWJsZWQiOnRydWUsInRocmVlRFNlY3VyZSI6eyJsb29rdXBVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvZGNwc3B5MmJyd2RqcjNxbi90aHJlZV9kX3NlY3VyZS9sb29rdXAifSwicGF5cGFsRW5hYmxlZCI6dHJ1ZSwicGF5cGFsIjp7ImRpc3BsYXlOYW1lIjoiQWNtZSBXaWRnZXRzLCBMdGQuIChTYW5kYm94KSIsImNsaWVudElkIjpudWxsLCJwcml2YWN5VXJsIjoiaHR0cDovL2V4YW1wbGUuY29tL3BwIiwidXNlckFncmVlbWVudFVybCI6Imh0dHA6Ly9leGFtcGxlLmNvbS90b3MiLCJiYXNlVXJsIjoiaHR0cHM6Ly9hc3NldHMuYnJhaW50cmVlZ2F0ZXdheS5jb20iLCJhc3NldHNVcmwiOiJodHRwczovL2NoZWNrb3V0LnBheXBhbC5jb20iLCJkaXJlY3RCYXNlVXJsIjpudWxsLCJhbGxvd0h0dHAiOnRydWUsImVudmlyb25tZW50Tm9OZXR3b3JrIjp0cnVlLCJlbnZpcm9ubWVudCI6Im9mZmxpbmUiLCJ1bnZldHRlZE1lcmNoYW50IjpmYWxzZSwiYnJhaW50cmVlQ2xpZW50SWQiOiJtYXN0ZXJjbGllbnQzIiwiYmlsbGluZ0FncmVlbWVudHNFbmFibGVkIjpmYWxzZSwibWVyY2hhbnRBY2NvdW50SWQiOiJzdGNoMm5mZGZ3c3p5dHc1IiwiY3VycmVuY3lJc29Db2RlIjoiVVNEIn0sImNvaW5iYXNlRW5hYmxlZCI6dHJ1ZSwiY29pbmJhc2UiOnsiY2xpZW50SWQiOiIxMWQyNzIyOWJhNThiNTZkN2UzYzAxYTA1MjdmNGQ1YjQ0NmQ0ZjY4NDgxN2NiNjIzZDI1NWI1NzNhZGRjNTliIiwibWVyY2hhbnRBY2NvdW50IjoiY29pbmJhc2UtZGV2ZWxvcG1lbnQtbWVyY2hhbnRAZ2V0YnJhaW50cmVlLmNvbSIsInNjb3BlcyI6ImF1dGhvcml6YXRpb25zOmJyYWludHJlZSB1c2VyIiwicmVkaXJlY3RVcmwiOiJodHRwczovL2Fzc2V0cy5icmFpbnRyZWVnYXRld2F5LmNvbS9jb2luYmFzZS9vYXV0aC9yZWRpcmVjdC1sYW5kaW5nLmh0bWwiLCJlbnZpcm9ubWVudCI6Im1vY2sifSwibWVyY2hhbnRJZCI6ImRjcHNweTJicndkanIzcW4iLCJ2ZW5tbyI6Im9mZmxpbmUiLCJhcHBsZVBheSI6eyJzdGF0dXMiOiJtb2NrIiwiY291bnRyeUNvZGUiOiJVUyIsImN1cnJlbmN5Q29kZSI6IlVTRCIsIm1lcmNoYW50SWRlbnRpZmllciI6Im1lcmNoYW50LmNvbS5icmFpbnRyZWVwYXltZW50cy5zYW5kYm94LkJyYWludHJlZS1EZW1vIiwic3VwcG9ydGVkTmV0d29ya3MiOlsidmlzYSIsIm1hc3RlcmNhcmQiLCJhbWV4Il19fQ==";

    override func setUp() {
        super.setUp()

        mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
    }

    override func tearDown() {
        for observer in observers { NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
        super.tearDown()
    }
    
    func testTokenization_whenAPIClientIsNil_callsBackWithError() {
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        venmoDriver.apiClient = nil
        
        let expectation = expectationWithDescription("Callback invoked with error")
        venmoDriver.tokenizeVenmoCardWithCompletion { (tokenizedCard, error) -> Void in
            XCTAssertNil(tokenizedCard)
            XCTAssertEqual(error!.domain, BTVenmoDriverErrorDomain)
            XCTAssertEqual(error!.code, BTVenmoDriverErrorType.Integration.rawValue)
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10, handler: nil)
    }

    func testTokenization_whenRemoteConfigurationFetchFails_callsBackWithConfigurationError() {
        mockAPIClient.cannedConfigurationResponseError = NSError(domain: "", code: 0, userInfo: nil)
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"

        let expectation = self.expectationWithDescription("Tokenize fails with error")
        venmoDriver.tokenizeVenmoCardWithCompletion { (tokenizedCard, error) -> Void in
            XCTAssertEqual(error!, self.mockAPIClient.cannedConfigurationResponseError!)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testTokenization_whenVenmoConfigurationDisabled_callsBackWithError() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [ "venmo": "off" ])
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"

        let expectation = expectationWithDescription("tokenization callback")
        venmoDriver.tokenizeVenmoCardWithCompletion { (tokenizedCard, error) -> Void in
            XCTAssertEqual(error!.domain, BTVenmoDriverErrorDomain)
            XCTAssertEqual(error!.code, BTVenmoDriverErrorType.Disabled.rawValue)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testTokenization_whenVenmoConfigurationMissing_callsBackWithError() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [:])
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"

        let expectation = expectationWithDescription("tokenization callback")
        venmoDriver.tokenizeVenmoCardWithCompletion { (tokenizedCard, error) -> Void in
            XCTAssertEqual(error!.domain, BTVenmoDriverErrorDomain)
            XCTAssertEqual(error!.code, BTVenmoDriverErrorType.Disabled.rawValue)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testTokenization_whenVenmoIsConfiguredCorrectly_opensVenmoURL() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "venmo": "production",
            "merchantId": "merchant_id" ])
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        venmoDriver.application = fakeApplication
        venmoDriver.bundle = FakeBundle()

        venmoDriver.tokenizeVenmoCardWithCompletion { _ -> Void in }

        XCTAssertTrue(fakeApplication.openURLWasCalled)
    }

    func testTokenization_beforeAppSwitch_informsDelegate() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "venmo": "production",
            "merchantId": "merchant_id" ])
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        let delegate = MockAppSwitchDelegate(willPerform: expectationWithDescription("willPerform called"), didPerform: expectationWithDescription("didPerform called"))
        venmoDriver.delegate = delegate
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        venmoDriver.application = fakeApplication
        venmoDriver.bundle = FakeBundle()

        venmoDriver.tokenizeVenmoCardWithCompletion { _ -> Void in
            XCTAssertEqual(delegate.lastAppSwitcher as? BTVenmoDriver, venmoDriver)
        }

        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testTokenization_whenUsingTokenizationKeyAndAppSwitchSucceeds_tokenizesVenmoCard() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "venmo": "production",
            "merchantId": "merchant_id" ])
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        mockAPIClient = venmoDriver.apiClient as! MockAPIClient
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()

        let expectation = self.expectationWithDescription("Callback")
        venmoDriver.tokenizeVenmoCardWithCompletion { (tokenizedCard, error) -> Void in
            guard let tokenizedCard = tokenizedCard else {
                XCTFail("Received an error: \(error)")
                return
            }

            XCTAssertNil(error)
            XCTAssertEqual(tokenizedCard.nonce, "fake-nonce")
            XCTAssertEqual(tokenizedCard.localizedDescription, "Card from Venmo")
            XCTAssertNil(tokenizedCard.lastTwo)
            XCTAssertEqual(tokenizedCard.cardNetwork, BTCardNetwork.Unknown)
            expectation.fulfill()
        }
        BTVenmoDriver.handleAppSwitchReturnURL(NSURL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce")!)

        self.waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testTokenization_whenUsingClientTokenAndAppSwitchSucceeds_tokenizesVenmoCard() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "venmo": "production",
            "merchantId": "merchant_id" ])
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "paymentMethods": [
                [
                    "nonce": "fake-nonce",
                    "description": "Visa ending in 11",
                    "details": [
                        "lastTwo" : "11",
                        "cardType": "visa"
                    ]
                ] ] ])
        // Test setup sets up mockAPIClient with a tokenization key, we want a client token
        mockAPIClient.tokenizationKey = nil
        mockAPIClient.clientToken = try! BTClientToken(clientToken: ValidClientToken)
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        mockAPIClient = venmoDriver.apiClient as! MockAPIClient
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()
        
        let expectation = self.expectationWithDescription("Callback")
        venmoDriver.tokenizeVenmoCardWithCompletion { (tokenizedCard, error) -> Void in
            guard let tokenizedCard = tokenizedCard else {
                XCTFail("Received an error: \(error)")
                return
            }
            
            XCTAssertNil(error)
            XCTAssertEqual(tokenizedCard.nonce, "fake-nonce")
            XCTAssertEqual(tokenizedCard.localizedDescription, "Visa ending in 11")
            XCTAssertEqual(tokenizedCard.lastTwo!, "11")
            XCTAssertEqual(tokenizedCard.cardNetwork, BTCardNetwork.Visa)
            expectation.fulfill()
        }
        BTVenmoDriver.handleAppSwitchReturnURL(NSURL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce")!)
        
        self.waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testTokenization_whenUsingJWTAndAppSwitchSucceeds_tokenizesVenmoCard() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "venmo": "production",
            "merchantId": "merchant_id" ])
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "paymentMethods": [
                [
                    "nonce": "fake-nonce",
                    "description": "Visa ending in 11",
                    "details": [
                        "lastTwo" : "11",
                        "cardType": "visa"
                        ]
                ] ] ])
        // Test setup sets up mockAPIClient with a tokenization key, we want a client token JWT
        mockAPIClient.tokenizationKey = nil
        // Note: for this test, it doesn't really matter that we provide a real JWT, since
        // BTVenmoDriver's implementation branches on whether a tokenization key exists or not, and
        // the stub API client will return a canned value
        mockAPIClient.clientJWT = "some-fake-JWT"
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        mockAPIClient = venmoDriver.apiClient as! MockAPIClient
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()

        let expectation = self.expectationWithDescription("Callback")
        venmoDriver.tokenizeVenmoCardWithCompletion { (tokenizedCard, error) -> Void in
            guard let tokenizedCard = tokenizedCard else {
                XCTFail("Received an error: \(error)")
                return
            }

            XCTAssertNil(error)
            XCTAssertEqual(tokenizedCard.nonce, "fake-nonce")
            XCTAssertEqual(tokenizedCard.localizedDescription, "Visa ending in 11")
            XCTAssertEqual(tokenizedCard.lastTwo!, "11")
            XCTAssertEqual(tokenizedCard.cardNetwork, BTCardNetwork.Visa)
            expectation.fulfill()
        }
        BTVenmoDriver.handleAppSwitchReturnURL(NSURL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce")!)

        self.waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testTokenization_whenAppSwitchSucceeds_makesDelegateCallbacks() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "venmo": "production",
            "merchantId": "merchant_id" ])
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        let delegate = MockAppSwitchDelegate(willPerform: expectationWithDescription("willPerform called"), didPerform: expectationWithDescription("didPerform called"))
        delegate.willProcess = expectationWithDescription("willProcess called")
        venmoDriver.delegate = delegate
        mockAPIClient = venmoDriver.apiClient as! MockAPIClient
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()

        let expectation = self.expectationWithDescription("Callback")
        venmoDriver.tokenizeVenmoCardWithCompletion { _ -> Void in
            XCTAssertEqual(delegate.lastAppSwitcher as? BTVenmoDriver, venmoDriver)
            expectation.fulfill()
        }
        BTVenmoDriver.handleAppSwitchReturnURL(NSURL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce")!)

        self.waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testTokenization_whenAppSwitchSucceeds_postsNotifications() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "venmo": "production",
            "merchantId": "merchant_id" ])
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        let delegate = MockAppSwitchDelegate(willPerform: expectationWithDescription("willPerform called"), didPerform: expectationWithDescription("didPerform called"))
        delegate.willProcess = expectationWithDescription("willProcess called")
        venmoDriver.delegate = delegate
        mockAPIClient = venmoDriver.apiClient as! MockAPIClient
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()

        let willAppSwitchNotificationExpectation = expectationWithDescription("willAppSwitch notification received")
        observers.append(NSNotificationCenter.defaultCenter().addObserverForName(BTAppSwitchWillSwitchNotification, object: nil, queue: nil) { (notification) -> Void in
            willAppSwitchNotificationExpectation.fulfill()
            })

        let didAppSwitchNotificationExpectation = expectationWithDescription("didAppSwitch notification received")
        observers.append(NSNotificationCenter.defaultCenter().addObserverForName(BTAppSwitchDidSwitchNotification, object: nil, queue: nil) { (notification) -> Void in
            didAppSwitchNotificationExpectation.fulfill()
            })

        venmoDriver.tokenizeVenmoCardWithCompletion { _ -> Void in }

        let willProcessNotificationExpectation = expectationWithDescription("willProcess notification received")
        observers.append(NSNotificationCenter.defaultCenter().addObserverForName(BTAppSwitchWillProcessPaymentInfoNotification, object: nil, queue: nil) { (notification) -> Void in
            willProcessNotificationExpectation.fulfill()
            })

        BTVenmoDriver.handleAppSwitchReturnURL(NSURL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce")!)

        self.waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testTokenization_whenAppSwitchFails_callsBackWithError() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "venmo": "production",
            "merchantId": "merchant_id" ])
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        mockAPIClient = venmoDriver.apiClient as! MockAPIClient
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()

        let expectation = self.expectationWithDescription("Callback invoked")
        venmoDriver.tokenizeVenmoCardWithCompletion { (tokenizedCard, error) -> Void in
            guard let error = error else {
                XCTFail("Did not receive expected error")
                return
            }

            XCTAssertNil(tokenizedCard)
            XCTAssertEqual(error.domain, BTVenmoDriverErrorDomain)
            XCTAssertEqual(error.code, BTVenmoDriverErrorType.AppSwitchFailed.rawValue)
            expectation.fulfill()
        }
        BTVenmoDriver.handleAppSwitchReturnURL(NSURL(string: "scheme://x-callback-url/vzero/auth/venmo/error")!)

        self.waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testTokenization_whenAppSwitchCancelled_callsBackWithNoError() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "venmo": "production",
            "merchantId": "merchant_id" ])
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        mockAPIClient = venmoDriver.apiClient as! MockAPIClient
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()

        let expectation = self.expectationWithDescription("Callback invoked")
        venmoDriver.tokenizeVenmoCardWithCompletion { (tokenizedCard, error) -> Void in
            XCTAssertNil(tokenizedCard)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        BTVenmoDriver.handleAppSwitchReturnURL(NSURL(string: "scheme://x-callback-url/vzero/auth/venmo/cancel")!)

        self.waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    // MARK: - Analytics
    
    func testAPIClientMetadata_hasSourceSetToVenmoApp() {
        // API client by default uses source = .Unknown and integration = .Custom
        let apiClient = BTAPIClient(authorization: "development_testing_integration_merchant_id")!
        let venmoDriver = BTVenmoDriver(APIClient: apiClient)
        
        XCTAssertEqual(venmoDriver.apiClient.metadata.integration, BTClientMetadataIntegrationType.Custom)
        XCTAssertEqual(venmoDriver.apiClient.metadata.source, BTClientMetadataSourceType.VenmoApp)
    }
}