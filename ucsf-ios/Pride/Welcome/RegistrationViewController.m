//
//  RegistrationViewController.m
//  Pride
//
//  Created by Patrick Krabeepetcharat on 5/22/15.
//  Copyright (c) 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import "RegistrationViewController.h"
#import "MBProgressHUD.h"
#import "AppConstants.h"
#import "HKHealthStore+AAPLExtensions.h"
#import <ResearchKit/ResearchKit.h>
#import "Reachability.h"

@interface RegistrationViewController ()
{
    UIDatePicker* datePicker;
}

@property bool isValid_email;
@property bool isValid_password;
@property bool isValid_zip;
@property bool isValid_birthday;

@end

@implementation RegistrationViewController

- (void)viewDidAppear:(BOOL)animated{
    // RadiumOne Tracking
    [[R1Emitter sharedInstance] emitScreenViewWithDocumentTitle:@"Registration"
                                             contentDescription:nil
                                            documentLocationUrl:nil
                                               documentHostName:nil
                                                   documentPath:nil
                                                      otherInfo:nil];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Registration"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}
-(void)doneZipClicked
{
    [self.view endEditing:true];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Set up the Nav title bar
//    _birthdayField.text=@"";
    _birthdayField.placeholder=@"tap to add";
    [self.img_validBirthday setImage:[UIImage imageNamed:@"invalid_icon"]];

    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(handler_next)];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationItem setTitle:@"Registration"];
    [self.navigationItem setRightBarButtonItem:nextButton];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
    // Preset the name from the consent
    NSString *nameFirst = [[NSUserDefaults standardUserDefaults] valueForKey:USER_FIRST_NAME_IDENTIFIER];
    NSString *nameLast = [[NSUserDefaults standardUserDefaults] valueForKey:USER_LAST_NAME_IDENTIFIER];
    NSString *nameFull = [NSString stringWithFormat:@"%@ %@", nameFirst, nameLast];
    
    [self.textField_name setText:nameFull];
    
    // Set Text Field Delegate
    self.textField_email.delegate = self;
    self.textField_password.delegate=self;
    self.textField_zip.delegate=self;
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneZipClicked)];

//    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
  //                                                                 style:UIBarButtonItemStyleBordered target:self
    //                                                              action:@selector(doneZipClicked)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:space,doneButton, nil]];
    
    
    
    self.textField_zip.inputAccessoryView = keyboardDoneButtonView;

    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setBarStyle:UIBarStyleDefault];
    [toolbar sizeToFit];
    UIBarButtonItem *buttonflexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *buttonDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTapped:)];
    
    [toolbar setItems:[NSArray arrayWithObjects:buttonflexible,buttonDone, nil]];
    _birthdayField.inputAccessoryView = toolbar;
   // _appointmentDate.minimumDate=[NSDate date];
    
   // _appointmentTime.inputAccessoryView = toolbar;
    // _appointmentTime.minimumDate=[NSDate date];
    NSDateComponents *minusHundredYears = [NSDateComponents new];
    minusHundredYears.year = -18;
    NSDate *newdate = [[NSCalendar currentCalendar] dateByAddingComponents:minusHundredYears
                                                                    toDate:[NSDate date]
                                                                   options:0];
    
    [_birthdayField setDropDownMode:IQDropDownModeDatePicker];
    [_birthdayField setDate:newdate animated:NO];

    
    [_birthdayField setMaximumDate:[NSDate date]];
    [_birthdayField setCurrentText:@""];
    _birthdayField.delegate=self;

    
    [self validateFields];
}

-(void) doneTapped:(id)sender
{
    [_birthdayField resignFirstResponder];
    [self validateDOB];
}
-(void) validateDOB
{
    if(_birthdayField.text.length==0)
    {
        self.isValid_birthday = NO;
    
    [self validateFields];
        return;
    }

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy"];

    NSDate *eventDate = [dateFormat dateFromString:_birthdayField.text];
//
//    NSString *dateString = [dateFormat stringFromDate:eventDate];
//    _birthdayField.text = [NSString stringWithFormat:@"%@",dateString];
    
    [[NSUserDefaults standardUserDefaults] setObject:_birthdayField.text forKey:USER_BIRTHDAY_IDENTIFIER];
    
    
    NSDate* now = [NSDate date];
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                       components:NSCalendarUnitYear
                                       fromDate:eventDate
                                       toDate:now
                                       options:0];
    NSInteger age = [ageComponents year];
    dispatch_async(dispatch_get_main_queue(), ^{
        if(age<18)
        {
            [self.img_validBirthday setImage:[UIImage imageNamed:@"invalid_icon"]];
            self.isValid_birthday = NO;
        }
        else
        {
            [self.img_validBirthday setImage:[UIImage imageNamed:@"valid_icon"]];
            self.isValid_birthday = YES;
        }
        
        [self validateFields];
    });
   }
-(void)textField:(nonnull IQDropDownTextField*)textField didSelectItem:(nullable NSString*)item{
    [self validateDOB];
}
- (void)viewWillAppear:(BOOL)animated{
    self.healthStore = [[HKHealthStore alloc] init];
    
    // Initially hide the activity indicator
    [self hideActivityIndicator];
//        _birthdayField.text=@"";
    [_birthdayField setCurrentText:@""];

    // Set up an HKHealthStore, asking the user for read/write permissions. The profile view controller is the
    // first view controller that's shown to the user, so we'll ask for all of the desired HealthKit permissions now.
    // In your own app, you should consider requesting permissions the first time a user wants to interact with
    // HealthKit data.
    if ([HKHealthStore isHealthDataAvailable]) {
        NSSet *writeDataTypes = [self dataTypesToWrite];
        NSSet *readDataTypes = [self dataTypesToRead];
        
        [self.healthStore requestAuthorizationToShareTypes:writeDataTypes readTypes:readDataTypes completion:^(BOOL success, NSError *error) {
            if (!success) {
                NSLog(@"You didn't allow HealthKit to access these read/write data types. In your app, try to handle this error gracefully when a user decides not to provide access. The error was: %@. If you're using a simulator, try it on a device.", error);
               // [self updateUsersAgeLabel];
                NSString* date=[[NSUserDefaults standardUserDefaults] objectForKey:USER_BIRTHDAY_IDENTIFIER];
                if(date && [date length]>0)
                {
                    //if date is on user defaults
                    
                    [_birthdayField setCurrentText:date];

                    NSDateFormatter* myFormatter = [[NSDateFormatter alloc] init];
                    [myFormatter setDateFormat:@"MM/dd/yyyy"];
                    NSDate* myDate = [myFormatter dateFromString:date];
                    [datePicker setDate:myDate];
                    
                    NSDate* now = [NSDate date];
                    NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                                       components:NSCalendarUnitYear
                                                       fromDate:myDate
                                                       toDate:now
                                                       options:0];
                    NSInteger age = [ageComponents year];
                    
                    if(age<18)
                    {
                        [self.img_validBirthday setImage:[UIImage imageNamed:@"invalid_icon"]];
                        self.isValid_birthday = NO;
                    }
                    else
                    {
                        [self.img_validBirthday setImage:[UIImage imageNamed:@"valid_icon"]];
                        self.isValid_birthday = YES;
                    }
                    
                    
                }
                else
                {
                    [self.img_validBirthday setImage:[UIImage imageNamed:@"invalid_icon"]];
                    self.isValid_birthday = NO;
                }

                return;
            }
            else
            {
                NSDate *dateOfBirth = [self.healthStore dateOfBirthWithError:&error];
                if(dateOfBirth)
                {
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
                    NSString *stringBirthday = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:dateOfBirth]];
                    [[NSUserDefaults standardUserDefaults] setObject:stringBirthday forKey:USER_BIRTHDAY_IDENTIFIER];
                    
                    [_birthdayField setCurrentText:stringBirthday];
                    
                    NSDate* now = [NSDate date];
                    NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                                       components:NSCalendarUnitYear
                                                       fromDate:dateOfBirth
                                                       toDate:now
                                                       options:0];
                    NSInteger age = [ageComponents year];
                    
                    [datePicker setDate:dateOfBirth];

                    
                    if(age<18)
                    {
                        [self.img_validBirthday setImage:[UIImage imageNamed:@"invalid_icon"]];
                        self.isValid_birthday = NO;
                    }
                    else
                    {
                        [self.img_validBirthday setImage:[UIImage imageNamed:@"valid_icon"]];
                        self.isValid_birthday = YES;
                    }
                }
               // [self updateUsersAgeLabel];
                
            }
        }];
    }
    
    // Set Healthstore to AppDelegate so other views can use it later
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate setHealthStore:self.healthStore];
}


// Returns the types of data that Fit wishes to write to HealthKit.
- (NSSet *)dataTypesToWrite {
//    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
//    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    
    return [NSSet setWithObjects: nil];
}

// Returns the types of data that Fit wishes to read from HealthKit.
- (NSSet *)dataTypesToRead {
    HKCharacteristicType *birthdayType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    HKQuantityType *stepsType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKQuantityType *distanceType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    HKQuantityType *flightsType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierFlightsClimbed];
    
    return [NSSet setWithObjects:birthdayType, heightType, weightType, stepsType, distanceType, flightsType, nil];
}

- (void)showActivityIndicator{
    [self.activity setHidden:NO];
    [self.activity startAnimating];
}

- (void)hideActivityIndicator{
    [self.activity setHidden:YES];
    [self.activity stopAnimating];
}


#pragma mark Text Field Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    // handle email field
    if([textField isEqual:self.textField_email]){
        NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{0,50}";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
        
        if ([emailTest evaluateWithObject:self.textField_email.text] == NO) {
            [self.img_validEmail setImage:[UIImage imageNamed:@"invalid_icon"]];
            self.isValid_email = NO;
        }else{
            [self.img_validEmail setImage:[UIImage imageNamed:@"valid_icon"]];
            self.isValid_email = YES;
        }
    }
    else if([textField isEqual:self.textField_password])
    {
        NSString * proposedNewString = [[self.textField_password text] stringByReplacingCharactersInRange:range withString:string];

        if(proposedNewString.length<4)
        {
            [self.img_validPassword setImage:[UIImage imageNamed:@"invalid_icon"]];
            self.isValid_password = NO;
        }
        else
        {
            [self.img_validPassword setImage:[UIImage imageNamed:@"valid_icon"]];
            self.isValid_password = YES;
        }
    }
    else if([textField isEqual:self.textField_zip])
    {
        NSString * proposedNewString = [[self.textField_zip text] stringByReplacingCharactersInRange:range withString:string];
        
        if(proposedNewString.length<5)
        {
            [self.img_validZip setImage:[UIImage imageNamed:@"invalid_icon"]];
            self.isValid_zip = NO;
        }
        else
        {
            [self.img_validZip setImage:[UIImage imageNamed:@"valid_icon"]];
            self.isValid_zip = YES;
        }
    }
    
    [self validateFields];
    
    return YES;
}

- (void)login{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    
    [manager.requestSerializer setValue:PRIDE_API_AUTH forHTTPHeaderField:@"PRIDE-API-AUTH"];
    
    NSDictionary *parameters = @{@"email": self.textField_email.text,
                                 @"password": self.textField_password.text};
    
    [manager POST:[SERVER_URL stringByAppendingString:@"authenticate"] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
 
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
     
    }];
}

- (void)handler_next{
    // Do registration stuff here
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
    
    // Save the email variable
    [[NSUserDefaults standardUserDefaults] setObject:self.textField_email.text forKey:USER_EMAIL_IDENTIFIER];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    
    [manager.requestSerializer setValue:PRIDE_API_AUTH forHTTPHeaderField:@"PRIDE-API-AUTH"];
    
    // Get the PDF file
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths objectAtIndex:0];
    NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"consent.pdf"];
    NSData *pdfData = [[NSFileManager defaultManager] contentsAtPath:filePath];
  BOOL sharing_selection=[[NSUserDefaults standardUserDefaults] boolForKey:USER_SHARING_ENABLED];

    
    NSString* sharing=(sharing_selection)?@"1":@"0";
    
    NSDictionary *parameters = @{
                                 @"first_name": [[NSUserDefaults standardUserDefaults] valueForKey:USER_FIRST_NAME_IDENTIFIER],
                                 @"last_name": [[NSUserDefaults standardUserDefaults] valueForKey:USER_LAST_NAME_IDENTIFIER],
                                 @"email": self.textField_email.text,
                                 @"zip": self.textField_zip.text,
                                 @"sharing": sharing,
                                   @"dob":  _birthdayField.text,
                                 @"password": self.textField_password.text,
                                 @"consent_form": pdfData};
    ORKConsentSignature*    signature = [ORKConsentSignature signatureForPersonWithTitle:@"Participant"
                                                                        dateFormatString:nil
                                                                              identifier:@"participant"];
    NSData* imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"signature"];
    // Make the Network Request and Handle Response
    [manager POST:[SERVER_URL stringByAppendingString:@"create-account"] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        if(pdfData)
        {
        //    [formData appendPartWithFileData:pdfData name:@"consent_form" fileName:@"consent.pdf" mimeType:@"application/pdf"];
        }
       
        if(imageData)
        {
            [formData appendPartWithFileData:imageData name:@"signature" fileName:@"signature.png" mimeType:@"image/png"];
        }
           } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        id errors = [responseObject valueForKey:@"errors"];
        NSLog(@"Response error: %@", errors);
        [MBProgressHUD hideHUDForView:self.view animated:YES];

        if(errors && [errors count]>0)
        {
            NSString* errormessage=[errors objectForKey:@"email"] ;
            NSString* errorMessage=@"";
            if([errormessage isEqualToString:@"duplicate"])
            {
                errorMessage=@"The email has already been registered";
            }
            else if([errormessage isEqualToString:@"invalid"])
            {
                errorMessage=@"Invalid Email";
            }
            else if([errormessage isEqualToString:@"missing"])
            {
                errorMessage=@"Invalid Email";
            }
            else
            {
                errorMessage=@"Please Verify your information, and try again.";
            }
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:errorMessage
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            
            [alert show];
        }
        else
        {
            [self login];
            NSString *userID = [responseObject objectForKey:@"userID"];
            
            [[NSUserDefaults standardUserDefaults] setBool:false forKey:STATE_LEFT_STUDY];
            [[NSUserDefaults standardUserDefaults] setObject:_textField_name.text forKey:USER_FULL_NAME_IDENTIFIER];
            [[NSUserDefaults standardUserDefaults] setObject:_textField_zip.text forKey:USER_ZIP_IDENTIFIER];
            [[NSUserDefaults standardUserDefaults] setObject:_textField_email.text forKey:USER_EMAIL_IDENTIFIER];
            [[NSUserDefaults standardUserDefaults] setObject:userID forKey:USER_USER_ID_IDENTIFIER];
            
            [self performSegueWithIdentifier:@"WeightHeight" sender:self];
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Unable to connect to server"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
        [alert show];
        
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        

        
    }];
    }
}

- (void)validateFields{
    
    if(self.isValid_email &&self.isValid_zip &&
       self.isValid_password &&
       self.isValid_birthday){
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }else{
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
