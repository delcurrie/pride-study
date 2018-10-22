//
//  CreateScreenNameViewController.h
//  Pride
//
//  Created by Analog Republic on 11/12/15.
//  Copyright © 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"
@interface CreateScreenNameViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *screenNameField;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
- (IBAction)submit:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollV;

@end
