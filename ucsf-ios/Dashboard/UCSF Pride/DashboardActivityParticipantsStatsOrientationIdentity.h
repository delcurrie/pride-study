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
@interface DashboardActivityParticipantsStatsOrientationIdentity : UITableViewCell
@property (weak, nonatomic) IBOutlet PieChartView *orientationPieChart;
@property (weak, nonatomic) IBOutlet PieChartView *identityPieChart;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *orientationPercentages;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *orientationLabels;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *identityPercentages;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *identityLabels;

@end
