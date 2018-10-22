//
//  CommunityViewController.m
//  Pride
//
//  Created by Patrick Krabeepetcharat on 5/13/15.
//  Copyright (c) 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import "ProfileViewController.h"
#import "HKHealthStore+AAPLExtensions.h"
#import "UIColor+constants.h"
#import "AppConstants.h"
#import "ProfileCell.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "R1Push.h"
#import "R1WebCommand.h"

@interface ProfileViewController ()
{
    UIEdgeInsets tableviewInset;
    UIDatePicker *datePicker;
    NSArray* feetArray;
    ProfileCell* mainCell;
    UIPickerView* heightPicker;
    NSArray* autolockArray;
    UIPickerView* autolockPicker;
    __weak IBOutlet UITextField *heightField;
    NSArray* inchesArray;
    
    UILabel *labelCurrentStudy;
    
    ORKTaskViewController *taskViewController;
    
    bool sharingAllowed;
    
    // Demographic survey
    NSString *user_sex;
    NSString *user_orientation;
    NSString *user_identity;
    
    NSMutableArray *sexualOrientations;
    NSMutableArray *genderIdentities;
    
    NSString *formattedDate;
    NSString *urlString_results;
}
@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ProfileCell" bundle:nil] forCellReuseIdentifier:@"ProfileCell"];
    
    autolockArray=@[@"5",@"10",@"15",@"30",@"45"];
    self.healthStore = [[HKHealthStore alloc] init];
    datePicker = [[UIDatePicker alloc]init];
    
    
    
    //  self.tableView.contentInset = UIEdgeInsetsMake(44,0,0,0);
    
}

-(void) doneTapped:(id)sender
{
    [self.view endEditing:true];
    
}-(void) birthdayField:(id)sender
{
    mainCell=(ProfileCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [datePicker setMaximumDate:[NSDate date]];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSDate *eventDate = datePicker.date;
    [dateFormat setDateFormat:@"MM/dd/yyyy"];
    
    NSString *dateString = [dateFormat stringFromDate:eventDate];
    mainCell.birthDayField.text = [NSString stringWithFormat:@"%@",dateString];
    
    [[NSUserDefaults standardUserDefaults] setObject:dateString forKey:USER_BIRTHDAY_IDENTIFIER];
    
    // AppDelegate* appD = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //  [appD update_user_data];
    NSDate* now = [NSDate date];
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                       components:NSYearCalendarUnit
                                       fromDate:eventDate
                                       toDate:now
                                       options:0];
    NSInteger age = [ageComponents year];
    
}
#pragma mark - HealthKit Permissions

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

#pragma mark - Reading HealthKit Data

- (void)updateUsersAgeLabel:(UITextField*) birthday {
    // Set the user's age unit (years).
    NSError *error;
    NSDate *dateOfBirth = [self.healthStore dateOfBirthWithError:&error];
    
    if (!dateOfBirth) {
        
        NSLog(@"Either an error occured fetching the user's age information or none has been stored yet. In your app, try to handle this gracefully.");
        
        
        NSString* date=[[NSUserDefaults standardUserDefaults] objectForKey:USER_BIRTHDAY_IDENTIFIER];
        if(date && [date length]>0)
        {
            birthday.text = date;
            NSDateFormatter* myFormatter = [[NSDateFormatter alloc] init];
            [myFormatter setDateFormat:@"MM/dd/yyyy"];
            NSDate* myDate = [myFormatter dateFromString:date];
            [datePicker setDate:myDate];
            
            NSString *stringBirthday = [NSString stringWithFormat:@"%@",[myFormatter stringFromDate:myDate]];
            
            [[NSUserDefaults standardUserDefaults] setObject:stringBirthday forKey:USER_BIRTHDAY_IDENTIFIER];
            
            AppDelegate* appD = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appD update_user_data];
            
        }
        else
        {
            NSDateComponents *minusHundredYears = [NSDateComponents new];
            minusHundredYears.year = -18;
            NSDate *newdate = [[NSCalendar currentCalendar] dateByAddingComponents:minusHundredYears
                                                                            toDate:[NSDate date]
                                                                           options:0];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MM/dd/yyyy"];
            NSString *stringBirthday = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:newdate]];
            [[NSUserDefaults standardUserDefaults] setObject:stringBirthday forKey:USER_BIRTHDAY_IDENTIFIER];
            [datePicker setDate:newdate];
            
            AppDelegate* appD = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appD update_user_data];
            
            birthday.text = stringBirthday;
            
            
            
            
        }
        // _birthdayField.text = NSLocalizedString(@"Not available", nil);
        // [_birthdayField setEnabled:false];
    }
    else {
        // Compute the age of the user.
        //  [_birthdayField setEnabled:false];
        
        
        NSString* date=[[NSUserDefaults standardUserDefaults] objectForKey:USER_BIRTHDAY_IDENTIFIER];
        if(date && [date length]>0)
        {
            birthday.text = date;
            NSDateFormatter* myFormatter = [[NSDateFormatter alloc] init];
            [myFormatter setDateFormat:@"MM/dd/yyyy"];
            NSDate* myDate = [myFormatter dateFromString:date];
            [datePicker setDate:myDate];
            
            NSString *stringBirthday = [NSString stringWithFormat:@"%@",[myFormatter stringFromDate:myDate]];
            
            [[NSUserDefaults standardUserDefaults] setObject:stringBirthday forKey:USER_BIRTHDAY_IDENTIFIER];
            
            AppDelegate* appD = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appD update_user_data];
            
        }
        else
        {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MM/dd/yyyy"];
            NSString *stringBirthday = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:dateOfBirth]];
            [[NSUserDefaults standardUserDefaults] setObject:stringBirthday forKey:USER_BIRTHDAY_IDENTIFIER];
            
            AppDelegate* appD = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appD update_user_data];
            
            birthday.text = stringBirthday;
            
        }
        
        
        
    }
}

- (void)updateUsersHeightLabel:(UITextField*)userheightField {
    
    mainCell=(ProfileCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    // Fetch user's default height unit in inches.
    NSLengthFormatter *lengthFormatter = [[NSLengthFormatter alloc] init];
    lengthFormatter.unitStyle = NSFormattingUnitStyleLong;
    
    //    NSLengthFormatterUnit heightFormatterUnit = NSLengthFormatterUnitInch;
    //    NSString *heightUnitString = [lengthFormatter unitStringFromValue:10 unit:heightFormatterUnit];
    //    NSString *localizedHeightUnitDescriptionFormat = NSLocalizedString(@"Height (%@)", nil);
    
    //self.heightUnitLabel.text = [NSString stringWithFormat:localizedHeightUnitDescriptionFormat, heightUnitString];
    
    HKQuantityType *heightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    
    // Query to get the user's latest height, if it exists.
    [self.healthStore aapl_mostRecentQuantitySampleOfType:heightType predicate:nil completion:^(HKQuantity *mostRecentQuantity, NSError *error) {
        if (!mostRecentQuantity) {
            NSLog(@"Either an error occured fetching the user's height information or none has been stored yet. In your app, try to handle this gracefully.");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSString* heightString=[[NSUserDefaults standardUserDefaults] objectForKey:USER_HEIGHT_IDENTIFIER];
                int heightint=0;
                if(heightString)
                    heightint=[heightString intValue];
                if(heightString && heightint>0)
                {
                    double usersHeight=[heightString doubleValue];
                    int heightvalue=(int)ceil(usersHeight);
                    int feet=(int)(heightvalue/12);
                    int inches=(int)((int)heightvalue%12);
                    userheightField.text=[NSString stringWithFormat:@"%d' %d\"",feet,inches];
                    
                    
                }
                else
                {
                    userheightField.text = NSLocalizedString(@"Tap to add", nil);
                }
                
                
                //_heightField.text = NSLocalizedString(@"Tap to add", nil);
                //[_height setTitle:NSLocalizedString(@"Not available", nil) forState:UIControlStateNormal];
                
            });
        }
        else {
            // Determine the height in the required unit.
            HKUnit *heightUnit = [HKUnit inchUnit];
            double usersHeight = [mostRecentQuantity doubleValueForUnit:heightUnit];
            
            // Update the user interface.
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSString* heightString=[[NSUserDefaults standardUserDefaults] objectForKey:USER_HEIGHT_IDENTIFIER];
                int heightint=0;
                if(heightString)
                    heightint=[heightString intValue];
                
                //                if(heightString && heightint>0)
                //                {
                //                    double usersHeight=[heightString doubleValue];
                //                    int heightvalue=(int)ceil(usersHeight);
                //                    int feet=(int)(heightvalue/12);
                //                    int inches=(int)((int)heightvalue%12);
                //                    userheightField.text=[NSString stringWithFormat:@"%d' %d\"",feet,inches];
                //
                //
                //                }
                //                else
                //                {
                int heightvalue=(int)ceil(usersHeight);
                int feet=(int)(heightvalue/12);
                int inches=(int)((int)heightvalue%12);
                
                
                
                
                userheightField.text=[NSString stringWithFormat:@"%d' %d\"",feet,inches];
                
                NSString* heightstringx=[NSString stringWithFormat:@"%d", heightvalue];
                
                [[NSUserDefaults standardUserDefaults] setObject:heightstringx forKey:USER_HEIGHT_IDENTIFIER];
                AppDelegate* appD = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appD update_user_data];
                mainCell=(ProfileCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                
                
                // }
            });
        }
    }];
}

- (void)updateUsersWeightLabel:(UIButton*)userWeightField {
    
    mainCell=(ProfileCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    // Fetch the user's default weight unit in pounds.
    NSMassFormatter *massFormatter = [[NSMassFormatter alloc] init];
    massFormatter.unitStyle = NSFormattingUnitStyleLong;
    
    NSMassFormatterUnit weightFormatterUnit = NSMassFormatterUnitPound;
    NSString *weightUnitString = [massFormatter unitStringFromValue:10 unit:weightFormatterUnit];
    NSString *localizedWeightUnitDescriptionFormat = NSLocalizedString(@"Weight (%@)", nil);
    
    
    // Query to get the user's latest weight, if it exists.
    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    
    [self.healthStore aapl_mostRecentQuantitySampleOfType:weightType predicate:nil completion:^(HKQuantity *mostRecentQuantity, NSError *error) {
        if (!mostRecentQuantity) {
            NSLog(@"Either an error occured fetching the user's weight information or none has been stored yet. In your app, try to handle this gracefully.");
            
            NSString* weightstring=[[NSUserDefaults standardUserDefaults] objectForKey:USER_WEIGHT_IDENTIFIER];
            int weightint=0;
            if(weightstring)
                weightint=[weightstring intValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                if(weightstring && weightstring>0 && weightint>0)
                {
                    [userWeightField setTitle: weightstring forState:UIControlStateNormal];
                }
                else
                {
                    [userWeightField setTitle: @"Tap to add" forState:UIControlStateNormal];
                    
                }
            });
            
        }
        else {
            // Determine the weight in the required unit.
            HKUnit *weightUnit = [HKUnit poundUnit];
            double usersWeight = [mostRecentQuantity doubleValueForUnit:weightUnit];
            
            // Update the user interface.
            dispatch_async(dispatch_get_main_queue(), ^{
                //  self.weightValueLabel.text = [NSNumberFormatter localizedStringFromNumber:@(usersWeight) numberStyle:NSNumberFormatterNoStyle];
                
                
                NSString* weightstring=[[NSUserDefaults standardUserDefaults] objectForKey:USER_WEIGHT_IDENTIFIER];
                int weightint=0;
                
                if(weightstring)
                    weightint=[weightstring intValue];
                //                if(weightstring && weightint>0)
                //                {
                //                    [userWeightField setTitle: weightstring forState:UIControlStateNormal];
                //                }
                //                else
                //                {
                [userWeightField setTitle:[NSNumberFormatter localizedStringFromNumber:@(usersWeight) numberStyle:NSNumberFormatterNoStyle] forState:UIControlStateNormal];
                
                NSString* weightstringx=[NSString stringWithFormat:@"%.2f", usersWeight];
                [[NSUserDefaults standardUserDefaults] setObject:weightstringx forKey:USER_WEIGHT_IDENTIFIER];
                
                AppDelegate* appD = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appD update_user_data];
                
                
                // }
                
                
            });
        }
    }];
}

#pragma mark - Writing HealthKit Data

- (void)saveHeightIntoHealthStore:(double)height {
    //    // Save the user's height into HealthKit.
    //    HKUnit *inchUnit = [HKUnit inchUnit];
    //    HKQuantity *heightQuantity = [HKQuantity quantityWithUnit:inchUnit doubleValue:height];
    //
    //    HKQuantityType *heightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    //    NSDate *now = [NSDate date];
    //
    //    HKQuantitySample *heightSample = [HKQuantitySample quantitySampleWithType:heightType quantity:heightQuantity startDate:now endDate:now];
    //
    //    [self.healthStore saveObject:heightSample withCompletion:^(BOOL success, NSError *error) {
    //        if (!success) {
    //            NSLog(@"An error occured saving the height sample %@. In your app, try to handle this gracefully. The error was: %@.", heightSample, error);
    //            // abort();
    //        }
    //
    //        [self updateUsersHeightLabel];
    //    }];
    
    NSString* heightstring=[NSString stringWithFormat:@"%02f", height];
    
    [[NSUserDefaults standardUserDefaults] setObject:heightstring forKey:USER_HEIGHT_IDENTIFIER];
    AppDelegate* appD = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appD update_user_data];
    mainCell=(ProfileCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    [self updateUsersHeightLabel:mainCell.heightField];
    
    
}
//- (NSSet *)dataTypesToRead {
//    HKQuantityType *heightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
//    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
//    HKQuantityType *heartRate = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
//    HKQuantityType *walkingRunningDistance = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
//    HKCharacteristicType *biologicalSex = [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex];
//    HKCharacteristicType *birthday = [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
//    return [NSSet setWithObjects:heightType, weightType, heartRate, walkingRunningDistance, biologicalSex, birthday, nil];
//}
-(void)viewWillAppear:(BOOL)animated
{
    
    AppDelegate* appD = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appD update_user_data];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    //[self.navigationController setNavigationBarHidden:NO animated:YES];
    
    // [self.tableView setContentOffset:CGPointZero animated:YES];
    NSString* date=[[NSUserDefaults standardUserDefaults] objectForKey:USER_BIRTHDAY_IDENTIFIER];
    if(date && [date length]>0)
    {
        NSDateFormatter* myFormatter = [[NSDateFormatter alloc] init];
        [myFormatter setDateFormat:@"MM/dd/yyyy"];
        NSDate* myDate = [myFormatter dateFromString:date];
        [datePicker setDate:myDate];
    }
    else
    {
        NSDateComponents *minusHundredYears = [NSDateComponents new];
        minusHundredYears.year = -18;
        NSDate *newdate = [[NSCalendar currentCalendar] dateByAddingComponents:minusHundredYears
                                                                        toDate:[NSDate date]
                                                                       options:0];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
        NSString *stringBirthday = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:newdate]];
        [[NSUserDefaults standardUserDefaults] setObject:stringBirthday forKey:USER_BIRTHDAY_IDENTIFIER];
        [datePicker setDate:newdate];
        
        AppDelegate* appD = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appD update_user_data];
        
        NSDate* now = [NSDate date];
        NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                           components:NSYearCalendarUnit
                                           fromDate:newdate
                                           toDate:now
                                           options:0];
        NSInteger age = [ageComponents year];
    }
    
    // Update no study if not enrolled
    if([[NSUserDefaults standardUserDefaults] boolForKey:USER_HAS_LEFT_STUDY]){
        labelCurrentStudy.text = @"No Study";
    }
    
    // Reload the data
    [self.tableView reloadData];
    
    // RadiumOne Tracking
    [[R1Emitter sharedInstance] emitScreenViewWithDocumentTitle:@"Profile"
                                             contentDescription:nil
                                            documentLocationUrl:nil
                                               documentHostName:nil
                                                   documentPath:nil
                                                      otherInfo:nil];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Profile"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"No internet connection detected. Please connect to the internet to view this content."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)saveWeightIntoHealthStore:(double)weight {
    
    
    NSString* weightstring=[NSString stringWithFormat:@"%.2f", weight];
    [[NSUserDefaults standardUserDefaults] setObject:weightstring forKey:USER_WEIGHT_IDENTIFIER];
    
    AppDelegate* appD = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appD update_user_data];
    
    
    mainCell=(ProfileCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    [self updateUsersWeightLabel:mainCell.weightField];
    
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}
#pragma mark - Convenience

- (NSNumberFormatter *)numberFormatter {
    static NSNumberFormatter *numberFormatter;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        numberFormatter = [[NSNumberFormatter alloc] init];
    });
    
    return numberFormatter;
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

- (IBAction)leaveStudyPressed:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Leave Study",nil];
    [alert show];
}

- (IBAction)weightPressed:(id)sender {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Weight in pounds" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    // Add the text field to let the user enter a numeric value.
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        // Only allow the user to enter a valid number.
        textField.keyboardType = UIKeyboardTypeDecimalPad;
    }];
    
    // Create the "OK" button.
    NSString *okTitle = NSLocalizedString(@"OK", nil);
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = alertController.textFields.firstObject;
        
        double value = textField.text.doubleValue;
        [self saveWeightIntoHealthStore:value];
        //  valueChangedHandler(value);
        
        // [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];
    
    [alertController addAction:okAction];
    
    // Create the "Cancel" button.
    NSString *cancelTitle = NSLocalizedString(@"Cancel", nil);
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        
    }];
    
    [alertController addAction:cancelAction];
    
    // Present the alert controller.
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        [self leaveStudy];
    }
}
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ProfileCell";
    ProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ProfileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:USER_HAS_LEFT_STUDY]){
        [cell.leaveStudy setHidden:true];
        [cell.leaveStudy setEnabled:false];
        
    }
    else
    {
        [cell.leaveStudy setHidden:false];
        [cell.leaveStudy addTarget:self action:@selector(leaveStudyPressed:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    cell.userName.text=[[NSUserDefaults standardUserDefaults] objectForKey:USER_FULL_NAME_IDENTIFIER];
    cell.userEmail.text=[[NSUserDefaults standardUserDefaults] objectForKey:USER_EMAIL_IDENTIFIER];
    
    labelCurrentStudy = cell.currentStudy;
    
    NSString* sex_identity=[[NSUserDefaults standardUserDefaults] objectForKey:USER_SEX_IDENTIFIER];
    
    NSLog(@"THE STORED SEX: %@",  sex_identity);
    //  NSLog(@"THE STORED SEX LENGTH: %lu",  (unsigned long)sex_identity.length);
    
    if(sex_identity && [sex_identity length]>0)
    {
        cell.biologicalSex.text=sex_identity;
        
    }
    else
    {
        cell.biologicalSex.text=@"Tap to add";
    }
    
    NSArray* sexualOrientation=[[NSUserDefaults standardUserDefaults] objectForKey:USER_SEXUAL_ORIENTATION_IDENTIFIER];
    
    if([sexualOrientation count] == 0){
        cell.sexualOrientation.text = @"Tap to add";
        [cell.sexualOrientation setHidden:NO];
        [cell.btn_sexualOrientationNext setHidden:YES];
    }
    else if([sexualOrientation count] == 1)
    {
        cell.sexualOrientation.text = [sexualOrientation firstObject];
        [cell.sexualOrientation setHidden:NO];
        [cell.btn_sexualOrientationNext setHidden:YES];
    }
    else
    {
        [cell.sexualOrientation setHidden:YES];
        [cell.btn_sexualOrientationNext setHidden:NO];
    }
    
    NSArray* genderIdentity=[[NSUserDefaults standardUserDefaults] objectForKey:USER_GENDER_IDENTITY_IDENTIFIER];
    
    if([genderIdentity count] == 0){
        cell.genderIdentity.text = @"Tap to add";
        [cell.genderIdentity setHidden:NO];
        [cell.btn_genderIdentityNext setHidden:YES];
    }
    else if([genderIdentity count] == 1)
    {
        cell.genderIdentity.text= [genderIdentity firstObject];
        [cell.genderIdentity setHidden:NO];
        [cell.btn_genderIdentityNext setHidden:YES];
    }
    else
    {
        [cell.genderIdentity setHidden:YES];
        [cell.btn_genderIdentityNext setHidden:NO];
    }
    
    
    NSString* autolockTime=[[NSUserDefaults standardUserDefaults] objectForKey:USER_AUTOLOCK_TIME];
    if(autolockTime && autolockTime.length>0)
    {
        cell.autoLockField.text=[NSString stringWithFormat:@"%@ min",autolockTime];
        
    }
    else
    {
        cell.autoLockField.text=@"5 min";
    }
    
    
    
    
    
    [cell.weightField addTarget:self action:@selector(weightPressed:) forControlEvents:UIControlEventTouchUpInside];
    [cell.weightField setTitle:@"Tap to add" forState:UIControlStateNormal];
    cell.heightField.text=@"Tap to add";
    
    feetArray= [NSArray arrayWithObjects:@"1'",@"2'",@"3'",@"4'", @"5'", @"6'", @"7'", nil],
    inchesArray=[NSArray arrayWithObjects:@"0\"", @"1\"", @"2\"", @"3\"", @"4\"", @"5\"", @"6\"", @"7\"", @"8\"", @"9\"", @"10\"", @"11\"", nil];
    
    
    
    
    
    
    [self updateUsersAgeLabel:cell.birthDayField];
    [self updateUsersHeightLabel:cell.heightField];
    [self updateUsersWeightLabel:cell.weightField];
    NSDateComponents *minusHundredYears = [NSDateComponents new];
    minusHundredYears.year = -18;
    
    //[datePicker setDate:newdate];
    
    CGRect frame=datePicker.frame;
    frame.origin.y+=44;
    datePicker.frame=frame;
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker addTarget:self action:@selector(birthdayField:) forControlEvents:UIControlEventValueChanged];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    //    UIView *view= [[UIView alloc] initWithFrame:CGRectMake(0,0,screenWidth,240)];
    
    UIToolbar *toolBar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,screenWidth,44)];
    
    toolBar.barStyle = UIBarStyleDefault;
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTapped:)];
    
    toolBar.items = [NSArray arrayWithObjects:space,done, nil];
    
    UIToolbar *toolBar2= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,screenWidth,44)];
    
    toolBar2.barStyle = UIBarStyleDefault;
    
    UIBarButtonItem *space2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *done2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTapped:)];
    
    toolBar2.items = [NSArray arrayWithObjects:space2,done2, nil];
    
    
    [cell.birthDayField setInputAccessoryView:toolBar];
    [cell.birthDayField setInputView:datePicker];
    
    
    heightPicker = [[UIPickerView alloc]init];
    heightPicker.delegate=self;
    
    
    
    [cell.heightField setInputView:heightPicker];
    [cell.heightField setInputAccessoryView:toolBar2];
    
    
    
    UIToolbar *toolBar3= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,screenWidth,44)];
    
    toolBar3.barStyle = UIBarStyleDefault;
    
    UIBarButtonItem *space3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *done3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTapped:)];
    
    toolBar3.items = [NSArray arrayWithObjects:space3,done3, nil];
    
    
    
    autolockPicker=[[UIPickerView alloc]init];
    autolockPicker.delegate=self;
    
    [cell.autoLockField setInputView:autolockPicker];
    [cell.autoLockField setInputAccessoryView:toolBar3];
    
    
    [cell.changePasscode addTarget:self action:@selector(changePasscode) forControlEvents:UIControlEventTouchUpInside];
    [cell.sharingOptions addTarget:self action:@selector(sharingOptions) forControlEvents:UIControlEventTouchUpInside];
    [cell.permissions addTarget:self action:@selector(permissions) forControlEvents:UIControlEventTouchUpInside];
    [cell.reviewConsent addTarget:self action:@selector(reviewConsent) forControlEvents:UIControlEventTouchUpInside];
    [cell.privacyPolicy addTarget:self action:@selector(privacyPolicy) forControlEvents:UIControlEventTouchUpInside];
    [cell.licenseInformation addTarget:self action:@selector(licenseInformation) forControlEvents:UIControlEventTouchUpInside];
    [cell.btn_sexualOrientation addTarget:self action:@selector(showSexualOrientation) forControlEvents:UIControlEventTouchUpInside];
    [cell.btn_genderIdentity addTarget:self action:@selector(showGenderIdentity) forControlEvents:UIControlEventTouchUpInside];
    [cell.btn_biologicalSex addTarget:self action:@selector(startDemographicSurvey) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
    
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:true];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if(pickerView==heightPicker)
    {
        if(component== 0)
        {
            return [feetArray objectAtIndex:row];
        }
        else
        {
            return [inchesArray objectAtIndex:row];
            
        }
    }
    else
    {
        return [NSString stringWithFormat:@"%@ min",[autolockArray objectAtIndex:row]];
    }
    return 0;
    
}


-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if(pickerView==heightPicker)
        return 2;
    else
        return 1;
    
    
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    if(pickerView==heightPicker)
    {
        if(component== 0)
        {
            return [feetArray count];
        }
        else if (component== 1)
        {
            return [inchesArray count];
            
        }
    }
    else
    {
        return [autolockArray count];
    }
    return 0;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row   inComponent:(NSInteger)component{
    
    
    if(pickerView==heightPicker)
        
    {
        
        NSInteger firstComponentRow = [pickerView selectedRowInComponent:0];
        NSInteger secondComponentRow = [pickerView selectedRowInComponent:1];
        
        double height=(firstComponentRow+1)*12;
        height+=secondComponentRow;
        int feet=(int)(height/12);
        int inches=(int)((int)height%12);
        
        
        [self saveHeightIntoHealthStore:height];
    }
    else
    {
        NSInteger firstComponentRow = [pickerView selectedRowInComponent:0];
        NSString* autoTime=[autolockArray objectAtIndex:firstComponentRow];
        
        [self saveAutoLockTime:autoTime];
    }
    
}

-(void) saveAutoLockTime : (NSString*)autoTime
{
    mainCell=(ProfileCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    mainCell.autoLockField.text=[NSString stringWithFormat:@"%@ min",autoTime];
    
    
    [[NSUserDefaults standardUserDefaults] setObject:autoTime forKey:USER_AUTOLOCK_TIME];
    
}

-(void) changePasscode
{
    [[NSNotificationCenter defaultCenter] postNotificationName:STATE_CHANGE_PIN_POPUP object:nil];
    
}
-(void) sharingOptions
{
    //  [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    ORKConsentDocument *document = [ORKConsentDocument new];
    document.title = @"PRIDE Study";
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                         pathForResource:@"consent-sharing" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
    
    ORKConsentSharingStep *sharingStep =
    [[ORKConsentSharingStep alloc] initWithIdentifier:@"ConsentSharingIdentifier"
                         investigatorShortDescription:@"UCSF"
                          investigatorLongDescription:@"UCSF and its partners"
                        localizedLearnMoreHTMLContent:[[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil]];
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:@"SharingTaskIdentifier"
                                                                steps:@[sharingStep]];
    
    taskViewController = [[ORKTaskViewController alloc] initWithTask:task taskRunUUID:nil];
    [taskViewController setShowsProgressInNavigationBar:NO];
    taskViewController.delegate = self;
    
    [taskViewController.navigationBar.topItem setTitle:@"Sharing Options"];
    taskViewController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor grayColor]};
    
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
    //[self.navigationController pushViewController:taskViewController animated:YES];
    
    [self presentViewController:taskViewController animated:YES completion:nil];
}

-(void) permissions
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Welcome" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"Permission"];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)taskViewController:(ORKTaskViewController * __nonnull)taskViewController didChangeResult:(ORKTaskResult * __nonnull)result{
    ORKStepResult *stepResult;
    stepResult = [result stepResultForStepIdentifier:@"ConsentSharingIdentifier"];
    
    ORKChoiceQuestionResult *questionResult = (ORKChoiceQuestionResult*)[stepResult.results firstObject];
    NSArray *answer = questionResult.choiceAnswers;
    if([[answer firstObject] isEqual:[NSNumber numberWithInt:1]]){
        sharingAllowed = YES;
    }else if([[answer firstObject] isEqual:[NSNumber numberWithInt:0]]){
        sharingAllowed = NO;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:sharingAllowed forKey:USER_SHARING_ENABLED];

}
-(void) reviewConsent
{
    [[UIView appearanceWhenContainedIn:[UIAlertController class], nil] setTintColor:[UIColor primaryColor]];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Review Consent"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"View Consent", @"Watch Video", @"View Slides", nil];
    actionSheet.tag = 100;
    
    [actionSheet showInView:self.view];
}

-(void) privacyPolicy
{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"No internet connection detected. Please connect to the internet to view this content."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
    } else {
        
        UIViewController *vc = [[UIViewController alloc] init];
        UIWebView *webView = [[UIWebView alloc] initWithFrame:vc.view.frame];
        
        NSURL *url = [NSURL URLWithString:@"http://pridestudy.org/app/privacypolicy.html?hidenav=true"];
        
        [webView loadRequest:[NSURLRequest requestWithURL:url]];
        [webView.scrollView setBounces:YES];
        [webView.scrollView setDecelerationRate:UIScrollViewDecelerationRateNormal];
        [vc.view addSubview:webView];
        
        [self.tabBarController.navigationController pushViewController:vc animated:YES];
        [vc.navigationItem setTitle:@"Privacy Policy"];
        
    }
}

-(void) licenseInformation
{
    UIViewController *vc = [[UIViewController alloc] init];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:vc.view.frame];
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                         pathForResource:@"credits-and-licensing" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    [webView.scrollView setBounces:YES];
    [webView.scrollView setDecelerationRate:UIScrollViewDecelerationRateNormal];
    [vc.view addSubview:webView];
    
    [self.tabBarController.navigationController pushViewController:vc animated:YES];
    [vc.navigationItem setTitle:@"License Information"];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:true];
    
}
- (void) showSexualOrientation{
    if([[NSUserDefaults standardUserDefaults] boolForKey:STATE_DEMOGRAPHIC_SURVEY_COMPLETE]){
        
        
        [self performSegueWithIdentifier:@"SexualOrientation" sender:self];
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Please complete the Demographic Survey." message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        
        // Create the "OK" button.
        NSString *okTitle = NSLocalizedString(@"OK", nil);
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
        }];
        
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
}

- (void) showGenderIdentity{
    if([[NSUserDefaults standardUserDefaults] boolForKey:STATE_DEMOGRAPHIC_SURVEY_COMPLETE]){
        
        [self performSegueWithIdentifier:@"GenderIdentity" sender:self];
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Please complete the Demographic Survey." message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        
        // Create the "OK" button.
        NSString *okTitle = NSLocalizedString(@"OK", nil);
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
        }];
        
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
}

- (void)leaveStudy{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"No internet connection detected. Please connect to the internet to view this content."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
    } else {
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        //Get API Data
        NSDictionary *params = @{ @"user_id": [[NSUserDefaults standardUserDefaults] objectForKey:USER_USER_ID_IDENTIFIER ] };
        
        NSURL *url = [NSURL URLWithString:
                      [SERVER_URL stringByAppendingString:@"user-delete"]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[self httpBodyForParamsDictionary:params]];
        
        [request setValue:PRIDE_API_AUTH forHTTPHeaderField:@"PRIDE-API-AUTH"];
        
        NSOperationQueue *queue = [[NSOperationQueue alloc]init];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:queue
                               completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error) {
                                   [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
                                       [[NSUserDefaults standardUserDefaults] setBool:YES forKey:USER_HAS_LEFT_STUDY];
                                       [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DASHBOARD_FORCE_REFRESH];
                                        [[R1Push sharedInstance].tags setTags:@[ @"App Installed", @"logged in user left study" ]];
                                       [MBProgressHUD hideHUDForView:self.view animated:YES];
                                       
                                       labelCurrentStudy.text = @"No Study";
                                       [self.tableView reloadData];
                                   }];
                               }];
    }
}

#pragma mark UIActionSheet Delegate Methods
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet.tag == 100) {
        if(buttonIndex == 0){ // View Consent
            UIViewController *vc = [[UIViewController alloc] init];
            UIWebView *webView = [[UIWebView alloc] initWithFrame:vc.view.frame];
            
            NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                                 pathForResource:@"consent-review" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
            [webView loadRequest:[NSURLRequest requestWithURL:url]];
            [webView.scrollView setBounces:YES];
            [webView.scrollView setDecelerationRate:UIScrollViewDecelerationRateNormal];
            [vc.view addSubview:webView];
            
            [self.tabBarController.navigationController pushViewController:vc animated:YES];
            [vc.navigationItem setTitle:@"Consent"];
        }else if  (buttonIndex == 1){
            NSString *videoPath=[[NSBundle mainBundle] pathForResource:@"intro" ofType:@"mp4"];
            NSURL *videoURL=[NSURL fileURLWithPath:videoPath isDirectory:NO];
            
            self.controller = [[MPMoviePlayerViewController alloc]initWithContentURL:videoURL];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(moviePlayBackDidFinish:)
                                                         name:MPMoviePlayerPlaybackDidFinishNotification
                                                       object:self.controller.moviePlayer];
            
            self.controller.view.frame = self.view.bounds;
            
            // [self.view addSubview:self.controller.view];
            
            [self.controller.moviePlayer prepareToPlay];
            [self.controller.moviePlayer play];
            ///  [self.controller.moviePlayer setFullscreen:YES animated:YES];
            [self presentViewController:self.controller animated:true completion:NULL];
        }else if  (buttonIndex == 2){
            [self showConsent];
        }
    }
}

- (void)showConsent{
    NSURL *url;
    
    ORKConsentSignature*    signature = [ORKConsentSignature signatureForPersonWithTitle:@"Participant"
                                                                        dateFormatString:nil
                                                                              identifier:@"participant"];
    
    self.document = [ORKConsentDocument new];
    self.document.title = @"PRIDE Study";
    self.document.signaturePageTitle = @"Signature";
    [self.document addSignature:signature];
    
    // Set the review document
    url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                  pathForResource:@"consent-review-simple" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
    self.document.htmlReviewContent = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    ORKConsentSection *sectionOverview =
    [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeOverview];
    sectionOverview.title = @"Welcome";
    sectionOverview.summary = @"Researchers at the University of California, San Francisco are using this app to enable LGBTQ and other sexual and gender minority people to help design research studies for their own communities.\n\n The info collected will help create a long-term study which will help better understand the conditions and experiences that influence the physical and mental health of LGBTQ people and other sexual and gender minorities.\n\n Get started to learn more";
    sectionOverview.customLearnMoreButtonTitle = @"Learn More";
    url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                  pathForResource:@"consent-welcome" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
    sectionOverview.htmlContent = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    ORKConsentSection *sectionUnderstanding =
    [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeCustom];
    sectionUnderstanding.title = @"We’ll Test Your Understanding";
    sectionUnderstanding.summary = @"After you complete this walkthrough about the study, there will be a short quiz at the end to confirm your understanding.";
    sectionUnderstanding.customLearnMoreButtonTitle = @"Learn More";
    sectionUnderstanding.customAnimationURL = [[NSBundle mainBundle] URLForResource:@"01_We’ll Test Your Understanding" withExtension:@"mp4"];
    sectionUnderstanding.customImage = [UIImage imageNamed:@"01_Well-Test-Your-Understanding"];
    url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                  pathForResource:@"consent-understanding" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
    sectionUnderstanding.htmlContent = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    ORKConsentSection *sectionInsight =
    [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeCustom];
    sectionInsight.title = @"Your Insight";
    sectionInsight.summary = @"Because we want to learn about your health questions and priorities, we will ask you to participate in a community discussion forum. Doing so will help us design a nationwide long-term health study.";
    sectionInsight.customLearnMoreButtonTitle = @"Learn More";
    sectionInsight.customAnimationURL = [[NSBundle mainBundle] URLForResource:@"02_Your Insight" withExtension:@"mp4"];
    sectionInsight.customImage = [UIImage imageNamed:@"02_Your-Insight"];
    url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                  pathForResource:@"consent-insights" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
    sectionInsight.htmlContent = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    ORKConsentSection *sectionSurveys =
    [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeCustom];
    sectionSurveys.title = @"Surveys";
    sectionSurveys.summary = @"We will ask you to complete brief surveys about a variety of topics including your identities, your health, and your behaviors. You may always choose not to answer questions that make you uncomfortable.";
    sectionSurveys.customLearnMoreButtonTitle = @"Learn More";
    sectionSurveys.customAnimationURL = [[NSBundle mainBundle] URLForResource:@"03_Surveys" withExtension:@"mp4"];
    sectionSurveys.customImage = [UIImage imageNamed:@"03_Surveys"];
    url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                  pathForResource:@"consent-surveys" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
    sectionSurveys.htmlContent = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    ORKConsentSection *sectionSensorData =
    [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeCustom];
    sectionSensorData.title = @"Sensor Data";
    sectionSensorData.summary = @"This study will gather sensor data from your iPhone and other personal devices with your permission.";
    sectionSensorData.customLearnMoreButtonTitle = @"Learn More";
    sectionSensorData.customAnimationURL = [[NSBundle mainBundle] URLForResource:@"04_Sensor Data" withExtension:@"mp4"];
    sectionSensorData.customImage = [UIImage imageNamed:@"04_Sensor-Data"];
    url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                  pathForResource:@"consent-sensor" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
    sectionSensorData.htmlContent = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    ORKConsentSection *sectionDataUse =
    [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeCustom];
    sectionDataUse.title = @"Data Use";
    sectionDataUse.summary = @"We will not share your personal identifiable information with any commercial third parties, such as advertisers.";
    sectionDataUse.customLearnMoreButtonTitle = @"Learn More";
    sectionDataUse.customAnimationURL = [[NSBundle mainBundle] URLForResource:@"05_Data Use" withExtension:@"mp4"];
    sectionDataUse.customImage = [UIImage imageNamed:@"05_Data-Use"];
    url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                  pathForResource:@"consent-data" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
    sectionDataUse.htmlContent = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    ORKConsentSection *sectionTimeCommitment =
    [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeCustom];
    sectionTimeCommitment.title = @"Time Commitment";
    sectionTimeCommitment.summary = @"Your participation in this study will average approximately 15 minutes per week for 6-9 months. You can adjust your level of participation, as you desire.";
    sectionTimeCommitment.customLearnMoreButtonTitle = @"Learn More";
    sectionTimeCommitment.customAnimationURL = [[NSBundle mainBundle] URLForResource:@"06_Time Commitment" withExtension:@"mp4"];
    sectionTimeCommitment.customImage = [UIImage imageNamed:@"06_Time-Commitment"];
    url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                  pathForResource:@"consent-time" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
    sectionTimeCommitment.htmlContent = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    ORKConsentSection *sectionPotentialBenefits =
    [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeCustom ];
    sectionPotentialBenefits.title = @"Potential Benefits";
    sectionPotentialBenefits.summary = @"Many participants will experience personal satisfaction knowing that they are contributing to the planning of a national LGBTQ health study. However, we cannot guarantee that you will experience benefit from participating.";
    sectionPotentialBenefits.customLearnMoreButtonTitle = @"Learn More";
    sectionPotentialBenefits.customAnimationURL = [[NSBundle mainBundle] URLForResource:@"07_Potential Benefits" withExtension:@"mp4"];
    sectionPotentialBenefits.customImage = [UIImage imageNamed:@"07_Potential-Benefits"];
    url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                  pathForResource:@"consent-benefits" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
    sectionPotentialBenefits.htmlContent = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    ORKConsentSection *sectionProtectingYourPrivacy =
    [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeCustom];
    sectionProtectingYourPrivacy.title = @"Protecting Your Privacy";
    sectionProtectingYourPrivacy.summary = @"To protect your privacy, information that identifies you (e.g., name, email address) is stored in a physically and digitally separate secure database from your study information.";
    sectionProtectingYourPrivacy.customLearnMoreButtonTitle = @"Learn More";
    sectionProtectingYourPrivacy.customAnimationURL = [[NSBundle mainBundle] URLForResource:@"08_Protecting Your Privacy" withExtension:@"mp4"];
    sectionProtectingYourPrivacy.customImage = [UIImage imageNamed:@"08_Protecting-Your-Privacy"];
    url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                  pathForResource:@"consent-privacy" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
    sectionProtectingYourPrivacy.htmlContent = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    ORKConsentSection *sectionSecureDatabases =
    [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeCustom];
    sectionSecureDatabases.title = @"Secure Databases";
    sectionSecureDatabases.summary = @"Your data will be stored in military-grade secure databases on secure servers that use procedures to safeguard your information and prevent unauthorized access.";
    sectionSecureDatabases.customLearnMoreButtonTitle = @"Learn More";
    sectionSecureDatabases.customAnimationURL = [[NSBundle mainBundle] URLForResource:@"09_Secure Databases" withExtension:@"mp4"];
    sectionSecureDatabases.customImage = [UIImage imageNamed:@"09_Secure-Databases"];
    url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                  pathForResource:@"consent-databases" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
    sectionSecureDatabases.htmlContent = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    ORKConsentSection *sectionWithdrawing =
    [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeCustom ];
    sectionWithdrawing.title = @"Withdrawing";
    sectionWithdrawing.summary = @"Your participation in this study is voluntary. You may withdraw your consent and stop your participation at any time.";
    sectionWithdrawing.customLearnMoreButtonTitle = @"Learn More";
    sectionWithdrawing.customAnimationURL = [[NSBundle mainBundle] URLForResource:@"10_Withdrawing" withExtension:@"mp4"];
    sectionWithdrawing.customImage = [UIImage imageNamed:@"10_Withdrawing"];
    url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                  pathForResource:@"consent-withdrawing" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
    sectionWithdrawing.htmlContent = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    
    
    self.document.sections = @[sectionOverview, sectionUnderstanding, sectionInsight, sectionSurveys, sectionSensorData, sectionDataUse, sectionTimeCommitment, sectionPotentialBenefits, sectionProtectingYourPrivacy, sectionSecureDatabases, sectionWithdrawing];
    
    ORKVisualConsentStep *visualStep =
    [[ORKVisualConsentStep alloc] initWithIdentifier:@"VisualConsentIdentifier"
                                            document:self.document];
    
    PRIDEConsentOrderedTask *task =
    [[PRIDEConsentOrderedTask alloc] initWithIdentifier:@"ConsentTaskIdentifier"
                                                  steps:@[visualStep]];
    
    taskViewController = [[ORKTaskViewController alloc] initWithTask:task taskRunUUID:nil];
    [taskViewController setShowsProgressInNavigationBar:NO];
    taskViewController.delegate = self;
    
    [taskViewController.navigationBar.topItem setTitle:@"Consent"];
    taskViewController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor grayColor]};
    
    [self presentViewController:taskViewController animated:YES completion:nil];
}
- (void) taskViewController:(ORKTaskViewController * __nonnull)taskViewController didFinishWithReason:(ORKTaskViewControllerFinishReason)reason error:(nullable NSError *)error{
    
    //resolves PRI-190

    
    [self dismissViewControllerAnimated:true completion:NULL];
    
    AppDelegate* appD = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appD update_user_data];
}
- (void) moviePlayBackDidFinish:(NSNotification*)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:self.controller];
    
    [self dismissMoviePlayerViewControllerAnimated];
}





/////////////////////////////////////////////////////////////////
// DEMOGRAPHIC SURVEY: THIS NEEDS TO BE MOVED TO A GLOBAL FUNCTION SOME HOW
/////////////////////////////////////////////////////////////////

- (void)startDemographicSurvey{
    NSArray *choicesText;
    ORKAnswerFormat *formatAnswer;
    
    choicesText = [NSArray arrayWithObjects:
                   [ORKTextChoice choiceWithText:@"Female" value:@"1"],
                   [ORKTextChoice choiceWithText:@"Male" value:@"2"], nil];
    formatAnswer = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice textChoices:choicesText];
    ORKQuestionStep *stepSex =
    [ORKQuestionStep questionStepWithIdentifier:SURVEY_SEX
                                          title:@"What sex were you assigned (on your birth certificate)?"
                                         answer:formatAnswer];
    
    choicesText = [NSArray arrayWithObjects:
                   [ORKTextChoice choiceWithText:@"Asexual" value:@"Asexual"],
                   [ORKTextChoice choiceWithText:@"Bisexual" value:@"Bisexual"],
                   [ORKTextChoice choiceWithText:@"Gay" value:@"Gay"],
                   [ORKTextChoice choiceWithText:@"Lesbian" value:@"Lesbian"],
                   [ORKTextChoice choiceWithText:@"Queer" value:@"Queer"],
                   [ORKTextChoice choiceWithText:@"Questioning" value:@"Questioning"],
                   [ORKTextChoice choiceWithText:@"Straight/Heterosexual" value:@"Straight/Heterosexual"],
                   [ORKTextChoice choiceWithText:@"Another sexual orientation" value:@"Another"],nil];
    formatAnswer = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleMultipleChoice textChoices:choicesText];
    ORKQuestionStep *stepOrientation =
    [ORKQuestionStep questionStepWithIdentifier:SURVEY_SEXUAL_ORIENTATION
                                          title:@"How would you describe your current sexual orientation? (Select all that apply)"
                                         answer:formatAnswer];
    // CONDITIONAL
    formatAnswer = [ORKAnswerFormat textAnswerFormat];
    ORKQuestionStep *stepOrientation_a =
    [ORKQuestionStep questionStepWithIdentifier:SURVEY_SEXUAL_ORIENTATION_A
                                          title:@"Please tell us about your sexual orientation."
                                         answer:formatAnswer];
    
    choicesText = [NSArray arrayWithObjects:
                   [ORKTextChoice choiceWithText:@"Genderqueer" value:@"Genderqueer"],
                   [ORKTextChoice choiceWithText:@"Man" value:@"Man"],
                   [ORKTextChoice choiceWithText:@"Transgender Man (Female­-to-­Male)" value:@"Transgender Man (Female­-to-­Male)"],
                   [ORKTextChoice choiceWithText:@"Woman" value:@"Woman"],
                   [ORKTextChoice choiceWithText:@"Transgender Woman (Male­-to-­Female)" value:@"Transgender Woman (Male­-to-­Female)"],
                   [ORKTextChoice choiceWithText:@"Another gender identity" value:@"Another"], nil];
    formatAnswer = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleMultipleChoice textChoices:choicesText];
    ORKQuestionStep *stepGenderIdentity =
    [ORKQuestionStep questionStepWithIdentifier:SURVEY_GENDER_IDENTITY
                                          title:@"How would you describe your current gender identity? (Select all that apply)"
                                         answer:formatAnswer];
    // CONDITIONAL
    formatAnswer = [ORKAnswerFormat textAnswerFormat];
    ORKQuestionStep *stepGenderIdentity_a =
    [ORKQuestionStep questionStepWithIdentifier:SURVEY_GENDER_IDENTITY_A
                                          title:@"Please tell us about your gender identity."
                                         answer:formatAnswer];
    
    formatAnswer = [ORKBooleanAnswerFormat new];
    ORKQuestionStep *stepBornInUS =
    [ORKQuestionStep questionStepWithIdentifier:SURVEY_BORN_IN_US
                                          title:@"Were you born in the United States? "
                                         answer:formatAnswer];
    
    formatAnswer = [ORKBooleanAnswerFormat new];
    ORKQuestionStep *stepHispanic =
    [ORKQuestionStep questionStepWithIdentifier:SURVEY_HISPANIC
                                          title:@"Are you Hispanic, Latino, or of Spanish Origin?"
                                         answer:formatAnswer];
    // CONDITIONAL
    choicesText = [NSArray arrayWithObjects:
                   [ORKTextChoice choiceWithText:@"Mexican, Mexican-American, or Chicano" value:@"Mexican"],
                   [ORKTextChoice choiceWithText:@"Puerto Rican" value:@"Puerto Rican"],
                   [ORKTextChoice choiceWithText:@"Cuban" value:@"Cuban"],
                   [ORKTextChoice choiceWithText:@"Another Hispanic/Latino/Spanish Origin" value:@"Another"],nil];
    formatAnswer = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleMultipleChoice textChoices:choicesText];
    ORKQuestionStep *stepHispanic_a =
    [ORKQuestionStep questionStepWithIdentifier:SURVEY_HISPANIC_A
                                          title:@"Please select your ethnicity. (Select all that apply.)"
                                         answer:formatAnswer];
    
    
    // ----- CONDITIONAL
    formatAnswer = [ORKAnswerFormat textAnswerFormat];
    ORKQuestionStep *stepHispanic_b =
    [ORKQuestionStep questionStepWithIdentifier:SURVEY_HISPANIC_B
                                          title:@"Please tell us about your origin (e.g., Argentinian, Colombian, Dominican, Nicaraguan, Salvadoran, Spaniard)."
                                         answer:formatAnswer];
    
    choicesText = [NSArray arrayWithObjects:
                   [ORKTextChoice choiceWithText:@"White" value:@"White"],
                   [ORKTextChoice choiceWithText:@"Black, African-­American, or Negro" value:@"Black"],
                   [ORKTextChoice choiceWithText:@"American Indian or Alaska Native" value:@"American Indian"],
                   [ORKTextChoice choiceWithText:@"Asian Indian" value:@"Asian Indian"],
                   [ORKTextChoice choiceWithText:@"Chinese" value:@"Chinese"],
                   [ORKTextChoice choiceWithText:@"Filipino" value:@"Filipino"],
                   [ORKTextChoice choiceWithText:@"Japanese" value:@"Japanese"],
                   [ORKTextChoice choiceWithText:@"Korean" value:@"Korean"],
                   [ORKTextChoice choiceWithText:@"Vietnamese" value:@"Vietnamese"],
                   [ORKTextChoice choiceWithText:@"Native Hawaiian" value:@"Native Hawaiian"],
                   [ORKTextChoice choiceWithText:@"Guamanian or Chamorro" value:@"Guamanian or Chamorro"],
                   [ORKTextChoice choiceWithText:@"Samoan" value:@"Samoan"],
                   [ORKTextChoice choiceWithText:@"Other Pacific Islander" value:@"Other Pacific Islander"],
                   [ORKTextChoice choiceWithText:@"Other Asian" value:@"Other Asian"],
                   [ORKTextChoice choiceWithText:@"Another race" value:@"Another"], nil];
    formatAnswer = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleMultipleChoice textChoices:choicesText];
    ORKQuestionStep *stepRace =
    [ORKQuestionStep questionStepWithIdentifier:SURVEY_RACE
                                          title:@"What is your race? (Select all that apply.)"
                                         answer:formatAnswer];
    
    // SEVERAL CONDITIONALS HERE FOR RACE
    formatAnswer = [ORKAnswerFormat textAnswerFormat];
    ORKQuestionStep *stepRace_native =
    [ORKQuestionStep questionStepWithIdentifier:SURVEY_RACE_A
                                          title:@"What is your enrolled or principal tribe?"
                                         answer:formatAnswer];
    formatAnswer = [ORKAnswerFormat textAnswerFormat];
    ORKQuestionStep *stepRace_another =
    [ORKQuestionStep questionStepWithIdentifier:SURVEY_RACE_B
                                          title:@"Please tell us about your race."
                                         answer:formatAnswer];
    
    
    choicesText = [NSArray arrayWithObjects:
                   [ORKTextChoice choiceWithText:@"No schooling" value:@"No School"],
                   [ORKTextChoice choiceWithText:@"Nursery school to high school, no diploma" value:@"Nursery"],
                   [ORKTextChoice choiceWithText:@"High school graduate or equivalent (e.g., GED)" value:@"High school"],
                   [ORKTextChoice choiceWithText:@"Trade/Technical/Vocational training" value:@"Trade"],
                   [ORKTextChoice choiceWithText:@"Some college" value:@"Some college"],
                   [ORKTextChoice choiceWithText:@"2-year college degree" value:@"2­ year"],
                   [ORKTextChoice choiceWithText:@"4-­year college degree" value:@"4 ­year"],
                   [ORKTextChoice choiceWithText:@"Master’s degree" value:@"Master’s"],
                   [ORKTextChoice choiceWithText:@"Doctoral degree" value:@"Doctoral"],
                   [ORKTextChoice choiceWithText:@"Professional degree (e.g., M.D., J.D., M.B.A.)" value:@"Professional"], nil];
    formatAnswer = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice textChoices:choicesText];
    ORKQuestionStep *stepEducation =
    [ORKQuestionStep questionStepWithIdentifier:SURVEY_EDUCATION
                                          title:@"What is your highest education level completed?"
                                         answer:formatAnswer];
    
    
    choicesText = [NSArray arrayWithObjects:
                   [ORKTextChoice choiceWithText:@"$0-5,000" value:@"$0-5,000"],
                   [ORKTextChoice choiceWithText:@"$5,001-­10,000" value:@"$5,001-­10,000"],
                   [ORKTextChoice choiceWithText:@"$10,001-­15,000" value:@"$10,001-­15,000"],
                   [ORKTextChoice choiceWithText:@"$15,001-­20,000" value:@"$15,001-­20,000"],
                   [ORKTextChoice choiceWithText:@"$20,001-­30,000" value:@"$20,001-­30,000"],
                   [ORKTextChoice choiceWithText:@"$30,001­-40,000" value:@"$30,001­-40,000"],
                   [ORKTextChoice choiceWithText:@"$40,001-­50,000" value:@"$40,001-­50,000"],
                   [ORKTextChoice choiceWithText:@"$50,001­-60,000" value:@"$50,001­-60,000"],
                   [ORKTextChoice choiceWithText:@"$60,001­-70,000" value:@"$60,001­-70,000"],
                   [ORKTextChoice choiceWithText:@"$70,001-­80,000" value:@"$70,001-­80,000"],
                   [ORKTextChoice choiceWithText:@"$80,001-­90,000" value:@"$80,001-­90,000"],
                   [ORKTextChoice choiceWithText:@"$90,001-­100,000" value:@"$90,001-­100,000"],
                   [ORKTextChoice choiceWithText:@"$100,001+" value:@"$100,001+"],nil];
    formatAnswer = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice textChoices:choicesText];
    ORKQuestionStep *stepIncome =
    [ORKQuestionStep questionStepWithIdentifier:SURVEY_INCOME
                                          title:@"What is your annual gross income (before taxes and deductions) from all sources?"
                                         answer:formatAnswer];
    
    formatAnswer = [ORKBooleanAnswerFormat new];
    ORKQuestionStep *stepArmedServices =
    [ORKQuestionStep questionStepWithIdentifier:SURVEY_ARMED_SERVICES
                                          title:@"Are you currently or have you ever been a member of the United States Armed Services?"
                                         answer:formatAnswer];
    
    formatAnswer = [ORKBooleanAnswerFormat new];
    ORKQuestionStep *stepHealthInsurance =
    [ORKQuestionStep questionStepWithIdentifier:SURVEY_HEALTH_INSURANCE
                                          title:@"Do you currently have health insurance?"
                                         answer:formatAnswer];
    
    formatAnswer = [ORKBooleanAnswerFormat new];
    ORKQuestionStep *stepRelationship =
    [ORKQuestionStep questionStepWithIdentifier:SURVEY_RELATIONSHIP
                                          title:@"Are you currently in a relationship?"
                                         answer:formatAnswer];
    // SEVERAL CONDITIONALS HERE FOR RELATIONSHIP
    choicesText = [NSArray arrayWithObjects:
                   [ORKTextChoice choiceWithText:@"Dating (not living together)" value:@"Dating"],
                   [ORKTextChoice choiceWithText:@"Cohabitation (living together)" value:@"Cohabitation"],
                   [ORKTextChoice choiceWithText:@"Civil union/Domestic partnership" value:@"Civil union"],
                   [ORKTextChoice choiceWithText:@"Married" value:@"Married"],
                   [ORKTextChoice choiceWithText:@"Another relationship" value:@"Another"], nil];
    formatAnswer = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice textChoices:choicesText];
    ORKQuestionStep *stepRelationship_yes =
    [ORKQuestionStep questionStepWithIdentifier:SURVEY_RELATIONSHIP_YES
                                          title:@"Which of the following best describes you?"
                                         answer:formatAnswer];
    formatAnswer = [ORKAnswerFormat textAnswerFormat];
    ORKQuestionStep *stepRelationship_another =
    [ORKQuestionStep questionStepWithIdentifier:SURVEY_RELATIONSHIP_ANOTHER
                                          title:@"Please tell us about your relationship status."
                                         answer:formatAnswer];
    choicesText = [NSArray arrayWithObjects:
                   [ORKTextChoice choiceWithText:@"Single, never married or in civil union/domestic partnership" value:@"Single"],
                   [ORKTextChoice choiceWithText:@"Separated" value:@"Separated"],
                   [ORKTextChoice choiceWithText:@"Divorced" value:@"Divorced"],
                   [ORKTextChoice choiceWithText:@"Widowed" value:@"Widowed"], nil];
    formatAnswer = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice textChoices:choicesText];
    ORKQuestionStep *stepRelationship_no =
    [ORKQuestionStep questionStepWithIdentifier:SURVEY_RELATIONSHIP_NO
                                          title:@"Which of the following best describes you?"
                                         answer:formatAnswer];
    
    choicesText = [NSArray arrayWithObjects:
                   [ORKTextChoice choiceWithText:@"Social Media" value:@"Social"],
                   [ORKTextChoice choiceWithText:@"Email from a friend" value:@"Email"],
                   [ORKTextChoice choiceWithText:@"Health professional or health center" value:@"Health"],
                   [ORKTextChoice choiceWithText:@"LGBTQ-focused organization" value:@"organization"],
                   [ORKTextChoice choiceWithText:@"Billboard" value:@"Billboard"],
                   [ORKTextChoice choiceWithText:@"TV ad" value:@"TV"],
                   [ORKTextChoice choiceWithText:@"Print Ad" value:@"Print"],
                   [ORKTextChoice choiceWithText:@"Searching online (e.g., Google, etc.)" value:@"Searching"],
                   [ORKTextChoice choiceWithText:@"General media coverage (e.g., news story, radio, print, TV, online)" value:@"General"], nil];
    formatAnswer = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleMultipleChoice textChoices:choicesText];
    ORKQuestionStep *stepFinal =
    [ORKQuestionStep questionStepWithIdentifier:SURVEY_HOW_DID_YOU_HEAR
                                          title:@"How did you hear about The PRIDE Study? (Select all that apply.)"
                                         answer:formatAnswer];
    
    // Create a task with all the steps
    PRIDEOrderedTask *task =
    [[PRIDEOrderedTask alloc] initWithIdentifier:SURVEY_DEMOGRAPHIC_SURVEY_TASK_IDENTIFIER
                                           steps:@[stepSex, stepOrientation, stepOrientation_a, stepGenderIdentity, stepGenderIdentity_a, stepBornInUS, stepHispanic, stepHispanic_a, stepHispanic_b, stepRace, stepRace_native, stepRace_another, stepEducation, stepIncome, stepArmedServices, stepHealthInsurance, stepRelationship, stepRelationship_yes, stepRelationship_another, stepRelationship_no, stepFinal]];
    
    // Create a task view controller using the task and set a delegate.
    self.task_demographicSurvey = [[ORKTaskViewController alloc] initWithTask:task taskRunUUID:nil];
    self.task_demographicSurvey.delegate = self;
    [self.task_demographicSurvey setShowsProgressInNavigationBar:NO];
    [self.task_demographicSurvey.navigationBar.topItem setTitle:@"Demographic Survey"];
    
    // Present the task view controller.
    [self presentViewController:self.task_demographicSurvey animated:YES completion:nil];
}

- (IBAction)notifyServer:(NSString*)responseid {
    //Get API Data
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


@end
