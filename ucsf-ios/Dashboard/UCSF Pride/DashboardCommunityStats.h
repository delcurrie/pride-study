//
//  DashboardActivityCompletionCell.h
//  UCSF Pride
//
//  Created by Analog Republic on 5/17/15.
//  Copyright (c) 2015 Pride Study. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBStackedBarChart.h"
@interface DashboardCommunityStats : UITableViewCell
@property (weak, nonatomic) IBOutlet SBBarChart *healthBarChart;
@property (weak, nonatomic) IBOutlet SBBarChart *identityBarChart;
@property (weak, nonatomic) IBOutlet SBBarChart *ageBarChart;
@property (weak, nonatomic) IBOutlet UIButton *headerButton;
@property (strong, nonatomic)IBOutletCollection(UILabel) NSArray * postsCollection;
@property (strong, nonatomic)IBOutletCollection(UILabel) NSArray * postsUpCountCollection;
@property (strong, nonatomic)IBOutletCollection(UILabel) NSArray * postsDownCountCollection;
@property (strong, nonatomic)IBOutletCollection(UILabel) NSArray * postsCommentCountLabel;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *healthPercentages;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *healhLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *agePercentages;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *identityPercentages;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *ageLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *identity_Labels;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *postsButtons;


@end
