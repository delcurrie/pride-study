//
//  RegistrationViewController.h
//  Pride
//
//  Created by Patrick Krabeepetcharat on 5/22/15.
//  Copyright (c) 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>
#import "AppDelegate.h"
#import "AppConstants.h"
#import "HKHealthStore+AAPLExtensions.h"
#import "R1Emitter.h"
#import "GAITrackedViewController.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "IQDropDownTextField.h"
@import HealthKit;

@interface RegistrationViewController : GAITrackedViewController <UITextFieldDelegate,IQDropDownTextFieldDelegate>

@property (nonatomic) HKHealthStore *healthStore;
@property (weak, nonatomic) IBOutlet UITextField *textField_zip;

@property (weak, nonatomic) IBOutlet UITextField *textField_name;
@property (weak, nonatomic) IBOutlet UITextField *textField_email;
@property (weak, nonatomic) IBOutlet UITextField *textField_password;
@property (weak, nonatomic) IBOutlet IQDropDownTextField *birthdayField;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (weak, nonatomic) IBOutlet UIImageView *img_validZip;

@property (weak, nonatomic) IBOutlet UIImageView *img_validName;
@property (weak, nonatomic) IBOutlet UIImageView *img_validEmail;
@property (weak, nonatomic) IBOutlet UIImageView *img_validPassword;
@property (weak, nonatomic) IBOutlet UIImageView *img_validBirthday;

@end
