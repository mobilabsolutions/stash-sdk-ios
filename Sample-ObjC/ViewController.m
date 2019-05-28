//
//  ViewController.m
//  Demo-ObjC
//
//  Created by Robert on 14.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

@import MobilabPaymentCore;
@import MobilabPaymentBSPayone;
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    MLMobilabPaymentConfiguration *configuration = [[MLMobilabPaymentConfiguration alloc]
                                                  initWithPublicKey:@"mobilab-D4eWavRIslrUCQnnH6cn" endpoint:@"https://payment-dev.mblb.net/api/v1" uiConfiguration:nil];
    [configuration setUseTestMode:YES];
    [configuration setLoggingEnabled:YES];

    [MLMobilabPaymentSDK initializeWithConfiguration:configuration];

    MLMobilabBSPayone *pspBsPayone = [MLMobilabBSPayone createModule];
    [MLMobilabPaymentSDK registerProviderWithProvider:pspBsPayone paymentMethods:@[@"creditCard", @"sepa"]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    MLPaymentMethodUIConfiguration *configuration = [[MLPaymentMethodUIConfiguration alloc] initWithBackgroundColor:[UIColor blackColor]
                                                                                                          textColor:[UIColor whiteColor]
                                                                                                        buttonColor:nil
                                                                                                mediumEmphasisColor:[UIColor lightTextColor]
                                                                                                cellBackgroundColor:[UIColor darkGrayColor] buttonTextColor:nil
                                                                                                buttonDisabledColor: [[UIColor whiteColor]
                                                                                                                      colorWithAlphaComponent: 0.4]
                                                                                                  errorMessageColor:nil errorMessageTextColor:nil];

    [MLMobilabPaymentSDK configureUIWithConfiguration:configuration];

    __weak typeof(self) weakSelf = self;
    [[MLMobilabPaymentSDK getRegistrationManager] registerPaymentMethodUsingUIOn:self
                                                           specificPaymentMethod: MLPaymentMethodTypeNone
                                                                     billingData: nil
                                                                  idempotencyKey: [[NSUUID new] UUIDString]
                                                                      completion:^(MLRegistration * _Nullable registration, MLError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (registration != nil) {
                NSLog(@"Got alias: %@", registration.alias);
                [weakSelf showAlertWithTitle:@"Success" andBody:@"Successfully registered payment method"
                            onViewController:[self presentedViewController]];
            }
            else {
                NSLog(@"Got error: %@", [error description]);
                [weakSelf showAlertWithTitle:@"Error" andBody:[NSString stringWithFormat:@"%@", [error description]]
                            onViewController:[self presentedViewController]];
            }
        });
    }];
}

- (void) showAlertWithTitle: (NSString *)title andBody: (NSString *)body onViewController: (UIViewController *)viewController {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:body preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    [viewController presentViewController:alert animated:YES completion:nil];
}

@end
