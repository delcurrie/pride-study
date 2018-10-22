//
//  PermissionsViewController.h
//  Pride
//
//  Created by Patrick Krabeepetcharat on 6/2/15.
//  Copyright (c) 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "UIColor+constants.h"
#import "TabBarViewController.h"
#import "R1Emitter.h"
#import "GAITrackedViewController.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface PermissionsViewController : GAITrackedViewController <CLLocationManagerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UIButton *btn_allowLocation;
@property (weak, nonatomic) IBOutlet UIButton *btn_allowNotifications;

@property (weak, nonatomic) IBOutlet UILabel *desc_location;
@property (weak, nonatomic) IBOutlet UILabel *desc_notifications;

- (IBAction)handler_allowLocation:(id)sender;
- (IBAction)handler_allowNotifications:(id)sender;

@end
