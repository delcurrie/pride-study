//
//  ActivitiesViewController.h
//  Pride
//
//  Created by Patrick Krabeepetcharat on 5/13/15.
//  Copyright (c) 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ResearchKit/ResearchKit.h>
#import <AFNetworking/AFNetworking.h>
#import "UIColor+constants.h"
#import "PRIDEOrderedTask.h"
#import "ActivitiesHeaderTableViewCell.h"
#import "AppConstants.h"
#import "R1Emitter.h"
#import "GAITrackedViewController.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface ActivitiesViewController : GAITrackedViewController <ORKTaskViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property NSMutableArray *activeTitles;
@property NSMutableArray *activeImageNames;
@property NSMutableArray *activeIdentifiers;

@property NSMutableArray *inactiveTitles;
@property NSMutableArray *inactiveImageNames;
@property NSMutableArray *inactiveIdentifiers;

@property ORKTaskViewController *task_demographicSurvey;
@property ORKTaskViewController *task_communityCreateScreenName;
@property ORKTaskViewController *task_communityCreateTopic;
@property ORKTaskViewController *task_communityReviewTopics;
@property ORKTaskViewController *task_communityVoteOnTopics;
@property ORKTaskViewController *task_communityCommentOnTopics;

@end
