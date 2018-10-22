//
//  DashboardActivityCompletionCell.h
//  UCSF Pride
//
//  Created by Analog Republic on 5/17/15.
//  Copyright (c) 2015 Pride Study. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Charts/Charts.h>

@interface DashboardCommunityStatsPostsGraph : UITableViewCell
@property (weak, nonatomic) IBOutlet LineChartView *CommunityGraph;
@property (weak, nonatomic) IBOutlet UIButton *expandButton;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *rightLabels;

@end
