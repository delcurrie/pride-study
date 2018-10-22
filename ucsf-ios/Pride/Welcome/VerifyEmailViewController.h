//
//  VerifyEmailViewController.h
//  Pride
//
//  Created by Patrick Krabeepetcharat on 5/22/15.
//  Copyright (c) 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>
#import "AppConstants.h"
#import "UIColor+constants.h"
#import "MBProgressHUD.h"
#import "RegistrationViewController.h"
#import "R1Emitter.h"
#import "GAITrackedViewController.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface VerifyEmailViewController : GAITrackedViewController

@property (weak, nonatomic) IBOutlet UILabel *label_email;
@property (weak, nonatomic) IBOutlet UIButton *btn_continue;

@property (weak, nonatomic) IBOutlet UILabel *label_desc;

- (IBAction)wrongEmail:(id)sender;

- (IBAction)continue:(id)sender;

@end
