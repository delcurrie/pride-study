//
//  CreateTopicViewController.m
//  Pride
//
//  Created by Analog Republic on 11/12/15.
//  Copyright © 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import "SetupNotificationsViewController.h"
#import "CreateTopicCell.h"
#import "UIColor+constants.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import <AFNetworking/AFNetworking.h>
#import "AppConstants.h"
#import "UIButton+BackgroundColor.h"
#import "CreateTopicHeader.h"
@interface SetupNotificationsViewController ()
{
    NSMutableArray *categories;
    NSMutableArray *stateArray;
    BOOL commentsOnPosts;
    BOOL newPosts;
    BOOL repliesToPosts;
}
@property (strong, nonatomic) IBOutlet UIView *divider2;
@property (strong, nonatomic) IBOutlet UIView *divider1;
@end

@implementation SetupNotificationsViewController
-(void)exitScreen
{
    [self dismissViewControllerAnimated:true completion:nil];
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
   
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
  
    [_submitButton setBackgroundColor:[UIColor primaryColor] forState:UIControlStateHighlighted];
    
    _divider1.frame=CGRectMake(_divider1.frame.origin.x, _divider1.frame.origin.y+_divider1.frame.size.height/2, _divider1.frame.size.width, _divider1.frame.size.height/2);
    _divider2.frame=CGRectMake(_divider2.frame.origin.x, _divider2.frame.origin.y, _divider2.frame.size.width, _divider2.frame.size.height/2);
    self.title=@"Community Screen Name";
    
//    _tableV.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

    UIBarButtonItem *refreshButton = [
                                      [UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                      target:self action:@selector(exitScreen)];
    self.navigationItem.rightBarButtonItem = refreshButton;

    self.navigationItem.hidesBackButton = YES;
    commentsOnPosts=false;
    newPosts=false;
    repliesToPosts=false;
    
    [_tableV registerNib:[UINib nibWithNibName:@"CreateTopicCell" bundle:nil] forCellReuseIdentifier:@"CreateTopicCell"];
    [_tableV registerNib:[UINib nibWithNibName:@"CreateTopicHeader" bundle:nil] forCellReuseIdentifier:@"CreateTopicHeader"];
    _submitButton.layer.cornerRadius = 5.0f;//any float value
    _submitButton.layer.borderWidth = 2.0f;//any float value
    _submitButton.layer.borderColor = [[UIColor primaryColor]CGColor];
    
    [_submitButton setTitleColor:[UIColor primaryColor] forState:UIControlStateNormal];
    stateArray=[NSMutableArray new];
 
    [self getCategories];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    
    [manager.requestSerializer setValue:PRIDE_API_AUTH forHTTPHeaderField:@"PRIDE-API-AUTH"];
    NSDictionary *params = @{ @"user_id": [[NSUserDefaults standardUserDefaults] objectForKey:USER_USER_ID_IDENTIFIER ]};
    
    
    [manager POST:[SERVER_URL stringByAppendingString:@"get-notification-settings"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* data=[responseObject objectForKey:@"data"];
        commentsOnPosts=[[data objectForKey:@"notification_setting_comments_on_posts"] boolValue];
        newPosts=[[data objectForKey:@"notification_setting_new_posts"] boolValue];
        repliesToPosts=[[data objectForKey:@"notification_setting_replies_to_posts"] boolValue];
        
        [_tableV reloadData];

        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}
- (void)getCategories
{
    categories=[@[@"New posts",@"Replies to my posts",@"Comments on my posts"]mutableCopy];
//    @"notification_setting_new_posts":  ([defaults boolForKey:USER_NOTIFICATION_POSTS])?@"1":@"0",
//    @"notification_setting_replies_to_posts":  ([defaults boolForKey:USER_NOTIFICATION_REPLIES])?@"1":@"0",
//    @"notification_setting_comments_on_posts":  ([defaults boolForKey:USER_NOTIFICATION_COMMENTS])?@"1":@"0",
//    
    [_tableV reloadData];
    
}
-(void) saveNotifications {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    
    
    
    [manager.requestSerializer setValue:PRIDE_API_AUTH forHTTPHeaderField:@"PRIDE-API-AUTH"];
    
    NSUserDefaults* defaults=[NSUserDefaults standardUserDefaults];
    
    //    categories=[@[@"New posts",@"Replies to my posts",@"Comments on my posts"]mutableCopy];
    
    NSDictionary *parameters = @{
                                 @"user_id": ([defaults objectForKey:USER_USER_ID_IDENTIFIER])?[defaults objectForKey:USER_USER_ID_IDENTIFIER]:@"",
                                 @"new_posts":  ([defaults boolForKey:USER_NOTIFICATION_POSTS])?@"1":@"0",
                                 @"replies_to_posts":  ([defaults boolForKey:USER_NOTIFICATION_REPLIES])?@"1":@"0",
                                 @"replies_to_comments":  ([defaults boolForKey:USER_NOTIFICATION_COMMENTS])?@"1":@"0"};
    
    [manager POST:[SERVER_URL stringByAppendingString:@"set-community-notifications"] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"The responseObject: %@", responseObject);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CreateTopicCell";
    CreateTopicCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CreateTopicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSString* row=[categories objectAtIndex:indexPath.row];
    [cell.dividerLine setHidden:false];
    
    cell.dividerLine.frame=CGRectMake( cell.dividerLine.frame.origin.x,  cell.dividerLine.frame.origin.y,  cell.dividerLine.frame.size.width,  0.5);
    
    cell.backView.backgroundColor=[UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.titleLabel.text=row;
    
    switch (indexPath.row) {
        case 0:
        {
            [cell.checkButton setImage:(newPosts)?[UIImage imageNamed:@"orange_check.png"]:NULL forState:UIControlStateNormal];

        }
            break;
        case 1:
        {
            [cell.checkButton setImage:(repliesToPosts)?[UIImage imageNamed:@"orange_check.png"]:NULL forState:UIControlStateNormal];

        }
            break;
        case 2:
        {
            [cell.checkButton setImage:(commentsOnPosts)?[UIImage imageNamed:@"orange_check.png"]:NULL forState:UIControlStateNormal];

        }
            break;
        default:
            break;
    }
    
    if(indexPath.row==categories.count-1)
    {
        [cell.dividerLine setHidden:true];
    }
    else
    {
        [cell.dividerLine setHidden:false];

    }
   
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
    return categories.count;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    switch (indexPath.row) {
        case 0:
        {
            newPosts=!newPosts;
        }
            break;
        case 1:
        {
            repliesToPosts=!repliesToPosts;
            
        }
            break;
        case 2:
        {
            commentsOnPosts=!commentsOnPosts;
            
        }
            break;
        default:
            break;
    }
    
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}


- (IBAction)submitPressed:(id)sender {
    [self.view endEditing:true];
    
    [[NSUserDefaults standardUserDefaults] setBool:newPosts forKey:USER_NOTIFICATION_POSTS];
    [[NSUserDefaults standardUserDefaults] setBool:repliesToPosts forKey:USER_NOTIFICATION_REPLIES];
    [[NSUserDefaults standardUserDefaults] setBool:commentsOnPosts forKey:USER_NOTIFICATION_COMMENTS];
    
    [self saveNotifications];
    
    [self dismissViewControllerAnimated:true completion:NULL];

    
}
@end
