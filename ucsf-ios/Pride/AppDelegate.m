    //
//  AppDelegate.m
//  Pride
//
//  Created by Patrick Krabeepetcharat on 5/6/15.
//  Copyright (c) 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#import "LockScreenViewController.h"
#import "R1Push.h"
#import "R1WebCommand.h" // required for rich push
@interface AppDelegate ()
{
    int healthquerycheck;
    NSMutableArray* datedata;
    NSMutableArray* healthdata;
    NSMutableArray* stepsdata;
    NSMutableArray* flightsclimbed;
    NSMutableArray* walkingrunningdist;
    NSMutableArray* weightdata;
    NSMutableArray* heightdata;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    _networkReachability = [Reachability reachabilityForInternetConnection];
    // Initialize Health Store
    self.healthStore = [[HKHealthStore alloc] init];
    [[NSUserDefaults standardUserDefaults] setBool:true forKey:STATE_SHOW_PIN_POPUP];
    [Fabric with:@[[Crashlytics class]]];

    // Should conditionally take you to Welcome screen here
    UIStoryboard *storyboard;
    UIViewController *rootViewController;
    
    
    if([[[NSUserDefaults standardUserDefaults] valueForKey:STATE_CONSENT_COMPLETE] boolValue]==true){
        storyboard = [UIStoryboard storyboardWithName:@"TabBar" bundle:nil];
        rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarNavigationController"];
    }else{
        storyboard = [UIStoryboard storyboardWithName:@"Welcome" bundle:nil];
        rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"WelcomeNavigationController"];
    }
    
    self.window.rootViewController = rootViewController;
    
    // Set the tint color for the entire app
    [self.window setTintColor:[UIColor primaryColor]];
    
    // Initialize RadiumOne Tracking
    R1SDK *sdk = [R1SDK sharedInstance];
//    id userID = [[NSUserDefaults standardUserDefaults] valueForKey:USER_USER_ID_IDENTIFIER];

    if( [[NSUserDefaults standardUserDefaults] objectForKey:USER_USER_ID_IDENTIFIER ])
    {
        sdk.applicationUserId= [[NSUserDefaults standardUserDefaults] objectForKey:USER_USER_ID_IDENTIFIER ];
    }
    
    if([[SERVER_URL lowercaseString] containsString:@"verify"])
    {
        sdk.applicationId = R1_PROD_ID;
        sdk.clientKey = R1_CLIENT_KEY_PROD;  //Ask your RadiumOne contact for a client key

         [R1Emitter sharedInstance].appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    }
    else
    {
        sdk.applicationId = R1_PROD_ID;
        sdk.clientKey = R1_CLIENT_KEY_PROD;  //Ask your RadiumOne contact for a client key
        [R1Emitter sharedInstance].appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];

    }
    [[R1Push sharedInstance] handleNotification:[launchOptions valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey]
                               applicationState: application.applicationState];
    [[R1Push sharedInstance] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                                 UIRemoteNotificationTypeSound |
                                                                 UIRemoteNotificationTypeAlert)];
    
    
    [[R1Push sharedInstance] setPushEnabled:YES];

    
    [R1Emitter sharedInstance].appName = @"PRIDE";

    [sdk start];

    [[R1Push sharedInstance].tags addTag:@"App Installed"];

    
    // Initialize Google Analytics
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-64072816-2"];
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    
    return YES;
}
-(void)noInternetConnectionPopup
{
   
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"No internet connection detected. Please connect to the internet to view this content."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [alert show];

}
- (void)update_user_data{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    
    
    
    [manager.requestSerializer setValue:PRIDE_API_AUTH forHTTPHeaderField:@"PRIDE-API-AUTH"];

    NSUserDefaults* defaults=[NSUserDefaults standardUserDefaults];
    
//    categories=[@[@"New posts",@"Replies to my posts",@"Comments on my posts"]mutableCopy];

    NSDictionary *parameters = @{@"first_name": ([defaults objectForKey:USER_FIRST_NAME_IDENTIFIER])?[defaults objectForKey:USER_FIRST_NAME_IDENTIFIER]:@"",
                                @"last_name": ([defaults objectForKey:USER_LAST_NAME_IDENTIFIER])?[defaults objectForKey:USER_LAST_NAME_IDENTIFIER]:@"",
                                 @"email": ([defaults objectForKey:USER_EMAIL_IDENTIFIER])?[defaults objectForKey:USER_EMAIL_IDENTIFIER]:@"",
//                                 @"password": [defaults objectForKey:USER_FIRST_NAME_IDENTIFIER],
                                 @"user_id": ([defaults objectForKey:USER_USER_ID_IDENTIFIER])?[defaults objectForKey:USER_USER_ID_IDENTIFIER]:@"",
                                 @"zip": ([defaults objectForKey:USER_ZIP_IDENTIFIER])?[defaults objectForKey:USER_ZIP_IDENTIFIER]:@"",
                                 @"flights_climbed":([defaults objectForKey:USER_FLIGHTS_CLIMBED])?[defaults objectForKey:USER_FLIGHTS_CLIMBED]:@"",
                                 @"steps_count":([defaults objectForKey:USER_STEPS_COUNT])?[defaults objectForKey:USER_STEPS_COUNT]:@"" ,
                                 @"walking_running_distance": ([defaults objectForKey:USER_STEPS_COUNT])?[defaults objectForKey:USER_WALKING_RUNNING_DIS]:@"",
                                 @"sharing":  ([defaults boolForKey:USER_SHARING_ENABLED])?@"1":@"0",
                                 @"activity_type_1":  ([defaults boolForKey:STATE_DEMOGRAPHIC_SURVEY_COMPLETE])?@"1":@"0",
                                 @"activity_type_1":  ([defaults boolForKey:STATE_DEMOGRAPHIC_SURVEY_COMPLETE])?@"1":@"0",
                                 @"activity_type_1":  ([defaults boolForKey:STATE_DEMOGRAPHIC_SURVEY_COMPLETE])?@"1":@"0",
                                 @"activity_type_2":  ([defaults boolForKey:STATE_CREATE_SCREEN_NAME_COMPLETE])?@"1":@"0",
                                 @"activity_type_3":  ([defaults boolForKey:STATE_CREATE_TOPIC_COMPLETE])?@"1":@"0",
                                 @"activity_type_4":  ([defaults boolForKey:STATE_REVIEW_TOPICS_COMPLETE])?@"1":@"0",
                                 @"activity_type_5":  ([defaults boolForKey:STATE_VOTE_ON_TOPICS_COMPLETE])?@"1":@"0",
                                 @"activity_type_6":  ([defaults boolForKey:STATE_COMMENT_ON_TOPICS_COMPLETE])?@"1":@"0",
                                 @"activity_type_7":  ([defaults boolForKey:STATE_IMPROVING_SURVEY_COMPLETE])?@"1":@"0",
                                 @"activity_type_8":  ([defaults boolForKey:STATE_PHYSICAL_HEALTH_SURVEY_COMPLETE])?@"1":@"0",
                                 @"activity_type_9":  ([defaults boolForKey:STATE_MENTAL_HEALTH_SURVEY_COMPLETE])?@"1":@"0",
                                 @"activity_type_10":  ([defaults boolForKey:STATE_SOCIAL_HEALTH_SURVEY_COMPLETE])?@"1":@"0",
                                  @"activity_type_11":  ([defaults boolForKey:STATE_AGE_SURVEY_COMPLETE])?@"1":@"0",
                                 @"height":  ([defaults objectForKey:USER_HEIGHT_IDENTIFIER])?[defaults objectForKey:USER_HEIGHT_IDENTIFIER]:@"",
                                 @"weight": ([defaults objectForKey:USER_WEIGHT_IDENTIFIER])?[defaults objectForKey:USER_WEIGHT_IDENTIFIER]:@"",
                                 @"dob":  ([defaults objectForKey:USER_BIRTHDAY_IDENTIFIER])?[defaults objectForKey:USER_BIRTHDAY_IDENTIFIER]:@""};
    
    [manager POST:[SERVER_URL stringByAppendingString:@"update-account"] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
    
            NSLog(@"The responseObject: %@", responseObject);
            
 
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

    }];
    [self updatehealthdata];
}
-(void)updatehealthdata
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    
    
    
    [manager.requestSerializer setValue:PRIDE_API_AUTH forHTTPHeaderField:@"PRIDE-API-AUTH"];

    NSUserDefaults* defaults=[NSUserDefaults standardUserDefaults];

    NSString* userid=([defaults objectForKey:USER_USER_ID_IDENTIFIER])?[defaults objectForKey:USER_USER_ID_IDENTIFIER]:@"";
    
    if(!healthdata || healthdata.count==0 || userid.length==0)
    {
        return;
    }
    
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:healthdata options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSDictionary *parameters = @{
                                 @"user_id": ([defaults objectForKey:USER_USER_ID_IDENTIFIER])?[defaults objectForKey:USER_USER_ID_IDENTIFIER]:@"",
                                 @"data":jsonString
                                 };
    
    [manager POST:[SERVER_URL stringByAppendingString:@"update-health-data-bulk"] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"The responseObject: %@", responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];

}
// Returns the types of data that Fit wishes to write to HealthKit.
- (NSSet *)dataTypesToWrite {
    
    return [NSSet setWithObjects: nil];
}

// Returns the types of data that Fit wishes to read from HealthKit.
- (NSSet *)dataTypesToRead {
    HKCharacteristicType *birthdayType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
    //HKCharacteristicType *biologicalSexType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex];
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    HKQuantityType *stepsType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKQuantityType *distanceType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    HKQuantityType *flightsType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierFlightsClimbed];
    
    return [NSSet setWithObjects:birthdayType, heightType, weightType, stepsType, distanceType, flightsType, nil];
}
-(void)checkhealthquerydata
{
    
    if(healthquerycheck==3)
    {
        NSUserDefaults* defaults=[NSUserDefaults standardUserDefaults];

        NSLog(@"%@ %@ %@ %@",datedata,stepsdata,walkingrunningdist,flightsclimbed);
        healthdata=[[NSMutableArray alloc] init];
        for(int i =0;i<datedata.count;i++)
        {
            
            NSMutableDictionary* data=[[NSMutableDictionary alloc]init];
            NSDate* date=[datedata objectAtIndex:i];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MM/dd/yyyy"];
            NSString *textDate = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:date]];
            [data setObject:textDate forKey:@"date"];
            [data setObject:([flightsclimbed count]>i)?[flightsclimbed objectAtIndex:i]:@"0" forKey:@"flights_climbed"];
            [data setObject:([stepsdata count]>i)?[stepsdata objectAtIndex:i]:@"0" forKey:@"steps_count"];
            [data setObject:([walkingrunningdist count]>i)?[walkingrunningdist objectAtIndex:i]:@"0" forKey:@"walking_running_distance"];
            [data setObject:([defaults objectForKey:USER_WEIGHT_IDENTIFIER])?[defaults objectForKey:USER_WEIGHT_IDENTIFIER]:@"" forKey:@"weight"];
            [data setObject:([defaults objectForKey:USER_HEIGHT_IDENTIFIER])?[defaults objectForKey:USER_HEIGHT_IDENTIFIER]:@"" forKey:@"height"];
            [healthdata addObject:data];
            
            
        }
       
        [self update_user_data];
    }
}
-(void)getHealthkitData
{
    NSSet *shareObjectTypes = [NSSet setWithObjects:
                               [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass],
                               [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight],
                               nil];
    
    healthquerycheck=0;
    
    stepsdata=[[NSMutableArray alloc]init];
    flightsclimbed=[[NSMutableArray alloc]init];
    walkingrunningdist=[[NSMutableArray alloc]init];
    datedata=[[NSMutableArray alloc]init];
    weightdata=[[NSMutableArray alloc]init];
    heightdata=[[NSMutableArray alloc]init];
    
    [self.healthStore requestAuthorizationToShareTypes:shareObjectTypes
                                        readTypes:[self dataTypesToRead]
                                       completion:^(BOOL success, NSError *error) {
                                           
                                           if(success == YES)
                                           {
                                               // Set your start and end date for your query of interest
                                               NSCalendar *calendar = [NSCalendar currentCalendar];

                                               NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay
                                                                                      value:1
                                                                                     toDate:[NSDate date]
                                                                                    options:0];
                                               NSDate *startDate = [calendar dateByAddingUnit:NSCalendarUnitDay
                                                                                        value:-90
                                                                                       toDate:endDate
                                                                                      options:0];
                                               

                                               NSDateComponents *interval = [[NSDateComponents alloc] init];
                                               interval.day = 1;
                                               
                                               NSDateComponents *anchorComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear
                                                                                                fromDate:[NSDate date]];
                                               anchorComponents.hour = 0;
                                               NSDate *anchorDate = [calendar dateFromComponents:anchorComponents];
                                               HKQuantityType *quantityType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
                                               
                                               // Create the query
                                               HKStatisticsCollectionQuery *query = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:quantityType
                                                                                                                      quantitySamplePredicate:nil
                                                                                                                                      options:HKStatisticsOptionCumulativeSum
                                                                                                                                   anchorDate:anchorDate
                                                                                                                           intervalComponents:interval];
                                               
                                               // Set the results handler
                                               query.initialResultsHandler = ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection *results, NSError *error) {
                                                   if (error) {
                                                       // Perform proper error handling here
                                                       NSLog(@"*** An error occurred while calculating the statistics: %@ ***",error.localizedDescription);
                                                   }
//                                                   
//                                                   NSDate *endDate = [NSDate date];
//                                                   NSDate *startDate = [calendar dateByAddingUnit:NSCalendarUnitDay
//                                                                                            value:-30
//                                                                                           toDate:endDate
//                                                                                          options:0];
                                                   
                                                   NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay
                                                                                          value:1
                                                                                         toDate:[NSDate date]
                                                                                        options:0];
                                                   NSDate *startDate = [calendar dateByAddingUnit:NSCalendarUnitDay
                                                                                            value:-90
                                                                                           toDate:endDate
                                                                                          options:0];
                                                   
                                                   // Plot the daily step counts over the past 7 days
                                                   [results enumerateStatisticsFromDate:startDate
                                                                                 toDate:endDate
                                                                              withBlock:^(HKStatistics *result, BOOL *stop) {
                                                                                  
                                                                                  HKQuantity *quantity = result.sumQuantity;
                                                                                  if (quantity) {
                                                                                      NSDate *date = result.startDate;
                                                                                      [datedata addObject:date];
                                                                                     // NSLog(@"%@",date);
                                                                                      //HKQuantity *quantity = quantitySample.quantity;
                                                                                      NSString *string=[NSString stringWithFormat:@"%@",quantity];
                                                                                      NSString *newString1 = [string stringByReplacingOccurrencesOfString:@" count" withString:@""];
                                                                                      newString1 = [newString1 stringByReplacingOccurrencesOfString:@" ng" withString:@""];
                                                                                      newString1 = [newString1 stringByReplacingOccurrencesOfString:@" m" withString:@""];
                                                                                      //walkingrunningdist addObject:@[@"date":@"",@"":@""];
                                                                                      [walkingrunningdist addObject:newString1];
                                                                                     // NSInteger count=[newString1 integerValue];
                                                                                      
                                                                                   //   NSLog(@"%@: %@", date, newString1);
                                                                                  }
                                                                                  
                                                                              }];
                                                   healthquerycheck++;
                                                   [self checkhealthquerydata];
                                               };
                                               
                                               [self.healthStore executeQuery:query];

                                               HKQuantityType *quantityType2 = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
                                               
                                               // Create the query
                                               HKStatisticsCollectionQuery *query2 = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:quantityType2
                                                                                                                      quantitySamplePredicate:nil
                                                                                                                                      options:HKStatisticsOptionCumulativeSum
                                                                                                                                   anchorDate:anchorDate
                                                                                                                           intervalComponents:interval];
                                               
                                               // Set the results handler
                                               query2.initialResultsHandler = ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection *results, NSError *error) {
                                                   if (error) {
                                                       // Perform proper error handling here
                                                       NSLog(@"*** An error occurred while calculating the statistics: %@ ***",error.localizedDescription);
                                                   }
                                                   
                                                   
                                                   NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay
                                                                                          value:1
                                                                                         toDate:[NSDate date]
                                                                                        options:0];
                                                   NSDate *startDate = [calendar dateByAddingUnit:NSCalendarUnitDay
                                                                                            value:-90
                                                                                           toDate:endDate
                                                                                          options:0];
                                                   
                                                   // Plot the daily step counts over the past 7 days
                                                   [results enumerateStatisticsFromDate:startDate
                                                                                 toDate:endDate
                                                                              withBlock:^(HKStatistics *result, BOOL *stop) {
                                                                                  
                                                                                  HKQuantity *quantity = result.sumQuantity;
                                                                                  if (quantity) {
                                                                                      NSDate *date = result.startDate;
                                                                                      // NSLog(@"%@",date);
                                                                                      //HKQuantity *quantity = quantitySample.quantity;
                                                                                      NSString *string=[NSString stringWithFormat:@"%@",quantity];
                                                                                      NSString *newString1 = [string stringByReplacingOccurrencesOfString:@" count" withString:@""];
                                                                                      newString1 = [newString1 stringByReplacingOccurrencesOfString:@" ng" withString:@""];
                                                                                      newString1 = [newString1 stringByReplacingOccurrencesOfString:@" m" withString:@""];
                                                                                      //walkingrunningdist addObject:@[@"date":@"",@"":@""];
                                                                                      [stepsdata addObject:newString1];
                                                                                      // NSInteger count=[newString1 integerValue];
                                                                                      
                                                                                      //   NSLog(@"%@: %@", date, newString1);
                                                                                  }
                                                                                  
                                                                              }];
                                                   healthquerycheck++;
                                                   [self checkhealthquerydata];
                                               };
                                               
                                               [self.healthStore executeQuery:query2];
                                              
                                               
                                               HKQuantityType *quantityType3 = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierFlightsClimbed];
                                               
                                               // Create the query
                                               HKStatisticsCollectionQuery *query3 = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:quantityType3
                                                                                                                       quantitySamplePredicate:nil
                                                                                                                                       options:HKStatisticsOptionCumulativeSum
                                                                                                                                    anchorDate:anchorDate
                                                                                                                            intervalComponents:interval];
                                               
                                               // Set the results handler
                                               query3.initialResultsHandler = ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection *results, NSError *error) {
                                                   if (error) {
                                                       // Perform proper error handling here
                                                       NSLog(@"*** An error occurred while calculating the statistics: %@ ***",error.localizedDescription);
                                                   }
                                                   
                                                   NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay
                                                                                          value:1
                                                                                         toDate:[NSDate date]
                                                                                        options:0];
                                                   NSDate *startDate = [calendar dateByAddingUnit:NSCalendarUnitDay
                                                                                            value:-90
                                                                                           toDate:endDate
                                                                                          options:0];
                                                   // Plot the daily step counts over the past 7 days
                                                   [results enumerateStatisticsFromDate:startDate
                                                                                 toDate:endDate
                                                                              withBlock:^(HKStatistics *result, BOOL *stop) {
                                                                                  
                                                                                  HKQuantity *quantity = result.sumQuantity;
                                                                                  if (quantity) {
                                                                                      NSDate *date = result.startDate;
                                                                                      // NSLog(@"%@",date);
                                                                                      //HKQuantity *quantity = quantitySample.quantity;
                                                                                      NSString *string=[NSString stringWithFormat:@"%@",quantity];
                                                                                      NSString *newString1 = [string stringByReplacingOccurrencesOfString:@" count" withString:@""];
                                                                                      newString1 = [newString1 stringByReplacingOccurrencesOfString:@" ng" withString:@""];
                                                                                      newString1 = [newString1 stringByReplacingOccurrencesOfString:@" m" withString:@""];
                                                                                      //walkingrunningdist addObject:@[@"date":@"",@"":@""];
                                                                                      [flightsclimbed addObject:newString1];
                                                                                      // NSInteger count=[newString1 integerValue];
                                                                                      
                                                                                      //   NSLog(@"%@: %@", date, newString1);
                                                                                  }
                                                                                  
                                                                              }];
                                                   healthquerycheck++;
                                                   [self checkhealthquerydata];
                                               };
                                               
                                               [self.healthStore executeQuery:query3];
                                               
                                               
                                               HKQuantityType *quantityType4 = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
                                               
                                               // Create the query
                                               HKStatisticsCollectionQuery *query4 = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:quantityType4
                                                                                                                       quantitySamplePredicate:nil
                                                                                                                                       options:HKStatisticsOptionCumulativeSum
                                                                                                                                    anchorDate:anchorDate
                                                                                                                            intervalComponents:interval];
                                               
                                               // Set the results handler
                                               query4.initialResultsHandler = ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection *results, NSError *error) {
                                                   if (error) {
                                                       // Perform proper error handling here
                                                       NSLog(@"*** An error occurred while calculating the statistics: %@ ***",error.localizedDescription);
                                                   }
                                                   
                                                   NSDate *endDate = [NSDate date];
                                                   NSDate *startDate = [calendar dateByAddingUnit:NSCalendarUnitDay
                                                                                            value:-30
                                                                                           toDate:endDate
                                                                                          options:0];
                                                   
                                                   // Plot the daily step counts over the past 7 days
                                                   [results enumerateStatisticsFromDate:startDate
                                                                                 toDate:endDate
                                                                              withBlock:^(HKStatistics *result, BOOL *stop) {
                                                                                  
                                                                                  HKQuantity *quantity = result.sumQuantity;
                                                                                  if (quantity) {
                                                                                      NSDate *date = result.startDate;
                                                                                      // NSLog(@"%@",date);
                                                                                      //HKQuantity *quantity = quantitySample.quantity;
                                                                                      NSString *string=[NSString stringWithFormat:@"%@",quantity];
                                                                                      NSString *newString1 = [string stringByReplacingOccurrencesOfString:@" count" withString:@""];
                                                                                      newString1 = [newString1 stringByReplacingOccurrencesOfString:@" ng" withString:@""];
                                                                                      newString1 = [newString1 stringByReplacingOccurrencesOfString:@" m" withString:@""];
                                                                                      //walkingrunningdist addObject:@[@"date":@"",@"":@""];
                                                                                      [heightdata addObject:newString1];
                                                                                      // NSInteger count=[newString1 integerValue];
                                                                                      
                                                                                      //   NSLog(@"%@: %@", date, newString1);
                                                                                  }
                                                                                  
                                                                              }];
                                                   healthquerycheck++;
                                                   [self checkhealthquerydata];
                                               };
                                               
                                             //  [self.healthStore executeQuery:query4];
                                               
                                               HKQuantityType *quantityType5 = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
                                               
                                               // Create the query
                                               HKStatisticsCollectionQuery *query5 = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:quantityType5
                                                                                                                       quantitySamplePredicate:nil
                                                                                                                                       options:HKStatisticsOptionCumulativeSum
                                                                                                                                    anchorDate:anchorDate
                                                                                                                            intervalComponents:interval];
                                               
                                               // Set the results handler
                                               query5.initialResultsHandler = ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection *results, NSError *error) {
                                                   if (error) {
                                                       // Perform proper error handling here
                                                       NSLog(@"*** An error occurred while calculating the statistics: %@ ***",error.localizedDescription);
                                                   }
                                                   
                                                   
                                                   NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay
                                                                                          value:1
                                                                                         toDate:[NSDate date]
                                                                                        options:0];
                                                   NSDate *startDate = [calendar dateByAddingUnit:NSCalendarUnitDay
                                                                                            value:-90
                                                                                           toDate:endDate
                                                                                          options:0];
                                                   
                                                   // Plot the daily step counts over the past 7 days
                                                   [results enumerateStatisticsFromDate:startDate
                                                                                 toDate:endDate
                                                                              withBlock:^(HKStatistics *result, BOOL *stop) {
                                                                                  
                                                                                  HKQuantity *quantity = result.sumQuantity;
                                                                                  if (quantity) {
                                                                                      NSDate *date = result.startDate;
                                                                                      // NSLog(@"%@",date);
                                                                                      //HKQuantity *quantity = quantitySample.quantity;
                                                                                      NSString *string=[NSString stringWithFormat:@"%@",quantity];
                                                                                      NSString *newString1 = [string stringByReplacingOccurrencesOfString:@" count" withString:@""];
                                                                                      newString1 = [newString1 stringByReplacingOccurrencesOfString:@" ng" withString:@""];
                                                                                      newString1 = [newString1 stringByReplacingOccurrencesOfString:@" m" withString:@""];
                                                                                      //walkingrunningdist addObject:@[@"date":@"",@"":@""];
                                                                                      [weightdata addObject:newString1];
                                                                                      // NSInteger count=[newString1 integerValue];
                                                                                      
                                                                                      //   NSLog(@"%@: %@", date, newString1);
                                                                                  }
                                                                                  
                                                                              }];
                                                   healthquerycheck++;
                                                   [self checkhealthquerydata];
                                               };
                                
                                           }
                                       }];
    
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[R1Push sharedInstance] registerDeviceToken:deviceToken];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [[R1Push sharedInstance] failToRegisterDeviceTokenWithError:error];
}
- (NSData *)httpBodyForParamsDictionary:(NSDictionary *)paramDictionary {
    NSMutableArray *parameterArray = [NSMutableArray array];
    
    [paramDictionary enumerateKeysAndObjectsUsingBlock: ^(NSString *key, NSString *obj, BOOL *stop) {
        NSString *param = [NSString stringWithFormat:@"%@=%@", key, [self percentEscapeString:obj]];
        [parameterArray addObject:param];
    }];
    
    NSString *string = [parameterArray componentsJoinedByString:@"&"];
    
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}
- (NSString *)percentEscapeString:(NSString *)string {
    NSString *result = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                 (CFStringRef)string,
                                                                                 (CFStringRef)@" ",
                                                                                 (CFStringRef)@":/?@!$&'()*+,;=",
                                                                                 kCFStringEncodingUTF8));
    return [result stringByReplacingOccurrencesOfString:@" " withString:@"+"];
}
-(void)updateUserInfo
{
    NSDictionary *params = @{ @"user_id": [[NSUserDefaults standardUserDefaults] objectForKey:USER_USER_ID_IDENTIFIER ] };
    
    NSURL *url = [NSURL URLWithString:
                  [SERVER_URL stringByAppendingString:@"get-survey-results"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[self httpBodyForParamsDictionary:params]];
    
    [request setValue:PRIDE_API_AUTH forHTTPHeaderField:@"PRIDE-API-AUTH"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (error) {
                               
                               }
                               else {
                                   NSMutableDictionary *innerJson = [NSJSONSerialization
                                                                     JSONObjectWithData:data options:kNilOptions error:NULL];
                                   
                                   NSData *jsonData = [NSJSONSerialization dataWithJSONObject:innerJson
                                                                                      options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                                                        error:&error];
                                   
                                   
                                   NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                   jsonString=[jsonString stringByReplacingOccurrencesOfString:@"Aesexual" withString:@"Asexual"];
                                   NSError *jsonError;
                                   NSData *objectData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                                   innerJson = [NSJSONSerialization JSONObjectWithData:objectData
                                                                               options:NSJSONReadingMutableContainers
                                                                                 error:&jsonError];

                                   
                                   NSDictionary *user = innerJson[@"user"];
                                   
                                   if(user)
                                   {
                                   
                                       NSArray* related_stats=[user objectForKey:@"related_stats"];
                                       
                                       NSString *user_sex;
                                       NSString *user_orientation;
                                       NSString *user_identity;


                                       for(NSDictionary* row in related_stats)
                                       {
                                           
                                           if([[[row objectForKey:@"stat_group"] lowercaseString]isEqualToString:@"assigned_gender"])
                                           {
                                               
                                               NSString* data=[row objectForKey:@"name"];

                                               [[NSUserDefaults standardUserDefaults]setObject:data forKey:USER_SEX_IDENTIFIER];
                                           }
                                           if([[[row objectForKey:@"stat_group"] lowercaseString]isEqualToString:@"orientation"])
                                           {
                                               NSArray* data=@[[row objectForKey:@"name"]];
                                               [[NSUserDefaults standardUserDefaults]setObject:data forKey:USER_SEXUAL_ORIENTATION_IDENTIFIER];
                                           }
                                           if([[[row objectForKey:@"stat_group"] lowercaseString]isEqualToString:@"gender_identity"])
                                           {
                                               NSArray* data=@[[row objectForKey:@"name"]];

                                               [[NSUserDefaults standardUserDefaults]setObject:data forKey:USER_GENDER_IDENTITY_IDENTIFIER];
                                           }
                                           
                                       }
                                   }
                                   //  }
                                   
                       
                               }
                           }];
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [[R1Push sharedInstance] handleNotification:userInfo applicationState:application.applicationState];
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [self checkFailedSubmittedSurvey];

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
    // If the survey hasn't been sent yet, then submit it.

    [self checkFailedSubmittedSurvey];
    
}
-(void)checkFailedSubmittedSurvey
{
    
    // If the survey hasn't been sent yet, then submit it.
    if([[NSUserDefaults standardUserDefaults] valueForKey:SURVEY_RESULTS]){
        // Encode the URL to make it valid for the request
        
        NSString *urlString_results = [[NSUserDefaults standardUserDefaults] valueForKey:SURVEY_RESULTS];
        if([urlString_results length]>0)
        {
            // Make the network request
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            [manager GET:urlString_results parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                // Remove the survey results after they've been submitted successfully
                [[NSUserDefaults standardUserDefaults] setValue:nil forKey:SURVEY_RESULTS];
                
                NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                //NSLog(@"RESPONSE: %@", string);
                [self notifyServer:string];
                [[NSUserDefaults standardUserDefaults] setValue:string forKey:USER_DEMOGRAPHIC_SURVEY_RESPONSE_ID_IDENTIFIER];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"ERROR: %@", error);
            }];
        }
    }

}
- (IBAction)notifyServer:(NSString*)responseid {
    //Get API Data
    //notifies server to update dashboard cache
    NSDictionary *params = @{ @"response_id":responseid};
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DASHBOARD_FORCE_REFRESH];
    
    NSURL *url = [NSURL URLWithString:
                  [SERVER_URL stringByAppendingString:@"update-survey-result-cache"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[self httpBodyForParamsDictionary:params]];
    
    [request setValue:PRIDE_API_AUTH forHTTPHeaderField:@"PRIDE-API-AUTH"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error) {
                               [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
                                   ///  [MBProgressHUD hideHUDForView:self.view animated:YES];
                                   
                                   
                                   
                               }];
                           }];
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
