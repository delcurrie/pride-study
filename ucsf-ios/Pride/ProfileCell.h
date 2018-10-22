//
//  ProfileCell.h
//  Pride
//
//  Created by Analog Republic on 6/9/15.
//  Copyright (c) 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *currentlyParticipatingLabel;
@property (weak, nonatomic) IBOutlet UILabel *prideStudyLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentStudy;
@property (weak, nonatomic) IBOutlet UIButton *userImag;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UILabel *userEmail;
@property (weak, nonatomic) IBOutlet UIButton *leaveStudy;
@property (weak, nonatomic) IBOutlet UITextField *birthDayField;
@property (weak, nonatomic) IBOutlet UITextField *heightField;
@property (weak, nonatomic) IBOutlet UIButton *weightField;
@property (weak, nonatomic) IBOutlet UILabel *biologicalSex;
@property (weak, nonatomic) IBOutlet UILabel *sexualOrientation;
@property (weak, nonatomic) IBOutlet UILabel *genderIdentity;
@property (weak, nonatomic) IBOutlet UITextField *autoLockField;
@property (weak, nonatomic) IBOutlet UIButton *privacyPolicy;
@property (weak, nonatomic) IBOutlet UIButton *permissions;
@property (weak, nonatomic) IBOutlet UIButton *changePasscode;
@property (weak, nonatomic) IBOutlet UIButton *reviewConsent;
@property (weak, nonatomic) IBOutlet UIButton *licenseInformation;

@property (weak, nonatomic) IBOutlet UIButton *btn_biologicalSex;
@property (weak, nonatomic) IBOutlet UIButton *btn_sexualOrientation;
@property (weak, nonatomic) IBOutlet UIButton *btn_genderIdentity;
@property (weak, nonatomic) IBOutlet UIButton *btn_sexualOrientationNext;
@property (weak, nonatomic) IBOutlet UIButton *btn_genderIdentityNext;

@property (weak, nonatomic) IBOutlet UIButton *sharingOptions;
@end
