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
    [MLMobilabPaymentSDK addProviderWithProvider:[MLMobilabBSPayone createModuleWithPublicKey:@"PD-BS2-nF7kU7xY8ESLgflavGW9CpUv1I"]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [[MLMobilabPaymentSDK getRegisterManager] registerPaymentMethodUsingUIOn:self completion:^(NSString * _Nullable alias, MLError * _Nullable error) {
        if (alias != nil) {
            NSLog(@"Got alias: %@", alias);
        }
        else {
            NSLog(@"Got error: %@", [error failureReason]);
        }
    }];
}

@end
