//
//  YouAreNotEligibleViewController.h
//  pride
//
//  Created by Patrick Krabeepetcharat on 5/18/15.
//  Copyright (c) 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+constants.h"
#import "R1Emitter.h"
#import "GAITrackedViewController.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface YouAreNotEligibleViewController : GAITrackedViewController

@property (weak, nonatomic) IBOutlet UIButton *btn_learnMore;

- (IBAction)learn_more:(id)sender;

@end
