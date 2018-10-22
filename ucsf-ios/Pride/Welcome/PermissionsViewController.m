//
//  PermissionsViewController.m
//  Pride
//
//  Created by Patrick Krabeepetcharat on 6/2/15.
//  Copyright (c) 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import "PermissionsViewController.h"
#import "AppConstants.h"
#import "AppDelegate.h"
@interface PermissionsViewController ()

@end

@implementation PermissionsViewController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self updatePermissionStates];
    
    // RadiumOne Tracking
    [[R1Emitter sharedInstance] emitScreenViewWithDocumentTitle:@"Permissions"
                                             contentDescription:nil
                                            documentLocationUrl:nil
                                               documentHostName:nil
                                                   documentPath:nil
                                                      otherInfo:nil];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Permissions"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIViewController *previousViewController = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    
    // if it's not being shown from the TabBar (profile) view, then show the next button
    if(![previousViewController isKindOfClass:[TabBarViewController class]]){
        // Set up Nav Bar
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.navigationItem setTitle:@"Permissions"];
        UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(handler_next)];
        [self.navigationItem setRightBarButtonItem:nextButton];
    }
    
    // Stylize Buttons
    self.btn_allowLocation.layer.cornerRadius = 5.0f;
    self.btn_allowLocation.layer.borderWidth = 1.0f;
    self.btn_allowLocation.layer.borderColor = [[UIColor primaryColor]CGColor];
    [self.btn_allowLocation setTitleColor:[UIColor primaryColor] forState:UIControlStateNormal];
    
    self.btn_allowNotifications.layer.cornerRadius = 5.0f;
    self.btn_allowNotifications.layer.borderWidth = 1.0f;
    self.btn_allowNotifications.layer.borderColor = [[UIColor primaryColor]CGColor];
    [self.btn_allowNotifications setTitleColor:[UIColor primaryColor] forState:UIControlStateNormal];
    
    // Scale the labels to fit
    [self.desc_location sizeToFit];
    [self.desc_notifications sizeToFit];
    
    // Ask for notification permission
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    // Update when entering re-entering app
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatePermissionStates)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
    
    
    AppDelegate* appD = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appD updateUserInfo];
    [appD update_user_data];
    
    
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    [self updatePermissionStates];
}

- (void)updatePermissionStates{
    // Check for Location Permission
    if([CLLocationManager locationServicesEnabled]){
        if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied ||
           [CLLocationManager authorizationStatus]==kCLAuthorizationStatusRestricted){
            
            NSLog(@"Location Services NOT Authorized: %d", [CLLocationManager authorizationStatus]);
            
            [self setLocationGranted:NO];
            
        }else if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorizedAlways){
            NSLog(@"Authorized Always");
            [[NSUserDefaults standardUserDefaults] setBool:true forKey:USER_LOCATION_SETTING];

            [self setLocationGranted:YES];
        }
    }
    
    // Check for Notification Permission
    UIUserNotificationSettings *grantedSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    
    if (grantedSettings.types == UIUserNotificationTypeNone) {
        NSLog(@"Notification Permissions NOT Granted");
        [self setNotificationsGranted:NO];
    }
    else if (grantedSettings.types  & UIUserNotificationTypeAlert){
        [self setNotificationsGranted:YES];
    }
}

- (void)handler_next{
    // Do registration stuff here
    
    [self performSegueWithIdentifier:@"Verify" sender:self];
}

- (void)setLocationGranted:(bool)granted{
    if(granted){
        
        self.btn_allowLocation.layer.borderColor = [[UIColor grayColor] CGColor];
        [self.btn_allowLocation setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.btn_allowLocation setTitle:@"Granted" forState:UIControlStateNormal];
        [self.btn_allowLocation setEnabled:NO];
    }else{
        self.btn_allowLocation.layer.borderColor = [[UIColor primaryColor] CGColor];
        [self.btn_allowLocation setTitleColor:[UIColor primaryColor] forState:UIControlStateNormal];
        [self.btn_allowLocation setTitle:@"Allow" forState:UIControlStateNormal];
        [self.btn_allowLocation setEnabled:YES];
    }
}

- (void)setNotificationsGranted:(bool) granted{
    if(granted){
        self.btn_allowNotifications.layer.borderColor = [[UIColor grayColor] CGColor];
        [self.btn_allowNotifications setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.btn_allowNotifications setTitle:@"Granted" forState:UIControlStateNormal];
        [self.btn_allowNotifications setEnabled:NO];
    }else{
        self.btn_allowNotifications.layer.borderColor = [[UIColor primaryColor] CGColor];
        [self.btn_allowNotifications setTitleColor:[UIColor primaryColor] forState:UIControlStateNormal];
        [self.btn_allowNotifications setTitle:@"Allow" forState:UIControlStateNormal];
        [self.btn_allowNotifications setEnabled:YES];
    }
}

#pragma mark Button Actions
- (IBAction)handler_allowLocation:(id)sender {
    
    if(!self.locationManager){
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        [self.locationManager requestAlwaysAuthorization];
        
        [self.locationManager startUpdatingLocation];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Permission"
                                                        message:@"Please visit your device settings to enable location permissions for PRIDE Study."
                                                       delegate:self
                                              cancelButtonTitle:@"Settings"
                                              otherButtonTitles:@"Dismiss", nil];
        [alert show];
    }
}

- (IBAction)handler_allowNotifications:(id)sender {
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Permission"
                                                    message:@"Please visit your device settings to enable notification permissions for PRIDE Study."
                                                   delegate:self
                                          cancelButtonTitle:@"Settings"
                                          otherButtonTitles:@"Dismiss", nil];
    [alert show];
}

#pragma mark Alert View Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView.title isEqualToString:@"Permission"]){
        if(buttonIndex == 0){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
}

@end
