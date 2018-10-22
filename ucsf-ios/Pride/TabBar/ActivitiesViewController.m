//
//  ActivitiesViewController.m
//  Pride
//
//  Created by Patrick Krabeepetcharat on 5/13/15.
//  Copyright (c) 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import "ActivitiesViewController.h"
#import "AppConstants.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import "R1Push.h"
#import "LockScreenViewController.h"
#import "CreateScreenNameViewController.h"
#import "CreateTopicViewController.h"
#import "SurveyWebViewerViewController.h"
@interface ActivitiesViewController ()<JKLLockScreenViewControllerDataSource, JKLLockScreenViewControllerDelegate>
{
    NSString *user_sex;
    NSString *user_orientation;
    NSString *user_identity;
    
    NSMutableArray *sexualOrientations;
    NSMutableArray *genderIdentities;
    NSMutableDictionary *demographicSurveyAnswers;
}

@end

@implementation ActivitiesViewController

NSString *formattedDate;
NSString *urlString_results;

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSLog(@"THE SEXUAL ORIENTATIONS: %@", [[NSUserDefaults standardUserDefaults] valueForKey:USER_SEXUAL_ORIENTATION_IDENTIFIER]);
    NSLog(@"THE GENDER IDENTITIES: %@", [[NSUserDefaults standardUserDefaults] valueForKey:USER_GENDER_IDENTITY_IDENTIFIER]);
    
    AppDelegate* appD = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appD update_user_data];
    
    [self.parentViewController viewWillAppear:true];
    
    
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self loadActiveData];
    
    [self.tableView reloadData];
    [[R1Push sharedInstance].tags addTag:@"DEBUG_TAG"];

    if(![[NSUserDefaults standardUserDefaults] boolForKey:STATE_CREATE_SCREEN_NAME_COMPLETE]){
        //if screen name not completed check on API to see if completed through community
        [self checkScreenName];
    }
    // RadiumOne Tracking
    [[R1Emitter sharedInstance] emitScreenViewWithDocumentTitle:@"Activities"
                                             contentDescription:nil
                                            documentLocationUrl:nil
                                               documentHostName:nil
                                                   documentPath:nil
                                                      otherInfo:nil];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Activities"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate* appD = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appD getHealthkitData];

    // Do any additional setup after loading the view.
    demographicSurveyAnswers= [[NSMutableDictionary alloc]init];
    // Set up table view
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    
    // Set Nav Bar title
    [self.tabBarController.navigationItem setTitle:self.title];
    
    NSDate *date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd"];
    formattedDate = [NSString stringWithFormat:@"Today, %@", [formatter stringFromDate:date]];
    
    
    
}

- (BOOL)lockScreenViewController:(LockScreenViewController *)lockScreenViewController pincode:(NSString *)pincode{
    return YES;
}
-(void)checkScreenName
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    
    [manager.requestSerializer setValue:PRIDE_API_AUTH forHTTPHeaderField:@"PRIDE-API-AUTH"];
    NSDictionary *params = @{ @"user_id": [[NSUserDefaults standardUserDefaults] objectForKey:USER_USER_ID_IDENTIFIER ] };
    
    
    [manager POST:[SERVER_URL stringByAppendingString:@"has-community-screen-name"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        id errors = [responseObject valueForKey:@"errors"];
        
        if(errors && [errors count]>0){
            
        }
        else{
            // Success
            
            NSLog(@"The responseObject: %@", responseObject);
            
            bool has_community_screen_name = [[responseObject objectForKey:@"has_community_screen_name"] boolValue];
            bool has_community_account = [[responseObject objectForKey:@"has_community_account"] boolValue];
            // bool banned = [[responseObject objectForKey:@"banned"] boolValue];
            [[NSUserDefaults standardUserDefaults] setBool:has_community_account forKey:STATE_HAS_COMMUNITY_ACCOUNT];

            if(has_community_screen_name==true)
            {
                
                
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:STATE_CREATE_SCREEN_NAME_COMPLETE];
                [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:STATE_CREATE_SCREEN_NAME_COMPLETE_DATE];
                
                [self loadActiveData];
                [self.tableView reloadData];
                
            }
            else
            {
                
            }
            
            // Save values in user defaults
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
}
- (void)loadActiveData{
    // Set up the active tasks that actually show up
    self.activeTitles = [NSMutableArray new];
    self.activeImageNames = [NSMutableArray new];
    self.activeIdentifiers = [NSMutableArray new];
    
    self.inactiveTitles = [NSMutableArray new];
    self.inactiveImageNames = [NSMutableArray new];
    self.inactiveIdentifiers = [NSMutableArray new];
    
    float activitiesCompleted = 0;
    float activitiesTotal = 10;
    float activitiesRatioCompleted = 0;
    
    double secondsInDay = 86400;
    NSDate *currentDate = [NSDate date];
    NSDate *dateCompleted;
    NSTimeInterval timeSince;
    
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:STATE_DEMOGRAPHIC_SURVEY_COMPLETE]){
        [self.activeTitles addObject:@"Demographic Survey"];
        [self.activeImageNames addObject:@"icon_survey"];
        [self.activeIdentifiers addObject:DEMOGRAPHIC_SURVEY];
    }else{
        dateCompleted = [[NSUserDefaults standardUserDefaults] valueForKey:STATE_DEMOGRAPHIC_SURVEY_COMPLETE_DATE];
        timeSince = [currentDate timeIntervalSinceDate:dateCompleted];
        
        if (timeSince < secondsInDay) {
            [self.inactiveTitles addObject:@"Demographic Survey"];
            [self.inactiveImageNames addObject:@"icon_survey"];
            [self.inactiveIdentifiers addObject:DEMOGRAPHIC_SURVEY];
        }
        
        activitiesCompleted++;
    }
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:STATE_IMPROVING_SURVEY_COMPLETE]){
        [self.activeTitles addObject:@"Improving The PRIDE Study Survey\n(3-5 minutes to complete)"];
        [self.activeImageNames addObject:@"icon_survey"];
        [self.activeIdentifiers addObject:IMPROVING_SURVEY];
    }else{
        dateCompleted = [[NSUserDefaults standardUserDefaults] valueForKey:STATE_IMPROVING_SURVEY_COMPLETE_DATE];
        timeSince = [currentDate timeIntervalSinceDate:dateCompleted];
        
        if (timeSince < secondsInDay) {
            [self.inactiveTitles addObject:@"Improving The PRIDE Study Survey\n(3-5 minutes to complete)"];
            [self.inactiveImageNames addObject:@"icon_survey"];
            [self.inactiveIdentifiers addObject:IMPROVING_SURVEY];
        }
        
        activitiesCompleted++;
    }
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:STATE_PHYSICAL_HEALTH_SURVEY_COMPLETE]){
        [self.activeTitles addObject:@"Physical Health Survey\n(10-15 minutes to complete)"];
        [self.activeImageNames addObject:@"icon_survey"];
        [self.activeIdentifiers addObject:PHYSICAL_SURVEY];
    }else{
        dateCompleted = [[NSUserDefaults standardUserDefaults] valueForKey:STATE_PHYSICAL_HEALTH_SURVEY_COMPLETE_DATE];
        timeSince = [currentDate timeIntervalSinceDate:dateCompleted];
        
        if (timeSince < secondsInDay) {
            [self.inactiveTitles addObject:@"Physical Health Survey\n(10-15 minutes to complete)"];
            [self.inactiveImageNames addObject:@"icon_survey"];
            [self.inactiveIdentifiers addObject:PHYSICAL_SURVEY];
        }
        
        activitiesCompleted++;
    }
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:STATE_MENTAL_HEALTH_SURVEY_COMPLETE]){
        [self.activeTitles addObject:@"Mental Health Survey\n(10-15 minutes to complete)"];
        [self.activeImageNames addObject:@"icon_survey"];
        [self.activeIdentifiers addObject:MENTAL_SURVEY];
    }else{
        dateCompleted = [[NSUserDefaults standardUserDefaults] valueForKey:STATE_MENTAL_HEALTH_SURVEY_COMPLETE_DATE];
        timeSince = [currentDate timeIntervalSinceDate:dateCompleted];
        
        if (timeSince < secondsInDay) {
            [self.inactiveTitles addObject:@"Mental Health Survey\n(10-15 minutes to complete)"];
            [self.inactiveImageNames addObject:@"icon_survey"];
            [self.inactiveIdentifiers addObject:MENTAL_SURVEY];
        }
        
        activitiesCompleted++;
    }
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:STATE_SOCIAL_HEALTH_SURVEY_COMPLETE]){
        [self.activeTitles addObject:@"Social Health Survey\n(10-15 minutes to complete)"];
        [self.activeImageNames addObject:@"icon_survey"];
        [self.activeIdentifiers addObject:SOCIAL_SURVEY];
    }else{
        dateCompleted = [[NSUserDefaults standardUserDefaults] valueForKey:STATE_SOCIAL_HEALTH_SURVEY_COMPLETE_DATE];
        timeSince = [currentDate timeIntervalSinceDate:dateCompleted];
        
        if (timeSince < secondsInDay) {
            [self.inactiveTitles addObject:@"Social Health Survey\n(10-15 minutes to complete)"];
            [self.inactiveImageNames addObject:@"icon_survey"];
            [self.inactiveIdentifiers addObject:SOCIAL_SURVEY];
        }
        
        activitiesCompleted++;
    }
    
    //
    //remove comments
    if(![[NSUserDefaults standardUserDefaults] boolForKey:USER_HAS_LEFT_STUDY]){
        
        if(![[NSUserDefaults standardUserDefaults] boolForKey:STATE_CREATE_SCREEN_NAME_COMPLETE]){
            [self.activeTitles addObject:@"Create your community screen name"];
            [self.activeImageNames addObject:@"tab_community"];
            [self.activeIdentifiers addObject:@"create_screen_name"];
            
        }else{
            dateCompleted = [[NSUserDefaults standardUserDefaults] valueForKey:STATE_CREATE_SCREEN_NAME_COMPLETE_DATE];
            timeSince = [currentDate timeIntervalSinceDate:dateCompleted];
            
            if (timeSince < secondsInDay) {
                [self.inactiveTitles addObject:@"Create your community screen name"];
                [self.inactiveImageNames addObject:@"tab_community"];
                [self.inactiveIdentifiers addObject:@"create_screen_name"];
            }
            
            activitiesCompleted++;
        }
    }
    if(![[NSUserDefaults standardUserDefaults] boolForKey:USER_HAS_LEFT_STUDY]){
        
        if(![[NSUserDefaults standardUserDefaults] boolForKey:STATE_CREATE_TOPIC_COMPLETE]){
            [self.activeTitles addObject:@"Create a topic for community discussion"];
            [self.activeImageNames addObject:@"tab_community"];
            [self.activeIdentifiers addObject:@"create_topic"];
        }else{
            dateCompleted = [[NSUserDefaults standardUserDefaults] valueForKey:STATE_CREATE_TOPIC_COMPLETE_DATE];
            timeSince = [currentDate timeIntervalSinceDate:dateCompleted];
            
            if (timeSince < secondsInDay) {
                [self.inactiveTitles addObject:@"Create a topic for community discussion"];
                [self.inactiveImageNames addObject:@"tab_community"];
                [self.inactiveIdentifiers addObject:@"create_topic"];
            }
            
            activitiesCompleted++;
        }
    }
    if(![[NSUserDefaults standardUserDefaults] boolForKey:STATE_REVIEW_TOPICS_COMPLETE]){
        [self.activeTitles addObject:@"Review other topics"];
        [self.activeImageNames addObject:@"tab_community"];
        [self.activeIdentifiers addObject:@"review_topics"];
    }else{
        dateCompleted = [[NSUserDefaults standardUserDefaults] valueForKey:STATE_REVIEW_TOPICS_COMPLETE_DATE];
        timeSince = [currentDate timeIntervalSinceDate:dateCompleted];
        
        if (timeSince < secondsInDay) {
            [self.inactiveTitles addObject:@"Review other topics"];
            [self.inactiveImageNames addObject:@"tab_community"];
            [self.inactiveIdentifiers addObject:@"review_topics"];
        }
        
        activitiesCompleted++;
    }
    if(![[NSUserDefaults standardUserDefaults] boolForKey:USER_HAS_LEFT_STUDY]){
        
        if(![[NSUserDefaults standardUserDefaults] boolForKey:STATE_VOTE_ON_TOPICS_COMPLETE]){
            [self.activeTitles addObject:@"Vote on topics that matter most to you"];
            [self.activeImageNames addObject:@"tab_community"];
            [self.activeIdentifiers addObject:@"vote_on_topics"];
        }else{
            dateCompleted = [[NSUserDefaults standardUserDefaults] valueForKey:STATE_VOTE_ON_TOPICS_COMPLETE_DATE];
            timeSince = [currentDate timeIntervalSinceDate:dateCompleted];
            
            if (timeSince < secondsInDay) {
                [self.inactiveTitles addObject:@"Vote on topics that matter most to you"];
                [self.inactiveImageNames addObject:@"tab_community"];
                [self.inactiveIdentifiers addObject:@"vote_on_topics"];
            }
            
            activitiesCompleted++;
        }
    }
    if(![[NSUserDefaults standardUserDefaults] boolForKey:USER_HAS_LEFT_STUDY]){
        
        if(![[NSUserDefaults standardUserDefaults] boolForKey:STATE_COMMENT_ON_TOPICS_COMPLETE]){
            [self.activeTitles addObject:@"Comment on topics of interest"];
            [self.activeImageNames addObject:@"tab_community"];
            [self.activeIdentifiers addObject:@"comment_on_topics"];
        }else{
            dateCompleted = [[NSUserDefaults standardUserDefaults] valueForKey:STATE_COMMENT_ON_TOPICS_COMPLETE_DATE];
            timeSince = [currentDate timeIntervalSinceDate:dateCompleted];
            
            if (timeSince < secondsInDay) {
                [self.inactiveTitles addObject:@"Comment on topics of interest"];
                [self.inactiveImageNames addObject:@"tab_community"];
                [self.inactiveIdentifiers addObject:@"comment_on_topics"];
            }
            
            activitiesCompleted++;
        }
    }
    activitiesRatioCompleted = activitiesCompleted/activitiesTotal;
    
    // Save ratio of activities completed
    [[NSUserDefaults standardUserDefaults] setFloat:activitiesRatioCompleted forKey:STATE_ACTIVITES_RATIO_COMPLETED];
}


#pragma mark TableView Delegate Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return [self.activeTitles count];
    }else if(section == 1){
        return [self.inactiveTitles count];
    }else{
        // Just in case, but this should never happen
        return [self.activeTitles count];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if ([self.inactiveTitles count] > 0) {
        return 2;
    }else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = @"";
    NSString *imageName = @"";
    
    if(indexPath.section == 0){
        title = [self.activeTitles objectAtIndex:indexPath.row];
        imageName = [self.activeImageNames objectAtIndex:indexPath.row];
    }else if(indexPath.section == 1){
        title = [self.inactiveTitles objectAtIndex:indexPath.row];
        imageName = [self.inactiveImageNames objectAtIndex:indexPath.row];
    }
    
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = title;
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    cell.textLabel.numberOfLines = 2;
    cell.imageView.image = [UIImage imageNamed:imageName];
    cell.imageView.frame = CGRectMake(0, 0, 5, 5);
    
    // Show disabled state if not in the first section.
    [cell.textLabel setTextColor:[UIColor blackColor]];
    [cell.imageView setTintColor:[UIColor primaryColor]];
    
    if(indexPath.section == 1){
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell.textLabel setTextColor:[UIColor grayColor]];
        [cell.imageView setTintColor:[UIColor grayColor]];
    }
    
    return cell;
}

// The Header
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSString *identifier = @"HeaderCell";
    
    ActivitiesHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[ActivitiesHeaderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    // Customize text for date or completed section
    if(section == 0){
        cell.labelDate.text = formattedDate;
        
        if([self.activeTitles count] == 0){
            cell.labelDescription.text = @"You have completed all activities available today";
        }
    }else if(section ==1){
        cell.labelDate.text = @"Recently Completed Tasks";
        cell.labelDescription.text = @"Tasks you have completed in the last 24 hours";
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 60;
}
-(void)goToCommunityTab {
    [self.tabBarController setSelectedIndex:2];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    // Only handle if it's the first section
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"No internet connection detected. Please connect to the internet to view this content."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
    } else {
        
        if(indexPath.section == 0){
            if([self.activeIdentifiers[indexPath.row] isEqualToString:DEMOGRAPHIC_SURVEY]){
                [self startDemographicSurvey];
            }else if([self.activeIdentifiers[indexPath.row] isEqualToString:@"create_screen_name"]){
                if([[NSUserDefaults standardUserDefaults] boolForKey:STATE_HAS_COMMUNITY_ACCOUNT])
                    [self showCreateScreenNameTask];
                else
                    [self goToCommunityTab];
            }else if([self.activeIdentifiers[indexPath.row] isEqualToString:@"create_topic"]){
                if([[NSUserDefaults standardUserDefaults] boolForKey:STATE_HAS_COMMUNITY_ACCOUNT])
                    [self showCreateTopicTask];
                else
                    [self goToCommunityTab];
            }else if([self.activeIdentifiers[indexPath.row] isEqualToString:@"review_topics"]){
                [self showReviewTopicsTask];
            }else if([self.activeIdentifiers[indexPath.row] isEqualToString:@"vote_on_topics"]){
                [self showVoteOnTopicsTask];
            }else if([self.activeIdentifiers[indexPath.row] isEqualToString:@"comment_on_topics"]){
                [self showCommentOnTopicsTask];
            }else if([self.activeIdentifiers[indexPath.row] isEqualToString:IMPROVING_SURVEY] ||
                     [self.activeIdentifiers[indexPath.row] isEqualToString:PHYSICAL_SURVEY] ||
                     [self.activeIdentifiers[indexPath.row] isEqualToString:MENTAL_SURVEY] ||
                     [self.activeIdentifiers[indexPath.row] isEqualToString:SOCIAL_SURVEY] ||
                     [self.activeIdentifiers[indexPath.row] isEqualToString:AGE_SURVEY]){
                [self showWebViewSurvey:self.activeIdentifiers[indexPath.row]];
            }else{
                
            }
        }
    }
}

#pragma mark Task ViewController Delegates
- (void)taskViewController:(ORKTaskViewController * __nonnull)taskViewController didChangeResult:(ORKTaskResult * __nonnull)result{
    
    ORKStepResult *stepResult;
    ORKChoiceQuestionResult *choiceQuestionResult;
    ORKBooleanQuestionResult *booleanQuestionResult;
    ORKTextQuestionResult *textQuestionResult;
    
    NSArray *answer;
    NSString *textAnswer;
    NSMutableArray *codedAnswer;
    NSNumber *boolAnswer;
    
    
    // Question: SURVEY_SEX
    stepResult = [result stepResultForStepIdentifier:SURVEY_SEX];
    choiceQuestionResult = (ORKChoiceQuestionResult*)[stepResult.results firstObject];
    answer = choiceQuestionResult.choiceAnswers;
    
    [demographicSurveyAnswers setValue:[answer firstObject] forKey:SURVEY_SEX];
    
    NSString *sexAnswer = (NSString *)[answer firstObject];
    // SET USER VALUE FOR SEX
    if([sexAnswer isEqualToString:@"1"]){
        NSLog(@"FEMALE");
        user_sex = @"Female";
    }else if([sexAnswer isEqualToString:@"2"]){
        NSLog(@"MALE");
        user_sex = @"Male";
    }
    
    NSLog(@"THE SEX: %@", user_sex);
    
    // Question: SURVEY_SEXUAL_ORIENTATION
    stepResult = [result stepResultForStepIdentifier:SURVEY_SEXUAL_ORIENTATION];
    choiceQuestionResult = [stepResult.results firstObject];
    answer = choiceQuestionResult.choiceAnswers;
    
    codedAnswer = [NSMutableArray new];
    sexualOrientations = [NSMutableArray new];
    
    for (NSString *item in answer) {
        NSLog(@"item: %@", item);
        if([item isEqualToString:@"Asexual"]){
            [codedAnswer addObject:[NSNumber numberWithInt:1]];
            [sexualOrientations addObject:@"Asexual"];
        }else if([item isEqualToString:@"Bisexual"]){
            [codedAnswer addObject:[NSNumber numberWithInt:2]];
            [sexualOrientations addObject:@"Bisexual"];
        }else if([item isEqualToString:@"Gay"]){
            [codedAnswer addObject:[NSNumber numberWithInt:3]];
            [sexualOrientations addObject:@"Gay"];
        }else if([item isEqualToString:@"Lesbian"]){
            [codedAnswer addObject:[NSNumber numberWithInt:4]];
            [sexualOrientations addObject:@"Lesbian"];
        }else if([item isEqualToString:@"Queer"]){
            [codedAnswer addObject:[NSNumber numberWithInt:5]];
            [sexualOrientations addObject:@"Queer"];
        }else if([item isEqualToString:@"Questioning"]){
            [codedAnswer addObject:[NSNumber numberWithInt:6]];
            [sexualOrientations addObject:@"Questioning"];
        }else if([item isEqualToString:@"Straight/Heterosexual"]){
            [codedAnswer addObject:[NSNumber numberWithInt:7]];
            [sexualOrientations addObject:@"Straight/Heterosexual"];
        }else if([item isEqualToString:@"Another"]){
            [codedAnswer addObject:[NSNumber numberWithInt:8]];
        }
    }
    
    [demographicSurveyAnswers setObject:codedAnswer forKey:SURVEY_SEXUAL_ORIENTATION];
    
    // Question: Orientation_a
    stepResult = [result stepResultForStepIdentifier:SURVEY_SEXUAL_ORIENTATION_A];
    textQuestionResult = [stepResult.results firstObject];
    textAnswer = textQuestionResult.textAnswer;
    
    [demographicSurveyAnswers setValue:textAnswer forKey:SURVEY_SEXUAL_ORIENTATION_A];
    
    /////// Save the Orientation values for the user defaults later
    if([textAnswer length] > 0){
        [sexualOrientations addObject:textAnswer];
    }
    
    // Question: SURVEY_GENDER_IDENTITY
    stepResult = [result stepResultForStepIdentifier:SURVEY_GENDER_IDENTITY];
    choiceQuestionResult = [stepResult.results firstObject];
    answer = choiceQuestionResult.choiceAnswers;
    
    codedAnswer = [NSMutableArray new];
    genderIdentities = [NSMutableArray new];
    
    for (NSString *item in answer) {
        NSLog(@"item: %@", item);
        if([item isEqualToString:@"Genderqueer"]){
            [codedAnswer addObject:[NSNumber numberWithInt:1]];
            [genderIdentities addObject:@"Genderqueer"];
        }else if([item isEqualToString:@"Man"]){
            [codedAnswer addObject:[NSNumber numberWithInt:2]];
            [genderIdentities addObject:@"Man"];
        }else if([item isEqualToString:@"Transgender Man (Female­-to-­Male)"]){
            [codedAnswer addObject:[NSNumber numberWithInt:3]];
            [genderIdentities addObject:@"Transgender Man (Female­-to-­Male)"];
        }else if([item isEqualToString:@"Woman"]){
            [codedAnswer addObject:[NSNumber numberWithInt:4]];
            [genderIdentities addObject:@"Woman"];
        }else if([item isEqualToString:@"Transgender Woman (Male­-to-­Female)"]){
            [codedAnswer addObject:[NSNumber numberWithInt:5]];
            [genderIdentities addObject:@"Transgender Woman (Male­-to-­Female)"];
        }else if([item isEqualToString:@"Another"]){
            [codedAnswer addObject:[NSNumber numberWithInt:6]];
        }
    }
    
    [demographicSurveyAnswers setObject:codedAnswer forKey:SURVEY_GENDER_IDENTITY];
    
    // Question: SURVEY_GENDER_IDENTITY_A
    stepResult = [result stepResultForStepIdentifier:SURVEY_GENDER_IDENTITY_A];
    textQuestionResult = [stepResult.results firstObject];
    textAnswer = textQuestionResult.textAnswer;
    
    [demographicSurveyAnswers setValue:textAnswer forKey:SURVEY_GENDER_IDENTITY_A];
    
    /////// Save the Orientation values for the user defaults later
    if([textAnswer length] > 0){
        [genderIdentities addObject:textAnswer];
    }
    
    // Question: SURVEY_BORN_IN_US
    stepResult = [result stepResultForStepIdentifier:SURVEY_BORN_IN_US];
    booleanQuestionResult = [stepResult.results firstObject];
    boolAnswer = booleanQuestionResult.booleanAnswer;
    
    if([boolAnswer isEqual:[NSNumber numberWithInt:1]]){
        [demographicSurveyAnswers setValue:[NSNumber numberWithInt:1] forKey:SURVEY_BORN_IN_US];
    }else if([boolAnswer isEqual:[NSNumber numberWithInt:0]]){
        [demographicSurveyAnswers setValue:[NSNumber numberWithInt:2] forKey:SURVEY_BORN_IN_US];
    }
    
    // Question: SURVEY_HISPANIC
    stepResult = [result stepResultForStepIdentifier:SURVEY_HISPANIC];
    booleanQuestionResult = [stepResult.results firstObject];
    boolAnswer = booleanQuestionResult.booleanAnswer;
    
    if([boolAnswer isEqual:[NSNumber numberWithInt:1]]){
        [demographicSurveyAnswers setValue:[NSNumber numberWithInt:1] forKey:SURVEY_HISPANIC];
    }else if([boolAnswer isEqual:[NSNumber numberWithInt:0]]){
        [demographicSurveyAnswers setValue:[NSNumber numberWithInt:2] forKey:SURVEY_HISPANIC];
    }
    
    // Question: SURVEY_HISPANIC_A
    stepResult = [result stepResultForStepIdentifier:SURVEY_HISPANIC_A];
    choiceQuestionResult = [stepResult.results firstObject];
    answer = choiceQuestionResult.choiceAnswers;
    
    codedAnswer = [NSMutableArray new];
    
    for (NSString *item in answer) {
        NSLog(@"item: %@", item);
        if([item isEqualToString:@"Mexican"]){
            [codedAnswer addObject:[NSNumber numberWithInt:5]];
        }else if([item isEqualToString:@"Puerto Rican"]){
            [codedAnswer addObject:[NSNumber numberWithInt:2]];
        }else if([item isEqualToString:@"Cuban"]){
            [codedAnswer addObject:[NSNumber numberWithInt:3]];
        }else if([item isEqualToString:@"Another"]){
            [codedAnswer addObject:[NSNumber numberWithInt:4]];
        }
    }
    
    [demographicSurveyAnswers setObject:codedAnswer forKey:SURVEY_HISPANIC_A];
    
    // Question: SURVEY_HISPANIC_B
    stepResult = [result stepResultForStepIdentifier:SURVEY_HISPANIC_B];
    textQuestionResult = [stepResult.results firstObject];
    textAnswer = textQuestionResult.textAnswer;
    
    [demographicSurveyAnswers setValue:textAnswer forKey:SURVEY_HISPANIC_B];
    
    // Question: Race
    stepResult = [result stepResultForStepIdentifier:SURVEY_RACE];
    choiceQuestionResult = [stepResult.results firstObject];
    answer = choiceQuestionResult.choiceAnswers;
    
    codedAnswer = [NSMutableArray new];
    
    for (NSString *item in answer) {
        NSLog(@"item: %@", item);
        if([item isEqualToString:@"White"]){
            [codedAnswer addObject:[NSNumber numberWithInt:1]];
        }else if([item isEqualToString:@"Black"]){
            [codedAnswer addObject:[NSNumber numberWithInt:2]];
        }else if([item isEqualToString:@"American Indian"]){
            [codedAnswer addObject:[NSNumber numberWithInt:3]];
        }else if([item isEqualToString:@"Asian Indian"]){
            [codedAnswer addObject:[NSNumber numberWithInt:5]];
        }else if([item isEqualToString:@"Chinese"]){
            [codedAnswer addObject:[NSNumber numberWithInt:6]];
        }else if([item isEqualToString:@"Filipino"]){
            [codedAnswer addObject:[NSNumber numberWithInt:7]];
        }else if([item isEqualToString:@"Japanese"]){
            [codedAnswer addObject:[NSNumber numberWithInt:8]];
        }else if([item isEqualToString:@"Korean"]){
            [codedAnswer addObject:[NSNumber numberWithInt:9]];
        }else if([item isEqualToString:@"Vietnamese"]){
            [codedAnswer addObject:[NSNumber numberWithInt:10]];
        }else if([item isEqualToString:@"Native Hawaiian"]){
            [codedAnswer addObject:[NSNumber numberWithInt:11]];
        }else if([item isEqualToString:@"Guamanian or Chamorro"]){
            [codedAnswer addObject:[NSNumber numberWithInt:12]];
        }else if([item isEqualToString:@"Samoan"]){
            [codedAnswer addObject:[NSNumber numberWithInt:13]];
        }else if([item isEqualToString:@"Other Pacific Islander"]){
            [codedAnswer addObject:[NSNumber numberWithInt:14]];
        }else if([item isEqualToString:@"Other Asian"]){
            [codedAnswer addObject:[NSNumber numberWithInt:15]];
        }else if([item isEqualToString:@"Another"]){
            [codedAnswer addObject:[NSNumber numberWithInt:16]];
        }
    }
    
    [demographicSurveyAnswers setObject:codedAnswer forKey:SURVEY_RACE];
    
    // Question: SURVEY_RACE_A
    stepResult = [result stepResultForStepIdentifier:SURVEY_RACE_A];
    textQuestionResult = [stepResult.results firstObject];
    textAnswer = textQuestionResult.textAnswer;
    
    [demographicSurveyAnswers setValue:textAnswer forKey:SURVEY_RACE_A];
    
    // Question: SURVEY_RACE_B
    stepResult = [result stepResultForStepIdentifier:SURVEY_RACE_B];
    textQuestionResult = [stepResult.results firstObject];
    textAnswer = textQuestionResult.textAnswer;
    
    [demographicSurveyAnswers setValue:textAnswer forKey:SURVEY_RACE_B];
    
    // Question: SURVEY_EDUCATION
    stepResult = [result stepResultForStepIdentifier:SURVEY_EDUCATION];
    choiceQuestionResult = [stepResult.results firstObject];
    answer = choiceQuestionResult.choiceAnswers;
    
    codedAnswer = [NSMutableArray new];
    
    for (NSString *item in answer) {
        NSLog(@"item: %@", item);
        if([item isEqualToString:@"No School"]){
            [codedAnswer addObject:[NSNumber numberWithInt:1]];
        }else if([item isEqualToString:@"Nursery"]){
            [codedAnswer addObject:[NSNumber numberWithInt:2]];
        }else if([item isEqualToString:@"High school"]){
            [codedAnswer addObject:[NSNumber numberWithInt:3]];
        }else if([item isEqualToString:@"Trade"]){
            [codedAnswer addObject:[NSNumber numberWithInt:4]];
        }else if([item isEqualToString:@"Some college"]){
            [codedAnswer addObject:[NSNumber numberWithInt:5]];
        }else if([item isEqualToString:@"2­ year"]){
            [codedAnswer addObject:[NSNumber numberWithInt:6]];
        }else if([item isEqualToString:@"4 ­year"]){
            [codedAnswer addObject:[NSNumber numberWithInt:7]];
        }else if([item isEqualToString:@"Master’s"]){
            [codedAnswer addObject:[NSNumber numberWithInt:8]];
        }else if([item isEqualToString:@"Doctoral"]){
            [codedAnswer addObject:[NSNumber numberWithInt:9]];
        }else if([item isEqualToString:@"Professional"]){
            [codedAnswer addObject:[NSNumber numberWithInt:10]];
        }
    }
    
    [demographicSurveyAnswers setObject:codedAnswer forKey:SURVEY_EDUCATION];
    
    // Question: SURVEY_INCOME
    stepResult = [result stepResultForStepIdentifier:SURVEY_INCOME];
    choiceQuestionResult = [stepResult.results firstObject];
    answer = choiceQuestionResult.choiceAnswers;
    
    codedAnswer = [NSMutableArray new];
    
    for (NSString *item in answer) {
        NSLog(@"item: %@", item);
        if([item isEqualToString:@"$0-5,000"]){
            [codedAnswer addObject:[NSNumber numberWithInt:1]];
        }else if([item isEqualToString:@"$5,001-­10,000"]){
            [codedAnswer addObject:[NSNumber numberWithInt:2]];
        }else if([item isEqualToString:@"$10,001-­15,000"]){
            [codedAnswer addObject:[NSNumber numberWithInt:3]];
        }else if([item isEqualToString:@"$15,001-­20,000"]){
            [codedAnswer addObject:[NSNumber numberWithInt:4]];
        }else if([item isEqualToString:@"$20,001-­30,000"]){
            [codedAnswer addObject:[NSNumber numberWithInt:5]];
        }else if([item isEqualToString:@"$30,001­-40,000"]){
            [codedAnswer addObject:[NSNumber numberWithInt:6]];
        }else if([item isEqualToString:@"$40,001-­50,000"]){
            [codedAnswer addObject:[NSNumber numberWithInt:7]];
        }else if([item isEqualToString:@"$50,001­-60,000"]){
            [codedAnswer addObject:[NSNumber numberWithInt:8]];
        }else if([item isEqualToString:@"$60,001­-70,000"]){
            [codedAnswer addObject:[NSNumber numberWithInt:9]];
        }else if([item isEqualToString:@"$70,001-­80,000"]){
            [codedAnswer addObject:[NSNumber numberWithInt:10]];
        }else if([item isEqualToString:@"$80,001-­90,000"]){
            [codedAnswer addObject:[NSNumber numberWithInt:11]];
        }else if([item isEqualToString:@"$90,001-­100,000"]){
            [codedAnswer addObject:[NSNumber numberWithInt:12]];
        }else if([item isEqualToString:@"$100,001+"]){
            [codedAnswer addObject:[NSNumber numberWithInt:13]];
        }
    }
    
    [demographicSurveyAnswers setObject:codedAnswer forKey:SURVEY_INCOME];
    
    // Question: SURVEY_ARMED_SERVICES
    stepResult = [result stepResultForStepIdentifier:SURVEY_ARMED_SERVICES];
    booleanQuestionResult = [stepResult.results firstObject];
    boolAnswer = booleanQuestionResult.booleanAnswer;
    
    if([boolAnswer isEqual:[NSNumber numberWithInt:1]]){
        [demographicSurveyAnswers setValue:[NSNumber numberWithInt:1] forKey:SURVEY_ARMED_SERVICES];
    }else if([boolAnswer isEqual:[NSNumber numberWithInt:0]]){
        [demographicSurveyAnswers setValue:[NSNumber numberWithInt:2] forKey:SURVEY_ARMED_SERVICES];
    }
    
    // Question: SURVEY_HEALTH_INSURANCE
    stepResult = [result stepResultForStepIdentifier:SURVEY_HEALTH_INSURANCE];
    booleanQuestionResult = [stepResult.results firstObject];
    boolAnswer = booleanQuestionResult.booleanAnswer;
    
    if([boolAnswer isEqual:[NSNumber numberWithInt:1]]){
        [demographicSurveyAnswers setValue:[NSNumber numberWithInt:1] forKey:SURVEY_HEALTH_INSURANCE];
    }else if([boolAnswer isEqual:[NSNumber numberWithInt:0]]){
        [demographicSurveyAnswers setValue:[NSNumber numberWithInt:2] forKey:SURVEY_HEALTH_INSURANCE];
    }
    
    // Question: SURVEY_RELATIONSHIP
    stepResult = [result stepResultForStepIdentifier:SURVEY_RELATIONSHIP];
    booleanQuestionResult = [stepResult.results firstObject];
    boolAnswer = booleanQuestionResult.booleanAnswer;
    
    if([boolAnswer isEqual:[NSNumber numberWithInt:1]]){
        [demographicSurveyAnswers setValue:[NSNumber numberWithInt:1] forKey:SURVEY_RELATIONSHIP];
    }else if([boolAnswer isEqual:[NSNumber numberWithInt:0]]){
        [demographicSurveyAnswers setValue:[NSNumber numberWithInt:2] forKey:SURVEY_RELATIONSHIP];
    }
    
    // Question: SURVEY_RELATIONSHIP_YES
    stepResult = [result stepResultForStepIdentifier:SURVEY_RELATIONSHIP_YES];
    choiceQuestionResult = [stepResult.results firstObject];
    answer = choiceQuestionResult.choiceAnswers;
    
    codedAnswer = [NSMutableArray new];
    
    for (NSString *item in answer) {
        NSLog(@"item: %@", item);
        if([item isEqualToString:@"Dating"]){
            [codedAnswer addObject:[NSNumber numberWithInt:1]];
        }else if([item isEqualToString:@"Cohabitation"]){
            [codedAnswer addObject:[NSNumber numberWithInt:2]];
        }else if([item isEqualToString:@"Civil union"]){
            [codedAnswer addObject:[NSNumber numberWithInt:3]];
        }else if([item isEqualToString:@"Married"]){
            [codedAnswer addObject:[NSNumber numberWithInt:4]];
        }else if([item isEqualToString:@"Another"]){
            [codedAnswer addObject:[NSNumber numberWithInt:5]];
        }
    }
    
    [demographicSurveyAnswers setObject:codedAnswer forKey:SURVEY_RELATIONSHIP_YES];
    
    // Question: SURVEY_RELATIONSHIP_ANOTHER
    stepResult = [result stepResultForStepIdentifier:SURVEY_RELATIONSHIP_ANOTHER];
    textQuestionResult = [stepResult.results firstObject];
    textAnswer = textQuestionResult.textAnswer;
    
    [demographicSurveyAnswers setValue:textAnswer forKey:SURVEY_RELATIONSHIP_ANOTHER];
    
    // Question: SURVEY_RELATIONSHIP_NO
    stepResult = [result stepResultForStepIdentifier:SURVEY_RELATIONSHIP_NO];
    choiceQuestionResult = [stepResult.results firstObject];
    answer = choiceQuestionResult.choiceAnswers;
    
    codedAnswer = [NSMutableArray new];
    
    for (NSString *item in answer) {
        NSLog(@"item: %@", item);
        if([item isEqualToString:@"Single"]){
            [codedAnswer addObject:[NSNumber numberWithInt:1]];
        }else if([item isEqualToString:@"Separated"]){
            [codedAnswer addObject:[NSNumber numberWithInt:2]];
        }else if([item isEqualToString:@"Divorced"]){
            [codedAnswer addObject:[NSNumber numberWithInt:3]];
        }else if([item isEqualToString:@"Widowed"]){
            [codedAnswer addObject:[NSNumber numberWithInt:4]];
        }
    }
    
    [demographicSurveyAnswers setObject:codedAnswer forKey:SURVEY_RELATIONSHIP_NO];
    
    // Question: SURVEY_HOW_DID_YOU_HEAR
    stepResult = [result stepResultForStepIdentifier:SURVEY_HOW_DID_YOU_HEAR];
    choiceQuestionResult = [stepResult.results firstObject];
    answer = choiceQuestionResult.choiceAnswers;
    
    codedAnswer = [NSMutableArray new];
    
    for (NSString *item in answer) {
        NSLog(@"item: %@", item);
        if([item isEqualToString:@"Social"]){
            [codedAnswer addObject:[NSNumber numberWithInt:1]];
        }else if([item isEqualToString:@"Email"]){
            [codedAnswer addObject:[NSNumber numberWithInt:2]];
        }else if([item isEqualToString:@"Health"]){
            [codedAnswer addObject:[NSNumber numberWithInt:3]];
        }else if([item isEqualToString:@"organization"]){
            [codedAnswer addObject:[NSNumber numberWithInt:4]];
        }else if([item isEqualToString:@"Billboard"]){
            [codedAnswer addObject:[NSNumber numberWithInt:5]];
        }else if([item isEqualToString:@"TV"]){
            [codedAnswer addObject:[NSNumber numberWithInt:6]];
        }else if([item isEqualToString:@"Print"]){
            [codedAnswer addObject:[NSNumber numberWithInt:7]];
        }else if([item isEqualToString:@"Searching"]){
            [codedAnswer addObject:[NSNumber numberWithInt:8]];
        }else if([item isEqualToString:@"General"]){
            [codedAnswer addObject:[NSNumber numberWithInt:9]];
        }
    }
    
    [demographicSurveyAnswers setObject:codedAnswer forKey:SURVEY_HOW_DID_YOU_HEAR];
    
    // Anamorphic Measurements and User ID
    id height = [[NSUserDefaults standardUserDefaults] valueForKey:USER_HEIGHT_IDENTIFIER];
    id weight = [[NSUserDefaults standardUserDefaults] valueForKey:USER_WEIGHT_IDENTIFIER];
    id userID = [[NSUserDefaults standardUserDefaults] valueForKey:USER_USER_ID_IDENTIFIER];
    
    if(height){
        [demographicSurveyAnswers setObject:height forKey:SURVEY_HEIGHT];
    }
    if(weight){
        [demographicSurveyAnswers setObject:weight forKey:SURVEY_WEIGHT];
    }
    if(userID){
        [demographicSurveyAnswers setObject:userID forKey:SURVEY_USER_ID];
    }
    
    
}

- (void)taskViewController:(ORKTaskViewController *)taskViewController stepViewControllerWillAppear:(ORKStepViewController *)stepViewController{
    
    // Change the button titles
    if ([stepViewController.step.identifier isEqualToString:TASK_COMMUNITY_CREATE_SCREEN_NAME]) {
        stepViewController.continueButtonTitle = @"Create a Screen Name";
    }else if([stepViewController.step.identifier isEqualToString:TASK_COMMUNITY_CREATE_TOPIC]){
        stepViewController.continueButtonTitle = @"Get Started";
    }else if([stepViewController.step.identifier isEqualToString:TASK_COMMUNITY_REVIEW_TOPICS]){
        stepViewController.continueButtonTitle = @"Get Started";
    }else if([stepViewController.step.identifier isEqualToString:TASK_COMMUNITY_VOTE_ON_TOPICS]){
        stepViewController.continueButtonTitle = @"Get Started";
    }else if([stepViewController.step.identifier isEqualToString:TASK_COMMUNITY_COMMENT_ON_TOPICS]){
        stepViewController.continueButtonTitle = @"Get Started";
    }
}

- (void)taskViewController:(ORKTaskViewController * __nonnull)taskViewController didFinishWithReason:(ORKTaskViewControllerFinishReason)reason error:(nullable NSError *)error{
    
    if([taskViewController isEqual:self.task_demographicSurvey]){
        // quit reason = 1  ||  finish reason = 2
        if (reason == 1) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }else if (reason == 2){
            // Encode the URL to make it valid for the request
            
            // Serialize to JSON
            NSError *error = nil;
            NSData *json;
            NSString *jsonString;
            
            if ([NSJSONSerialization isValidJSONObject:demographicSurveyAnswers]){
                // Serialize the dictionary
                json = [NSJSONSerialization dataWithJSONObject:demographicSurveyAnswers options:NSJSONWritingPrettyPrinted error:&error];
                
                // If no errors, let's view the JSON
                if (json != nil && error == nil){
                    jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
                }
            }else{
            }
            
            // Make the request
            urlString_results = [NSString stringWithFormat:QUALTRICS_DEMOGRAPHICS_SURVEY_URL, jsonString];
            
            urlString_results = [urlString_results stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            // Make the network request
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            [manager GET:urlString_results parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                NSLog(@"RESPONSE: %@", string);
                [self notifyServer:string];
                [[NSUserDefaults standardUserDefaults] setValue:nil forKey:SURVEY_RESULTS];
                
                [[NSUserDefaults standardUserDefaults] setValue:string forKey:USER_DEMOGRAPHIC_SURVEY_RESPONSE_ID_IDENTIFIER];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"ERROR: %@", error);
                
                // Save the string here, so we can try again later after the app launches
                [[NSUserDefaults standardUserDefaults] setValue:urlString_results forKey:SURVEY_RESULTS];
            }];
            
            // Save user values to later show in the profile
            if(user_sex){
                [[NSUserDefaults standardUserDefaults] setValue:user_sex forKey:USER_SEX_IDENTIFIER];
            }
            if(sexualOrientations){
                [[NSUserDefaults standardUserDefaults] setValue:sexualOrientations forKey:USER_SEXUAL_ORIENTATION_IDENTIFIER];
            }
            if(genderIdentities){
                [[NSUserDefaults standardUserDefaults] setValue:genderIdentities forKey:USER_GENDER_IDENTITY_IDENTIFIER];
            }
            
            // Save constant that the quiz is finished so it doesn't show up in the activities later
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:STATE_DEMOGRAPHIC_SURVEY_COMPLETE];
            [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:STATE_DEMOGRAPHIC_SURVEY_COMPLETE_DATE];
            
            AppDelegate* appD = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appD update_user_data];
            
        }
    }
    
    if(reason == 2){
        if([taskViewController isEqual:self.task_communityCreateScreenName]){
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:STATE_CREATE_SCREEN_NAME_COMPLETE];
            [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:STATE_CREATE_SCREEN_NAME_COMPLETE_DATE];
            
            [self.tabBarController setSelectedIndex:2];
            AppDelegate* appD = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appD update_user_data];
        }
        
        else if([taskViewController isEqual:self.task_communityCreateTopic]){
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:STATE_CREATE_TOPIC_COMPLETE];
            [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:STATE_CREATE_TOPIC_COMPLETE_DATE];
            AppDelegate* appD = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appD update_user_data];
            [self.tabBarController setSelectedIndex:2];
        }
        
        else if([taskViewController isEqual:self.task_communityReviewTopics]){
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:STATE_REVIEW_TOPICS_COMPLETE];
            [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:STATE_REVIEW_TOPICS_COMPLETE_DATE];
            AppDelegate* appD = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appD update_user_data];
            [self.tabBarController setSelectedIndex:2];
        }
        
        else if([taskViewController isEqual:self.task_communityVoteOnTopics]){
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:STATE_VOTE_ON_TOPICS_COMPLETE];
            [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:STATE_VOTE_ON_TOPICS_COMPLETE_DATE];
            AppDelegate* appD = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appD update_user_data];
            [self.tabBarController setSelectedIndex:2];
        }
        
        else if([taskViewController isEqual:self.task_communityCommentOnTopics]){
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:STATE_COMMENT_ON_TOPICS_COMPLETE];
            [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:STATE_COMMENT_ON_TOPICS_COMPLETE_DATE];
            
            AppDelegate* appD = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appD update_user_data];
            
            [self.tabBarController setSelectedIndex:2];
        }
    }
    
    // Updates the activities completed ratio
    [self loadActiveData];
    
    // Close the View controller when finished
    [taskViewController dismissViewControllerAnimated:YES completion:nil];
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


#pragma mark Survey
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


#pragma mark Get Started Steps
- (void)showCreateScreenNameTask{
    
    
    CreateScreenNameViewController* screen=[[CreateScreenNameViewController alloc]init];
    
    UINavigationController* nav=[[UINavigationController alloc]initWithRootViewController:screen];
    
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)showCreateTopicTask{
    
    CreateTopicViewController* screen=[[CreateTopicViewController alloc]init];
    
    UINavigationController* nav=[[UINavigationController alloc]initWithRootViewController:screen];
    
    [self presentViewController:nav animated:YES completion:nil];
}
- (void)showWebViewSurvey : (NSString*)surveyType{
    
    SurveyWebViewerViewController* screen=[[SurveyWebViewerViewController alloc]init];
    screen.surveyType=surveyType;
    UINavigationController* nav=[[UINavigationController alloc]initWithRootViewController:screen];
    [self presentViewController:nav animated:YES completion:nil];
}
- (void)showReviewTopicsTask{
    ORKInstructionStep *stepInstruction = [[ORKInstructionStep alloc] initWithIdentifier:TASK_COMMUNITY_REVIEW_TOPICS];
    stepInstruction.title = @"Review other topics";
    stepInstruction.text = @"Read and review other topics to understand if that topic is something you would consider worthy of research as part of The PRIDE Study. ";
    stepInstruction.image = [UIImage imageNamed:@"community-thumb-review-topics"];
    
    // Create a task with all the steps
    PRIDEOrderedTask *task =
    [[PRIDEOrderedTask alloc] initWithIdentifier:TASK_COMMUNITY_REVIEW_TOPICS
                                           steps:@[stepInstruction]];
    
    // Create a task view controller using the task and set a delegate.
    self.task_communityReviewTopics = [[ORKTaskViewController alloc] initWithTask:task taskRunUUID:nil];
    self.task_communityReviewTopics.delegate = self;
    [self.task_communityReviewTopics setShowsProgressInNavigationBar:NO];
    [self.task_communityReviewTopics.navigationBar.topItem setTitle:@"Getting Started"];
    
    // Present the task view controller.
    [self presentViewController:self.task_communityReviewTopics animated:YES completion:nil];
}

- (void)showVoteOnTopicsTask{
    ORKInstructionStep *stepInstruction = [[ORKInstructionStep alloc] initWithIdentifier:TASK_COMMUNITY_VOTE_ON_TOPICS];
    stepInstruction.title = @"Vote on topics that matter most to you";
    stepInstruction.text = @"Voting on a topic is how the community at large informs The PRIDE Study researchers what are important topics to research.\n\nVoting a topic “up” or “down” changes the priority of topics in the Community Forum list. Simply tap on the “up” or “down” to cast your vote.\n\nRemember, you can only vote on a topic once you are registered with The PRIDE Study.\n\nNot seeing a topic you want to vote “up”? Feel free to post a new topic!";
    stepInstruction.image = [UIImage imageNamed:@"community-thumb-vote"];
    
    // Create a task with all the steps
    PRIDEOrderedTask *task =
    [[PRIDEOrderedTask alloc] initWithIdentifier:TASK_COMMUNITY_VOTE_ON_TOPICS
                                           steps:@[stepInstruction]];
    
    // Create a task view controller using the task and set a delegate.
    self.task_communityVoteOnTopics = [[ORKTaskViewController alloc] initWithTask:task taskRunUUID:nil];
    self.task_communityVoteOnTopics.delegate = self;
    [self.task_communityVoteOnTopics setShowsProgressInNavigationBar:NO];
    [self.task_communityVoteOnTopics.navigationBar.topItem setTitle:@"Getting Started"];
    
    // Present the task view controller.
    [self presentViewController:self.task_communityVoteOnTopics animated:YES completion:nil];
}

- (void)showCommentOnTopicsTask{
    ORKInstructionStep *stepInstruction = [[ORKInstructionStep alloc] initWithIdentifier:TASK_COMMUNITY_COMMENT_ON_TOPICS];
    stepInstruction.title = @"Comment on topics of interest";
    stepInstruction.text = @"Adding your comments to topics of interest helps add to the community experience and informs PRIDE researchers on what aspects of topics should be included in their research study.\n\nRemember, you can only comment once you are registered with The PRIDE Study.\n\nAgain, the more you engage, the more The PRIDE Study can help research topics that are important to YOU!";
    stepInstruction.image = [UIImage imageNamed:@"community-thumb-comment"];
    
    // Create a task with all the steps
    PRIDEOrderedTask *task =
    [[PRIDEOrderedTask alloc] initWithIdentifier:TASK_COMMUNITY_COMMENT_ON_TOPICS
                                           steps:@[stepInstruction]];
    
    // Create a task view controller using the task and set a delegate.
    self.task_communityCommentOnTopics = [[ORKTaskViewController alloc] initWithTask:task taskRunUUID:nil];
    self.task_communityCommentOnTopics.delegate = self;
    [self.task_communityCommentOnTopics setShowsProgressInNavigationBar:NO];
    [self.task_communityCommentOnTopics.navigationBar.topItem setTitle:@"Getting Started"];
    
    // Present the task view controller.
    [self presentViewController:self.task_communityCommentOnTopics animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
