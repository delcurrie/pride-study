//
//  WhatToExpectViewController.m
//  Pride
//
//  Created by Patrick Krabeepetcharat on 5/28/15.
//  Copyright (c) 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import "WhatToExpectViewController.h"

@interface WhatToExpectViewController ()

@end

@implementation WhatToExpectViewController

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationItem setTitle:@"Device Access"];
    
    // Change the back button to a cancel button
    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = barBtnItem;
}

- (void)viewDidAppear:(BOOL)animated{
    // RadiumOne Tracking
    [[R1Emitter sharedInstance] emitScreenViewWithDocumentTitle:@"What to expect"
                                             contentDescription:nil
                                            documentLocationUrl:nil
                                               documentHostName:nil
                                                   documentPath:nil
                                                      otherInfo:nil];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"What to expect"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Stylize the got it button
    self.btn_gotit.layer.cornerRadius = 5.0f;//any float value
    self.btn_gotit.layer.borderWidth = 2.0f;//any float value
    self.btn_gotit.layer.borderColor = [[UIColor primaryColor]CGColor];
    [self.btn_gotit setTitleColor:[UIColor primaryColor] forState:UIControlStateNormal];
}

- (void) cancel{
    [self.navigationController popToRootViewControllerAnimated:YES];
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

- (IBAction)nextPage:(id)sender {
    [self performSegueWithIdentifier:@"Registration" sender:self];
}

@end
