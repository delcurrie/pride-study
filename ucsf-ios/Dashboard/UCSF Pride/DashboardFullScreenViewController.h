//
//  DashboardFullScreenViewController.h
//  UCSF Pride
//
//  Created by Analog Republic on 5/20/15.
//  Copyright (c) 2015 Pride Study. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Charts/Charts.h>
#import "TYMProgressBarView.h"
@interface DashboardFullScreenViewController : UIViewController
- (IBAction)closeFullScreen:(id)sender;
@property (strong, nonatomic) IBOutlet LineChartView *communityLineChart;
@property (strong, nonatomic) IBOutlet NSMutableArray *communityData;
@property (strong, nonatomic) IBOutlet NSMutableArray *culturalIdentityData;
@property (strong, nonatomic) IBOutlet NSMutableArray *relationshipdata;
@property (weak, nonatomic) IBOutlet UIView *sidebar;
@property (weak, nonatomic) IBOutlet UIView *AxisHolder;

@property (weak, nonatomic) IBOutlet UIView *postsGraphContainer;
@property (weak, nonatomic) IBOutlet UIButton *expandButton;
@property (weak, nonatomic) IBOutlet UIScrollView *identityScrollV;
@property (weak, nonatomic) IBOutlet UILabel *scrollHeader;
@property (strong, nonatomic)IBOutletCollection(UILabel) NSArray * scrollLabels;
@property (strong, nonatomic)IBOutletCollection(TYMProgressBarView) NSArray * scrollProgress;
@property (weak, nonatomic) IBOutlet UIScrollView *progressScrollV;
@property (weak, nonatomic) IBOutlet UILabel *toplabel;
@property (weak, nonatomic) IBOutlet UILabel *currentlabel;

@end
