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
                                                  initWithPublicKey:@"PD-BS2-nF7kU7xY8ESLgflavGW9CpUv1I" endpoint:@"https://payment-dev.mblb.net/api/v1"];
    [MLMobilabPaymentSDK configureWithConfiguration:configuration];
    
    MLMobilabBSPayone *pspBsPayone = [MLMobilabBSPayone createModuleWithPublicKey:@"PD-BS2-nF7kU7xY8ESLgflavGW9CpUv1I"];
    [MLMobilabPaymentSDK registerProviderWithProvider:pspBsPayone paymentMethods:@[@"creditCard", @"sepa"]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    __weak typeof(self) weakSelf = self;
    
    [[MLMobilabPaymentSDK getRegisterManager] registerPaymentMethodUsingUIOn:self completion:^(NSString * _Nullable alias, MLError * _Nullable error) {
        if (alias != nil) {
            NSLog(@"Got alias: %@", alias);
            [weakSelf dismissViewControllerAnimated:YES completion:^{
                [weakSelf showAlertWithTitle:@"Success" andBody:@"Successfully registered payment method"];
            }];
        }
        else {
            NSLog(@"Got error: %@", [error failureReason]);
            [weakSelf dismissViewControllerAnimated:YES completion:^{
                NSString *errorMessage = [NSString stringWithFormat:@"Failed to register payment method: %@", [error failureReason]];
                [weakSelf showAlertWithTitle:@"Failure" andBody:errorMessage];
            }];
        }
    }];
}

- (void) showAlertWithTitle: (NSString *)title andBody: (NSString *)body {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:body preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
