//
//  YouAreEligibleViewController.h
//  Pride
//
//  Created by Patrick Krabeepetcharat on 5/8/15.
//  Copyright (c) 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <ResearchKit/ResearchKit.h>
#import "AppConstants.h"
#import "UIColor+constants.h"
#import "PRIDEConsentOrderedTask.h"
#import "R1Emitter.h"
#import "GAITrackedViewController.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface YouAreEligibleViewController : GAITrackedViewController <ORKTaskViewControllerDelegate>

@property (nonatomic) ORKConsentDocument *document;

@property (weak, nonatomic) IBOutlet UIButton *btn_startConsent;

- (IBAction)startConsent:(id)sender;

@end
