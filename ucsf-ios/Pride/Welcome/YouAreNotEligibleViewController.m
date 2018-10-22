//
//  YouAreNotEligibleViewController.m
//  pride
//
//  Created by Patrick Krabeepetcharat on 5/18/15.
//  Copyright (c) 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import "YouAreNotEligibleViewController.h"

@interface YouAreNotEligibleViewController ()

@end

@implementation YouAreNotEligibleViewController

- (void)viewDidAppear:(BOOL)animated{
    // RadiumOne Tracking
    [[R1Emitter sharedInstance] emitScreenViewWithDocumentTitle:@"You are not eligible"
                                             contentDescription:nil
                                            documentLocationUrl:nil
                                               documentHostName:nil
                                                   documentPath:nil
                                                      otherInfo:nil];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"You are not eligible"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Stylize the "Join Study" button
    self.btn_learnMore.layer.cornerRadius = 5.0f;//any float value
    self.btn_learnMore.layer.borderWidth = 2.0f;//any float value
    self.btn_learnMore.layer.borderColor = [[UIColor primaryColor]CGColor];
    [self.btn_learnMore setTitleColor:[UIColor primaryColor] forState:UIControlStateNormal];
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

- (IBAction)learn_more:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.pridestudy.org/Donate.html"]];
}

@end
