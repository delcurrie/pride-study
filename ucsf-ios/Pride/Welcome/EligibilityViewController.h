//
//  EligibilityViewController.h
//  Pride
//
//  Created by Patrick Krabeepetcharat on 5/8/15.
//  Copyright (c) 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+constants.h"
#import "R1Emitter.h"
#import "GAITrackedViewController.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface EligibilityViewController : GAITrackedViewController <UIWebViewDelegate>

@property (nonatomic, assign) BOOL isComplete;
@property (nonatomic, assign) BOOL isEligible;

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end 