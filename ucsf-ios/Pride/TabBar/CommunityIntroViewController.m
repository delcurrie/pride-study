//
//  CommunityIntroViewController.m
//  Pride
//
//  Created by Patrick Krabeepetcharat on 5/18/15.
//  Copyright (c) 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import "CommunityIntroViewController.h"

@interface CommunityIntroViewController ()

@end

@implementation CommunityIntroViewController

- (void)viewWillAppear:(BOOL)animated{
    [self.view setNeedsLayout];
    
    // Go away if not enrolled in the study
    if([[NSUserDefaults standardUserDefaults] boolForKey:USER_HAS_LEFT_STUDY]){
        [self performSegueWithIdentifier:@"NotEnrolled" sender:self];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [self populateScrollView];
    
    // RadiumOne Tracking
    [[R1Emitter sharedInstance] emitScreenViewWithDocumentTitle:@"Community Intro"
                                             contentDescription:nil
                                            documentLocationUrl:nil
                                               documentHostName:nil
                                                   documentPath:nil
                                                      otherInfo:nil];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Community Intro"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Set up the scroll view
    [self.scrollView setDelegate:self];
    [self.scrollView setPagingEnabled:YES];
    [self.scrollView setBounces: NO];
    
    // Stylize the "Join Study" button
    self.btn_community.layer.cornerRadius = 5.0f;
    [self.btn_community setTitleColor:[UIColor primaryColor] forState:UIControlStateNormal];
    [self.btn_community setBackgroundColor:[UIColor whiteColor]];
    
    self.btn_register.layer.cornerRadius = 5.0f;
    [self.btn_register setTitleColor:[UIColor primaryColor] forState:UIControlStateNormal];
    [self.btn_register setBackgroundColor:[UIColor whiteColor]];
}

- (void)populateScrollView{
    UIWebView *webView;
    NSURL *url;
    NSMutableArray *viewsForScroll = [[NSMutableArray alloc] init];
    
    url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                  pathForResource:@"community-welcome" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
    webView =[[UIWebView alloc] initWithFrame:self.scrollView.frame];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    [webView.scrollView setBounces:NO];
    [webView setDelegate:self]; // Only the first one needs to have the delegate, so we run the init function when it loads
    [viewsForScroll addObject:webView];
    
    url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                  pathForResource:@"community-page2" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
    webView =[[UIWebView alloc] initWithFrame:self.scrollView.frame];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    [webView.scrollView setBounces:NO];
    [viewsForScroll addObject:webView];
    
    url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                  pathForResource:@"community-page3" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
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


#pragma mark - WebView Delegates
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSString * jsCallBack = [NSString stringWithFormat:@"init();"];
    [self.scrollView.subviews[0] stringByEvaluatingJavaScriptFromString:jsCallBack];
}


#pragma mark - Scroll View Delegates
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat pageWidth = self.scrollView.frame.size.width;
    float fractionalPage = self.scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    
    // Set the current page on the page controller
    self.pageControl.currentPage = page;
}

- (IBAction)handler_community:(id)sender {
    [[NSUserDefaults standardUserDefaults] setValue:@"http://ucsfapi.dmclientportal.com/generate_community_token.php" forKey:@"community_url"];
    
    [self performSegueWithIdentifier:@"Community" sender:self];
}


@end
