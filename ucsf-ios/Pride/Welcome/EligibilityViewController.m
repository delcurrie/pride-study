//
//  EligibilityViewController.m
//  Pride
//
//  Created by Patrick Krabeepetcharat on 5/8/15.
//  Copyright (c) 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import "EligibilityViewController.h"

@interface EligibilityViewController ()

@end

@implementation EligibilityViewController

- (void)viewDidAppear:(BOOL)animated{
    // RadiumOne Tracking
    [[R1Emitter sharedInstance] emitScreenViewWithDocumentTitle:@"Eligibility"
                                             contentDescription:nil
                                            documentLocationUrl:nil
                                               documentHostName:nil
                                                   documentPath:nil
                                                      otherInfo:nil];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Eligibility"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.isComplete = NO;
    self.isEligible = NO;
    
    // Show the nav bar and add the next button
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationItem setTitle:@"Eligibility"];
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(handler_next)];
    self.navigationItem.rightBarButtonItem = nextButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    // Set up the WebView
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                  pathForResource:@"eligibility_new" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    [self.webView.scrollView setBounces:YES];
    [self.webView.scrollView setDecelerationRate:UIScrollViewDecelerationRateNormal]; //Make scroll decelleration more like native
    [self.webView setDelegate:self];
    
    
}

- (void)handler_next{
    if(self.isEligible){
        NSLog(@"is eligible");
        [self performSegueWithIdentifier:@"YouAreEligible" sender:self];
    }else{
        NSLog(@"is not eligible");
        [self performSegueWithIdentifier:@"YouAreNotEligible" sender:self];
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
    if ([actionType isEqualToString:@"updateEligibility"]) {
        
        // If all questions are answered
        if([[queryStringDictionary objectForKey:@"isComplete"] isEqualToString:@"true"]){
            [self.navigationItem.rightBarButtonItem setEnabled:YES];
        }else{
            [self.navigationItem.rightBarButtonItem setEnabled:NO];
        }
        
        // If answered YES to all questions
        if([[queryStringDictionary objectForKey:@"isEligible"] isEqualToString:@"true"]){
            self.isEligible = YES;
        }else{
            self.isEligible = NO;
        }
    }
    
    // make sure to return NO so that your webview doesn't try to load your made-up URL
    return NO;
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

@end
