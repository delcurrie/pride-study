//
//  AppDelegate.h
//  Pride
//
//  Created by Patrick Krabeepetcharat on 5/6/15.
//  Copyright (c) 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>
#import "UIColor+constants.h"
#import "AppConstants.h"

#import "R1SDK.h"
#import "R1Emitter.h"

#import "GAI.h"
#import "Reachability.h"

@import HealthKit;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) Reachability *networkReachability;
@property (nonatomic) HKHealthStore *healthStore;
-(void)updateUserInfo;
- (void)update_user_data;
-(void)getHealthkitData;
-(void)noInternetConnectionPopup;
@end

