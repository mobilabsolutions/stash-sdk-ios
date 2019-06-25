//
//  ObjCIntegrationTests.m
//  MobilabPaymentTests
//
//  Created by Robert on 15.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

@import Foundation;
@import MobilabPaymentCore;
@import MobilabPaymentBSPayone;
@import OHHTTPStubs;

#import "MobilabPaymentTests-Swift.h"
#import <XCTest/XCTest.h>

@interface ObjCIntegrationTests : XCTestCase

@end

@implementation ObjCIntegrationTests

static NSString *bsPayoneHost = @"secure.pay1.de";

- (void)setUp {
    [super setUp];
    [SDKResetter resetMobilabSDK];
}

- (void)tearDown {
    [super tearDown];
    [OHHTTPStubs removeAllStubs];
    [SDKResetter resetMobilabSDK];
}

- (void) testCreateConfiguration {
    MLMobilabPaymentConfiguration *configuration = [[MLMobilabPaymentConfiguration alloc]
                                                    initWithPublicKey:@"mobilab-D4eWavRIslrUCQnnH6cn"
                                                    endpoint: @"https://payment-dev.mblb.net/api/v1"
                                                    integrations: @[]
                                                    uiConfiguration:nil];

    XCTAssertFalse(configuration.loggingEnabled, @"Logging should not be enabled when creating a new configuration");

    configuration.loggingEnabled = YES;
    configuration.useTestMode = YES;
    XCTAssertTrue(configuration.loggingEnabled, @"Logging should be enabled after explicitely setting it to true");
}

- (void) testAddConfigurationAndProviderToSDK {
    MLPaymentProvider *bsPayone = [MLMobilabBSPayone createModule];

    NSSet<NSNumber *> *paymentMethodTypes = [[NSSet alloc] initWithObjects:[NSNumber numberWithInteger:MLPaymentMethodTypeCreditCard], nil];
    MLPaymentProviderIntegration *integration = [[MLPaymentProviderIntegration alloc] initWithPaymentServiceProvider: bsPayone
                                                                                                  paymentMethodTypes: paymentMethodTypes];
    MLMobilabPaymentConfiguration *configuration = [[MLMobilabPaymentConfiguration alloc]
                                                    initWithPublicKey:@"mobilab-D4eWavRIslrUCQnnH6cn" endpoint: @"https://payment-dev.mblb.net/api/v1"
                                                    integrations: @[ integration ]
                                                    uiConfiguration:nil];

    [MLMobilabPaymentSDK initializeWithConfiguration:configuration];

    // This should compile and *not* cause a runtime error since the SDK is now configured.
    // We don't care about the return value in this context, so we ignore it.
    (void) [MLMobilabPaymentSDK getRegistrationManager];
}

- (void) testRegisterCreditCardBSPayone {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [request.URL.host isEqualToString:bsPayoneHost];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSString* fixture = OHPathForFile(@"bs_credit_card_success.json", self.class);
        return [OHHTTPStubsResponse responseWithFileAtPath:fixture
                                                statusCode:200 headers:nil];
    }];

    MLPaymentMethodUIConfiguration *uiConfiguration = [[MLPaymentMethodUIConfiguration alloc] initWithBackgroundColor:nil
                                                                                                            textColor:nil
                                                                                                          buttonColor:[UIColor blueColor] mediumEmphasisColor:nil
                                                                                                  cellBackgroundColor:nil
                                                                                                      buttonTextColor:nil
                                                                                                  buttonDisabledColor:nil
                                                                                                    errorMessageColor:nil
                                                                                                errorMessageTextColor:nil];

    MLPaymentProvider *bsPayone = [MLMobilabBSPayone createModule];

    NSSet<NSNumber *> *paymentMethodTypes = [[NSSet alloc] initWithObjects:[NSNumber numberWithInteger:MLPaymentMethodTypeCreditCard], nil];
    MLPaymentProviderIntegration *integration = [[MLPaymentProviderIntegration alloc] initWithPaymentServiceProvider: bsPayone
                                                                                                  paymentMethodTypes: paymentMethodTypes];
    MLMobilabPaymentConfiguration *configuration = [[MLMobilabPaymentConfiguration alloc]
                                                    initWithPublicKey:@"mobilab-D4eWavRIslrUCQnnH6cn" endpoint: @"https://payment-dev.mblb.net/api/v1"
                                                    integrations: @[ integration ]
                                                    uiConfiguration:uiConfiguration];

    [MLMobilabPaymentSDK initializeWithConfiguration:configuration];

    NSError *error;
    
    MLSimpleNameProvider *name = [[MLSimpleNameProvider alloc] initWithFirstName: @"Max" lastName: @"Mustermann"];
    MLBillingData *billingData = [[MLBillingData alloc] initWithEmail:nil
                                                                 name:name
                                                             address1:nil
                                                             address2:nil
                                                                  zip:nil
                                                                 city:nil
                                                                state:nil
                                                              country:nil
                                                                phone:nil
                                                           languageId:nil
                                                              basedOn:nil];

    MLCreditCardData *creditCard = [[MLCreditCardData alloc] initWithCardNumber:@"4111 1111 1111 1111"
                                                                            cvv:@"123"
                                                                    expiryMonth:10
                                                                     expiryYear:21
                                                                        country: @"DE"
                                                                    billingData:billingData
                                                                          error:&error];

    XCTAssertNotNil(creditCard, @"Creating a credit card from valid data should return valid credit card data");
    XCTAssertNil(error, @"Creating a credit card from valid data should not return an error but got %@", error);

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Registering a credit card should not time out"];

    [[MLMobilabPaymentSDK getRegistrationManager] registerCreditCardWithCreditCardData:creditCard
                                                                        idempotencyKey: [[NSUUID new] UUIDString]
                                                                            completion:^(MLPaymentMethodAlias * _Nullable registration, MLError * _Nullable error) {
        XCTAssertNotNil(registration, @"A registration should be returned when registering a valid credit card");
        XCTAssertNil(error, @"There should not be an error when registering a valid credit card but got %@", error);
        [expectation fulfill];
    }];

    [self waitForExpectations:@[expectation] timeout:10.0];
}

- (void) testRegisterSEPABSPayone {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [request.URL.host isEqualToString:bsPayoneHost];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSString* fixture = OHPathForFile(@"bs_sepa_success.json", self.class);
        return [OHHTTPStubsResponse responseWithFileAtPath:fixture
                                                statusCode:200 headers:nil];
    }];

    MLPaymentProvider *bsPayone = [MLMobilabBSPayone createModule];

    NSSet<NSNumber *> *paymentMethodTypes = [[NSSet alloc] initWithObjects:[NSNumber numberWithInteger:MLPaymentMethodTypeSepa], nil];
    MLPaymentProviderIntegration *integration = [[MLPaymentProviderIntegration alloc] initWithPaymentServiceProvider: bsPayone
                                                                                                  paymentMethodTypes: paymentMethodTypes];
    MLMobilabPaymentConfiguration *configuration = [[MLMobilabPaymentConfiguration alloc]
                                                    initWithPublicKey:@"mobilab-D4eWavRIslrUCQnnH6cn" endpoint: @"https://payment-dev.mblb.net/api/v1"
                                                    integrations: @[ integration ]
                                                    uiConfiguration:nil];

    [MLMobilabPaymentSDK initializeWithConfiguration:configuration];

    MLSimpleNameProvider *name = [[MLSimpleNameProvider alloc] initWithFirstName: @"Max" lastName: @"Mustermann"];

    MLBillingData *billingData = [[MLBillingData alloc] initWithEmail:nil
                                                                 name:name
                                                             address1:nil
                                                             address2:nil
                                                                  zip:nil
                                                                 city:nil
                                                                state:nil
                                                              country:@"DE"
                                                                phone:nil
                                                           languageId:[[NSLocale currentLocale] languageCode]
                                                              basedOn: nil];

    NSError *error;
    MLSEPAData * sepaData = [[MLSEPAData alloc] initWithIban:@"DE75512108001245126199" bic:@"COLSDE33XXX" billingData:billingData error:&error];
    XCTAssertNil(error, @"There should not be an error when creating valid SEPA data but got %@", error);
    XCTAssertNotNil(sepaData, @"Creating valid SEPA data should return said data and not nil");

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Registering a SEPA account should not time out"];

    [[MLMobilabPaymentSDK getRegistrationManager] registerSEPAAccountWithSepaData:sepaData
                                                                   idempotencyKey:[[NSUUID new] UUIDString]
                                                                       completion:^(MLPaymentMethodAlias * _Nullable registration, MLError * _Nullable error) {
        XCTAssertNotNil(registration, @"Registering a valid SEPA method should return a registration");
        XCTAssertNotNil(registration.alias, @"The alias should not be nil when registering with BS Payone");
        XCTAssertNil(error, @"Registering a valid SEPA method should not return any error but got %@", error);
        // These are nil, since error is nil. We want to make sure that we can access these values, though (that the code compiles).
        XCTAssertNil([error description]);
        [expectation fulfill];
    }];

    [self waitForExpectations:@[expectation] timeout:10.0];
}

- (void) testNilifiesInvalidCreditCardAndSEPAData {
    MLSimpleNameProvider *name = [[MLSimpleNameProvider alloc] initWithFirstName: @"Max" lastName: @"Mustermann"];

    MLBillingData *billingData = [[MLBillingData alloc] initWithEmail:nil
                                                                 name:name
                                                             address1:nil
                                                             address2:nil
                                                                  zip:nil
                                                                 city:nil
                                                                state:nil
                                                              country:@"DE"
                                                                phone:nil
                                                           languageId:[[NSLocale currentLocale] languageCode]
                                                              basedOn: nil];

    NSError *error;
    
    MLCreditCardData *creditCard = [[MLCreditCardData alloc] initWithCardNumber:@"4511 1511 1511 1511"
                                                                            cvv:@"123"
                                                                    expiryMonth:10
                                                                     expiryYear:21
                                                                    country: @"DE"
                                                                    billingData:billingData
                                                                          error:&error];
    XCTAssertNotNil(error);
    XCTAssertNil(creditCard);

    MLSEPAData *sepaData = [[MLSEPAData alloc] initWithIban:@"DE75534348001245126145" bic:@"COLSDE33XXX" billingData:billingData error:&error];
    XCTAssertNil(sepaData, @"Creating invalid SEPA data should return nil");
    XCTAssertNotNil(error, @"Creating invalid SEPA data should return an error");
}

@end
