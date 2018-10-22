//
//  FailedQuizViewController.m
//  pride
//
//  Created by Patrick Krabeepetcharat on 5/19/15.
//  Copyright (c) 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import "FailedQuizViewController.h"

@interface FailedQuizViewController ()

@end

@implementation FailedQuizViewController

- (void)viewDidAppear:(BOOL)animated{
    // RadiumOne Tracking
    [[R1Emitter sharedInstance] emitScreenViewWithDocumentTitle:@"Failed Quiz"
                                             contentDescription:nil
                                            documentLocationUrl:nil
                                               documentHostName:nil
                                                   documentPath:nil
                                                      otherInfo:nil];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Failed quiz"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Stylize the "Join Study" button
    self.btn_next.layer.cornerRadius = 5.0f;//any float value
    self.btn_next.layer.borderWidth = 2.0f;//any float value
    self.btn_next.layer.borderColor = [[UIColor primaryColor]CGColor];
    [self.btn_next setTitleColor:[UIColor primaryColor] forState:UIControlStateNormal];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationItem setTitle:@"Consent"];
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

- (IBAction)retry:(id)sender {
    [self consentRestart];
}

- (IBAction)gotoIntro:(id)sender {
    [self consentRestart];
}

- (void)consentRestart{
    // Flags starting up the consent when we pop to the Eligible view controller
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"shouldStartConsent"];
    
    // Pop to the eligible view controller.
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[YouAreEligibleViewController class]]){
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
}

@end
