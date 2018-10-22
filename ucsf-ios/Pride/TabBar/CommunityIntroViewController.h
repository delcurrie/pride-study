//
//  CommunityIntroViewController.h
//  Pride
//
//  Created by Patrick Krabeepetcharat on 5/18/15.
//  Copyright (c) 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+constants.h"
#import "AppConstants.h"
#import "R1Emitter.h"
#import "GAITrackedViewController.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface CommunityIntroViewController : GAITrackedViewController <UIScrollViewAccessibilityDelegate, UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (weak, nonatomic) IBOutlet UIButton *btn_community;
@property (weak, nonatomic) IBOutlet UIButton *btn_register;
@property (weak, nonatomic) IBOutlet UIButton *btn_signin;

- (IBAction)handler_community:(id)sender;
- (IBAction)handler_register:(id)sender;
- (IBAction)handler_signin:(id)sender;

@end
