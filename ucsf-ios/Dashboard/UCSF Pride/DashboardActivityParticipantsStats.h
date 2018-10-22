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
@interface DashboardActivityParticipantsStats : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *expandRelationshipStatus;
@property (weak, nonatomic) IBOutlet UIButton *expandCulturalIdentity;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *cultureIdentityLabels;
@property (strong, nonatomic) IBOutletCollection(TYMProgressBarView) NSArray *cultureIdentityProgress;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *relationshipLabels;
@property (strong, nonatomic) IBOutletCollection(TYMProgressBarView) NSArray *relationshipProgress;

@end
