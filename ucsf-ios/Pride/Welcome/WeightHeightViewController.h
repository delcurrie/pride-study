//
//  WeightHeightViewController.h
//  Pride
//
//  Created by Patrick Krabeepetcharat on 5/22/15.
//  Copyright (c) 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "HKHealthStore+AAPLExtensions.h"
#import "R1Emitter.h"
#import "GAITrackedViewController.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@import HealthKit;

@interface WeightHeightViewController : GAITrackedViewController <UIPickerViewDataSource,UIPickerViewDelegate>

@property (nonatomic) HKHealthStore *healthStore;
@property (weak, nonatomic) IBOutlet UITextField *heightField;

@property (weak, nonatomic) IBOutlet UILabel *label_weight;

@end
