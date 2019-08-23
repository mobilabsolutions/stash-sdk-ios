//
//  ViewController.m
//  Demo-ObjC
//
//  Created by Robert on 14.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

@import StashCore;
@import StashBSPayone;
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    MLPaymentProvider *pspBsPayone = [MLStashBSPayone createModule];
    NSSet<NSNumber *> *paymentMethodTypes = [NSSet setWithObjects:[NSNumber numberWithLong:MLPaymentMethodTypeCreditCard],
                                             [NSNumber numberWithLong:MLPaymentMethodTypeSepa], nil];
    MLPaymentProviderIntegration *integration = [[MLPaymentProviderIntegration alloc] initWithPaymentServiceProvider:pspBsPayone
                                                                                                  paymentMethodTypes:paymentMethodTypes];

    MLStashConfiguration *configuration = [[MLStashConfiguration alloc]
                                                  initWithPublishableKey:@"mobilabios-3FkSmKQ0sUmzDqxciqRF"
                                                    endpoint:@"https://payment-dev.mblb.net/api/v1"
                                                    integrations: @[integration]
                                                    uiConfiguration:nil];
    [configuration setUseTestMode:YES];
    [configuration setLoggingLevel:LoggingLevelNormal];

    [MLStash initializeWithConfiguration:configuration];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    MLStashPaymentMethodUIConfiguration *configuration = [[MLStashPaymentMethodUIConfiguration alloc] initWithBackgroundColor:[UIColor blackColor]
                                                                                                          textColor:[UIColor whiteColor]
                                                                                                        buttonColor:nil
                                                                                                mediumEmphasisColor:[UIColor lightTextColor]
                                                                                                cellBackgroundColor:[UIColor darkGrayColor] buttonTextColor:nil
                                                                                                buttonDisabledColor: [[UIColor whiteColor]
                                                                                                                      colorWithAlphaComponent: 0.4]
                                                                                                  errorMessageColor:nil errorMessageTextColor:nil];

    [MLStash configureUIWithConfiguration:configuration];

    __weak typeof(self) weakSelf = self;
    [[MLStash getRegistrationManager] registerPaymentMethodUsingUIOn:self
                                                           specificPaymentMethod: MLPaymentMethodTypeNone
                                                                     billingData: nil
                                                                      completion:^(MLPaymentMethodAlias * _Nullable registration, MLError * _Nullable error) {
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
