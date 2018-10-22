//
//  CreateTopicViewController.m
//  Pride
//
//  Created by Analog Republic on 11/12/15.
//  Copyright © 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import "CreateTopicViewController.h"
#import "CreateTopicCell.h"
#import "UIColor+constants.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import <AFNetworking/AFNetworking.h>
#import "AppConstants.h"
#import "UIButton+BackgroundColor.h"
#import "CreateTopicHeader.h"
@interface CreateTopicViewController ()
{
    NSMutableArray *categories;
    NSMutableArray *identityData;
    NSMutableArray *ageData;
    NSMutableArray *healthData;
    NSMutableArray *categoriesfull;
    NSMutableArray *stateArray;

}
@property (strong, nonatomic) IBOutlet UILabel *minLabel2;
@property (strong, nonatomic) IBOutlet UILabel *minLabel1;
@property (strong, nonatomic) IBOutlet UIView *divider2;
@property (strong, nonatomic) IBOutlet UIView *divider1;
@end

@implementation CreateTopicViewController
-(void)exitScreen
{
    [self dismissViewControllerAnimated:true completion:nil];
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
        _minLabel1.text=@"Required field";
        [_minLabel1 setHidden:false];
    }
    else if(proposedNewString.length<10)
    {
        _minLabel1.text=@"Please enter at least 10 characters";
        [_minLabel1 setHidden:false];
    }
    else
    {
        [_minLabel1 setHidden:true];
        
    }
    return true;
    
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {

    if(_topicTextView.text.length==0)
    {
        //display required
        _minLabel1.text=@"Required field";
        [_minLabel1 setHidden:false];
    }
    else if(_topicTextView.text.length<10)
    {
        _minLabel1.text=@"Please enter at least 10 characters";
        [_minLabel1 setHidden:false];
    }
    else
    {
        [_minLabel1 setHidden:true];

    }
    
    
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView
{

    
    
    if(_whyTextView.text.length==0)
    {
        //display required
        [_minLabel2 setHidden:false];

        _minLabel2.text=@"Required field";
    }
    else if(_whyTextView.text.length<10)
    {
        _minLabel2.text=@"Please enter at least 10 characters";
        [_minLabel2 setHidden:false];
    }
    else
    {
        [_minLabel2 setHidden:true];
        
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
  
    [_submitButton setBackgroundColor:[UIColor primaryColor] forState:UIControlStateHighlighted];
    _minLabel1.textColor=[UIColor primaryColor];
    _minLabel2.textColor=[UIColor primaryColor];

    stateArray=[[NSMutableArray alloc]init];
    _whyTextView.delegate=self;
    _topicTextView.delegate=self;
    
    _divider1.frame=CGRectMake(_divider1.frame.origin.x, _divider1.frame.origin.y+_divider1.frame.size.height/2, _divider1.frame.size.width, _divider1.frame.size.height/2);
    _divider2.frame=CGRectMake(_divider2.frame.origin.x, _divider2.frame.origin.y, _divider2.frame.size.width, _divider2.frame.size.height/2);
    self.title=@"Community Topic";
//    _tableV.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
//categories=[@[@"Mental/Emotional",@"Physical",@"Social",@"Asexual",@"Bisexual",@"Gay",@"Lesbian",@"Queer",@"Transgender Man",@"Transgender Woman",@"Children & Teenagers (0-18)",@"Young Adults (18-40)",@"Middle Aged Adults (40-65)",@"Senior Adults (65+)"]mutableCopy];
    
    UIBarButtonItem *refreshButton = [
                                      [UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                      target:self action:@selector(exitScreen)];
    self.navigationItem.rightBarButtonItem = refreshButton;

    
    
    [_tableV registerNib:[UINib nibWithNibName:@"CreateTopicCell" bundle:nil] forCellReuseIdentifier:@"CreateTopicCell"];
    [_tableV registerNib:[UINib nibWithNibName:@"CreateTopicHeader" bundle:nil] forCellReuseIdentifier:@"CreateTopicHeader"];
    _submitButton.layer.cornerRadius = 5.0f;//any float value
    _submitButton.layer.borderWidth = 2.0f;//any float value
    _submitButton.layer.borderColor = [[UIColor primaryColor]CGColor];
    
    [_submitButton setTitleColor:[UIColor primaryColor] forState:UIControlStateNormal];
 
    
    _topicContainerView.layer.cornerRadius = 5.0f;//any float value
    _topicContainerView.layer.borderWidth = 1.0f;//any float value
    _topicContainerView.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    _whyContainerView.layer.cornerRadius = 5.0f;//any float value
    _whyContainerView.layer.borderWidth = 1.0f;//any float value
    _whyContainerView.layer.borderColor = [[UIColor lightGrayColor]CGColor];

    [self getTopics];
    [_topicTextView setValue:[UIColor lightGrayColor]
                    forKeyPath:@"_placeholderLabel.textColor"];
    _whyTextView.placeholderColor=[UIColor lightGrayColor];
    _whyTextView.placeholderText=@"ex: What cancer screenings are appropriate for me as a member of the LGBT community?";
    
    
    
  //  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
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
            
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:errorstring message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            
            // Create the "OK" button.
            NSString *okTitle = NSLocalizedString(@"OK", nil);
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
            }];
            
            [alertController addAction:okAction];
            
            [self presentViewController:alertController animated:YES completion:nil];

            
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
                
              
                
            }
            else
            {
                
      
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Please create a screen name first." message:nil preferredStyle:UIAlertControllerStyleAlert];
                
                
                // Create the "OK" button.
                NSString *okTitle = NSLocalizedString(@"OK", nil);
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [self dismissViewControllerAnimated:true completion:NULL];

                }];
                
                [alertController addAction:okAction];
                
                [self presentViewController:alertController animated:YES completion:nil];

                
            }
            
            // Save values in user defaults
            
        }
        
       // MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //[MBProgressHUD hideHUDForView:self.view animated:YES];
        
        
    }];
    

    
    // Do any additional setup after loading the view from its nib.
}
- (void)getTopics
{
[MBProgressHUD showHUDAddedTo:self.view animated:YES];

AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

manager.responseSerializer = [AFJSONResponseSerializer serializer];
manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];

[manager.requestSerializer setValue:PRIDE_API_AUTH forHTTPHeaderField:@"PRIDE-API-AUTH"];
NSDictionary *params = @{ @"user_id": [[NSUserDefaults standardUserDefaults] objectForKey:USER_USER_ID_IDENTIFIER ]};


[manager POST:[SERVER_URL stringByAppendingString:@"get-community-topic-categories"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
    
    
    
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
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
//                                                        message:errorstring
//                                                       delegate:self
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//        
//        [alert show];
    }
    else{
        // Success
        
        NSLog(@"The responseObject: %@", responseObject);
        NSDictionary* categoriesarray=[responseObject objectForKey:@"categories"];
        if([categoriesarray count]>0)
        {
        identityData=[categoriesarray objectForKey:@"identity"];
        healthData=[categoriesarray objectForKey:@"health"];
        ageData=[categoriesarray objectForKey:@"age"];
        categories=[[NSMutableArray alloc]init] ;
//        [categories addObjectsFromArray:identity];
//        [categories addObjectsFromArray:health];
//        [categories addObjectsFromArray:age];
        [_tableV reloadData];
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
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CreateTopicCell";
    CreateTopicCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CreateTopicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSDictionary* row=NULL;
    switch (indexPath.section)
    {
        case 0:
            row =  [healthData objectAtIndex:indexPath.row];
            if(indexPath.row==healthData.count-1)
            {
                [cell.dividerLine setHidden:true];
                
            }
            else
            {
                [cell.dividerLine setHidden:false];
                
                cell.dividerLine.frame=CGRectMake( cell.dividerLine.frame.origin.x,  cell.dividerLine.frame.origin.y,  cell.dividerLine.frame.size.width,  0.5);
            }
            
            break;
        case 1:
            row =  [identityData objectAtIndex:indexPath.row];
            if(indexPath.row==identityData.count-1)
            {
                [cell.dividerLine setHidden:true];
                
            }
            else
            {
                [cell.dividerLine setHidden:false];
                
                cell.dividerLine.frame=CGRectMake( cell.dividerLine.frame.origin.x,  cell.dividerLine.frame.origin.y,  cell.dividerLine.frame.size.width,  0.5);
            }
            break;
        case 2:
            row =  [ageData objectAtIndex:indexPath.row];
            if(indexPath.row==ageData.count-1)
            {
                [cell.dividerLine setHidden:true];
                
            }
            else
            {
                [cell.dividerLine setHidden:false];
                
                cell.dividerLine.frame=CGRectMake( cell.dividerLine.frame.origin.x,  cell.dividerLine.frame.origin.y,  cell.dividerLine.frame.size.width,  0.5);
            }
            break;
        default:
            return 0;
            break;
    }
    
   
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.titleLabel.text=[row objectForKey:@"name"];
    
    
    if([stateArray containsObject:indexPath])
    {
        [cell.checkButton setImage:[UIImage imageNamed:@"orange_check.png"] forState:UIControlStateNormal];
     //   cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        [cell.checkButton setImage:NULL forState:UIControlStateNormal];

     //   cell.accessoryType = UITableViewCellAccessoryNone;
    }
   
    return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
    
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:true];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
   
    return 49.f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    static NSString *CellIdentifier = @"CreateTopicHeader";
    CreateTopicHeader *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CreateTopicHeader alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.dividerLineTop.frame=CGRectMake( cell.dividerLine.frame.origin.x, 0.5,  cell.dividerLine.frame.size.width,  0.5);

    [cell.dividerLineTop setHidden:false];
    NSString *sectionName;
    switch (section)
    {
        case 0:
            [cell.dividerLineTop setHidden:true];

            sectionName =@"Health";
            break;
        case 1:

            sectionName = @"Identity";
            break;
        case 2:

            sectionName = @"Age";
            break;
        default:
            sectionName = @"";
            break;
    }
    
    cell.titleLabel.text=[sectionName uppercaseString];
    
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section)
    {
        case 0:
            return healthData.count;
            break;
        case 1:
            return identityData.count;
            break;
        case 2:
            return ageData.count;
            break;
        default:
            return 0;
            break;
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if([stateArray containsObject:indexPath])
    {
        [stateArray removeObject:indexPath];
    }
    else
    {
        [stateArray addObject:indexPath];

    }
//    [stateArray replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:![[stateArray objectAtIndex:indexPath.row] boolValue]]];
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)submitPressed:(id)sender {
    [self.view endEditing:true];
    if(_topicTextView.text.length<10)
    {
     
        
        
        if(_topicTextView.text.length==0)
        {
            //display required
            _minLabel1.text=@"Required field";
            [_minLabel1 setHidden:false];
        }
        else if(_topicTextView.text.length<10)
        {
            _minLabel1.text=@"Please enter at least 10 characters";
            [_minLabel1 setHidden:false];
        }
        else
        {
            [_minLabel1 setHidden:true];
            
        }
        if(_whyTextView.text.length==0)
        {
            //display required
            [_minLabel2 setHidden:false];
            
            _minLabel2.text=@"Required field";
        }
        else if(_whyTextView.text.length<10)
        {
            _minLabel2.text=@"Please enter at least 10 characters";
            [_minLabel2 setHidden:false];
        }
        else
        {
            [_minLabel2 setHidden:true];
            
        }
        

             [_tableV setContentOffset:CGPointZero animated:YES];

        return;
    }
    else
    {
       // _minLabel1.textColor=[UIColor blackColor];

    }
    if(_whyTextView.text.length<10)
    {
        
        if(_whyTextView.text.length==0)
        {
            //display required
            [_minLabel2 setHidden:false];
            
            _minLabel2.text=@"Required field";
        }
        else if(_whyTextView.text.length<10)
        {
            _minLabel2.text=@"Please enter at least 10 characters";
            [_minLabel2 setHidden:false];
        }
        else
        {
            [_minLabel2 setHidden:true];
            
        }

        [_tableV setContentOffset:CGPointZero animated:YES];

        return;
    }
    else
    {
       // _minLabel1.textColor=[UIColor blackColor];
        
    }
    NSMutableArray* selectedCategories=[[NSMutableArray alloc]init];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    
    for( NSIndexPath* indx in stateArray)
       {
           NSDictionary* row=NULL;
           
           switch (indx.section)
           {
               case 0:
                   row =  [healthData objectAtIndex:indx.row];
                   break;
               case 1:
                   row =  [identityData objectAtIndex:indx.row];
                   break;
               case 2:
                   row =  [ageData objectAtIndex:indx.row];
                   break;
               default:
                   ;
                   break;
           }
           

           
           [selectedCategories addObject:[row objectForKey:@"id" ]];
       }
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    
    [manager.requestSerializer setValue:PRIDE_API_AUTH forHTTPHeaderField:@"PRIDE-API-AUTH"];
    
    NSDictionary *params = @{ @"user_id": [[NSUserDefaults standardUserDefaults] objectForKey:USER_USER_ID_IDENTIFIER ],  @"title":_topicTextView.text,  @"description":_whyTextView.text,  @"topic_categories":[selectedCategories componentsJoinedByString:@","]};

    [manager POST:[SERVER_URL stringByAppendingString:@"create-community-topic"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        id errors = [responseObject valueForKey:@"errors"];
        
        if(errors && [errors count]>0){
            // Failure
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
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:errorstring message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            
            // Create the "OK" button.
            NSString *okTitle = NSLocalizedString(@"OK", nil);
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
            }];
            
            [alertController addAction:okAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
     
            
        }else{
            // Success
            ///
            NSLog(@"The responseObject: %@", responseObject);
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:STATE_CREATE_TOPIC_COMPLETE];
            [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:STATE_CREATE_TOPIC_COMPLETE_DATE];
            
            
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Your topic has been posted" message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            
            // Create the "OK" button.
            NSString *okTitle = NSLocalizedString(@"OK", nil);
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self dismissViewControllerAnimated:true completion:NULL];

            }];
            
            [alertController addAction:okAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
            
            
            // Save values in user defaults
            
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
@end
