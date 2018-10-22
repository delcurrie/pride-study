//
//  VerifyEmailViewController.m
//  Pride
//
//  Created by Patrick Krabeepetcharat on 5/22/15.
//  Copyright (c) 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import "VerifyEmailViewController.h"
#import "LockScreenViewController.h"
#import "AppConstants.h"
#import "Reachability.h"
#import "R1Push.h"
#import "R1WebCommand.h"
@interface VerifyEmailViewController ()

@end

@implementation VerifyEmailViewController

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewDidAppear:(BOOL)animated{
    // RadiumOne Tracking
    [[R1Emitter sharedInstance] emitScreenViewWithDocumentTitle:@"Verify email"
                                             contentDescription:nil
                                            documentLocationUrl:nil
                                               documentHostName:nil
                                                   documentPath:nil
                                                      otherInfo:nil];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Verify email"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.label_email setText:[[NSUserDefaults standardUserDefaults] valueForKey:USER_EMAIL_IDENTIFIER]];
    
    // Stylize the continue button
    self.btn_continue.layer.cornerRadius = 5.0f;//any float value
    self.btn_continue.layer.borderWidth = 2.0f;//any float value
    self.btn_continue.layer.borderColor = [[UIColor primaryColor]CGColor];
    self.btn_continue.layer.backgroundColor = [[UIColor whiteColor]CGColor];
    [self.btn_continue setTitleColor:[UIColor primaryColor] forState:UIControlStateNormal];
    
    // Size the description
    [self.label_desc sizeToFit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)resendVerificationEmail:(id)sender {
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

    NSDictionary *params = @{ @"user_id": [[NSUserDefaults standardUserDefaults] objectForKey:USER_USER_ID_IDENTIFIER ] };
    
    NSURL *url = [NSURL URLWithString:
                  [SERVER_URL stringByAppendingString:@"resend-verification-email"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[self httpBodyForParamsDictionary:params]];
    
    [request setValue:PRIDE_API_AUTH forHTTPHeaderField:@"PRIDE-API-AUTH"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error) {
                               [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
                                   [MBProgressHUD hideHUDForView:self.view animated:YES];
                                   
                                   UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"The verification email has been sent. Please check your inbox to confirm." message:nil preferredStyle:UIAlertControllerStyleAlert];
                                   
                                   
                                   // Create the "OK" button.
                                   NSString *okTitle = NSLocalizedString(@"OK", nil);
                                   UIAlertAction *okAction = [UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                       
                                       //                                           [self performSelector:@selector(dismiss) withObject:NULL afterDelay:0.3];
                                   }];
                                   
                                   [alertController addAction:okAction];
                                   
                                   
                                   // Present the alert controller.
                                   [self presentViewController:alertController animated:YES completion:nil];
                                   
                               }];
                           }];
    
    }
}

- (IBAction)continue:(id)sender {
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

    [[NSUserDefaults standardUserDefaults] setBool:true forKey:STATE_SHOW_PIN_POPUP];
    
    // Testing: go to next screen regardless of verification
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TabBar" bundle:nil];
//    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
//    [self.navigationController setViewControllers:@[vc] animated:YES];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    
    [manager.requestSerializer setValue:PRIDE_API_AUTH forHTTPHeaderField:@"PRIDE-API-AUTH"];
    
    NSDictionary *parameters = @{@"user_id": [[NSUserDefaults standardUserDefaults] stringForKey:USER_USER_ID_IDENTIFIER]};
    NSLog(@"VERIFYING WITH USER ID: %@", [[NSUserDefaults standardUserDefaults] stringForKey:USER_USER_ID_IDENTIFIER]);
    
    [manager POST:[SERVER_URL stringByAppendingString:@"check-user-verification"] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"THE RESPONSE OBJECT: %@", responseObject);
        
        NSString *verified;
        
        if([[responseObject valueForKey:@"verified"] isEqualToNumber:[NSNumber numberWithInt:1]]){
            verified = @"YES";
        }else{
            verified = @"NO";
        }
        
        NSLog(@"VERIFIED: %@", verified);
        
        if([verified isEqualToString:@"YES"]){
            // Success
            [[NSUserDefaults standardUserDefaults] setBool:true forKey:STATE_CONSENT_COMPLETE];

            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TabBar" bundle:nil];
            UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
            [self.navigationController setViewControllers:@[vc] animated:YES];
            [[R1Push sharedInstance].tags setTags:@[ @"App Installed", @"logged in user in study" ]];

            
        }else{
            // Failure
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Your email has not yet been verified. Please check your email for instructions on how to verify your email."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            
            [alert show];
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
- (IBAction)wrongEmail:(id)sender {
    UIViewController *viewController;
    
    for (UIViewController *vc in self.navigationController.viewControllers){
        NSLog(@"VC: %@", vc);
        
        if ([vc isKindOfClass:[RegistrationViewController class]]) {
            viewController = vc;
        
            [self.navigationController popToViewController:viewController animated:YES];
            
            return;
        }
    }
}

@end
