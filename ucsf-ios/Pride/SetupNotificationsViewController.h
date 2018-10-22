//
//  CreateTopicViewController.h
//  Pride
//
//  Created by Analog Republic on 11/12/15.
//  Copyright © 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KTTextView.h"
@interface SetupNotificationsViewController : UIViewController<UITextViewDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UITableView *tableV;
- (IBAction)submitPressed:(id)sender;

@end
