//
//  FailedQuizViewController.h
//  pride
//
//  Created by Patrick Krabeepetcharat on 5/19/15.
//  Copyright (c) 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YouAreEligibleViewController.h"
#import "R1Emitter.h"
#import "GAITrackedViewController.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface FailedQuizViewController : GAITrackedViewController

@property (weak, nonatomic) IBOutlet UIButton *btn_next;

- (IBAction)retry:(id)sender;
- (IBAction)gotoIntro:(id)sender;

@end
