//
//  GenderIdentityTableViewController.h
//  Pride
//
//  Created by Patrick Krabeepetcharat on 6/10/15.
//  Copyright (c) 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ResearchKit/ResearchKit.h>
#import <AFNetworking/AFNetworking.h>

#import "PRIDEOrderedTask.h"

#import "AppConstants.h"
#import "R1Emitter.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface GenderIdentityTableViewController : UITableViewController

@property ORKTaskViewController *task_demographicSurvey;

@end
