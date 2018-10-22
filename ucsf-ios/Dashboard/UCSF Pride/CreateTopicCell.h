//
//  DashboardActivityCompletionCell.h
//  UCSF Pride
//
//  Created by Analog Republic on 5/17/15.
//  Copyright (c) 2015 Pride Study. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface DashboardSectionHeaderCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *plusButton;
@property (weak, nonatomic) IBOutlet UIView *sectionBackgroundView;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UIButton *circleButton;

@end
