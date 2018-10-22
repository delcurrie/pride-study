//
//  WhatToExpectViewController.h
//  Pride
//
//  Created by Patrick Krabeepetcharat on 5/28/15.
//  Copyright (c) 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+constants.h"
#import "R1Emitter.h"
#import "GAITrackedViewController.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface WhatToExpectViewController : GAITrackedViewController

@property (weak, nonatomic) IBOutlet UIButton *btn_gotit;

- (IBAction)nextPage:(id)sender;

@end
