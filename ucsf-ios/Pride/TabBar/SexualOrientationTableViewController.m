//
//  SexualOrientationTableViewController.m
//  Pride
//
//  Created by Patrick Krabeepetcharat on 6/10/15.
//  Copyright (c) 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import "SexualOrientationTableViewController.h"
#import "AppDelegate.h"
@interface SexualOrientationTableViewController ()
{
    //NSArray *sexualOrientations;
    
    // DEMOGRAPHIC SURVEY
    NSString *user_sex;
    NSString *user_orientation;
    NSString *user_identity;
    
    NSMutableArray *sexualOrientations;
    NSMutableArray *genderIdentities;
    NSMutableDictionary *profileSurveyAnswers;

    //NSString *formattedDate;
    NSString *urlString_results;
}

@end

@implementation SexualOrientationTableViewController

- (void)viewDidAppear:(BOOL)animated{
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(startDemographicSurvey)];
    
    [self.navigationItem setRightBarButtonItem:nextButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    sexualOrientations = [[NSUserDefaults standardUserDefaults] valueForKey:USER_SEXUAL_ORIENTATION_IDENTIFIER];
    profileSurveyAnswers=[[NSMutableDictionary alloc]init];
    self.navigationItem.title = @"Sexual Orientation";
    
    // RadiumOne Tracking
    [[R1Emitter sharedInstance] emitScreenViewWithDocumentTitle:@"Sexual Orientation"
                                             contentDescription:nil
                                            documentLocationUrl:nil
                                               documentHostName:nil
                                                   documentPath:nil
                                                      otherInfo:nil];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Sexual Orientation"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [sexualOrientations count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [sexualOrientations objectAtIndex:indexPath.row];
    
    return cell;
}



///////////////////////////////////////////////////////////////////////////////////
// DEMOGRAPHIC SURVEY
///////////////////////////////////////////////////////////////////////////////////

- (void)startDemographicSurvey{
    NSArray *choicesText;
    ORKAnswerFormat *formatAnswer;
    

    
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
    

    
    // Create a task with all the steps
    PRIDEOrderedTask *task =
    [[PRIDEOrderedTask alloc] initWithIdentifier:SURVEY_DEMOGRAPHIC_SURVEY_TASK_IDENTIFIER
                                           steps:@[stepOrientation, stepOrientation_a, stepGenderIdentity, stepGenderIdentity_a]];
    task.showSexuality=true;
    // Create a task view controller using the task and set a delegate.
    self.task_demographicSurvey = [[ORKTaskViewController alloc] initWithTask:task taskRunUUID:nil];
    self.task_demographicSurvey.delegate = self;
    [self.task_demographicSurvey setShowsProgressInNavigationBar:NO];
    [self.task_demographicSurvey.navigationBar.topItem setTitle:@"Demographic Survey"];
    
    // Present the task view controller.
    [self presentViewController:self.task_demographicSurvey animated:YES completion:nil];
}

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
    
   // [dict setValue:[answer firstObject] forKey:SURVEY_SEX];
    
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
    
    [profileSurveyAnswers setObject:codedAnswer forKey:@"QID2"];
    
    // Question: Orientation_a
    stepResult = [result stepResultForStepIdentifier:SURVEY_SEXUAL_ORIENTATION_A];
    textQuestionResult = [stepResult.results firstObject];
    textAnswer = textQuestionResult.textAnswer;
    
    [profileSurveyAnswers setValue:textAnswer forKey:@"QID33"];
    
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
    
    [profileSurveyAnswers setObject:codedAnswer forKey:@"QID3"];
    
    // Question: SURVEY_GENDER_IDENTITY_A
    stepResult = [result stepResultForStepIdentifier:SURVEY_GENDER_IDENTITY_A];
    textQuestionResult = [stepResult.results firstObject];
    textAnswer = textQuestionResult.textAnswer;
    
    [profileSurveyAnswers setValue:textAnswer forKey:@"QID39"];
    
    /////// Save the Orientation values for the user defaults later
    if([textAnswer length] > 0){
        [genderIdentities addObject:textAnswer];
    }
    
   

    // Anamorphic Measurements and User ID
    id height = [[NSUserDefaults standardUserDefaults] valueForKey:USER_HEIGHT_IDENTIFIER];
    id weight = [[NSUserDefaults standardUserDefaults] valueForKey:USER_WEIGHT_IDENTIFIER];
  id userID = [[NSUserDefaults standardUserDefaults] valueForKey:USER_USER_ID_IDENTIFIER];
    
    if(height){
        [profileSurveyAnswers setObject:height forKey:SURVEY_HEIGHT];
    }
    if(weight){
        [profileSurveyAnswers setObject:weight forKey:SURVEY_WEIGHT];
    }
    if(userID){
        [profileSurveyAnswers setObject:userID forKey:@"QID64"];
    }
    
}

- (void)taskViewController:(ORKTaskViewController * __nonnull)taskViewController didFinishWithReason:(ORKTaskViewControllerFinishReason)reason error:(nullable NSError *)error{
    
    if([taskViewController isEqual:self.task_demographicSurvey]){
        // quit reason = 1  ||  finish reason = 2
        if (reason == 1) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }else if (reason == 2){
            // Encode the URL to make it valid for the request
            NSError *error = nil;
            NSData *json;
            NSString *jsonString;
            
            if ([NSJSONSerialization isValidJSONObject:profileSurveyAnswers]){
                // Serialize the dictionary
                json = [NSJSONSerialization dataWithJSONObject:profileSurveyAnswers options:NSJSONWritingPrettyPrinted error:&error];
                
                // If no errors, let's view the JSON
                if (json != nil && error == nil){
                    jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
                }
            }else{
            }
            
            // Make the request
            urlString_results = [NSString stringWithFormat:QUALTRICS_PROFILE_SURVEY_URL, jsonString];
            
            urlString_results = [urlString_results stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            // Make the network request
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            [manager GET:urlString_results parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                NSLog(@"RESPONSE: %@", string);
                [self notifyServer:string];
                [self updateCache:string];
                
                [[NSUserDefaults standardUserDefaults] setValue:string forKey:USER_DEMOGRAPHIC_SURVEY_RESPONSE_ID_IDENTIFIER];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"ERROR: %@", error);
                
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
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:STATE_PROFILE_SURVEY_COMPLETE];
            [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:STATE_DEMOGRAPHIC_SURVEY_COMPLETE_DATE];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DASHBOARD_FORCE_REFRESH];

            AppDelegate* appD = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appD update_user_data];
        }
    }
    
    // Close the View controller when finished
    [taskViewController dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
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
- (IBAction)updateCache:(NSString*)responseid {
    //Get API Data
    NSDictionary *params = @{ @"response_id":responseid};
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DASHBOARD_FORCE_REFRESH];
    
    NSURL *url = [NSURL URLWithString:
                  [SERVER_URL stringByAppendingString:@"update-profile-survey-result-cache"]];
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

///////////////////////////////////////////////////////////////////////////////////
// DEMOGRAPHIC SURVEY
///////////////////////////////////////////////////////////////////////////////////

@end
