//
//  CommunityViewController.m
//  Pride
//
//  Created by Patrick Krabeepetcharat on 5/13/15.
//  Copyright (c) 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import "CommunityViewController.h"
#import "AppConstants.h"
@interface CommunityViewController ()

@property UIWebView *loadingWebView;

@end

@implementation CommunityViewController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self getCommunityUrl];

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
        [_loadingWebView setUserInteractionEnabled:false];
        [_webView setUserInteractionEnabled:false];

    }
    else
    {
        [_loadingWebView setUserInteractionEnabled:true];
        [_webView setUserInteractionEnabled:true];
    }
    // RadiumOne Tracking
    [[R1Emitter sharedInstance] emitScreenViewWithDocumentTitle:@"Community"
                                             contentDescription:nil
                                            documentLocationUrl:nil
                                               documentHostName:nil
                                                   documentPath:nil
                                                      otherInfo:nil];
    
    self.screenName = @"Community";
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Community"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSURL *url;
    
    
    url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                  pathForResource:@"community-loading" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
    self.loadingWebView =[[UIWebView alloc] initWithFrame:self.view.frame];
    [self.loadingWebView loadRequest:[NSURLRequest requestWithURL:url]];
    [self.loadingWebView.scrollView setBounces:NO];
    [self.loadingWebView setDelegate:self];
    [self.view addSubview:self.loadingWebView];
    

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getCommunityUrl)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    

}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}
- (void)getCommunityUrl {
    //Get API Data
    NSDictionary *params = @{ @"user_id": [[NSUserDefaults standardUserDefaults] objectForKey:USER_USER_ID_IDENTIFIER ] };
    NSString* path=[NSString stringWithFormat:@"generate-community-url"];
    
    NSURL *url = [NSURL URLWithString:
                  [SERVER_URL stringByAppendingString:path]];
    
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
                                        [self.loadingWebView setHidden:true];

                                   }];
                               }
                               else {
                                   NSMutableDictionary *innerJson = [NSJSONSerialization
                                                                     JSONObjectWithData:data options:kNilOptions error:NULL];
                                   
                                   
                                   [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
                                       // Your code to run on the main queue/thread
                                       [self loadUrl:[innerJson objectForKey:@"url"]];
                                       
                                   }];
                               }
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
-(void) loadUrl:(NSString*)urlToLoad
{
    NSURL *url = [NSURL URLWithString:urlToLoad];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    [self.webView.scrollView setBounces:YES];
    [self.webView.scrollView setDecelerationRate:UIScrollViewDecelerationRateNormal];
    [self.webView setDelegate:self];
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    if ([webView isEqual:self.webView]) {
        [self.loadingWebView removeFromSuperview];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
