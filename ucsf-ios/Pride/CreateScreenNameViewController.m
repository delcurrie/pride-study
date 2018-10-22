//
//  CreateScreenNameViewController.m
//  Pride
//
//  Created by Analog Republic on 11/12/15.
//  Copyright © 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import "CreateScreenNameViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+constants.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import <AFNetworking/AFNetworking.h>
#import "AppConstants.h"
#import "UIButton+BackgroundColor.h"
#import "SetupNotificationsViewController.h"

@interface CreateScreenNameViewController ()
@property (weak, nonatomic) IBOutlet UIView *screenNameContainer;

@end

@implementation CreateScreenNameViewController
-(void)textFieldDidChange
{
    //resolves PRI-84
    _statusLabel.textColor=[UIColor primaryColor];

    if(_screenNameField.text.length>7)
    {
        [_statusLabel setHidden:true];
    }
    else
    {
        [_statusLabel setHidden:false];
    }
    //
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * proposedNewString = [[textField text] stringByReplacingCharactersInRange:range withString:string];
    
    if(proposedNewString.length==0)
    {
        //display required
        _statusLabel.text=@"Required field";
        [_statusLabel setHidden:false];
    }
    else if(proposedNewString.length<9)
    {
        _statusLabel.text=@"Minimum 8 characters";
        [_statusLabel setHidden:false];
    }
    else
    {
        [_statusLabel setHidden:true];
        
    }
    return true;
    
}
-(void)exitScreen
{
    [self dismissViewControllerAnimated:true completion:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title=@"Community Screen Name";

    [_submitButton setBackgroundColor:[UIColor primaryColor] forState:UIControlStateHighlighted];

    _screenNameField.delegate=self;
    [_screenNameField addTarget:self
                         action:@selector(textFieldDidChange)
               forControlEvents:UIControlEventEditingChanged];
    _screenNameContainer.layer.cornerRadius = 5.0f;//any float value
    _screenNameContainer.layer.borderWidth = 1.0f;//any float value
    _screenNameContainer.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    [_scrollV setContentSize:CGSizeMake(0, 667.f)];
    UIBarButtonItem *refreshButton = [
                                      [UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                       target:self action:@selector(exitScreen)];
    self.navigationItem.rightBarButtonItem = refreshButton;

    
    _submitButton.layer.cornerRadius = 5.0f;//any float value
    _submitButton.layer.borderWidth = 2.0f;//any float value
    _submitButton.layer.borderColor = [[UIColor primaryColor]CGColor];
    
    [_submitButton setTitleColor:[UIColor primaryColor] forState:UIControlStateNormal];
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    
    [manager.requestSerializer setValue:PRIDE_API_AUTH forHTTPHeaderField:@"PRIDE-API-AUTH"];
    NSDictionary *params = @{ @"user_id": [[NSUserDefaults standardUserDefaults] objectForKey:USER_USER_ID_IDENTIFIER ] };
    
    
    [manager POST:[SERVER_URL stringByAppendingString:@"has-community-screen-name"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        id errors = [responseObject valueForKey:@"errors"];
        
        if(errors && [errors count]>0){
            NSString* errorstring=@"";
            for (NSString* key in errors) {
                id value = [errors objectForKey:key];
                
                errorstring=[NSString stringWithFormat:@"%@\n%@ is %@",errorstring,[key capitalizedString],value];
                
                // do stuff
            }
            
            if([errorstring length]>0)
            {
                errorstring =[errorstring substringFromIndex:1];
                errorstring=[errorstring stringByReplacingOccurrencesOfString:@"_" withString:@" "];
                
                
            }
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
//                                                            message:errorstring
//                                                           delegate:self
//                                                  cancelButtonTitle:@"OK"
//                                                  otherButtonTitles:nil];
//            
//            [alert show];
        }
        else{
            // Success
            
            NSLog(@"The responseObject: %@", responseObject);
            
            bool has_community_screen_name = [[responseObject objectForKey:@"has_community_screen_name"] boolValue];
            bool banned = [[responseObject objectForKey:@"banned"] boolValue];
            
            if(banned==true)
            {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"This account has been banned." message:nil preferredStyle:UIAlertControllerStyleAlert];
                
                
                // Create the "OK" button.
                NSString *okTitle = NSLocalizedString(@"OK", nil);
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [self dismissViewControllerAnimated:true completion:NULL];
                    
                }];
                
                [alertController addAction:okAction];
                
                [self presentViewController:alertController animated:YES completion:nil];
            }
            else if(has_community_screen_name==true)
            {
                
             
                
            

                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:STATE_CREATE_SCREEN_NAME_COMPLETE];
                [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:STATE_CREATE_SCREEN_NAME_COMPLETE_DATE];
                
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Screen name already created" message:nil preferredStyle:UIAlertControllerStyleAlert];
                
                
                // Create the "OK" button.
                NSString *okTitle = NSLocalizedString(@"OK", nil);
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [self dismissViewControllerAnimated:true completion:NULL];

                    //                                           [self performSelector:@selector(dismiss) withObject:NULL afterDelay:0.3];
                }];
                
                [alertController addAction:okAction];
                
                [self presentViewController:alertController animated:YES completion:nil];
                
                
                
                
            }
            else
            {
                
            }
            
            // Save values in user defaults
           
        }
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        
    }];

    
    
    // Do any additional setup after loading the view from its nib.
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
-(void)viewWillAppear:(BOOL)animated
{

    

}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    if (textField.text.length >= 8 && range.length == 0)
//    {
//        return NO; // return NO to not change text
//    }
//    else
//    {return YES;}
//}
- (IBAction)submit:(id)sender {
    
    if(_screenNameField.text.length>7)
    {
    [self.view endEditing:true];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    
    [manager.requestSerializer setValue:PRIDE_API_AUTH forHTTPHeaderField:@"PRIDE-API-AUTH"];
    NSDictionary *params = @{ @"user_id": [[NSUserDefaults standardUserDefaults] objectForKey:USER_USER_ID_IDENTIFIER ],  @"screen_name": _screenNameField.text};
    
    
    [manager POST:[SERVER_URL stringByAppendingString:@"create-community-screen-name"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        id errors = [responseObject valueForKey:@"errors"];
        
        if(errors && [errors count]>0){
            NSString* errorstring=@"";
            for (NSString* key in errors) {
                id value = [errors objectForKey:key];
                
                errorstring=[NSString stringWithFormat:@"%@\n%@ is %@",errorstring,[key capitalizedString],value];
                
                // do stuff
            }
            
            if([errorstring length]>0)
            {
                errorstring =[errorstring substringFromIndex:1];
                errorstring=[errorstring stringByReplacingOccurrencesOfString:@"_" withString:@" "];
                
                
            }
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
//                                                            message:errorstring
//                                                           delegate:self
//                                                  cancelButtonTitle:@"OK"
//                                                  otherButtonTitles:nil];
//            
//            [alert show];
//            
//            
            
            if([errorstring containsString:@"duplicate"])
            {
                errorstring=@"Screen name is already taken.\nPlease select a new one.";
            }
            BOOL usernameCreated=false;
            if([errorstring containsString:@"has"])
            {
                usernameCreated=true;
                errorstring=@"Screen name already created";
            }
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:errorstring message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            
            // Create the "OK" button.
            NSString *okTitle = NSLocalizedString(@"OK", nil);
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                if(usernameCreated==true)
                {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:STATE_CREATE_SCREEN_NAME_COMPLETE];
                    [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:STATE_CREATE_SCREEN_NAME_COMPLETE_DATE];
                    [self dismissViewControllerAnimated:true completion:NULL];

                }
                //                                           [self performSelector:@selector(dismiss) withObject:NULL afterDelay:0.3];
            }];
            
            [alertController addAction:okAction];
            
            [self presentViewController:alertController animated:YES completion:nil];

            
            
        }else{
            // Success
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:STATE_CREATE_SCREEN_NAME_COMPLETE];
            [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:STATE_CREATE_SCREEN_NAME_COMPLETE_DATE];
            
            NSLog(@"The responseObject: %@", responseObject);
            
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
//                                                            message:@"Screen name created successfully"
//                                                           delegate:self
//                                                  cancelButtonTitle:@"OK"
//                                                  otherButtonTitles:nil];
//            
//            [alert show];
//            
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Successfully created community screen name." message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            
            // Create the "OK" button.
            NSString *okTitle = NSLocalizedString(@"OK", nil);
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                SetupNotificationsViewController* view=[[SetupNotificationsViewController alloc]init];
                [self.navigationController pushViewController:view animated:false];

                
            }];
            
            [alertController addAction:okAction];
            
            [self presentViewController:alertController animated:YES completion:nil];

            
            // Save values in user defaults
            
        }
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Unable to connect to server" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        
        // Create the "OK" button.
        NSString *okTitle = NSLocalizedString(@"OK", nil);
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            [self dismissViewControllerAnimated:true completion:NULL];
        }];
        
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        

      
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
    }
    else
    {
        if(_screenNameField.text.length==0)
        {
            //display required
            _statusLabel.text=@"This field is required.";
            [_statusLabel setHidden:false];
        }
        else if(_screenNameField.text.length<9)
        {
            _statusLabel.text=@"Please enter at least 8 characters.";
            [_statusLabel setHidden:false];
        }
        else
        {
            [_statusLabel setHidden:true];
            
        }
    }
}
@end
