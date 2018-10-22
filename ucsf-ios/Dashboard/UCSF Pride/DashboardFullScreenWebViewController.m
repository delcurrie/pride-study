//
//  DashboardFullScreenViewController.m
//  UCSF Pride
//
//  Created by Analog Republic on 5/20/15.
//  Copyright (c) 2015 Pride Study. All rights reserved.
//

#import "DashboardFullScreenWebViewController.h"

@interface DashboardFullScreenWebViewController ()

@end

@implementation DashboardFullScreenWebViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self prefersStatusBarHidden];
	
	[_webViewer loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]]];
	// Do any additional setup after loading the view from its nib.
}

- (BOOL)prefersStatusBarHidden {
	return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
	return (UIInterfaceOrientationMaskPortrait);
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
}

- (void)viewDidAppear:(BOOL)animated {
}

/*
   #pragma mark - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
   }
 */
 
- (IBAction)closeFullScreen:(id)sender {
	[self dismissViewControllerAnimated:true completion:NULL];
}

@end
