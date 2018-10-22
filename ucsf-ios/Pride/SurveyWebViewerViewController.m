//
//  CreateScreenNameViewController.m
//  Pride
//
//  Created by Analog Republic on 11/12/15.
//  Copyright © 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import "SurveyWebViewerViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+constants.h"
#import <AFNetworking/AFNetworking.h>
#import "AppConstants.h"

@interface SurveyWebViewerViewController ()

@property (weak, nonatomic) IBOutlet UIView *screenNameContainer;
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation SurveyWebViewerViewController
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString* urlToLoad=request.URL.absoluteString;
    if([urlToLoad containsString:@"endsurvey"])
    {
        if([_surveyType isEqualToString:IMPROVING_SURVEY])
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:STATE_IMPROVING_SURVEY_COMPLETE];
            [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:STATE_IMPROVING_SURVEY_COMPLETE_DATE];        }
        else if([_surveyType isEqualToString:PHYSICAL_SURVEY])
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:STATE_PHYSICAL_HEALTH_SURVEY_COMPLETE];
            [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:STATE_PHYSICAL_HEALTH_SURVEY_COMPLETE_DATE];        }
        else if([_surveyType isEqualToString:MENTAL_SURVEY])
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:STATE_MENTAL_HEALTH_SURVEY_COMPLETE];
            [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:STATE_MENTAL_HEALTH_SURVEY_COMPLETE_DATE];
        }
        else if([_surveyType isEqualToString:SOCIAL_SURVEY])
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:STATE_SOCIAL_HEALTH_SURVEY_COMPLETE];
            [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:STATE_SOCIAL_HEALTH_SURVEY_COMPLETE_DATE];
        }
        else if([_surveyType isEqualToString:AGE_SURVEY])
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:STATE_AGE_SURVEY_COMPLETE];
            [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:STATE_AGE_SURVEY_COMPLETE_DATE];
        }
        else
        {
            
        }
        [self dismissViewControllerAnimated:true completion:nil];

    }
    NSLog(@"url: %@",urlToLoad);
    return true;
}
-(void)exitScreen
{
    [self dismissViewControllerAnimated:true completion:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *exitBarButtonItem = [
                                      [UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                      target:self action:@selector(exitScreen)];
    self.navigationItem.rightBarButtonItem = exitBarButtonItem;
    
    NSString* surveyUrl=@"";
    
    if([_surveyType isEqualToString:IMPROVING_SURVEY])
    {
        self.title=@"Improving The PRIDE Study";
        surveyUrl=IMPROVING_SURVEY_URL;

    }
    else if([_surveyType isEqualToString:PHYSICAL_SURVEY])
    {
        self.title=@"Physical Health Survey";
        surveyUrl=PHYSICAL_SURVEY_URL;

    }
    else if([_surveyType isEqualToString:MENTAL_SURVEY])
    {
        self.title=@"Mental Health Survey";
        surveyUrl=MENTAL_HEALTH_SURVEY_URL;

    }
    else if([_surveyType isEqualToString:SOCIAL_SURVEY])
    {
        self.title=@"Social Health Survey";
        surveyUrl=SOCIAL_HEALTH_SURVEY_URL;

    }
    else if([_surveyType isEqualToString:AGE_SURVEY])
    {
        self.title=@"Age Survey";
        surveyUrl=AGE_SURVEY_URL;

    }
    else
    {
        
    }
    NSString* userid=([[NSUserDefaults standardUserDefaults] objectForKey:USER_USER_ID_IDENTIFIER])?[[NSUserDefaults standardUserDefaults] objectForKey:USER_USER_ID_IDENTIFIER]:@"";

    surveyUrl=[NSString stringWithFormat:@"%@&customerID=%@",surveyUrl,userid];
    NSURL *websiteUrl = [NSURL URLWithString:surveyUrl];

    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:websiteUrl];
    _webView.delegate=self;
    [_webView loadRequest:urlRequest];
    
    
    //style
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init]
                                      forBarPosition:UIBarPositionAny
                                          barMetrics:UIBarMetricsDefault];
    
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    
    // Do any additional setup after loading the view from its nib.
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
-(void)viewWillAppear:(BOOL)animated
{

    

}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    if (textField.text.length >= 8 && range.length == 0)
//    {
//        return NO; // return NO to not change text
//    }
//    else
//    {return YES;}
//}
@end
