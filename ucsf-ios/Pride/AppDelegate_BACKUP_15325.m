//
//  AppDelegate.m
//  Pride
//
//  Created by Patrick Krabeepetcharat on 5/6/15.
//  Copyright (c) 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import "AppDelegate.h"
#import "LockScreenViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Initialize Health Store
    self.healthStore = [[HKHealthStore alloc] init];
    [[NSUserDefaults standardUserDefaults] setBool:true forKey:STATE_SHOW_PIN_POPUP];

    // Should conditionally take you to Welcome screen here
    UIStoryboard *storyboard;
    UIViewController *rootViewController;
    
    if([[NSUserDefaults standardUserDefaults] valueForKey:STATE_CONSENT_COMPLETE]){
        storyboard = [UIStoryboard storyboardWithName:@"TabBar" bundle:nil];
        rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarNavigationController"];
    }else{
        storyboard = [UIStoryboard storyboardWithName:@"Welcome" bundle:nil];
        rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"WelcomeNavigationController"];
    }
    
    //// TEST ////
//    storyboard = [UIStoryboard storyboardWithName:@"TabBar" bundle:nil];
//    rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarNavigationController"];
//    storyboard = [UIStoryboard storyboardWithName:@"Welcome" bundle:nil];
//    rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"WelcomeNavigationController"];
    
    self.window.rootViewController = rootViewController;
    
    // Set the tint color for the entire app
    [self.window setTintColor:[UIColor primaryColor]];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[NSUserDefaults standardUserDefaults] setBool:true forKey:STATE_SHOW_PIN_POPUP];
    
    [[NSUserDefaults standardUserDefaults]  setObject:[NSDate date] forKey:STATE_EXIT_TIME];


}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if([[[NSUserDefaults standardUserDefaults] objectForKey:STATE_CONSENT_COMPLETE]boolValue]==true)
    {
    NSDate* exittime=[[NSUserDefaults standardUserDefaults] objectForKey:STATE_EXIT_TIME];
    
        if(exittime)
        {
            NSInteger minutes = [[[NSCalendar currentCalendar] components:NSCalendarUnitMinute fromDate:exittime toDate:[NSDate date] options:0] minute];

           
            NSString* autolockTime=[[NSUserDefaults standardUserDefaults] objectForKey:USER_AUTOLOCK_TIME];
            if(autolockTime && autolockTime.length>0)
            {
                int minute=[autolockTime intValue];
                if(minutes>minute)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:STATE_SHOW_PIN_POPUP object:nil];

                }
            }
            else
            {
                int minute=5;
                if(minutes>minute)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:STATE_SHOW_PIN_POPUP object:nil];
                    
                }
            }
        }
        else
        {
    
            [[NSNotificationCenter defaultCenter] postNotificationName:STATE_SHOW_PIN_POPUP object:nil];
        }
    }
    
<<<<<<< HEAD
    
=======
    // If the survey hasn't been sent yet, then submit it.
    if([[NSUserDefaults standardUserDefaults] valueForKey:SURVEY_RESULTS]){
        // Encode the URL to make it valid for the request
        
        NSString *urlString_results = [[NSUserDefaults standardUserDefaults] valueForKey:SURVEY_RESULTS];
        urlString_results = [urlString_results stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        // Make the network request
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager GET:urlString_results parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            // Remove the survey results after they've been submitted successfully
            [[NSUserDefaults standardUserDefaults] setValue:nil forKey:SURVEY_RESULTS];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"ERROR: %@", error);
        }];
    }
>>>>>>> 5323e7b67743d34139f13eecf396a8c3a23b43bc
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
