//
//  WelcomeViewController.h
//  Pride
//
//  Created by Patrick Krabeepetcharat on 5/6/15.
//  Copyright (c) 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MediaPlayer/MediaPlayer.h>
#import "UIColor+constants.h"
#import "PRIDEUserAuthentication.h"
#import "R1Emitter.h"
#import "GAITrackedViewController.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface IntroViewController : GAITrackedViewController <UIScrollViewAccessibilityDelegate, UIWebViewDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *btn_joinStudy;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end