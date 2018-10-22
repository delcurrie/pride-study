//
//  LoginViewController.m
//  Pride
//
//  Created by Patrick Krabeepetcharat on 6/2/15.
//  Copyright (c) 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import "LoginViewController.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import "R1Push.h"
#import "R1WebCommand.h"
#import "ForgotPasswordViewController.h"
@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[R1Push sharedInstance].tags addTag:@"DEBUG_TAG"];

    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewDidAppear:(BOOL)animated{
    // RadiumOne Tracking
    [[R1Emitter sharedInstance] emitScreenViewWithDocumentTitle:@"Login"
                                             contentDescription:nil
                                            documentLocationUrl:nil
                                               documentHostName:nil
                                                   documentPath:nil
                                                      otherInfo:nil];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Login"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationItem setTitle:@"Sign In"];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(handler_done)];
    [self.navigationItem setRightBarButtonItem:doneButton];
}

- (void)handler_done{
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
    else {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
        
        [manager.requestSerializer setValue:PRIDE_API_AUTH forHTTPHeaderField:@"PRIDE-API-AUTH"];
        
        NSDictionary *parameters = @{@"email": self.textField_email.text,
                                     @"password": self.textField_password.text};
        
        [manager POST:[SERVER_URL stringByAppendingString:@"authenticate"] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            id errors = [responseObject valueForKey:@"errors"];
            
            if(errors && [errors count]>0){
                // Failure
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Unable to verify email and/or password"
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                
                [alert show];
            }else{
                // Success
                
                NSLog(@"The responseObject: %@", responseObject);
                
                NSString *firstName = [responseObject valueForKey:@"firstName"];
                NSString *lastName = [responseObject valueForKey:@"lastName"];
                NSString *userId = [responseObject valueForKey:@"userId"];
                NSString *email = [responseObject valueForKey:@"email"];
                NSString *dob = [responseObject valueForKey:@"dob"];
                NSString *height = [responseObject valueForKey:@"height"];
                NSString *weight = [responseObject valueForKey:@"weight"];
                NSString *zip = [responseObject valueForKey:@"zip"];
                bool activityType1 = [[responseObject objectForKey:@"activityType1"] boolValue];
                int archived = [[responseObject objectForKey:@"archived"] intValue];
                bool activityType2 = [[responseObject objectForKey:@"activityType2"] boolValue];
                bool activityType3 = [[responseObject objectForKey:@"activityType3"] boolValue];
                bool activityType4 = [[responseObject objectForKey:@"activityType4"] boolValue];
                bool activityType5 = [[responseObject objectForKey:@"activityType5"] boolValue];
                bool  activityType6 = [[responseObject objectForKey:@"activityType6"] boolValue];
                bool  activityType7 = [[responseObject objectForKey:@"activityType7"] boolValue];
                bool  activityType8 = [[responseObject objectForKey:@"activityType8"] boolValue];
                bool  activityType9 = [[responseObject objectForKey:@"activityType9"] boolValue];
                bool  activityType10 = [[responseObject objectForKey:@"activityType10"] boolValue];
                bool  activityType11 = [[responseObject objectForKey:@"activityType11"] boolValue];
                
                // Save values in user defaults
                [[NSUserDefaults standardUserDefaults] setValue:dob forKey:USER_BIRTHDAY_IDENTIFIER];
                [[NSUserDefaults standardUserDefaults] setValue:height forKey:USER_HEIGHT_IDENTIFIER];
                [[NSUserDefaults standardUserDefaults] setValue:weight forKey:USER_WEIGHT_IDENTIFIER];
                [[NSUserDefaults standardUserDefaults] setValue:zip forKey:USER_ZIP_IDENTIFIER];
                [[NSUserDefaults standardUserDefaults] setValue:firstName forKey:USER_FIRST_NAME_IDENTIFIER];
                [[NSUserDefaults standardUserDefaults] setValue:email forKey:USER_EMAIL_IDENTIFIER];
                
                [[NSUserDefaults standardUserDefaults] setValue:lastName forKey:USER_LAST_NAME_IDENTIFIER];
                [[NSUserDefaults standardUserDefaults] setValue:userId forKey:USER_USER_ID_IDENTIFIER];
                
                [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@ %@",firstName,lastName] forKey:USER_FULL_NAME_IDENTIFIER];
                
                // Set consent complete state
                [[NSUserDefaults standardUserDefaults] setBool:true forKey:STATE_CONSENT_COMPLETE];
                
                if(archived==1)
                {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:USER_HAS_LEFT_STUDY];
                    
                }
                if(activityType1==true)
                {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:STATE_DEMOGRAPHIC_SURVEY_COMPLETE];
                    [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:STATE_DEMOGRAPHIC_SURVEY_COMPLETE_DATE];
                }
                if(activityType2==true)
                {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:STATE_CREATE_SCREEN_NAME_COMPLETE];
                    [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:STATE_CREATE_SCREEN_NAME_COMPLETE_DATE];
                }
                if(activityType3==true)
                {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:STATE_CREATE_TOPIC_COMPLETE];
                    [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:STATE_CREATE_TOPIC_COMPLETE_DATE];
                }
                if(activityType4==true)
                {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:STATE_REVIEW_TOPICS_COMPLETE];
                    [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:STATE_REVIEW_TOPICS_COMPLETE_DATE];
                }
                if(activityType5==true)
                {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:STATE_VOTE_ON_TOPICS_COMPLETE];
                    [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:STATE_VOTE_ON_TOPICS_COMPLETE_DATE];
                }
                if(activityType6==true)
                {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:STATE_COMMENT_ON_TOPICS_COMPLETE];
                    [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:STATE_COMMENT_ON_TOPICS_COMPLETE_DATE];
                }
                
                if(activityType7==true)
                {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:STATE_IMPROVING_SURVEY_COMPLETE];
                    [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:STATE_IMPROVING_SURVEY_COMPLETE_DATE];
                }
                
                
                if(activityType8==true)
                {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:STATE_PHYSICAL_HEALTH_SURVEY_COMPLETE];
                    [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:STATE_PHYSICAL_HEALTH_SURVEY_COMPLETE_DATE];
                }
                
                
                if(activityType9==true)
                {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:STATE_MENTAL_HEALTH_SURVEY_COMPLETE];
                    [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:STATE_MENTAL_HEALTH_SURVEY_COMPLETE_DATE];
                }
                
                if(activityType10==true)
                {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:STATE_SOCIAL_HEALTH_SURVEY_COMPLETE];
                    [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:STATE_SOCIAL_HEALTH_SURVEY_COMPLETE_DATE];
                }
                
                
                if(activityType11==true)
                {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:STATE_AGE_SURVEY_COMPLETE];
                    [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:STATE_AGE_SURVEY_COMPLETE_DATE];
                }
                
                
                [[NSUserDefaults standardUserDefaults] setBool:false forKey:STATE_LEFT_STUDY];
                
                
                [[NSUserDefaults standardUserDefaults] setBool:true forKey:STATE_SHOW_PIN_POPUP];
                AppDelegate* appD = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appD updateUserInfo];
                [self gotoTabBar];
                [[R1Push sharedInstance].tags setTags:@[ @"App Installed", @"logged in user in study" ]];
                
            }
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
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

- (void)gotoTabBar{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TabBar" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
    vc.view.backgroundColor=[UIColor whiteColor];
    [self.navigationController setViewControllers:@[vc] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)forgotPassword:(id)sender {
    //    NSString *msg = [NSString stringWithFormat:@"Please check your email %@ for instructions on how to reset your Password", self.textField_email.text];
    //    
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
    //                                                    message:msg
    //                                                   delegate:self
    //                                          cancelButtonTitle:@"OK"
    //                                          otherButtonTitles:nil];
    //    [alert show];
    
    ForgotPasswordViewController* view=[[ForgotPasswordViewController alloc]init];
    view.emailTxt=self.textField_email.text;
    UINavigationController* nav=[[UINavigationController alloc]initWithRootViewController:view];
    view.title=@"Forgot Password";
    [self presentViewController:nav animated:true completion:NULL];
    
    
}

@end
