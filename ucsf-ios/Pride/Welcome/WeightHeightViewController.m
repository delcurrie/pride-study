//
//  WeightHeightViewController.m
//  Pride
//
//  Created by Patrick Krabeepetcharat on 5/22/15.
//  Copyright (c) 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import "WeightHeightViewController.h"
#include <math.h>
#import "UIColor+constants.h"

#import "AppConstants.h"
@interface WeightHeightViewController ()
{
    UIPickerView * heightPicker;
    NSArray* feetArray;
    
    NSArray* inchesArray;
}

@end

@implementation WeightHeightViewController

- (void)viewWillAppear:(BOOL)animated{
    //    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    //    self.healthStore = appDelegate.healthStore;
    
    self.navigationItem.hidesBackButton = YES;
}

- (void)viewDidAppear:(BOOL)animated{
    // RadiumOne Tracking
    [[R1Emitter sharedInstance] emitScreenViewWithDocumentTitle:@"Height and Weight"
                                             contentDescription:nil
                                            documentLocationUrl:nil
                                               documentHostName:nil
                                                   documentPath:nil
                                                      otherInfo:nil];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Height and Weight"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (IBAction)weightPressed:(id)sender {
    [self.view endEditing:true];
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
        _label_weight.text=[NSString stringWithFormat:@"%.2f",value];
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
- (void)saveWeightIntoHealthStore:(double)weight {
    // Save the user's weight into HealthKit.
//    HKUnit *poundUnit = [HKUnit poundUnit];
//    HKQuantity *weightQuantity = [HKQuantity quantityWithUnit:poundUnit doubleValue:weight];
//    
//    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
//    NSDate *now = [NSDate date];
//    
//    HKQuantitySample *weightSample = [HKQuantitySample quantitySampleWithType:weightType quantity:weightQuantity startDate:now endDate:now];
//    
//    [self.healthStore saveObject:weightSample withCompletion:^(BOOL success, NSError *error) {
//        if (!success) {
//            NSLog(@"An error occured saving the weight sample %@. In your app, try to handle this gracefully. The error was: %@.", weightSample, error);
//            //  abort();
//        }
//        
//    }];
    
    NSString* weightstring=[NSString stringWithFormat:@"%.2f", weight];
    [[NSUserDefaults standardUserDefaults] setObject:weightstring forKey:USER_WEIGHT_IDENTIFIER];
    [self updateUsersWeightLabel];

}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.healthStore = [[HKHealthStore alloc] init];
    feetArray= [NSArray arrayWithObjects:@"1'",@"2'",@"3'",@"4'", @"5'", @"6'", @"7'", nil],
    inchesArray=[NSArray arrayWithObjects:@"0\"", @"1\"", @"2\"", @"3\"", @"4\"", @"5\"", @"6\"", @"7\"", @"8\"", @"9\"", @"10\"", @"11\"", nil];
    
    _heightField.textColor=[UIColor primaryColor];
    _label_weight.textColor=[UIColor primaryColor];

    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationItem setTitle:@"Additional Information"];
    
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(handler_next)];
    [self.navigationItem setRightBarButtonItem:nextButton];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // Update the user interface based on the current user's health information.
        // [self updateUsersAgeLabel];
        [self updateUsersHeightLabel];
        [self updateUsersWeightLabel];
    });
    
    
    heightPicker = [[UIPickerView alloc]init];
    heightPicker.delegate=self;
    
    CGRect frame=heightPicker.frame;
    
    //    [heightPicker addTarget:self action:@selector(birthdayField:) forControlEvents:UIControlEventValueChanged];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    UIView *view= [[UIView alloc] initWithFrame:CGRectMake(0,0,screenWidth,frame.size.height)];
    
    
    [view addSubview:heightPicker];
    
    UIToolbar *toolBar2= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,screenWidth,44)];
    
    toolBar2.barStyle = UIBarStyleDefault;
    
    UIBarButtonItem *space2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *done2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTapped:)];
    
    toolBar2.items = [NSArray arrayWithObjects:space2,done2, nil];
    
    [_heightField setInputAccessoryView:toolBar2];
    
    [_heightField setInputView:view];
    
}
-(void) doneTapped:(id)sender
{
    [_heightField resignFirstResponder];
    
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:true];
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if(component== 0)
    {
        return [feetArray objectAtIndex:row];
    }
    else
    {
        return [inchesArray objectAtIndex:row];
        
    }
    
    return 0;
    
}


-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 2;
    
    
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    
    if(component== 0)
    {
        return [feetArray count];
    }
    else if (component== 1)
    {
        return [inchesArray count];
        
    }
    
    return 0;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row   inComponent:(NSInteger)component{
    
    
    NSInteger firstComponentRow = [heightPicker selectedRowInComponent:0];
    NSInteger secondComponentRow = [heightPicker selectedRowInComponent:1];
    
    double height=(firstComponentRow+1)*12;
    height+=secondComponentRow;
    [self saveHeightIntoHealthStore:height];
    int feet=(int)(height/12);
    int inches=(int)((int)height%12);
    
    _heightField.text=[NSString stringWithFormat:@"%d' %d\"",feet,inches];
    
    //_heightField.text=[NSString stringWithFormat:@"%2.f",height];
    
}

-(void)doneTapped
{
    [_heightField resignFirstResponder];
    
}
- (void)saveHeightIntoHealthStore:(double)height {
    // Save the user's height into HealthKit.
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
//    }];
    NSString* heightstring=[NSString stringWithFormat:@"%02f", height];

    [[NSUserDefaults standardUserDefaults] setObject:heightstring forKey:USER_HEIGHT_IDENTIFIER];
    
    [self updateUsersHeightLabel];

}

- (void)updateUsersAgeLabel {
    //    // Set the user's age unit (years).
    //    self.ageUnitLabel.text = NSLocalizedString(@"Age (yrs)", nil);
    //
    //    NSError *error;
    //    NSDate *dateOfBirth = [self.healthStore dateOfBirthWithError:&error];
    //
    //    if (!dateOfBirth) {
    //        NSLog(@"Either an error occured fetching the user's age information or none has been stored yet. In your app, try to handle this gracefully.");
    //
    //        self.ageValueLabel.text = NSLocalizedString(@"Not available", nil);
    //    }
    //    else {
    //        // Compute the age of the user.
    //        NSDate *now = [NSDate date];
    //
    //        NSDateComponents *ageComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:dateOfBirth toDate:now options:NSCalendarWrapComponents];
    //
    //        NSUInteger usersAge = [ageComponents year];
    //
    //        self.ageValueLabel.text = [NSNumberFormatter localizedStringFromNumber:@(usersAge) numberStyle:NSNumberFormatterNoStyle];
    //    }
}

- (void)updateUsersHeightLabel {
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
                    if(heightString && [heightString length]>0)
                    {
                        double usersHeight=[heightString doubleValue];
                        int heightvalue=(int)ceil(usersHeight);
                        int feet=(int)(heightvalue/12);
                        int inches=(int)((int)heightvalue%12);
                        _heightField.text=[NSString stringWithFormat:@"%d' %d\"",feet,inches];

                        
                    }
                    else
                    {
                        _heightField.text = NSLocalizedString(@"Tap to add", nil);
                    }
                
                });
            }
                    
        else {
            // Determine the height in the required unit.
            HKUnit *heightUnit = [HKUnit inchUnit];
            double usersHeight = [mostRecentQuantity doubleValueForUnit:heightUnit];
            
            // Update the user interface.
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                NSString* heightString=[[NSUserDefaults standardUserDefaults] objectForKey:USER_HEIGHT_IDENTIFIER];
                if(heightString && [heightString length]>0)
                {
                    double usersHeight=[heightString doubleValue];
                    int heightvalue=(int)ceil(usersHeight);
                    int feet=(int)(heightvalue/12);
                    int inches=(int)((int)heightvalue%12);
                    _heightField.text=[NSString stringWithFormat:@"%d' %d\"",feet,inches];
                    
                    
                }
                else
                {
                int heightvalue=(int)ceil(usersHeight);
                int feet=(int)(heightvalue/12);
                int inches=(int)((int)heightvalue%12);
                
                _heightField.text=[NSString stringWithFormat:@"%d' %d\"",feet,inches];
                }
                //_heightField.text = [NSNumberFormatter localizedStringFromNumber:@(usersHeight) numberStyle:NSNumberFormatterNoStyle];
            });
        }
    }];
}

- (void)updateUsersWeightLabel {
    
    // Fetch the user's default weight unit in pounds.
    NSMassFormatter *massFormatter = [[NSMassFormatter alloc] init];
    massFormatter.unitStyle = NSFormattingUnitStyleLong;
    
    //    NSMassFormatterUnit weightFormatterUnit = NSMassFormatterUnitPound;
    //    NSString *weightUnitString = [massFormatter unitStringFromValue:10 unit:weightFormatterUnit];
    //    NSString *localizedWeightUnitDescriptionFormat = NSLocalizedString(@"Weight (%@)", nil);
    //
    //    self.weightUnitLabel.text = [NSString stringWithFormat:localizedWeightUnitDescriptionFormat, weightUnitString];
    
    // Query to get the user's latest weight, if it exists.
    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    
    [self.healthStore aapl_mostRecentQuantitySampleOfType:weightType predicate:nil completion:^(HKQuantity *mostRecentQuantity, NSError *error) {
        
        if (!mostRecentQuantity) {
            NSLog(@"Either an error occured fetching the user's weight information or none has been stored yet. In your app, try to handle this gracefully.");
            NSString* weightstring=[[NSUserDefaults standardUserDefaults] objectForKey:USER_WEIGHT_IDENTIFIER];
            dispatch_async(dispatch_get_main_queue(), ^{
                if(weightstring && [weightstring length]>0)
                {
                     self.label_weight.text =weightstring;
                }
                else
                {
                self.label_weight.text = NSLocalizedString(@"Tap to add", nil);
                }
            });
        }
        else {
            // Determine the weight in the required unit.
            HKUnit *weightUnit = [HKUnit poundUnit];
            double usersWeight = [mostRecentQuantity doubleValueForUnit:weightUnit];
            
            // Update the user interface.
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString* weightstring=[[NSUserDefaults standardUserDefaults] objectForKey:USER_WEIGHT_IDENTIFIER];
                if(weightstring && [weightstring length]>0)
                {
                self.label_weight.text =weightstring;
                }
                else
                {
                self.label_weight.text = [NSNumberFormatter localizedStringFromNumber:@(usersWeight) numberStyle:NSNumberFormatterNoStyle];
                }
            });
        }
    }];
}

- (void)handler_next{
    // Do registration stuff here
    
    AppDelegate* appD = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appD updateUserInfo];
    [appD update_user_data];
    [self performSegueWithIdentifier:@"Permissions" sender:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
