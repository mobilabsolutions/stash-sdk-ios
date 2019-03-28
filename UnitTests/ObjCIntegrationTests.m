//
//  ObjCIntegrationTests.m
//  MobilabPaymentTests
//
//  Created by Robert on 15.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

@import MobilabPaymentCore;
@import MobilabPaymentBSPayone;
@import OHHTTPStubs;

#import <XCTest/XCTest.h>

@interface ObjCIntegrationTests : XCTestCase

@end

@implementation ObjCIntegrationTests

static NSString *bsPayoneHost = @"secure.pay1.de";

- (void) testCreateConfiguration {
    MLMobilabPaymentConfiguration *configuration = [[MLMobilabPaymentConfiguration alloc]
                                                    initWithPublicKey:@"PD-BS2-nF7kU7xY8ESLgflavGW9CpUv1I" endpoint: @"https://payment-dev.mblb.net/api/v1"];

    XCTAssertFalse(configuration.loggingEnabled);

    configuration.loggingEnabled = YES;
    XCTAssertTrue(configuration.loggingEnabled);

    NSError *error = nil;
    NSURL *endpointUrl = [configuration endpointUrlAndReturnError:&error];

    XCTAssertNil(error);
    XCTAssertNotNil(endpointUrl);
}

- (void) testCreateInvalidConfiguration {
    MLMobilabPaymentConfiguration *configuration = [[MLMobilabPaymentConfiguration alloc]
                                                    initWithPublicKey:@"PD-BS2-nF7kU7xY8ESLgflavGW9CpUv1I" endpoint: @"not a url"];
    NSError *error = nil;
    NSURL *endpointUrl = [configuration endpointUrlAndReturnError:&error];

    XCTAssertNotNil(error);
    XCTAssertNil(endpointUrl);
}

- (void) testAddConfigurationAndProviderToSDK {
    MLMobilabPaymentConfiguration *configuration = [[MLMobilabPaymentConfiguration alloc]
                                                    initWithPublicKey:@"PD-BS2-nF7kU7xY8ESLgflavGW9CpUv1I" endpoint: @"https://payment-dev.mblb.net/api/v1"];

    [MLMobilabPaymentSDK configureWithConfiguration:configuration];

    MLMobilabBSPayone *bsPayone = [MLMobilabBSPayone createModule];
    [MLMobilabPaymentSDK registerProviderWithProvider:bsPayone paymentMethods:@[@"creditCard"]];

    // This should compile and *not* cause a runtime error since the SDK is now configured.
    // We don't care about the return value in this context, so we ignore it.
    (void) [MLMobilabPaymentSDK getRegistrationManager];
}

- (void) testRegisterCreditCard {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [request.URL.host isEqualToString:bsPayoneHost];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSString* fixture = OHPathForFile(@"credit_card_success.json", self.class);
        return [OHHTTPStubsResponse responseWithFileAtPath:fixture
                                                statusCode:200 headers:nil];
    }];

    MLMobilabPaymentConfiguration *configuration = [[MLMobilabPaymentConfiguration alloc]
                                                    initWithPublicKey:@"PD-BS2-nF7kU7xY8ESLgflavGW9CpUv1I" endpoint: @"https://payment-dev.mblb.net/api/v1"];

    [MLMobilabPaymentSDK configureWithConfiguration:configuration];

    MLMobilabBSPayone *bsPayone = [MLMobilabBSPayone createModule];
    [MLMobilabPaymentSDK registerProviderWithProvider:bsPayone paymentMethods:@[@"creditCard"]];

    MLBillingData *billingData = [[MLBillingData alloc] initWithEmail:nil
                                                                 name:nil
                                                             address1:nil
                                                             address2:nil
                                                                  zip:nil
                                                                 city:nil
                                                                state:nil
                                                              country:nil
                                                                phone:nil
                                                           languageId:nil];

    NSError *error;
    MLCreditCardData *creditCard = [[MLCreditCardData alloc] initWithCardNumber:@"4111 1111 1111 1111"
                                                                            cvv:@"123"
                                                                    expiryMonth:10
                                                                     expiryYear:21
                                                                     holderName:@"Max Mustermann"
                                                                    billingData:billingData
                                                                          error:&error];
    XCTAssertNotNil(creditCard);
    XCTAssertNil(error);

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Registering a credit card should not time out"];

    [[MLMobilabPaymentSDK getRegistrationManager] registerCreditCardWithCreditCardData:creditCard completion:^(NSString * _Nullable alias, MLError * _Nullable error) {
        XCTAssertNotNil(alias);
        XCTAssertNil(error);
        [expectation fulfill];
    }];

    [self waitForExpectations:@[expectation] timeout:10.0];
}

- (void) testRegisterSEPA {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [request.URL.host isEqualToString:bsPayoneHost];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSString* fixture = OHPathForFile(@"sepa_success.json", self.class);
        return [OHHTTPStubsResponse responseWithFileAtPath:fixture
                                                statusCode:200 headers:nil];
    }];

    MLMobilabPaymentConfiguration *configuration = [[MLMobilabPaymentConfiguration alloc]
                                                    initWithPublicKey:@"PD-BS2-nF7kU7xY8ESLgflavGW9CpUv1I" endpoint: @"https://payment-dev.mblb.net/api/v1"];

    [MLMobilabPaymentSDK configureWithConfiguration:configuration];

    MLMobilabBSPayone *bsPayone = [MLMobilabBSPayone createModule];
    [MLMobilabPaymentSDK registerProviderWithProvider:bsPayone paymentMethods:@[@"sepa"]];

    MLBillingData *billingData = [[MLBillingData alloc] initWithEmail:nil
                                                                 name:@"Max Mustermann"
                                                             address1:nil
                                                             address2:nil
                                                                  zip:nil
                                                                 city:nil
                                                                state:nil
                                                              country:@"DE"
                                                                phone:nil
                                                           languageId:[[NSLocale currentLocale] languageCode]];

    NSError *error;
    MLSEPAData * sepaData = [[MLSEPAData alloc] initWithIban:@"DE75512108001245126199" bic:@"COLSDE33XXX" billingData:billingData error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(sepaData);

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Registering a SEPA account should not time out"];

    [[MLMobilabPaymentSDK getRegistrationManager] registerSEPAAccountWithSepaData:sepaData completion:^(NSString * _Nullable alias, MLError * _Nullable error) {
        XCTAssertNotNil(alias);
        XCTAssertNil(error);
        // These are nil, since error is nil. We want to make sure that we can access these values, though (that the code compiles).
        XCTAssertNil([error failureReason]);
        XCTAssertTrue([error code] == (long)nil);
        [expectation fulfill];
    }];

    [self waitForExpectations:@[expectation] timeout:10.0];
}

- (void) testNilifiesInvalidCreditCardAndSEPAData {
    MLBillingData *billingData = [[MLBillingData alloc] initWithEmail:nil
                                                                 name:@"Max Mustermann"
                                                             address1:nil
                                                             address2:nil
                                                                  zip:nil
                                                                 city:nil
                                                                state:nil
                                                              country:@"DE"
                                                                phone:nil
                                                           languageId:[[NSLocale currentLocale] languageCode]];

    NSError *error;
    MLCreditCardData *creditCard = [[MLCreditCardData alloc] initWithCardNumber:@"4511 1511 1511 1511"
                                                                            cvv:@"123"
                                                                    expiryMonth:10
                                                                     expiryYear:21
                                                                     holderName:@"Max Mustermann"
                                                                    billingData:billingData
                                                                          error:&error];
    XCTAssertNotNil(error);
    XCTAssertNil(creditCard);

    MLSEPAData *sepaData = [[MLSEPAData alloc] initWithIban:@"DE75534348001245126145" bic:@"COLSDE33XXX" billingData:billingData error:&error];
    XCTAssertNil(sepaData);
    XCTAssertNotNil(error);
}

@end
