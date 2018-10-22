//
//  TabBarViewController.m
//  Pride
//
//  Created by Patrick Krabeepetcharat on 5/11/15.
//  Copyright (c) 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import "TabBarViewController.h"
#import "LockScreenViewController.h"
#import "AppConstants.h"
@interface TabBarViewController ()<JKLLockScreenViewControllerDataSource, JKLLockScreenViewControllerDelegate>

@end

@implementation TabBarViewController

UIBarButtonItem * barButton_communityGuidelines;

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:true];
    
    self.title = @"Community";
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    NSLog(@"sex: %@", [[NSUserDefaults standardUserDefaults] valueForKey:USER_SEX_IDENTIFIER]);
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // RadiumOne Tracking
    [[R1Emitter sharedInstance] emitScreenViewWithDocumentTitle:@"Tab Bar"
                                             contentDescription:nil
                                            documentLocationUrl:nil
                                               documentHostName:nil
                                                   documentPath:nil
                                                      otherInfo:nil];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Tab Bar"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Set selection color
    [[self tabBar] setTintColor:[UIColor primaryColor]];

    barButton_communityGuidelines = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"info_icon"]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(showCommunityGuidelines)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(promptPin:)
                                                 name:STATE_SHOW_PIN_POPUP object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changePin:)
                                                 name:STATE_CHANGE_PIN_POPUP object:nil];

    [self promptPin:NULL];
    
    self.delegate = self;
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    [self.navigationItem setTitle:self.tabBar.selectedItem.title];
}

- (void)showCommunityGuidelines{
    UIViewController *vc = [[UIViewController alloc] init];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:vc.view.frame];
    CGRect frame=webView.frame;
    frame.size.height=frame.size.height-self.navigationController.navigationBar.frame.size.height;
    webView.frame=frame;
    
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                         pathForResource:@"community-guidelines" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    [webView.scrollView setBounces:YES];
    [webView.scrollView setDecelerationRate:UIScrollViewDecelerationRateNormal];
    [vc.view addSubview:webView];
    
    [self.navigationController pushViewController:vc animated:YES];
    [vc.navigationItem setTitle: @"Community FAQ"];
    [vc.navigationItem.backBarButtonItem setTitle:@"Title here"];
    self.title = @"";
}


#pragma mark - TabBarViewController Delegate Methods


- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    // Call view did appear when switching tabs
    [viewController viewDidAppear:YES];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.navigationController.navigationBar.translucent = NO;
    
    [viewController.view setNeedsLayout];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    [self.navigationItem setTitle:item.title];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.translucent = NO;
    
    // Hide and show the community bar button
    if ([item.title isEqualToString:@"Community"]) {
        self.navigationItem.rightBarButtonItem = barButton_communityGuidelines;
    }else{
        self.navigationItem.rightBarButtonItem = nil;
    }
}
-(void)promptPin:(NSNotification *)note
{
    BOOL showpinpopup=[[[NSUserDefaults standardUserDefaults] objectForKey:STATE_SHOW_PIN_POPUP] boolValue];
    if(showpinpopup==TRUE)
    {
        
        LockScreenViewController* view=[[LockScreenViewController alloc]init];
        NSString* userpincode=[[NSUserDefaults standardUserDefaults] objectForKey:USER_PIN_CODE];
        
        if([userpincode length]>0)
        {
            [view setLockScreenMode:0]; // enum { LockScreenModeNormal, LockScreenModeNew, LockScreenModeChange }
        }
        else
        {
            [view setLockScreenMode:1]; // enum { LockScreenModeNormal, LockScreenModeNew, LockScreenModeChange }
        }
        [view setDelegate:self];
        [view setDataSource:self];
        [self presentViewController:view animated:TRUE completion:NULL];
        [[NSUserDefaults standardUserDefaults] setBool:false forKey:STATE_SHOW_PIN_POPUP];
    }
    
}
-(void)changePin:(NSNotification *)note
{
   
        LockScreenViewController* view=[[LockScreenViewController alloc]init];
        
    
            [view setLockScreenMode:2]; // enum { LockScreenModeNormal, LockScreenModeNew, LockScreenModeChange }
        
        [view setDelegate:self];
        [view setDataSource:self];
        [self presentViewController:view animated:TRUE completion:NULL];
        [[NSUserDefaults standardUserDefaults] setBool:false forKey:STATE_SHOW_PIN_POPUP];
        
   

}

#pragma mark -
#pragma mark YMDLockScreenViewControllerDelegate
- (void)unlockWasCancelledLockScreenViewController:(LockScreenViewController *)lockScreenViewController {
    
    NSLog(@"LockScreenViewController dismiss because of cancel");
}

- (void)unlockWasSuccessfulLockScreenViewController:(LockScreenViewController *)lockScreenViewController pincode:(NSString *)pincode {
    
    [[NSUserDefaults standardUserDefaults] setObject:pincode forKey:USER_PIN_CODE];
}

#pragma mark -
#pragma mark YMDLockScreenViewControllerDataSource
- (BOOL)lockScreenViewController:(LockScreenViewController *)lockScreenViewController pincode:(NSString *)pincode {
    
    NSString* userpincode=[[NSUserDefaults standardUserDefaults] objectForKey:USER_PIN_CODE];
    return [userpincode isEqualToString:pincode];
}
- (BOOL)allowTouchIDLockScreenViewController:(LockScreenViewController *)lockScreenViewController {
    
    return YES;
}


@end
