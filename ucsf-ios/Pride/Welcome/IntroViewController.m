//
//  WelcomeViewController.m
//  Pride
//
//  Created by Patrick Krabeepetcharat on 5/6/15.
//  Copyright (c) 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import "IntroViewController.h"
#import "UIColor+constants.h"
#import "GAITrackedViewController.h"
#import "R1Push.h"
#import "R1WebCommand.h"
@interface IntroViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *test_webView;
@property MPMoviePlayerViewController *controller;

@end

@implementation IntroViewController

- (void)viewDidAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [self populateScrollView];
    
    // RadiumOne Tracking
    [[R1Emitter sharedInstance] emitScreenViewWithDocumentTitle:@"Intro"
                                             contentDescription:nil
                                            documentLocationUrl:nil
                                               documentHostName:nil
                                                   documentPath:nil
                                                      otherInfo:nil];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Intro"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Set the nav bar title
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav-title-intro"]];
    [titleView setContentMode:UIViewContentModeScaleAspectFit];
    
    [self.navigationItem setTitleView:titleView];
    
    [titleView setFrame:CGRectMake(
                                   0,
                                   0,
                                   self.navigationItem.titleView.frame.size.width*0.4,
                                   self.navigationItem.titleView.frame.size.height*0.5)];
    
    // Set up the scroll view
    [self.scrollView setDelegate:self];
    [self.scrollView setPagingEnabled:YES];
    [self.scrollView setBounces: NO];
    
    // Stylize the "Join Study" button
    self.btn_joinStudy.layer.cornerRadius = 5.0f;//any float value
    [self.btn_joinStudy setTitleColor:[UIColor primaryColor] forState:UIControlStateNormal];
    [self.btn_joinStudy setBackgroundColor:[UIColor whiteColor]];
    
    //// TEST ////
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Welcome" bundle:nil];
//    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"Registration"];
//    [self.navigationController pushViewController:vc animated:NO];
    
    // Globally set the nav bar color for the welcome section
    [[R1Push sharedInstance].tags setTags:@[ @"App Installed", @"unregistered user" ]];

    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor grayColor]}];
}

- (void)populateScrollView{
    
    
    if(self.scrollView.subviews.count == 0){
        UIWebView *webView;
        NSURL *url;
        NSMutableArray *viewsForScroll = [[NSMutableArray alloc] init];
        
        url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                      pathForResource:@"intro-welcome" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
        webView =[[UIWebView alloc] initWithFrame:self.scrollView.frame];
        [webView loadRequest:[NSURLRequest requestWithURL:url]];
        [webView.scrollView setBounces:NO];
        [webView setDelegate:self]; // Only register the delegate if you need to access native functions
        [viewsForScroll addObject:webView];
        
        url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                      pathForResource:@"intro-about-study" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
        webView =[[UIWebView alloc] initWithFrame:self.scrollView.frame];
        [webView loadRequest:[NSURLRequest requestWithURL:url]];
        [webView.scrollView setBounces:YES];
        [webView.scrollView setDecelerationRate:UIScrollViewDecelerationRateNormal];
        [viewsForScroll addObject:webView];
        
        url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                      pathForResource:@"intro-about-app" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
        webView =[[UIWebView alloc] initWithFrame:self.scrollView.frame];
        [webView loadRequest:[NSURLRequest requestWithURL:url]];
        [webView.scrollView setBounces:NO];
        [webView setDelegate:self]; // Only register the delegate if you need to access native functions
        [viewsForScroll addObject:webView];
        
        url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                      pathForResource:@"intro-how-study-works" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
        webView =[[UIWebView alloc] initWithFrame:self.scrollView.frame];
        [webView loadRequest:[NSURLRequest requestWithURL:url]];
        [webView.scrollView setBounces:YES];
        [webView.scrollView setDecelerationRate:UIScrollViewDecelerationRateNormal];
        [viewsForScroll addObject:webView];
        
        url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                      pathForResource:@"intro-help-this-study" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
        webView =[[UIWebView alloc] initWithFrame:self.scrollView.frame];
        [webView loadRequest:[NSURLRequest requestWithURL:url]];
        [webView.scrollView setBounces:NO];
        [viewsForScroll addObject:webView];
        
        url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                      pathForResource:@"intro-our-pledge" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
        webView =[[UIWebView alloc] initWithFrame:self.scrollView.frame];
        [webView loadRequest:[NSURLRequest requestWithURL:url]];
        [webView.scrollView setBounces:YES];
        [webView.scrollView setDecelerationRate:UIScrollViewDecelerationRateNormal];
        [viewsForScroll addObject:webView];
        
        url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                      pathForResource:@"intro-who-is-running-the-study" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
        webView =[[UIWebView alloc] initWithFrame:self.scrollView.frame];
        [webView loadRequest:[NSURLRequest requestWithURL:url]];
        [webView.scrollView setBounces:NO];
        [viewsForScroll addObject:webView];
        
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width*viewsForScroll.count, self.scrollView.frame.size.height)];
        
        for (int i = 0; i<viewsForScroll.count; i++)
        {
            UIView *view = viewsForScroll[i];
            [view setFrame:CGRectMake(view.frame.origin.x + (webView.frame.size.width*i), view.frame.origin.y, view.frame.size.width, view.frame.size.height)];
            
            [self.scrollView addSubview:view];
        }
        
        // Set number of pages for the page control
        [self.pageControl setNumberOfPages:viewsForScroll.count];
    }
}

- (void)showConsentDocument{
    UIViewController *vc = [[UIViewController alloc] init];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:vc.view.frame];
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                         pathForResource:@"consent-review" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    [webView.scrollView setBounces:YES];
    [webView.scrollView setDecelerationRate:UIScrollViewDecelerationRateNormal];
    [vc.view addSubview:webView];
    
    [self.navigationController pushViewController:vc animated:YES];
    [vc.navigationItem setTitle:@"Consent"];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)emailConsent{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"consent" ofType:@"pdf"];
    NSData *pdfData = [NSData dataWithContentsOfFile:filePath];
    
    MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
    vc.mailComposeDelegate = self;
    [vc setSubject:@"PRIDE Study Consent"];
    [vc addAttachmentData:pdfData mimeType:@"application/pdf" fileName:@"PRIDE_Consent.pdf"];
    [self presentViewController:vc animated:YES completion:NULL];
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

#pragma mark - WebView Delegates
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSString * jsCallBack = [NSString stringWithFormat:@"init();"];
    [self.scrollView.subviews[0] stringByEvaluatingJavaScriptFromString:jsCallBack];
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
    if ([actionType isEqualToString:@"showConsentDocument"]) {
        [self showConsentDocument];
    }else if([actionType isEqualToString:@"emailConsent"]){
        [self emailConsent];
    }else if([actionType isEqualToString:@"playIntroVideo"]){
        [self playIntroVideo];
    }
    
    // make sure to return NO so that your webview doesn't try to load your made-up URL
    return NO;
}


#pragma mark - Scroll View Delegates
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat pageWidth = self.scrollView.frame.size.width;
    float fractionalPage = self.scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    
    // Set the current page on the page controller
    self.pageControl.currentPage = page;
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGFloat pageWidth = self.scrollView.frame.size.width;
    float fractionalPage = self.scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    
    // Call the initial animation function on the displayed WebView
    NSString * jsCallBack = [NSString stringWithFormat:@"init();"];
    [scrollView.subviews[page] stringByEvaluatingJavaScriptFromString:jsCallBack];
    
    if(page==0){
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }else{
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}


#pragma mark Mail Delegate Methods
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Compose View Controller Delegate
    [self dismissViewControllerAnimated:YES completion:NULL];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
