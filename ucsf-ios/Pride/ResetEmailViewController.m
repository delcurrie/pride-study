//
//  ForgotPasswordViewController.m
//  Pride
//
//  Created by Analog Republic on 6/10/15.
//  Copyright (c) 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import "ResetEmailViewController.h"
#import "UIColor+constants.h"
#import "MBProgressHUD.h"
#import "AppConstants.h"

@interface ResetEmailViewController ()

@end

@implementation ResetEmailViewController

- (void)viewDidAppear:(BOOL)animated{
    // RadiumOne Tracking
    [[R1Emitter sharedInstance] emitScreenViewWithDocumentTitle:@"Forgot Password"
                                             contentDescription:nil
                                            documentLocationUrl:nil
                                               documentHostName:nil
                                                   documentPath:nil
                                                      otherInfo:nil];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Forgot password"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _emailField.delegate=self;
    _emailField.text=_emailTxt;
//    self.navigationController.navigationBar.tintColor = [UIColor primaryColor];
   // self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor primaryColor]};
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    [_emailSentLabel setHidden:true];
    self.navigationItem.rightBarButtonItem = anotherButton;
    
    _resetPasswordButton.backgroundColor = [UIColor whiteColor];
    _resetPasswordButton.layer.borderWidth = 1.0;
    _resetPasswordButton.layer.masksToBounds = YES;
    _resetPasswordButton.layer.cornerRadius = 5.0;
    [_resetPasswordButton setTintColor:[UIColor primaryColor]];
    _resetPasswordButton.layer.borderColor = [UIColor primaryColor].CGColor;
    [_emailField becomeFirstResponder];
    // Do any additional setup after loading the view from its nib.
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self sendPassword:NULL];
  
    
    return YES;
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

- (IBAction)sendPassword:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //Get API Data
    NSDictionary *params = @{ @"email":_emailField.text};
    
    NSURL *url = [NSURL URLWithString:
                  [SERVER_URL stringByAppendingString:@"reset-user-password"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[self httpBodyForParamsDictionary:params]];
    
    [request setValue:PRIDE_API_AUTH forHTTPHeaderField:@"PRIDE-API-AUTH"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (error) {
                                   [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
                                       [MBProgressHUD hideHUDForView:self.view animated:YES];
                                       
                                       UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Email not found, please try again" message:nil preferredStyle:UIAlertControllerStyleAlert];
                                       
                                       
                                       // Create the "OK" button.
                                       NSString *okTitle = NSLocalizedString(@"OK", nil);
                                       UIAlertAction *okAction = [UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                           
//                                           [self performSelector:@selector(dismiss) withObject:NULL afterDelay:0.3];
                                       }];
                                       
                                       [alertController addAction:okAction];
                                       
                                       
                                       // Present the alert controller.
                                       [self presentViewController:alertController animated:YES completion:nil];
                                       
                                   }];
                                   
                               }
                               else {
                                   [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
                                       [MBProgressHUD hideHUDForView:self.view animated:YES];
                                       
                                       NSMutableDictionary *innerJson = [NSJSONSerialization
                                                                         JSONObjectWithData:data options:kNilOptions error:NULL];
                                       
                                       
                                       id errors = [innerJson valueForKey:@"errors"];
                                       NSLog(@"Response error: %@", errors);
                                       [MBProgressHUD hideHUDForView:self.view animated:YES];
                                       NSString* errorMessage=@"";

                                       if(errors && [errors count]>0)
                                       {
                                           NSString* errormessage=[errors objectForKey:@"email"] ;
                                           if([errormessage isEqualToString:@"invalid"])
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
                                        }
                                       else
                                       {
                                           errorMessage=[innerJson objectForKey:@"message"];
                                       }
                                       
                                       UIAlertController *alertController = [UIAlertController alertControllerWithTitle:errorMessage message:nil preferredStyle:UIAlertControllerStyleAlert];
                                       
                                       
                                       // Create the "OK" button.
                                       NSString *okTitle = NSLocalizedString(@"OK", nil);
                                       UIAlertAction *okAction = [UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                           [self performSelector:@selector(dismiss) withObject:NULL afterDelay:0.1];
                                       }];
                                       
                                       [alertController addAction:okAction];
                                       
                                       
                                       // Present the alert controller.
                                       [self presentViewController:alertController animated:YES completion:nil];
                                   }];
                               }
                           }];
    

}
-(void)dismiss
{
    [self dismissViewControllerAnimated:true completion:NULL];
}
-(void)cancel
{
    [self dismissViewControllerAnimated:true completion:NULL];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)resetPassword:(id)sender {
    [self.view endEditing:true];
    [self sendPassword:NULL];

}
@end
