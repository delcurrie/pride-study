//
//  ForgotPasswordViewController.h
//  Pride
//
//  Created by Analog Republic on 6/10/15.
//  Copyright (c) 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "R1Emitter.h"
#import "GAITrackedViewController.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface ResetEmailViewController : GAITrackedViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *emailSentLabel;
@property (weak, nonatomic) IBOutlet UIButton *resetPasswordButton;
- (IBAction)resetPassword:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) NSString *emailTxt;

@end
