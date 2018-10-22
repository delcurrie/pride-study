//
//  CommunityViewController.h
//  Pride
//
//  Created by Patrick Krabeepetcharat on 5/13/15.
//  Copyright (c) 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ResearchKit/ResearchKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AFNetworking/AFNetworking.h>
@import HealthKit;

#import "PRIDEOrderedTask.h"
#import "PRIDEConsentOrderedTask.h"
#import "R1Emitter.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface ProfileViewController : UITableViewController <UIWebViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate, ORKTaskViewControllerDelegate, UIAlertViewDelegate, UIActionSheetDelegate>

@property (nonatomic) HKHealthStore *healthStore;

@property (nonatomic) ORKConsentDocument *document;

@property MPMoviePlayerViewController *controller;

@property ORKTaskViewController *task_demographicSurvey;

@end
