//
//  LearnViewController.m
//  Pride
//
//  Created by Patrick Krabeepetcharat on 5/14/15.
//  Copyright (c) 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import "LearnViewController.h"

@interface LearnViewController ()

@property MPMoviePlayerViewController *controller;

@end

@implementation LearnViewController

NSArray *titles;
NSArray *imageNames;
NSArray *htmlContentNames;

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    self.edgesForExtendedLayout=UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars=NO;
    self.automaticallyAdjustsScrollViewInsets=NO;
    
    [self.tableView reloadData];
    
    // RadiumOne Tracking
    [[R1Emitter sharedInstance] emitScreenViewWithDocumentTitle:@"Learn"
                                             contentDescription:nil
                                            documentLocationUrl:nil
                                               documentHostName:nil
                                                   documentPath:nil
                                                      otherInfo:nil];
    
    self.screenName = @"Learn";
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Learn"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    
    titles = [NSArray arrayWithObjects:
              @"Header",
              @"About the Study",
              @"About the App",
              @"How This Study Works",
              @"Help This Study",
              @"Our Pledge",
              @"Who’s Running the Study?", nil];
    
    imageNames = [NSArray arrayWithObjects:
                  @"nil",
                  @"about_study",
                  @"about_app",
                  @"howitworks",
                  @"help_study",
                  @"our_pledge",
                  @"running_the_study",nil];
    
    htmlContentNames = [NSArray arrayWithObjects:
                        @"nil",
                        @"intro-about-study",
                        @"intro-about-app",
                        @"intro-how-study-works",
                        @"intro-help-this-study",
                        @"intro-our-pledge",
                        @"intro-who-is-running-the-study",nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TableView Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [titles count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([[titles objectAtIndex:indexPath.row] isEqualToString:@"Header"]){
        return 80;
    }else{
        return 60;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *headerTableIdentifier = @"HeaderCell";
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    if([[titles objectAtIndex:indexPath.row] isEqualToString:@"Header"]){
        LearnHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:headerTableIdentifier];
        
        if (cell == nil) {
            cell = [[LearnHeaderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:headerTableIdentifier];
        }
        
        // Trying to hide the separator here, but it doesn't seem to work
        cell.separatorInset = UIEdgeInsetsMake(0.f, cell.bounds.size.width, 0.f, 0.f);
        
        return cell;
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        }
        
        cell.textLabel.text = [titles objectAtIndex:indexPath.row];
        cell.imageView.image = [UIImage imageNamed:[imageNames objectAtIndex:indexPath.row]];
        [cell.imageView setTintColor:[UIColor primaryColor]];
        return cell;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Don't allow selection of the header cell
    if([[titles objectAtIndex:indexPath.row] isEqualToString:@"Header"]){
        return nil;
    }else{
        return indexPath;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(![htmlContentNames[indexPath.row] isEqualToString:@"nil"]){
        UIViewController *vc = [[UIViewController alloc] init];
        UIWebView *webView = [[UIWebView alloc] initWithFrame:vc.view.bounds];
        double height = self.navigationController.navigationBar.frame.size.height;
        
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                             pathForResource:htmlContentNames[indexPath.row] ofType:@"html" inDirectory:@"HTMLContent/pages"]];
        [webView loadRequest:[NSURLRequest requestWithURL:url]];
        [webView.scrollView setBounces:YES];
        [webView.scrollView setDecelerationRate:UIScrollViewDecelerationRateNormal];
        webView.scrollView.contentInset = UIEdgeInsetsMake(-height, 0, height, 0);
        webView.delegate = self;
        
        [vc.view addSubview:webView];
        
        [self.tabBarController.navigationController pushViewController:vc animated:YES];
        [vc.navigationItem setTitle:[titles objectAtIndex:indexPath.row]];
    }else{
        
    }
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    // these need to match the values defined in your JavaScript
    NSString *myAppScheme = @"pride";
    
    // ignore legit webview requests so they load normally
    if (![request.URL.scheme isEqualToString:myAppScheme]) {
        return YES;
    }
    
    // get the action from the path
    NSString *actionType = request.URL.host;
    
    NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
    NSArray *urlComponents = [request.URL.query componentsSeparatedByString:@"&"];
    
    for (NSString *keyValuePair in urlComponents)
    {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
        NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
        
        [queryStringDictionary setObject:value forKey:key];
    }
    
    // look at the actionType and do whatever you want here
    if([actionType isEqualToString:@"playIntroVideo"]){
        [self playIntroVideo];
    }
    
    // make sure to return NO so that your webview doesn't try to load your made-up URL
    return NO;
}

- (void)playIntroVideo{
    NSString *videoPath=[[NSBundle mainBundle] pathForResource:@"intro" ofType:@"mp4"];
    NSURL *videoURL=[NSURL fileURLWithPath:videoPath isDirectory:NO];
    
    self.controller = [[MPMoviePlayerViewController alloc]initWithContentURL:videoURL];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.controller.moviePlayer];
    
    self.controller.view.frame = self.view.bounds;
    
    // [self.view addSubview:self.controller.view];
    
    [self.controller.moviePlayer prepareToPlay];
    [self.controller.moviePlayer play];
    // [self.controller.moviePlayer setFullscreen:YES animated:YES];
    [self presentViewController:self.controller animated:true completion:NULL];
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:self.controller];
    
    [self dismissMoviePlayerViewControllerAnimated];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
