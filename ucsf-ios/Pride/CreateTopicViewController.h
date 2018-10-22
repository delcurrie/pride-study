//
//  CreateTopicViewController.h
//  Pride
//
//  Created by Analog Republic on 11/12/15.
//  Copyright © 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KTTextView.h"
@interface CreateTopicViewController : UIViewController<UITextViewDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet KTTextView *whyTextView;
@property (weak, nonatomic) IBOutlet UITableView *tableV;
@property (weak, nonatomic) IBOutlet UITextField *topicTextView;
@property (weak, nonatomic) IBOutlet UIView *topicContainerView;
@property (weak, nonatomic) IBOutlet UIView *whyContainerView;
- (IBAction)submitPressed:(id)sender;

@end
