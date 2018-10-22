//
//  DashboardActivityCompletionCell.h
//  UCSF Pride
//
//  Created by Analog Republic on 5/17/15.
//  Copyright (c) 2015 Pride Study. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYMProgressBarView.h"
#import "UAProgressView.h"
#import <Charts/Charts.h>
@interface DashboardActivityParticipantsStatsAssignedSex : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *malePercentage;
@property (weak, nonatomic) IBOutlet PieChartView *genderPieChart;
@property (weak, nonatomic) IBOutlet UILabel *femalePercentage;
@end
