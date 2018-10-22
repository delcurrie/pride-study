//
//  DashboardActivityCompletionCell.h
//  UCSF Pride
//
//  Created by Analog Republic on 5/17/15.
//  Copyright (c) 2015 Pride Study. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UAProgressView.h"
@interface DashboardParticipantsLikeMe : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *footerPercentageLabel;
@property (strong, nonatomic) IBOutletCollection(UAProgressView) NSArray *progressCircles;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *progressPercentages;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *progressSubLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *progressLabels;
@property (weak, nonatomic) IBOutlet UIView *notAvailableView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end
