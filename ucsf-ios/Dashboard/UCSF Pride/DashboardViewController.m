//
//  ViewController.m
//  UCSF Pride
//
//  Created by Analog Republic on 5/17/15.
//  Copyright (c) 2015 Pride Study. All rights reserved.
//

#import "DashboardViewController.h"
#import "DashboardActivityCompletionCell.h"
#import "DashboardUsersStatsCell.h"
#import "DashboardSectionHeaderCell.h"
#import "DashboardActivityParticipantsStats.h"
#import "DashboardParticipantsLikeMe.h"
#import "DashboardCommunityStats.h"
#import <Charts/Charts.h>
#import "Reachability.h"

//#import "MBProgressHUD.h"
#import "AppConstants.h"
#import "DashboardFullScreenWebViewController.h"
#import "DashboardFullScreenViewController.h"
#import "DashboardActivityParticipantsStatsAssignedSex.h"
#import "DashboardActivityParticipantsStatsOrientationIdentity.h"
#import "DashboardCommunityStatsPostsGraph.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed: ((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 green: ((float)((rgbValue & 0xFF00) >> 8)) / 255.0 blue: ((float)(rgbValue & 0xFF)) / 255.0 alpha: 1.0]

@interface DashboardViewController ()
{
    NSDictionary *sectionsOpen;
    NSDictionary *responses;
    BOOL ParticipantStatisticsRowOpen;
    BOOL CommunityStatisticsRowOpen;
    BOOL HealthKitStatisticsRowOpen;
    BOOL loading;
    UIRefreshControl *refreshControl;
    NSMutableArray *CommunityPostsData;
    NSMutableArray *CommunityHealthData;
    NSMutableArray *CommunityAgeData;
    NSMutableArray *CommunityIdentityData;
    NSMutableArray *CommunityTop5Posts;
    NSDictionary *DemographicsData;
    NSString *userID;
    BOOL processingdata;
    UIEdgeInsets tableviewInset;
    NSString *alertTitle;
    NSString *alertDesc;
    float activityCompletion;
}

@property UIWebView *loadingWebView;

@end

@implementation DashboardViewController


- (void)refresh {
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // Create webview to show the loading animation

    [self.loadingWebView setHidden:false];
    [self getDemographicsData];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // Alert if no internet
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
        NSLog(@"There IS internet connection");
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Dashboard";
    self.loadingWebView =[[UIWebView alloc] initWithFrame:self.view.bounds];
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                         pathForResource:@"community-loading" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
    [self.loadingWebView loadRequest:[NSURLRequest requestWithURL:url]];
    [self.loadingWebView.scrollView setBounces:NO];
    [self.view addSubview:self.loadingWebView];
    [self.loadingWebView setCenter:self.view.center];
    [self.loadingWebView setHidden:true];
    float insety=self.navigationController.navigationBar.frame.size.height;
 //   self.tableView.contentInset = UIEdgeInsetsMake(insety,0,0,0);
    tableviewInset=self.tableView.contentInset;

    //The following are the only two variables that should be modified, the userID should come from the login/create account API Call
    //userID = @"2";
    [self performSelector:@selector(refreshTable) withObject:NULL afterDelay:0.1];
    
    //The following represents the percentage completed for the Activites, (This is the top Circle Graph in the Dashboard)
    
    
    //The following gets the Status of the Participants/Community Section to see if the user last opened/closed it
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    BOOL participantsOpen = [[defaults valueForKey:@"participantsOpen"] boolValue];
    BOOL communityOpen = [[defaults valueForKey:@"communityOpen"] boolValue];
    
    ParticipantStatisticsRowOpen = participantsOpen;
    CommunityStatisticsRowOpen = communityOpen;
    
    //Setup Tableview
    [self tableviewSetup];
    
    //Get Demographics Data from Server
    [self refresh];
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

- (void)getDemographicsData {
    //Get API Data
    NSDictionary *params = @{ @"user_id": [[NSUserDefaults standardUserDefaults] objectForKey:USER_USER_ID_IDENTIFIER ] };
    
    NSURL *url = [NSURL URLWithString:
                  [SERVER_URL stringByAppendingString:@"get-survey-results"]];
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
                                       // Your code to run on the main queue/thread
                                       [self.tableView reloadData];
                                       
                                       //[MBProgressHUD hideHUDForView:self.view animated:YES];
                                       NSLog(@"REMOVE");
                                       [self.loadingWebView setHidden:true];
                                      // [self.loadingWebView removeFromSuperview];
                                     //  self.loadingWebView = nil;
                                       
                                       [refreshControl endRefreshing];
                                   }];
                               }
                               else {
                                   NSMutableDictionary *innerJson = [NSJSONSerialization
                                                                     JSONObjectWithData:data options:kNilOptions error:NULL];
                                   
                                   NSData *jsonData = [NSJSONSerialization dataWithJSONObject:innerJson
                                                                                      options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                                                        error:&error];
                                   
                                 
                                    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                   jsonString=[jsonString stringByReplacingOccurrencesOfString:@"Aesexual" withString:@"Asexual"];
                                                                    NSError *jsonError;
                                   NSData *objectData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                                  innerJson = [NSJSONSerialization JSONObjectWithData:objectData
                                                                                        options:NSJSONReadingMutableContainers
                                                                                          error:&jsonError];
                                 //  }
                                   
                                   
                                   DemographicsData = innerJson;
                                   
                                   CommunityPostsData = innerJson[@"forum"][@"topics"][@"data"];
                                   CommunityHealthData = innerJson[@"forum"][@"health"][@"data"];
                                   CommunityAgeData = innerJson[@"forum"][@"age"][@"data"];
                                   CommunityIdentityData = innerJson[@"forum"][@"identity"][@"data"];
                                   CommunityTop5Posts = innerJson[@"forum"][@"best"][@"data"];
                                   
                                   [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
                                       // Your code to run on the main queue/thread
                                       [refreshControl endRefreshing];
                                       
                                       //[MBProgressHUD hideHUDForView:self.view animated:YES];
                                       NSLog(@"REMOVE");
                                       [self.loadingWebView setHidden:true];
                                     //  [self.loadingWebView removeFromSuperview];
                                     //  self.loadingWebView = nil;
                                       
                                       [self.tableView reloadData];
                                       [self performSelector:@selector(refreshTable) withObject:NULL afterDelay:0.1];
                                       
                                   }];
                               }
                           }];
}
-(void) refreshTable
{
    [self.tableView reloadData];
    //self.tableView.contentInset=tableviewInset;
    
}
- (void)tableviewSetup {
    //Register Nibs for Reuse in TableView Cells
    [self.tableView registerNib:[UINib nibWithNibName:@"DashboardActivityCompletionCell" bundle:nil] forCellReuseIdentifier:@"DashboardActivityCompletionCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"DashboardSectionHeaderCell" bundle:nil] forCellReuseIdentifier:@"DashboardSectionHeaderCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"DashboardUsersStatsCell" bundle:nil] forCellReuseIdentifier:@"DashboardUsersStatsCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"DashboardParticipantsLikeMe" bundle:nil] forCellReuseIdentifier:@"DashboardParticipantsLikeMe"];
    [self.tableView registerNib:[UINib nibWithNibName:@"DashboardActivityParticipantsStats" bundle:nil] forCellReuseIdentifier:@"DashboardActivityParticipantsStats"];
    [self.tableView registerNib:[UINib nibWithNibName:@"DashboardCommunityStats" bundle:nil] forCellReuseIdentifier:@"DashboardCommunityStats"];
    [self.tableView registerNib:[UINib nibWithNibName:@"DashboardActivityParticipantsStatsAssignedSex" bundle:nil] forCellReuseIdentifier:@"DashboardActivityParticipantsStatsAssignedSex"];
    [self.tableView registerNib:[UINib nibWithNibName:@"DashboardActivityParticipantsStatsOrientationIdentity" bundle:nil] forCellReuseIdentifier:@"DashboardActivityParticipantsStatsOrientationIdentity"];
    [self.tableView registerNib:[UINib nibWithNibName:@"DashboardCommunityStatsPostsGraph" bundle:nil] forCellReuseIdentifier:@"DashboardCommunityStatsPostsGraph"];
    
    
    //The following creates the drag to refresh control for the Tableview
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor whiteColor];
    refreshControl.tintColor = [UIColor darkGrayColor];
    [refreshControl addTarget:self
                       action:@selector(getDemographicsData)
             forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    self.tableView.layoutMargins = UIEdgeInsetsZero;
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    
}

//TableView Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ( DemographicsData && DemographicsData.count > 0) {
        if([[NSUserDefaults standardUserDefaults] boolForKey:USER_HAS_LEFT_STUDY])
            return 2;
        else
        return 3;
    }
    else {
        return 1;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:true];
    
   // [[NSUserDefaults standardUserDefaults] setFloat:activitiesRatioCompleted forKey:STATE_ACTIVITES_RATIO_COMPLETED];
    float completion=[[[NSUserDefaults standardUserDefaults] objectForKey:STATE_ACTIVITES_RATIO_COMPLETED] floatValue];
    
    activityCompletion = completion;
    
    alertTitle=@"Activity Completion";
    alertDesc=@"View and complete tasks in the Activities tab to see your completion rate.";
    processingdata=false;
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:DASHBOARD_FORCE_REFRESH]==YES){
//        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:DASHBOARD_FORCE_REFRESH];
//        processingdata=true;
        DemographicsData = [[NSDictionary alloc] init];
    
        CommunityPostsData = [[NSMutableArray alloc]init];
        CommunityHealthData = [[NSMutableArray alloc]init];
        CommunityAgeData = [[NSMutableArray alloc]init];
        CommunityIdentityData =[[NSMutableArray alloc]init];
        CommunityTop5Posts = [[NSMutableArray alloc]init];
        [self.tableView reloadData];

     //   [self tableviewSetup];
        [self refresh];
    
    }
    else
    {
        [self performSelector:@selector(refreshTable) withObject:NULL afterDelay:0.03];

    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
        {
            if (DemographicsData.count > 0) {
                return 3;
            }
            else {
                return 1;
            }
        }
            break;
            
        case 1:
        {
            return 3;
        }
            break;
            
        case 2:
        {
            return 2;
        }
            break;
            
        default:
            return 0;
            
            
            break;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NULL;
    }
    else if (section == 2) {
        static NSString *CellIdentifier = @"DashboardSectionHeaderCell";
        DashboardSectionHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[DashboardSectionHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        self.tableView.separatorColor = [UIColor clearColor];
        
        cell.sectionBackgroundView.backgroundColor = [UIColor colorWithRed:102 / 255.f green:188 / 255.f blue:176 / 255.f alpha:1.0];
        cell.titleLabel.text = @"Community Statistics";
        if (!CommunityStatisticsRowOpen) {
            [cell.plusButton setImage:[UIImage imageNamed:@"plusButton"] forState:UIControlStateNormal];
        }
        else {
            [cell.plusButton setImage:[UIImage imageNamed:@"minusButton"] forState:UIControlStateNormal];
        }
        cell.circleButton.tintColor=UIColorFromRGB(0x479a8e);
        
        cell.actionButton.tag = 2;
        
        [cell.actionButton addTarget:self action:@selector(closeSection:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    else {
        static NSString *CellIdentifier = @"DashboardSectionHeaderCell";
        DashboardSectionHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[DashboardSectionHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.sectionBackgroundView.backgroundColor = [UIColor colorWithRed:64 / 255.f green:180 / 255.f blue:229 / 255.f alpha:1.0];
        cell.titleLabel.text = @"Participant Statistics";
        
        if (!ParticipantStatisticsRowOpen) {
            [cell.plusButton setImage:[UIImage imageNamed:@"plusButton"] forState:UIControlStateNormal];
        }
        else {
            [cell.plusButton setImage:[UIImage imageNamed:@"minusButton"] forState:UIControlStateNormal];
        }
        cell.circleButton.tintColor=UIColorFromRGB(0x259dcf);
        
        cell.actionButton.tag = 3;
        
        [cell.actionButton addTarget:self action:@selector(closeSection:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return 0;
    else
        return 42.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0)
            return 215.f;
        else if (indexPath.row == 1)
            return 93.f;
        else
            return 334.f;
    }
    else if (indexPath.section == 1) {
        if (ParticipantStatisticsRowOpen) {
            if (indexPath.row == 0)
                return 89.f;
            else if (indexPath.row == 1)
                return 388.f;
            else
                return 591.f;
        }
        else
            return 0.f;
    }
    else {
        if (CommunityStatisticsRowOpen) {
            if (indexPath.row == 0) {
                return 273.f;
            }
            else {
                return 1390.f;
            }
        }
        else
            return 0.f;
    }
    
    return 43.f;
}

- (void)setOrientationData:(PieChartView *)chart {
    NSMutableArray *yVals1 = [[NSMutableArray alloc] init];
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    
    
    NSDictionary *stats = DemographicsData[@"stats"];
    NSArray *orientation = stats[@"orientation"][@"average"];
    
    for (int i = 0; i < orientation.count; i++) {
        NSDictionary *obj = [orientation objectAtIndex:i];
        float percentagefloat = [obj[@"result"] floatValue] / 100.f;
        
        [yVals1 addObject:[[BarChartDataEntry alloc] initWithValue:percentagefloat xIndex:i]];
    }
    
    
    PieChartDataSet *dataSet = [[PieChartDataSet alloc] initWithYVals:yVals1 label:@""];
    dataSet.sliceSpace = 10.f;
    
    NSMutableArray *colors = [[NSMutableArray alloc] init];
    
    [colors addObject:[UIColor colorWithRed:70 / 255.f green:184 / 255.f blue:230 / 255.f alpha:1]];
    [colors addObject:[UIColor colorWithRed:97 / 255.f green:196 / 255.f blue:173 / 255.f alpha:1]];
    [colors addObject:[UIColor colorWithRed:183 / 255.f green:211 / 255.f blue:51 / 255.f alpha:1]];
    [colors addObject:[UIColor colorWithRed:249 / 255.f green:215 / 255.f blue:35 / 255.f alpha:1]];
    
    [colors addObject:[UIColor colorWithRed:206 / 255.f green:181 / 255.f blue:212 / 255.f alpha:1]];
    
    [colors addObject:[UIColor colorWithRed:222 / 255.f green:28 / 255.f blue:125 / 255.f alpha:1]];
    
    [colors addObject:[UIColor colorWithRed:239 / 255.f green:61 / 255.f blue:50 / 255.f alpha:1]];
    
    [colors addObject:[UIColor colorWithRed:242 / 255.f green:107 / 255.f blue:40 / 255.f alpha:1]];
    
    dataSet.colors = colors;
    
    PieChartData *data = [[PieChartData alloc] initWithXVals:xVals dataSet:dataSet];
    
    NSNumberFormatter *pFormatter = [[NSNumberFormatter alloc] init];
    pFormatter.numberStyle = NSNumberFormatterPercentStyle;
    pFormatter.maximumFractionDigits = 1;
    pFormatter.multiplier = @1.f;
    pFormatter.percentSymbol = @" %";
    [data setValueFormatter:pFormatter];
    [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:11.f]];
    [data setValueTextColor:[UIColor clearColor]];
    
    chart.data = data;
    [chart highlightValues:nil];
    [chart animateWithXAxisDuration:1.8 yAxisDuration:1.8 easingOption:ChartEasingOptionEaseOutBack];
}

- (void)setIdentityData:(PieChartView *)chart {
    NSMutableArray *yVals1 = [[NSMutableArray alloc] init];
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    
    NSDictionary *stats = DemographicsData[@"stats"];
    NSArray *gender_identity = stats[@"gender_identity"][@"average"];
    
    for (int i = 0; i < gender_identity.count; i++) {
        NSDictionary *obj = [gender_identity objectAtIndex:i];
        float percentagefloat = [obj[@"result"] floatValue] / 100.f;
        
        [yVals1 addObject:[[BarChartDataEntry alloc] initWithValue:percentagefloat xIndex:i]];
    }
    
    PieChartDataSet *dataSet = [[PieChartDataSet alloc] initWithYVals:yVals1 label:@""];
    dataSet.sliceSpace = 10.f;
    
    NSMutableArray *colors = [[NSMutableArray alloc] init];
    
    [colors addObject:[UIColor colorWithRed:70 / 255.f green:184 / 255.f blue:230 / 255.f alpha:1]];
    [colors addObject:[UIColor colorWithRed:97 / 255.f green:196 / 255.f blue:173 / 255.f alpha:1]];
    [colors addObject:[UIColor colorWithRed:183 / 255.f green:211 / 255.f blue:51 / 255.f alpha:1]];
    [colors addObject:[UIColor colorWithRed:249 / 255.f green:215 / 255.f blue:35 / 255.f alpha:1]];
    
    [colors addObject:[UIColor colorWithRed:206 / 255.f green:181 / 255.f blue:212 / 255.f alpha:1]];
    
    [colors addObject:[UIColor colorWithRed:222 / 255.f green:28 / 255.f blue:125 / 255.f alpha:1]];
    
    [colors addObject:[UIColor colorWithRed:239 / 255.f green:61 / 255.f blue:50 / 255.f alpha:1]];
    
    [colors addObject:[UIColor colorWithRed:242 / 255.f green:107 / 255.f blue:40 / 255.f alpha:1]];
    
    dataSet.colors = colors;
    
    PieChartData *data = [[PieChartData alloc] initWithXVals:xVals dataSet:dataSet];
    
    NSNumberFormatter *pFormatter = [[NSNumberFormatter alloc] init];
    pFormatter.numberStyle = NSNumberFormatterPercentStyle;
    pFormatter.maximumFractionDigits = 1;
    pFormatter.multiplier = @1.f;
    pFormatter.percentSymbol = @" %";
    [data setValueFormatter:pFormatter];
    [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:11.f]];
    [data setValueTextColor:[UIColor clearColor]];
    
    chart.data = data;
    [chart highlightValues:nil];
    [chart animateWithXAxisDuration:1.8 yAxisDuration:1.8 easingOption:ChartEasingOptionEaseOutBack];
}

- (void)openPost:(UIButton *)sender {
    NSLog(@"%@", [CommunityTop5Posts objectAtIndex:sender.tag]);
    NSDictionary *obj = [[CommunityTop5Posts objectAtIndex:sender.tag] objectForKey:@"links"];
    DashboardFullScreenWebViewController *view = [[DashboardFullScreenWebViewController alloc]init];
    
    
    view.url = obj[@"self"];
    
    [self presentViewController:view animated:true completion:NULL];
}

- (void)setGenderData:(PieChartView *)chart {
    NSMutableArray *yVals1 = [[NSMutableArray alloc] init];
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    
    NSDictionary *stats = DemographicsData[@"stats"];
    NSArray *assigned_gender = stats[@"assigned_gender"][@"average"];
    
    NSDictionary *maleAverage = ([[[[assigned_gender objectAtIndex:0] objectForKey:@"name"]lowercaseString] isEqualToString:@"male"]) ? [assigned_gender objectAtIndex:0] :
    [assigned_gender objectAtIndex:1];
    
    NSDictionary *femaleAverage = ([[[[assigned_gender objectAtIndex:0] objectForKey:@"name"]lowercaseString] isEqualToString:@"female"]) ? [assigned_gender objectAtIndex:0] :
    [assigned_gender objectAtIndex:1];
    
    
    
    float percentageMale = [maleAverage[@"result"] floatValue] / 100.f;
    float percentageFemale = [femaleAverage[@"result"] floatValue] / 100.f;
    
    
    
    [yVals1 addObject:[[BarChartDataEntry alloc] initWithValue:percentageMale xIndex:0]];
    [yVals1 addObject:[[BarChartDataEntry alloc] initWithValue:percentageFemale xIndex:1]];
    
    PieChartDataSet *dataSet = [[PieChartDataSet alloc] initWithYVals:yVals1 label:@""];
    dataSet.sliceSpace = 10.f;
    
    NSMutableArray *colors = [[NSMutableArray alloc] init];
    
    [colors addObject:[UIColor colorWithRed:61 / 255.f green:180 / 255.f blue:229 / 255.f alpha:1]];
    [colors addObject:[UIColor colorWithRed:231 / 255.f green:60 / 255.f blue:43 / 255.f alpha:1]];
    dataSet.colors = colors;
    PieChartData *data = [[PieChartData alloc] initWithXVals:xVals dataSet:dataSet];
    NSNumberFormatter *pFormatter = [[NSNumberFormatter alloc] init];
    pFormatter.numberStyle = NSNumberFormatterPercentStyle;
    pFormatter.maximumFractionDigits = 1;
    pFormatter.multiplier = @1.f;
    pFormatter.percentSymbol = @" %";
    [data setValueFormatter:pFormatter];
    [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:11.f]];
    [data setValueTextColor:[UIColor clearColor]];
    
    chart.data = data;
    [chart highlightValues:nil];
    [chart animateWithXAxisDuration:1.8 yAxisDuration:1.8 easingOption:ChartEasingOptionEaseOutBack];
}

- (void)setupPieChart:(PieChartView *)chart {
    chart.usePercentValuesEnabled = NO;
    chart.holeTransparent = YES;
   // chart.centerTextFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.f];
    chart.holeRadiusPercent = 0.88f;
    chart.transparentCircleRadiusPercent = 0.21f;
    chart.descriptionText = @"";
    chart.drawCenterTextEnabled = NO;
    chart.drawHoleEnabled = YES;
    chart.rotationAngle = 0.f;
    chart.rotationEnabled = NO;
    chart.centerText = @"";
    ChartLegend *l =  chart.legend;
    [chart.legend setEnabled:false];
    
    l.position = ChartLegendPositionLeftOfChart;
    l.xEntrySpace = 7.f;
    l.yEntrySpace = 5.f;
}

- (void)setIdentityProgressBar:(TYMProgressBarView *)progress {
    [progress setBarBorderColor:[UIColor whiteColor]];
    [progress setBarFillColor:[UIColor colorWithRed:163 / 255.f green:213 / 255.f blue:93 / 255.f alpha:1]];
    
    [progress setBarBackgroundColor:[UIColor colorWithRed:232 / 255.f green:232 / 255.f blue:232 / 255.f alpha:1]];
}

- (void)setRelationshipProgressBar:(TYMProgressBarView *)progress {
    [progress setBarBorderColor:[UIColor whiteColor]];
    [progress setBarFillColor:[UIColor colorWithRed:255 / 255.f green:102 / 255.f blue:27 / 255.f alpha:1]];
    
    [progress setBarBackgroundColor:[UIColor colorWithRed:232 / 255.f green:232 / 255.f blue:232 / 255.f alpha:1]];
}

- (void)closeSection:(UIButton *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (sender.tag == 2) {
        CommunityStatisticsRowOpen = !CommunityStatisticsRowOpen;
        
        [self.tableView reloadData];
        
        if (CommunityStatisticsRowOpen)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
            [self.tableView scrollToRowAtIndexPath:indexPath
                                  atScrollPosition:UITableViewScrollPositionTop
                                          animated:YES];
        }
        [defaults setBool:CommunityStatisticsRowOpen forKey:@"communityOpen"];
    }
    else if (sender.tag == 3) {
        ParticipantStatisticsRowOpen = !ParticipantStatisticsRowOpen;
        [self.tableView reloadData];
        if (ParticipantStatisticsRowOpen) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
            [self.tableView scrollToRowAtIndexPath:indexPath
                                  atScrollPosition:UITableViewScrollPositionTop
                                          animated:YES];
        }
        [defaults setBool:ParticipantStatisticsRowOpen forKey:@"participantsOpen"];
    }
}

- (void)expandCommunityTopics {
    DashboardFullScreenViewController *view = [[DashboardFullScreenViewController alloc]init];
    view.communityData = CommunityPostsData;
    [self presentViewController:view animated:true completion:NULL];
}

- (void)expandCulturalIdentity {
    NSDictionary *stats = DemographicsData[@"stats"];
    NSArray *cultural_identity = stats[@"cultural_identity"][@"average"];
    
    DashboardFullScreenViewController *view = [[DashboardFullScreenViewController alloc]init];
    view.culturalIdentityData = [cultural_identity mutableCopy];
    [self presentViewController:view animated:true completion:NULL];
}

- (void)expandRelationshipStatus {
    NSDictionary *stats = DemographicsData[@"stats"];
    NSArray *relationship_status = stats[@"relationship_status"][@"average"];
    DashboardFullScreenViewController *view = [[DashboardFullScreenViewController alloc]init];
    view.relationshipdata = [relationship_status mutableCopy];
    [self presentViewController:view animated:true completion:NULL];
}

- (void)setupCommunityLineGraph:(LineChartView *)_chartView cell: (DashboardCommunityStatsPostsGraph*)cell{
    _chartView = (LineChartView *)_chartView;
    _chartView.descriptionText = @"";
    _chartView.noDataTextDescription = @"";
    
  //  _chartView.highlightEnabled = YES;
    _chartView.dragEnabled = YES;
    [_chartView setScaleEnabled:YES];
    _chartView.pinchZoomEnabled = NO;
    _chartView.drawGridBackgroundEnabled = NO;
    
    
    _chartView.leftAxis.enabled = NO;
    _chartView.rightAxis.enabled = NO;
    
    _chartView.legend.enabled = NO;
    
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setMaximumFractionDigits:0];
//    [_chartView setValueFormatter:numberFormatter];
    
    [_chartView animateWithXAxisDuration:1.0 yAxisDuration:1.0];
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    NSMutableArray *yVals1 = [[NSMutableArray alloc] init];
    
    //    index 0 -> 100%
    //    index 1 -> 80%
    //    index 2 -> 60%
    //    index 3 -> 40%
    //    index 4 -> 20%
    //    index 5 -> 0%
    int maxint=0;
    int todayspost=0;
    for (int i = 0; i < CommunityPostsData.count; i++) {
        NSDictionary *obj = [CommunityPostsData objectAtIndex:i];
        if (i == 0) {
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            NSString *monthName = [[df monthSymbols] objectAtIndex:([[obj objectForKey:@"month"] intValue] - 1)];
            [xVals addObject:[NSString stringWithFormat:@"     %@ %@", monthName, [obj objectForKey:@"day"]]];
        }
        else {
            [xVals addObject:[NSString stringWithFormat:@"%@", [obj objectForKey:@"day"]]];
        }
        int x=[[obj objectForKey:@"posts"] intValue];
        if(x>maxint)
            maxint=x;
        
        if(i==CommunityPostsData.count-1)
        {
            todayspost=x;
        }
        //[yVals1 addObject:[[ChartDataEntry alloc] initWithValue:x xIndex:i]];
        [yVals1 addObject:[[ChartDataEntry alloc] initWithValue:x xIndex:i]];
        
    }
    
    float yForCurrentDay=(float)todayspost/(float)maxint;
    
    yForCurrentDay=(yForCurrentDay* 142.f);
    yForCurrentDay=142-yForCurrentDay-2;
    for( int i =0;i< cell.rightLabels.count;i++)
    {
        UILabel* lbl=[cell.rightLabels objectAtIndex:i];
        [lbl setHidden:true];
        if( i==0)
        {
            [lbl setHidden:false];
            NSString* value=[NSString stringWithFormat:@"%d ー",maxint];
            lbl.text=value;
        }
        else if( i==1 && yForCurrentDay>15)
        {
            [lbl setHidden:false];
            CGRect frame=lbl.frame;
            frame.origin.y=yForCurrentDay;
            lbl.frame=frame;
            NSString* value=[NSString stringWithFormat:@"%d ー",todayspost];
            lbl.text=value;
        }
    }
    
    LineChartDataSet *set1 = [[LineChartDataSet alloc] initWithYVals:yVals1 label:@""];
    set1.drawCubicEnabled = YES;
    set1.cubicIntensity = 0.8f;
    set1.drawCirclesEnabled = NO;
    set1.lineWidth = 2.f;
    
    set1.circleRadius = 7.f;
    
    set1.highlightColor = [UIColor colorWithRed:97 / 255.f green:196 / 255.f blue:173 / 255.f alpha:1.f];
    [set1 setColor:[UIColor colorWithRed:97 / 255.f green:196 / 255.f blue:173 / 255.f alpha:1.f]];
    set1.fillColor = [UIColor colorWithRed:129 / 255.f green:208 / 255.f blue:189 / 255.f alpha:1.f];
    [set1 setValueFormatter:numberFormatter];
    set1.fillAlpha = 8.f;
    set1.circleColors = @[[UIColor colorWithRed:97 / 255.f green:196 / 255.f blue:173 / 255.f alpha:1.f]];
    LineChartData *data = [[LineChartData alloc] initWithXVals:xVals dataSet:set1];
    [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:7.f]];
    [data setDrawValues:NO];
    
    
    
    _chartView.data = data;
    
    for (LineChartDataSet *set in _chartView.data.dataSets) {
        set.drawFilledEnabled = !set.isDrawFilledEnabled;
    }
    for (LineChartDataSet *set in _chartView.data.dataSets) {
        set.drawCirclesEnabled = !set.isDrawCirclesEnabled;
    }
    int i = 0;
    for (LineChartDataSet *set in _chartView.data.dataSets) {
        set.drawCubicEnabled = !set.isDrawCubicEnabled;
        if (i % 2 == 0) {
            set.fillColor = [UIColor colorWithRed:129 / 255.f green:208 / 255.f blue:189 / 255.f alpha:1.f];
        }
        else {
            set.fillColor = [UIColor colorWithRed:97 / 255.f green:196 / 255.f blue:173 / 255.f alpha:1.f];
        }
        i++;
    }
    
    ChartXAxis *xAxis = _chartView.xAxis;
    xAxis.labelPosition = XAxisLabelPositionBottom;
    _chartView.xAxis.enabled = YES;
    [_chartView.xAxis setDrawAxisLineEnabled:false];
    [_chartView.xAxis setDrawGridLinesEnabled:false];
    [_chartView.xAxis setLabelTextColor:UIColorFromRGB(0x61c4ad)];
    [_chartView setNeedsDisplay];
}

- (void)animateWidth:(UIView *)view {
    //    float originalY= view.frame.origin.y;
    float originalW = view.frame.size.width;
    
    view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, 0, view.frame.size.height);
    [UIView animateWithDuration:1.0
                     animations: ^{
                         view.frame = CGRectMake(view.frame.origin.x,  view.frame.origin.y, originalW, view.frame.size.height);
                     }
                     completion: ^(BOOL finished) {
                         [UIView animateWithDuration:1
                                          animations: ^{
                                              view.transform = CGAffineTransformIdentity;
                                          }];
                     }];
}

- (void)animateViewHeight:(UIView *)view withAnimationType:(NSString *)animType {
    float originalY = view.frame.origin.y;
    view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y + 227.0, view.frame.size.width, 0);
    [UIView animateWithDuration:1.0
                     animations: ^{
                         view.frame = CGRectMake(view.frame.origin.x, originalY, view.frame.size.width, 227.0);
                     }
                     completion: ^(BOOL finished) {
                         [UIView animateWithDuration:1
                                          animations: ^{
                                              view.transform = CGAffineTransformIdentity;
                                          }];
                     }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        if (CommunityStatisticsRowOpen) {
            if (indexPath.row == 0) {
                static NSString *CellIdentifier = @"DashboardCommunityStatsPostsGraph";
                DashboardCommunityStatsPostsGraph *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (cell == nil) {
                    cell = [[DashboardCommunityStatsPostsGraph alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [self setupCommunityLineGraph:cell.CommunityGraph cell:cell];
                
                [cell.expandButton addTarget:self action:@selector(expandCommunityTopics) forControlEvents:UIControlEventTouchUpInside];
                return cell;
            }
            else {
                static NSString *CellIdentifier = @"DashboardCommunityStats";
                DashboardCommunityStats *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (cell == nil) {
                    cell = [[DashboardCommunityStats alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                //Health Bar
                int totalHealthPosts = 0;
                int totalAgePosts = 0;
                int totalIdentityPosts = 0;
                
                for (NSDictionary *obj in CommunityHealthData) {
                    totalHealthPosts += [obj[@"attributes"][@"postCount"] intValue];
                }
                for (NSDictionary *obj in CommunityAgeData) {
                    totalAgePosts += [obj[@"attributes"][@"postCount"] intValue];
                }
                for (NSDictionary *obj in CommunityIdentityData) {
                    totalIdentityPosts += [obj[@"attributes"][@"postCount"] intValue];
                }
                NSMutableArray *segments = [[NSMutableArray alloc] init];
                NSMutableArray *colors = [[NSMutableArray alloc] init];
                [colors addObject:UIColorFromRGB(0x40b3e5)];
                [colors addObject:UIColorFromRGB(0x6ec6b0)];
                [colors addObject:UIColorFromRGB(0xb1db75)];
                [colors addObject:UIColorFromRGB(0xfcd945)];
                [colors addObject:UIColorFromRGB(0xc8abcf)];
                [colors addObject:UIColorFromRGB(0xed352b)];
                [colors addObject:UIColorFromRGB(0xf58759)];
                
                
                //Health Bar Parser
                SBBarSegment *segment = [SBBarSegment barComponentWithValue:0.33];
                
                for (int i = 0; i < CommunityHealthData.count; i++) {
                    NSDictionary *obj = [CommunityHealthData objectAtIndex:i][@"attributes"];
                    float componentValue = [obj[@"postCount"] floatValue] / totalHealthPosts;
                    segment = [SBBarSegment barComponentWithValue:componentValue];
                    segment.color = [colors objectAtIndex:i];
                    [segments addObject:segment];
                    
                    UILabel *percentage = [cell.healthPercentages objectAtIndex:i];
                    UILabel *label = [cell.healhLabels objectAtIndex:i];
                    
                    int percentageint = (int)(componentValue * 100.0);
                    //label.text = obj[@"name"];
                    NSString* name=obj[@"name"];
                    name=[name stringByReplacingOccurrencesOfString:@"(" withString:@"\n("];
                    
                    NSMutableAttributedString* attrString2 = [[NSMutableAttributedString alloc] initWithString:name];
                    
                    
                    NSCharacterSet *charSet1 = [NSCharacterSet characterSetWithCharactersInString:@"("];
                    NSCharacterSet *charSet2 = [NSCharacterSet characterSetWithCharactersInString:@")"];
                    NSRange range1 = [name rangeOfCharacterFromSet:charSet1];
                    NSRange range2 = [name rangeOfCharacterFromSet:charSet2];
                    
                    if (range1.location != NSNotFound && range2.location != NSNotFound)
                    {
                        NSRange newrange = NSMakeRange(range1.location,name.length-range1.location);
                        [attrString2 addAttribute:NSFontAttributeName
                                            value:[UIFont systemFontOfSize:label.font.pointSize/1.4]
                                            range:newrange];
                        label.attributedText=attrString2;
                        
                        
                    }
                    else
                    {
                        label.text = name;
                    }
                    
                    //                    label.text = name;
                    //	percentage.text = [NSString stringWithFormat:@"%d%%", percentageint];
                    
                    NSString* percentageString=[NSString stringWithFormat:@"%d%%", percentageint];
                    
                    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:percentageString];
                    NSRange percentagelength = NSMakeRange(percentageString.length-1, 1);
                    [attrString addAttribute:NSFontAttributeName
                                       value:[UIFont boldSystemFontOfSize:percentage.font.pointSize/2]
                                       range:percentagelength];
                    
                    percentage.attributedText = attrString;
                    
                }
                cell.healthBarChart.segments = segments;
                segments = [[NSMutableArray alloc] init];
                for (int i = 0; i < CommunityIdentityData.count; i++) {
                    NSDictionary *obj = [CommunityIdentityData objectAtIndex:i][@"attributes"];
                    float componentValue = [obj[@"postCount"] floatValue] / totalIdentityPosts;
                    segment = [SBBarSegment barComponentWithValue:componentValue];
                    segment.color = [colors objectAtIndex:i];
                    [segments addObject:segment];
                    
                    UILabel *percentage = [cell.identityPercentages objectAtIndex:i];
                    UILabel *label = [cell.identity_Labels objectAtIndex:i];
                    
                    int percentageint = (int)(componentValue * 100.0);
                    
                    NSString* name=obj[@"name"];
                    name=[name stringByReplacingOccurrencesOfString:@"(" withString:@"\n("];
                    
                    NSMutableAttributedString* attrString2 = [[NSMutableAttributedString alloc] initWithString:name];
                    
                    
                    NSCharacterSet *charSet1 = [NSCharacterSet characterSetWithCharactersInString:@"("];
                    NSCharacterSet *charSet2 = [NSCharacterSet characterSetWithCharactersInString:@")"];
                    NSRange range1 = [name rangeOfCharacterFromSet:charSet1];
                    NSRange range2 = [name rangeOfCharacterFromSet:charSet2];
                    
                    if (range1.location != NSNotFound && range2.location != NSNotFound)
                    {
                        NSRange newrange = NSMakeRange(range1.location,name.length-range1.location);
                        [attrString2 addAttribute:NSFontAttributeName
                                            value:[UIFont systemFontOfSize:label.font.pointSize/1.4]
                                            range:newrange];
                        label.attributedText=attrString2;
                        
                        
                    }
                    else
                    {
                        label.text = name;
                    }
                    
                    
                    
                    //percentage.text = [NSString stringWithFormat:@"%d%%", percentageint];
                    NSString* percentageString=[NSString stringWithFormat:@"%d%%", percentageint];
                    
                    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:percentageString];
                    NSRange percentagelength = NSMakeRange(percentageString.length-1, 1);
                    [attrString addAttribute:NSFontAttributeName
                                       value:[UIFont boldSystemFontOfSize:percentage.font.pointSize/2]
                                       range:percentagelength];
                    percentage.attributedText=attrString;
                    
                    
                }
                cell.identityBarChart.segments = segments;
                segments = [[NSMutableArray alloc] init];
                for (int i = 0; i < CommunityAgeData.count; i++) {
                    NSDictionary *obj = [CommunityAgeData objectAtIndex:i][@"attributes"];
                    float componentValue = [obj[@"postCount"] floatValue] / totalAgePosts;
                    segment = [SBBarSegment barComponentWithValue:componentValue];
                    segment.color = [colors objectAtIndex:i];
                    [segments addObject:segment];
                    
                    UILabel *percentage = [cell.agePercentages objectAtIndex:i];
                    UILabel *label = [cell.ageLabels objectAtIndex:i];
                    
                    int percentageint = (int)(componentValue * 100.0);
                    NSString* name=obj[@"name"];
                    name=[name stringByReplacingOccurrencesOfString:@"(" withString:@"\n("];
                    
                    NSMutableAttributedString* attrString2 = [[NSMutableAttributedString alloc] initWithString:name];
                    
                    
                    NSCharacterSet *charSet1 = [NSCharacterSet characterSetWithCharactersInString:@"("];
                    NSCharacterSet *charSet2 = [NSCharacterSet characterSetWithCharactersInString:@")"];
                    NSRange range1 = [name rangeOfCharacterFromSet:charSet1];
                    NSRange range2 = [name rangeOfCharacterFromSet:charSet2];
                    
                    if (range1.location != NSNotFound && range2.location != NSNotFound)
                    {
                        NSRange newrange = NSMakeRange(range1.location,name.length-range1.location);
                        [attrString2 addAttribute:NSFontAttributeName
                                            value:[UIFont systemFontOfSize:label.font.pointSize/1.4]
                                            range:newrange];
                        label.attributedText=attrString2;
                        
                        
                    }
                    else
                    {
                        label.text = name;
                    }
                    
                    //                    label.text = name;					//percentage.text = [NSString stringWithFormat:@"%d%%", percentageint];
                    NSString* percentageString=[NSString stringWithFormat:@"%d%%", percentageint];
                    
                    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:percentageString];
                    NSRange percentagelength = NSMakeRange(percentageString.length-1, 1);
                    [attrString addAttribute:NSFontAttributeName
                                       value:[UIFont boldSystemFontOfSize:percentage.font.pointSize/2]
                                       range:percentagelength];
                    percentage.attributedText=attrString;
                    
                }
                cell.ageBarChart.segments = segments;
                
                //test commit
                [self animateViewHeight:cell.identityBarChart withAnimationType:kCATransitionFromBottom];
                
                [self animateViewHeight:cell.healthBarChart withAnimationType:kCATransitionFromBottom];
                
                [self animateViewHeight:cell.ageBarChart withAnimationType:kCATransitionFromBottom];
                if (CommunityTop5Posts.count > 0)
                    for (int i = 0; i < 5; i++) {
                        NSDictionary *obj = [CommunityTop5Posts objectAtIndex:i][@"attributes"];
                        
                        UILabel *postLbl = [cell.postsCollection objectAtIndex:i];
                        UILabel *postUpLbl = [cell.postsUpCountCollection objectAtIndex:i];
                        UILabel *postDownLbl = [cell.postsDownCountCollection objectAtIndex:i];
                        UILabel *postCommentCountLbl = [cell.postsCommentCountLabel objectAtIndex:i];
                        UIButton *postButton = [cell.postsButtons objectAtIndex:i];
                        [postButton addTarget:self action:@selector(openPost:) forControlEvents:UIControlEventTouchUpInside];
                        //test commit
                        postLbl.text = [NSString stringWithFormat:@"%@", [obj objectForKey:@"title"]];
                        postUpLbl.text = [NSString stringWithFormat:@"%@", [obj objectForKey:@"upvotes"]];
                        postDownLbl.text = [NSString stringWithFormat:@"%@", [obj objectForKey:@"downvotes"]];
                        postCommentCountLbl.text = [NSString stringWithFormat:@"%@", [obj objectForKey:@"commentCount"]];
                    }
                
                
                
                
                cell.headerButton.tag = indexPath.row;
                [cell.headerButton addTarget:self action:@selector(closeSection:) forControlEvents:UIControlEventTouchUpInside];
                
                
                
                return cell;
            }
        }
        else {
            return [[UITableViewCell alloc]init];
        }
    }
    else if (indexPath.section == 1) {
        if (ParticipantStatisticsRowOpen) {
            if (indexPath.row == 0) {
                static NSString *CellIdentifier = @"DashboardActivityParticipantsStatsAssignedSex";
                DashboardActivityParticipantsStatsAssignedSex *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (cell == nil) {
                    cell = [[DashboardActivityParticipantsStatsAssignedSex alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

                [self setupPieChart:cell.genderPieChart];
                [self setGenderData:cell.genderPieChart];
                
                NSDictionary *stats = DemographicsData[@"stats"];
                NSArray *assigned_gender = stats[@"assigned_gender"][@"average"];
                
                NSDictionary *maleAverage = ([[[[assigned_gender objectAtIndex:0] objectForKey:@"name"]lowercaseString] isEqualToString:@"male"]) ? [assigned_gender objectAtIndex:0] :
                [assigned_gender objectAtIndex:1];
                
                NSDictionary *femaleAverage = ([[[[assigned_gender objectAtIndex:0] objectForKey:@"name"]lowercaseString] isEqualToString:@"female"]) ? [assigned_gender objectAtIndex:0] :
                [assigned_gender objectAtIndex:1];
                
                
                
                float percentageMale = [maleAverage[@"result"] floatValue];
                float percentageFemale = [femaleAverage[@"result"] floatValue];
                
                
                //cell.malePercentage.text = [NSString stringWithFormat:@"%.1f%%", percentageMale];
                
                NSString* percentageString=[NSString stringWithFormat:@"%.1f%%", percentageMale];
                
                NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:percentageString];
                NSRange percentagelength = NSMakeRange(percentageString.length-1, 1);
                [attrString addAttribute:NSFontAttributeName
                                   value:[UIFont boldSystemFontOfSize:cell.malePercentage.font.pointSize/2]
                                   range:percentagelength];
                cell.malePercentage.attributedText=attrString;
                
                
                //cell.femalePercentage.text = [NSString stringWithFormat:@"%.1f%%", percentageFemale];
                
                NSString* percentageString2=[NSString stringWithFormat:@"%.1f%%", percentageFemale];
                
                NSMutableAttributedString* attrString2 = [[NSMutableAttributedString alloc] initWithString:percentageString2];
                NSRange percentagelength2 = NSMakeRange(percentageString2.length-1, 1);
                [attrString2 addAttribute:NSFontAttributeName
                                    value:[UIFont boldSystemFontOfSize:cell.femalePercentage.font.pointSize/2]
                                    range:percentagelength2];
                cell.femalePercentage.attributedText=attrString2;
                
                
                
                
                return cell;
            }
            else if (indexPath.row == 1) {
                static NSString *CellIdentifier = @"DashboardActivityParticipantsStatsOrientationIdentity";
                DashboardActivityParticipantsStatsOrientationIdentity *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (cell == nil) {
                    cell = [[DashboardActivityParticipantsStatsOrientationIdentity alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                NSDictionary *stats = DemographicsData[@"stats"];
                NSArray *gender_identity = stats[@"gender_identity"][@"average"];
                
                for (int i = 0; i < gender_identity.count; i++) {
                    NSDictionary *obj = [gender_identity objectAtIndex:i];
                    UILabel *percentage = [cell.identityPercentages objectAtIndex:i];
                    percentage.text = obj[@"name"];
                    UILabel *label = [cell.identityLabels objectAtIndex:i];
                    label.text = obj[@"name"];
                    float percentagefloat = [obj[@"result"] floatValue];
                    //percentage.text = [NSString stringWithFormat:@"%.1f%%", percentagefloat];
                    
                    
                    NSString* percentageString=[NSString stringWithFormat:@"%.1f%%", percentagefloat];
                    ;
                    
                    
                    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:percentageString];
                    NSRange percentagelength = NSMakeRange(percentageString.length-1, 1);
                    [attrString addAttribute:NSFontAttributeName
                                       value:[UIFont boldSystemFontOfSize:percentage.font.pointSize/2]
                                       range:percentagelength];
                    percentage.attributedText=attrString;
                    
                    NSString* name=obj[@"name"];
                    name=[name stringByReplacingOccurrencesOfString:@"(" withString:@"\n("];
                    
                    NSMutableAttributedString* attrString2 = [[NSMutableAttributedString alloc] initWithString:name];
                    
                    
                    NSCharacterSet *charSet1 = [NSCharacterSet characterSetWithCharactersInString:@"("];
                    NSCharacterSet *charSet2 = [NSCharacterSet characterSetWithCharactersInString:@")"];
                    NSRange range1 = [name rangeOfCharacterFromSet:charSet1];
                    NSRange range2 = [name rangeOfCharacterFromSet:charSet2];
                    
                    if (range1.location != NSNotFound && range2.location != NSNotFound)
                    {
                        NSRange newrange = NSMakeRange(range1.location,name.length-range1.location);
                        [attrString2 addAttribute:NSFontAttributeName
                                            value:[UIFont systemFontOfSize:0]
                                            range:newrange];
                        label.attributedText=attrString2;
                        
                        
                    }
                    else
                    {
                        label.text = obj[@"name"];
                    }
                }
                
                
                [self setupPieChart:cell.identityPieChart];
                [self setIdentityData:cell.identityPieChart];
                
                
                NSArray *orientation = stats[@"orientation"][@"average"];
                
                
                for (int i = 0; i < orientation.count; i++) {
                    NSDictionary *obj = [orientation objectAtIndex:i];
                    UILabel *percentage = [cell.orientationPercentages objectAtIndex:i];
                    percentage.text = obj[@"name"];
                    UILabel *label = [cell.orientationLabels objectAtIndex:i];
                    label.text = obj[@"name"];
                    float percentagefloat = [obj[@"result"] floatValue];
                    //	percentage.text = [NSString stringWithFormat:@"%.1f%%", percentagefloat];
                    
                    
                    NSString* percentageString=[NSString stringWithFormat:@"%.1f%%", percentagefloat];
                    ;
                    
                    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:percentageString];
                    NSRange percentagelength = NSMakeRange(percentageString.length-1, 1);
                    [attrString addAttribute:NSFontAttributeName
                                       value:[UIFont boldSystemFontOfSize:percentage.font.pointSize/2]
                                       range:percentagelength];
                    percentage.attributedText=attrString;
                    
                    
                    
                    label.text = obj[@"name"];
                }
                
                
                
                
                [self setupPieChart:cell.orientationPieChart];
                [self setOrientationData:cell.orientationPieChart];
                
                
                
                return cell;
            }
            else {
                static NSString *CellIdentifier = @"DashboardActivityParticipantsStats";
                DashboardActivityParticipantsStats *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (cell == nil) {
                    cell = [[DashboardActivityParticipantsStats alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                
                [cell.expandCulturalIdentity addTarget:self action:@selector(expandCulturalIdentity) forControlEvents:UIControlEventTouchUpInside];
                [cell.expandRelationshipStatus addTarget:self action:@selector(expandRelationshipStatus) forControlEvents:UIControlEventTouchUpInside];
                
                NSDictionary *stats = DemographicsData[@"stats"];
                NSArray *cultural_identity = stats[@"cultural_identity"][@"average"];
                
                for (int i = 0; i < 5; i++) {
                    NSDictionary *obj = [cultural_identity objectAtIndex:i];
                    UILabel *label = [cell.cultureIdentityLabels objectAtIndex:i];
                    float percentageFloat = [obj[@"result"] floatValue];
                    
                    
                    //label.text = [NSString stringWithFormat:@"%.2f%% %@", percentageFloat, obj[@"name"]];
                    
                    
                    NSString* percentage=[NSString stringWithFormat:@"%.2f%% %@", percentageFloat, obj[@"name"]];
                    
                    NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@"%%"];
                    NSRange range = [percentage rangeOfCharacterFromSet:charSet];
                    
                    
                    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:percentage];
                    NSRange percentagelength = range;
                    [attrString addAttribute:NSFontAttributeName
                                       value:[UIFont boldSystemFontOfSize:label.font.pointSize/1.5]
                                       range:percentagelength];
                    
                    [attrString addAttribute:NSFontAttributeName
                                       value:[UIFont boldSystemFontOfSize:label.font.pointSize/1.5]
                                       range:percentagelength];
                    NSRange range2 = NSMakeRange(0, range.location);
                    [attrString addAttribute:NSFontAttributeName
                                       value:[UIFont boldSystemFontOfSize:label.font.pointSize]
                                       range:range2];
                    
                    
                    
                    label.attributedText = attrString;
                    
                    
                    
                    TYMProgressBarView *bar = [cell.cultureIdentityProgress objectAtIndex:i];
                    
                    [self setIdentityProgressBar:bar];
                    bar.progress = (float)(percentageFloat / 100.f);
                    [self animateWidth:bar];
                }
                
                NSArray *relationship_status = stats[@"relationship_status"][@"average"];
                
                for (int i = 0; i < 5; i++) {
                    NSDictionary *obj = [relationship_status objectAtIndex:i];
                    UILabel *label = [cell.relationshipLabels objectAtIndex:i];
                    float percentageFloat = [obj[@"result"] floatValue];
                    
                    
                    
                    
                    NSString* percentage=[NSString stringWithFormat:@"%.2f%% %@", percentageFloat, obj[@"name"]];
                    
                    NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@"%%"];
                    NSRange range = [percentage rangeOfCharacterFromSet:charSet];
                    
                    
                    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:percentage];
                    NSRange percentagelength = range;
                    [attrString addAttribute:NSFontAttributeName
                                       value:[UIFont boldSystemFontOfSize:label.font.pointSize/1.5]
                                       range:percentagelength];
                    
                    NSRange range2 = NSMakeRange(0, range.location);
                    [attrString addAttribute:NSFontAttributeName
                                       value:[UIFont boldSystemFontOfSize:label.font.pointSize]
                                       range:range2];
                    
                    label.attributedText = attrString;
                    TYMProgressBarView *bar = [cell.relationshipProgress objectAtIndex:i];
                    
                    [self setRelationshipProgressBar:bar];
                    bar.progress = (float)(percentageFloat / 100.f);
                    [self animateWidth:bar];
                }
                
                
                return cell;
            }
        }
        else {
            return [[UITableViewCell alloc]init];
        }
    }
    else if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            static NSString *CellIdentifier = @"DashboardUsersStatsCell";
            DashboardUsersStatsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[DashboardUsersStatsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            if (DemographicsData.count > 0) {
                NSDictionary *total = DemographicsData[@"stats"][@"total"];
                NSDictionary *totalobj = [[total objectForKey:@"total"] objectAtIndex:0];
                
                int totalparticpants = [totalobj[@"result"] intValue];
                
                NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
                [fmt setNumberStyle:NSNumberFormatterDecimalStyle]; // to get commas (or locale equivalent)
                [fmt setMaximumFractionDigits:0]; // to avoid any decimal
                NSString *result = [fmt stringFromNumber:@(totalparticpants)];
                
                cell.countLabel.text = result;
            }
            return cell;
        }
        else if (indexPath.row == 2) {
            static NSString *CellIdentifier = @"DashboardParticipantsLikeMe";
            DashboardParticipantsLikeMe *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[DashboardParticipantsLikeMe alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            
            //Resets to 0 in order to animate to progress level;
            NSDictionary *user = DemographicsData[@"user"];
            
            if(user)
            {
               [cell.notAvailableView setHidden:true];
                if([[NSUserDefaults standardUserDefaults] boolForKey:DASHBOARD_FORCE_REFRESH]==YES){
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:DASHBOARD_FORCE_REFRESH];
                }
            }
            else 
            {
                if([[NSUserDefaults standardUserDefaults] boolForKey:DASHBOARD_FORCE_REFRESH]==YES){
            
                cell.statusLabel.text=@"Pull down to refresh data. Please allow a few moments for the data to be processed.";
                }
                [cell.notAvailableView setHidden:false];
                if([[NSUserDefaults standardUserDefaults] boolForKey:USER_HAS_LEFT_STUDY]){
                    cell.statusLabel.text=@"The data below is no longer being updated now that you have chosen to leave the Pride Study.";

                }
                
                
            }

            NSMutableArray *related_stats = [user[@"related_stats"] mutableCopy];
            
            float percentagefloat = [user[@"same_attributes_average"] floatValue];
            
            NSString* percentage=[NSString stringWithFormat:@"%.0f%%", percentagefloat];
            
            
            NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:percentage];
            NSRange percentagelength = NSMakeRange(percentage.length-1, 1);
            [attrString addAttribute:NSFontAttributeName
                               value:[UIFont boldSystemFontOfSize:19.0]
                               range:percentagelength];
            
            cell.footerPercentageLabel.attributedText = attrString;
            
            
            //Resets Progress Circles
            NSMutableArray* copy=[related_stats mutableCopy];
            
            int i =0;
//            for(NSDictionary* obj in copy)
//            {
//                NSString *sublabelString = obj[@"stat_group"];
//
//                
//                
//                if([[sublabelString lowercaseString]containsString:@"assigned_gender"])
//                {
//                    [related_stats removeObjectAtIndex:i];
//                }
//                
//                
//                
//                i++;
//            }
            
            // copy=[related_stats mutableCopy];
            i =0;
            BOOL culturalidentityfound=false;
//            for(NSDictionary* obj in copy)
//            {
//                NSString *sublabelString = obj[@"stat_group"];
//
//                if([[sublabelString lowercaseString]containsString:@"cultural_identity"])
//                {
//                    if(culturalidentityfound)
//                    {
//                        [related_stats removeObject:obj];
//                        
//                    }
//                    else
//                        culturalidentityfound=true;
//                }
//
//            }
          //  if(related_stats.count>=5)
            //  [related_stats removeObjectAtIndex:4];
            
            for (UAProgressView *progressbar in cell.progressCircles) {
                [progressbar setProgress:0.f animated:false];
                progressbar.animationDuration = 0.6;
                progressbar.backgroundColor = [UIColor clearColor];
                progressbar.lineWidth = 5;
            }
            
            NSMutableArray* stats=[[NSMutableArray alloc]init];
            NSMutableArray* custom_stats=[[NSMutableArray alloc]init];
            NSString* assigned_gender=@"1";
            NSString* gender_identity=@"2";
            for (int x = 0; x < related_stats.count; x++) {
                NSDictionary * obj = [related_stats objectAtIndex:x];
                NSString *sublabelString = obj[@"stat_group"];
                if([sublabelString isEqualToString:@"assigned_gender"])
                {
                    assigned_gender=obj[@"name"];
                }
                if([sublabelString isEqualToString:@"gender_identity"])
                {
                    gender_identity=obj[@"name"];
                }
            }
            
            for (int i = 0; i < 5; i++) {
                
                
                switch (i) {
                    case 0:
                    {
                        BOOL found=false;
                        for (int x = 0; x < related_stats.count; x++) {
                            NSDictionary * obj = [related_stats objectAtIndex:x];
                            NSString *sublabelString = obj[@"stat_group"];
                            if([sublabelString isEqualToString:@"orientation"])
                            {
                                found=true;
                                [custom_stats addObject:obj];
                                break;
                            }
                        }
                        
                        if(!found)
                        {
                            NSMutableDictionary* data=[[NSMutableDictionary alloc]init];
                            [data setObject:@"" forKey:@"stat_key"];
                            [data setObject:@"orientation" forKey:@"stat_group"];
                            [data setObject:@"" forKey:@"stat_type"];
                            [data setObject:@"Not Provided" forKey:@"name"];
                            [data setObject:[NSNumber numberWithFloat:100.f] forKey:@"result"];
                            
                            [custom_stats addObject:data];

        
                        }
                    }
                        break;
                    case 1:
                    {
                        BOOL found=false;

                        for (int x = 0; x < related_stats.count; x++) {
                            NSDictionary * obj = [related_stats objectAtIndex:x];
                            NSString *sublabelString = obj[@"stat_group"];
                            if([sublabelString isEqualToString:@"gender_identity"])
                            {
                                found=true;
                                [custom_stats addObject:obj];
                                break;
                            }
                        }
                        
                        if(!found)
                        {
                            NSMutableDictionary* data=[[NSMutableDictionary alloc]init];
                            [data setObject:@"" forKey:@"stat_key"];
                            [data setObject:@"gender_identity" forKey:@"stat_group"];
                            [data setObject:@"" forKey:@"stat_type"];
                            [data setObject:@"Not Provided" forKey:@"name"];
                            [data setObject:[NSNumber numberWithFloat:100.f] forKey:@"result"];
                            
                            [custom_stats addObject:data];

                            
                        }
                    }
                        break;
                    case 2:
                    {
                        NSDictionary *stats = DemographicsData[@"stats"];
                        
                        NSDictionary * obj=[[[stats objectForKey:@"gender_same_as_assigned_sex"] objectForKey:@"average"] objectAtIndex:0];
                        
                        if([[gender_identity lowercaseString]isEqualToString:@"man"] && [[assigned_gender lowercaseString]isEqualToString:@"male"])
                        {
                            [obj setValue:@"Gender Same" forKey:@"name"];
                            [obj setValue:@"as_assigned_sex" forKey:@"stat_group"];
                            [obj setValue:@"as_assigned_sex" forKey:@"stat_key"];
                            
                            [custom_stats addObject:obj];

                        }
                        else if([[gender_identity lowercaseString]isEqualToString:@"woman"] && [[assigned_gender lowercaseString]isEqualToString:@"female"])
                        {
                            [obj setValue:@"Gender Same" forKey:@"name"];
                            [obj setValue:@"as_assigned_sex" forKey:@"stat_group"];
                            [obj setValue:@"as_assigned_sex" forKey:@"stat_key"];
                            
                            [custom_stats addObject:obj];

                        }
                        else if([[gender_identity lowercaseString]isEqualToString:@"2"] && [[assigned_gender lowercaseString]isEqualToString:@"1"])
                        {
                            
                            NSMutableDictionary* data=[[NSMutableDictionary alloc]init];
                            [data setObject:@"" forKey:@"stat_key"];
                            [data setObject:@"gender_same_as_assigned_sex" forKey:@"stat_group"];
                            [data setObject:@"" forKey:@"stat_type"];
                            [data setObject:@"Not Provided" forKey:@"name"];
                            [data setObject:[NSNumber numberWithFloat:100.f] forKey:@"result"];
                            [custom_stats addObject:data];
                            
                        }
                        else
                        {
                            //override values
                            NSString* modified=[obj objectForKey:@"modified"];
                            
                            if(!modified || modified.length==0)
                            {
                            [obj setValue:@"Gender Differs" forKey:@"name"];
                            [obj setValue:@"from_assigned_sex" forKey:@"stat_group"];
                            [obj setValue:@"from_assigned_sex" forKey:@"stat_key"];
                            [obj setValue:@"modified" forKey:@"modified"];
                            int percentageinteger = [obj[@"result"] intValue];
                            percentageinteger=100-percentageinteger;
                            double percentagedouble=percentageinteger*1.00;
                            
                            [obj setValue:[NSString stringWithFormat:@"%f",percentagedouble] forKey:@"result"];
                            }
                            [custom_stats addObject:obj];

                        }
                        
                        
                        

                    }
                        break;
                    case 3:
                    {
                        BOOL found=false;

                        for (int x = 0; x < related_stats.count; x++) {
                            NSDictionary * obj = [related_stats objectAtIndex:x];
                            NSString *sublabelString = obj[@"stat_group"];
                            if([sublabelString isEqualToString:@"cultural_identity"])
                            {
                                found=true;
                                [custom_stats addObject:obj];
                                break;
                            }
                        }
                        if(!found)
                        {
                            NSMutableDictionary* data=[[NSMutableDictionary alloc]init];
                            [data setObject:@"" forKey:@"stat_key"];
                            [data setObject:@"cultural_identity" forKey:@"stat_group"];
                            [data setObject:@"" forKey:@"stat_type"];
                            [data setObject:@"Not Provided" forKey:@"name"];
                            [data setObject:[NSNumber numberWithFloat:100.f] forKey:@"result"];
                            [custom_stats addObject:data];

                            
                            
                        }
                        
                        
                    }
                        break;
                    case 4:
                    {
                        BOOL found=false;

                        for (int x = 0; x < related_stats.count; x++) {
                            NSDictionary * obj = [related_stats objectAtIndex:x];
                            NSString *sublabelString = obj[@"stat_group"];
                            if([sublabelString isEqualToString:@"relationship_status"])
                            {
                                found=true;
                                [custom_stats addObject:obj];
                                break;
                            }
                        }
                        if(!found)
                        {
                            NSMutableDictionary* data=[[NSMutableDictionary alloc]init];
                            [data setObject:@"" forKey:@"stat_key"];
                            [data setObject:@"relationship_status" forKey:@"stat_group"];
                            [data setObject:@"" forKey:@"stat_type"];
                            [data setObject:@"Not Provided" forKey:@"name"];
                            [data setObject:[NSNumber numberWithFloat:100.f] forKey:@"result"];
                            [custom_stats addObject:data];

                            
                            
                        }
                        
                    }
                        break;
                    default:
                        break;
                }
//                for (int x = 0; x < related_stats.count; x++) {
//                    NSDictionary * obj = [related_stats objectAtIndex:x];
//                    NSString *sublabelString = obj[@"stat_group"];
//                    if(i==2)
//                    {
//                      NSDictionary *stats = DemographicsData[@"stats"];
//                      NSDictionary*  obj1=[[[stats objectForKey:@"gender_same_as_assigned_sex"] objectForKey:@"average"] objectAtIndex:0];
//                        [custom_stats addObject:obj1];
//
//                    }
//                    else
//                    {
//                        if([sublabelString isEqualToString:@"orientation"])
//                        {
//                        [custom_stats addObject:obj];
//                        }
//                        else  if([sublabelString isEqualToString:@"gender_identity"])
//                        {
//                            [custom_stats addObject:obj];
//                        }
//                    
//                    }
//                    
//                    
//                    
//
//                }
            }
            for (int i = 0; i < custom_stats.count; i++) {
                NSDictionary *obj =[custom_stats objectAtIndex:i];
                
//                NSString *sublabelString = obj[@"stat_group"];
//                [stats addObject:sublabelString];
//                
           
                    
                    
                
                UAProgressView *progressbar = [cell.progressCircles objectAtIndex:i];
                UILabel *label = [cell.progressLabels objectAtIndex:i];
                UILabel *percentage = [cell.progressPercentages objectAtIndex:i];
                UILabel *subLabel = [cell.progressSubLabels objectAtIndex:i];
                
                label.text = obj[@"name"];
                NSString *sublabelString = obj[@"stat_group"];
                NSString *stat_type = obj[@"stat_type"];

                
                sublabelString = [sublabelString stringByReplacingOccurrencesOfString:@"_" withString:@" "];
                sublabelString = [NSString stringWithFormat:@"(%@)", sublabelString];
                    sublabelString=[sublabelString stringByReplacingOccurrencesOfString:@"assigned gender" withString:@"assigned sex"];
                    sublabelString=[sublabelString stringByReplacingOccurrencesOfString:@"Assigned Gender" withString:@"Assigned Sex"];

                    sublabelString=[sublabelString stringByReplacingOccurrencesOfString:@"gender identity" withString:@"gender"];
                    sublabelString=[sublabelString stringByReplacingOccurrencesOfString:@"orientation" withString:@"sexual orientation"];


                
                subLabel.text = sublabelString;
                if([stat_type length]==0)
                {
                    sublabelString=@"";
                    //subLabel.text = @"";

                }
                
                switch (i) {
                    case 0:
                    {
                        [progressbar setColorx:[UIColor colorWithRed:61 / 255.f green:180 / 255.f blue:229 / 255.f alpha:1] border:[UIColor clearColor]];
                    }
                        break;
                        
                    case 1:
                    {
                        // Level 2
                        [progressbar setColorx:[UIColor colorWithRed:102 / 255.f green:188 / 255.f blue:176 / 255.f alpha:1] border:[UIColor clearColor]];
                    }
                        break;
                        
                    case 2:
                    {
                        // Level 3
                        [progressbar setColorx:[UIColor colorWithRed:162 / 255.f green:207 / 255.f blue:95 / 255.f alpha:1] border:[UIColor clearColor]];
                    }
                        break;
                        
                    case 3:
                    {
                        // Level 4
                        
                        [progressbar setColorx:[UIColor colorWithRed:238 / 255.f green:59 / 255.f blue:51 / 255.f alpha:1] border:[UIColor clearColor]];
                    }
                        break;
                        
                    case 4:
                    {
                        // Level 5
                        [progressbar setColorx:[UIColor colorWithRed:242 / 255.f green:107 / 255.f blue:42 / 255.f alpha:1] border:[UIColor clearColor]];
                    }
                        break;
                        
                    default:
                        break;
                }
                if([stat_type length]==0)
                {
                    [progressbar setColorx:UIColorFromRGB(0xededed) border:[UIColor clearColor]];
                        
                }
                
                
                int percentageinteger = [obj[@"result"] intValue];
                //				percentage.text = [NSString stringWithFormat:@"%d%%", percentageinteger];
                
                NSString* percentageString=[NSString stringWithFormat:@"%d%%", percentageinteger];
                
                NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:percentageString];
                NSRange percentagelength = NSMakeRange(percentageString.length-1, 1);
                [attrString addAttribute:NSFontAttributeName
                                   value:[UIFont boldSystemFontOfSize:percentage.font.pointSize/2]
                                   range:percentagelength];
                
                percentage.attributedText = attrString;
                if([stat_type length]==0)
                {
                    percentage.text=@"";
                }
                
                float percent = [obj[@"result"] floatValue] / 100;
                [progressbar setProgress:percent animated:true];
            }
            
            
            return cell;
        }
        else {
            static NSString *CellIdentifier = @"DashboardActivityCompletionCell";
            DashboardActivityCompletionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[DashboardActivityCompletionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            
            [dateFormat setDateFormat:@"MMMM dd"];
            NSString *temp = [dateFormat stringFromDate:[[NSDate alloc]init]];
            cell.dateLbl.text = [NSString stringWithFormat:@"Today, %@", temp];
            
            
            cell.progressView.animationDuration = 0.6;
            [cell.questionButton addTarget:self action:@selector(popupQuestion) forControlEvents:UIControlEventTouchUpInside];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.progressView setProgress:0.f animated:false];
            
            [cell.progressView setColorx:UIColorFromRGB(0xa3d55d) border:[UIColor clearColor]];
            
            cell.grayCircle.progress=1.f;
            cell.grayCircle.lineWidth = 4.f;
            
            [cell.grayCircle setColorx:UIColorFromRGB(0xd9d9d9) border:UIColorFromRGB(0xffffff)];
            
            cell.progressView.lineWidth = 4.f;
            float percent = activityCompletion;
            int percentageint = (int)(percent * 100.0);
            
            //NSString *percentage = [NSString stringWithFormat:@"%d%%", percentageint];
            
            [cell.progressView setProgress:percent animated:true];
            //	cell.percentageLabel.text = percentage;
            NSString* percentageString=[NSString stringWithFormat:@"%d%%", percentageint];
            
            NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:percentageString];
            NSRange percentagelength = NSMakeRange(percentageString.length-1, 1);
            [attrString addAttribute:NSFontAttributeName
                               value:[UIFont boldSystemFontOfSize:cell.percentageLabel.font.pointSize/2]
                               range:percentagelength];
            
            cell.percentageLabel.attributedText = attrString;
            
            
            [cell.progressView addSubview:cell.percentageLabel];
            
            return cell;
        }
    }
    else {
        return [[UITableViewCell alloc]init];
    }
    return [[UITableViewCell alloc]init];
}

- (void)popupQuestion {
   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                   message:alertDesc
                                                  delegate:self
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil];
   alert.tintColor=[UIColor orangeColor];
   [alert show];
 
               ////    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertDesc preferredStyle:UIAlertControllerStyleAlert];
//    
//    
//    // Create the "OK" button.
//    NSString *okTitle = NSLocalizedString(@"OK", nil);
//    UIAlertAction *okAction = [UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        [self.tableView reloadData];
//        //[self performSelector:@selector(dismiss) withObject:NULL afterDelay:0.1];
//    }];
//    [self.tableView reloadData];
//    [alertController addAction:okAction];
//    
//    
//    // Present the alert controller.
//    [self.parentViewController.parentViewController presentViewController:alertController animated:YES completion:nil];
//

}

//
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
