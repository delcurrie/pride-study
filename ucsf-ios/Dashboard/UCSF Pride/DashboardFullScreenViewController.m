//
//  DashboardFullScreenViewController.m
//  UCSF Pride
//
//  Created by Analog Republic on 5/20/15.
//  Copyright (c) 2015 Pride Study. All rights reserved.
//

#import "DashboardFullScreenViewController.h"
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed: ((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 green: ((float)((rgbValue & 0xFF00) >> 8)) / 255.0 blue: ((float)(rgbValue & 0xFF)) / 255.0 alpha: 1.0]
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

@interface DashboardFullScreenViewController ()

@end

@implementation DashboardFullScreenViewController
- (void)animateWidth:(UIView *)view {
	//    float originalY= view.frame.origin.y;
	float originalW = view.frame.size.width;
	
	view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, 0, view.frame.size.height);
	[UIView animateWithDuration:1.8
	                 animations: ^{
	    view.frame = CGRectMake(view.frame.origin.x,  view.frame.origin.y, originalW, view.frame.size.height);
	}
	                 completion: ^(BOOL finished) {
	    [UIView animateWithDuration:1
	                     animations: ^{
	        view.transform = CGAffineTransformIdentity;
		}];
	}];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.view.transform = CGAffineTransformMakeRotation(-M_PI_2);
	[self prefersStatusBarHidden];
	
	
	if (_communityData) {
		[_progressScrollV setHidden:true];
		[_postsGraphContainer setHidden:false];
		[self setupCommunityLineGraph:_communityLineChart];
	}
	else if (_relationshipdata) {
		[_progressScrollV setHidden:false];
		[_postsGraphContainer setHidden:true];
		[_progressScrollV setContentSize:CGSizeMake(0, 0)];
		_scrollHeader.text = @"Relationship Status";
        _scrollHeader.textColor=[UIColor colorWithRed:255 / 255.f green:102 / 255.f blue:27 / 255.f alpha:1];
        
		for (int i = 0; i < _scrollProgress.count; i++) {
			if (_relationshipdata.count > i) {
				NSDictionary *obj = [_relationshipdata objectAtIndex:i];
				
				TYMProgressBarView *bar = [_scrollProgress objectAtIndex:i];
				[bar setHidden:false];
				
				[self setRelationshipProgressBar:bar];
				float percentageFloat = [obj[@"result"] floatValue];
				// [bar setProgress:.4];
				bar.progress = (float)(percentageFloat / 100.f);
				UILabel *label = [_scrollLabels objectAtIndex:i];
				[label setHidden:false];
				
//				label.text = [NSString stringWithFormat:@"%.2f%% %@", percentageFloat, obj[@"name"]];

                NSString* percentage=[NSString stringWithFormat:@"%.2f%% %@", percentageFloat, obj[@"name"]];
                
                NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@"%%"];
                NSRange range = [percentage rangeOfCharacterFromSet:charSet];
                
                
                NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:percentage];
                NSRange percentagelength = range;
                [attrString addAttribute:NSFontAttributeName
                                   value:[UIFont boldSystemFontOfSize:label.font.pointSize/1.5]
                                   range:percentagelength];
                
                [attrString addAttribute:NSFontAttributeName
                                   value:[UIFont boldSystemFontOfSize:label.font.pointSize/1.5]
                                   range:percentagelength];
                NSRange range2 = NSMakeRange(0, range.location);
                [attrString addAttribute:NSFontAttributeName
                                   value:[UIFont boldSystemFontOfSize:label.font.pointSize]
                                   range:range2];
                
                
                
                label.attributedText = attrString;
                
                [self animateWidth:bar];
			}
			else {
				TYMProgressBarView *bar = [_scrollProgress objectAtIndex:i];
				[bar setHidden:true];
				UILabel *label = [_scrollLabels objectAtIndex:i];
				[label setHidden:true];
			}
		}
	}
	else if (_culturalIdentityData) {
		[_progressScrollV setHidden:false];
		[_postsGraphContainer setHidden:true];
		[_progressScrollV setContentSize:CGSizeMake(0, 0)];
        _scrollHeader.text = @"Cultural Identity";
        _scrollHeader.textColor=[UIColor colorWithRed:163 / 255.f green:213 / 255.f blue:93 / 255.f alpha:1];
		for (int i = 0; i < _scrollProgress.count; i++) {
			if (_culturalIdentityData.count > i) {
				NSDictionary *obj = [_culturalIdentityData objectAtIndex:i];
				
				TYMProgressBarView *bar = [_scrollProgress objectAtIndex:i];
				[bar setHidden:false];
				
				[self setIdentityProgressBar:bar];
				float percentageFloat = [obj[@"result"] floatValue];
				// [bar setProgress:.4];
				bar.progress = (float)(percentageFloat / 100.f);
				UILabel *label = [_scrollLabels objectAtIndex:i];
				[label setHidden:false];
				
//				label.text = [NSString stringWithFormat:@"%.2f%% %@", percentageFloat, obj[@"name"]];
//                
                NSString* percentage=[NSString stringWithFormat:@"%.2f%% %@", percentageFloat, obj[@"name"]];
                
                NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@"%%"];
                NSRange range = [percentage rangeOfCharacterFromSet:charSet];
                
                
                NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:percentage];
                NSRange percentagelength = range;
                [attrString addAttribute:NSFontAttributeName
                                   value:[UIFont boldSystemFontOfSize:label.font.pointSize/1.5]
                                   range:percentagelength];
                
                [attrString addAttribute:NSFontAttributeName
                                   value:[UIFont boldSystemFontOfSize:label.font.pointSize/1.5]
                                   range:percentagelength];
                NSRange range2 = NSMakeRange(0, range.location);
                [attrString addAttribute:NSFontAttributeName
                                   value:[UIFont boldSystemFontOfSize:label.font.pointSize]
                                   range:range2];
                
                
                
                label.attributedText = attrString;
                
                
				[self animateWidth:bar];
			}
			else {
				TYMProgressBarView *bar = [_scrollProgress objectAtIndex:i];
				[bar setHidden:true];
				UILabel *label = [_scrollLabels objectAtIndex:i];
				[label setHidden:true];
			}
		}
	}
	// Do any additional setup after loading the view from its nib.
}

- (void)setIdentityProgressBar:(TYMProgressBarView *)progress {
	[progress setBarBorderColor:[UIColor whiteColor]];
	[progress setBarFillColor:[UIColor colorWithRed:163 / 255.f green:213 / 255.f blue:93 / 255.f alpha:1]];
	
	[progress setBarBackgroundColor:[UIColor colorWithRed:232 / 255.f green:232 / 255.f blue:232 / 255.f alpha:1]];
	
	_expandButton.tintColor = [UIColor colorWithRed:163 / 255.f green:213 / 255.f blue:93 / 255.f alpha:1];
    
    _sidebar.backgroundColor=[UIColor colorWithRed:163 / 255.f green:213 / 255.f blue:93 / 255.f alpha:1];
}

- (void)setRelationshipProgressBar:(TYMProgressBarView *)progress {
	[progress setBarBorderColor:[UIColor whiteColor]];
	[progress setBarFillColor:[UIColor colorWithRed:255 / 255.f green:102 / 255.f blue:27 / 255.f alpha:1]];
	
	[progress setBarBackgroundColor:[UIColor colorWithRed:232 / 255.f green:232 / 255.f blue:232 / 255.f alpha:1]];
	
	_expandButton.tintColor = [UIColor colorWithRed:255 / 255.f green:102 / 255.f blue:27 / 255.f alpha:1];
    
    _sidebar.backgroundColor=[UIColor colorWithRed:255 / 255.f green:102 / 255.f blue:27 / 255.f alpha:1];

}

- (BOOL)shouldAutorotate {
	return YES;
}

- (BOOL)prefersStatusBarHidden {
	return YES;
}

- (void)setupCommunityLineGraph:(LineChartView *)_chartView {
	_chartView = (LineChartView *)_chartView;
	_chartView.descriptionText = @"";
	_chartView.noDataTextDescription = @"";
	
	_chartView.highlightEnabled = YES;
	_chartView.dragEnabled = YES;
	[_chartView setScaleEnabled:YES];
	_chartView.pinchZoomEnabled = NO;
	_chartView.drawGridBackgroundEnabled = NO;
	
	
	_chartView.leftAxis.enabled = NO;
	_chartView.rightAxis.enabled = NO;
	
	_chartView.legend.enabled = NO;
	
	
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setMaximumFractionDigits:0];
	[_chartView setValueFormatter:numberFormatter];
	
	[_chartView animateWithXAxisDuration:1.0 yAxisDuration:1.0];
	NSMutableArray *xVals = [[NSMutableArray alloc] init];
	NSMutableArray *yVals1 = [[NSMutableArray alloc] init];
	
    
    int maxint=0;
    int todayspost=0;
    for (int i = 0; i < _communityData.count; i++) {
        NSDictionary *obj = [_communityData objectAtIndex:i];
        if (i == 0) {
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            NSString *monthName = [[df monthSymbols] objectAtIndex:([[obj objectForKey:@"month"] intValue] - 1)];
            [xVals addObject:[NSString stringWithFormat:@"     %@ %@", monthName, [obj objectForKey:@"day"]]];
        }
        else {
            [xVals addObject:[NSString stringWithFormat:@"%@",  [obj objectForKey:@"day"]]];
        }
        int x=[[obj objectForKey:@"posts"] intValue];
        if(x>maxint)
            maxint=x;
        
        if(i==_communityData.count-1)
        {
            todayspost=x;
        }
        [yVals1 addObject:[[ChartDataEntry alloc] initWithValue:x xIndex:i]];
        
    }
    
    float yForCurrentDay=(float)todayspost/(float)maxint;
    
    
    
    if(IS_IPHONE_6P)
    {
        yForCurrentDay=_AxisHolder.frame.size.height-yForCurrentDay+33;

    }
    else if (IS_IPHONE_6)
    {
        yForCurrentDay=_AxisHolder.frame.size.height-yForCurrentDay-2;

    }
    else
    {
        yForCurrentDay=_AxisHolder.frame.size.height-yForCurrentDay-55;

    }

    [_toplabel setHidden:false];
    NSString* value=[NSString stringWithFormat:@"%d ー",maxint];
            _toplabel.text=value;
    [_currentlabel setHidden:true];

       if(  yForCurrentDay>15)
        {
            [_currentlabel setHidden:false];
            CGRect frame=_currentlabel.frame;
            frame.origin.y=yForCurrentDay;
            _currentlabel.frame=frame;
            NSString* value=[NSString stringWithFormat:@"%d ー",todayspost];
            _currentlabel.text=value;
        }
    //
//	for (int i = 0; i < _communityData.count; i++) {
//		NSDictionary *obj = [_communityData objectAtIndex:i];
//		if (i == 0) {
//			NSDateFormatter *df = [[NSDateFormatter alloc] init];
//			NSString *monthName = [[df monthSymbols] objectAtIndex:([[obj objectForKey:@"month"] intValue] - 1)];
//			[xVals addObject:[NSString stringWithFormat:@"     %@ %@", monthName, [obj objectForKey:@"day"]]];
//		}
//		else {
//			[xVals addObject:[[obj objectForKey:@"day"] stringValue]];
//		}
//		[yVals1 addObject:[[ChartDataEntry alloc] initWithValue:[[obj objectForKey:@"posts"] floatValue] xIndex:i]];
//	}
	
	LineChartDataSet *set1 = [[LineChartDataSet alloc] initWithYVals:yVals1 label:@""];
	set1.drawCubicEnabled = YES;
	set1.cubicIntensity = 0.8f;
	set1.drawCirclesEnabled = NO;
	set1.lineWidth = 2.f;
	
	set1.circleRadius = 7.f;
	
	set1.highlightColor = [UIColor colorWithRed:97 / 255.f green:196 / 255.f blue:173 / 255.f alpha:1.f];
	[set1 setColor:[UIColor colorWithRed:97 / 255.f green:196 / 255.f blue:173 / 255.f alpha:1.f]];
	set1.fillColor = [UIColor colorWithRed:129 / 255.f green:208 / 255.f blue:189 / 255.f alpha:1.f];
	[set1 setValueFormatter:numberFormatter];
	set1.fillAlpha = 8.f;
	set1.circleColors = @[[UIColor colorWithRed:97 / 255.f green:196 / 255.f blue:173 / 255.f alpha:1.f]];
	LineChartData *data = [[LineChartData alloc] initWithXVals:xVals dataSet:set1];
	[data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:7.f]];
	[data setDrawValues:NO];
	
	
	
	_chartView.data = data;
	
	for (LineChartDataSet *set in _chartView.data.dataSets) {
		set.drawFilledEnabled = !set.isDrawFilledEnabled;
	}
	for (LineChartDataSet *set in _chartView.data.dataSets) {
		set.drawCirclesEnabled = !set.isDrawCirclesEnabled;
	}
	int i = 0;
	for (LineChartDataSet *set in _chartView.data.dataSets) {
		set.drawCubicEnabled = !set.isDrawCubicEnabled;
		if (i % 2 == 0) {
			set.fillColor = [UIColor colorWithRed:129 / 255.f green:208 / 255.f blue:189 / 255.f alpha:1.f];
		}
		else {
			set.fillColor = [UIColor colorWithRed:97 / 255.f green:196 / 255.f blue:173 / 255.f alpha:1.f];
		}
		i++;
	}
	
	ChartXAxis *xAxis = _chartView.xAxis;
	xAxis.labelPosition = XAxisLabelPositionBottom;
	_chartView.xAxis.enabled = YES;
	[_chartView.xAxis setDrawAxisLineEnabled:false];
	[_chartView.xAxis setDrawGridLinesEnabled:false];
    [_chartView.xAxis setLabelTextColor:UIColorFromRGB(0x61c4ad)];

	[_chartView setNeedsDisplay];
}

- (NSUInteger)supportedInterfaceOrientations {
	return (UIInterfaceOrientationMaskPortrait);
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
}

- (void)viewDidAppear:(BOOL)animated {
}

/*
   #pragma mark - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
   }
 */
 
- (IBAction)closeFullScreen:(id)sender {
	[self dismissViewControllerAnimated:true completion:NULL];
}

@end
