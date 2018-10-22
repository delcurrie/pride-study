//
//  DashboardFullScreenViewController.h
//  UCSF Pride
//
//  Created by Analog Republic on 5/20/15.
//  Copyright (c) 2015 Pride Study. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Charts/Charts.h>
@interface DashboardFullScreenWebViewController : UIViewController
- (IBAction)closeFullScreen:(id)sender;
@property (weak, nonatomic) IBOutlet UIWebView *webViewer;
@property (weak, nonatomic) IBOutlet NSString *url;
@property (weak, nonatomic) IBOutlet UIButton *expandButton;

@end
