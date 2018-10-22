//
//  JKLLockScreenViewController.m
//

#import "LockScreenViewController.h"

#import "LockScreenPincodeView.h"

#import <AudioToolbox/AudioToolbox.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import "UIColor+constants.h"
static const NSTimeInterval LSVSwipeAnimationDuration = 0.3f;
static const NSTimeInterval LSVDismissWaitingDuration = 0.4f;
static const NSTimeInterval LSVShakeAnimationDuration = 0.5f;

@interface LockScreenViewController()<JKLLockScreenPincodeViewDelegate> {
    
    NSString * _confirmPincode;
    LockScreenMode _prevLockScreenMode;
}

@property (nonatomic, weak) IBOutlet UILabel  * titleLabel;
@property (nonatomic, weak) IBOutlet UILabel  * subtitleLabel;
@property (nonatomic, weak) IBOutlet UIButton * cancelButton;
@property (nonatomic, weak) IBOutlet LockScreenPincodeView * pincodeView;

@end


@implementation LockScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_cancelButton setHidden:true];

    switch (_lockScreenMode) {
        case LockScreenModeVerification:
        case LockScreenModeNormal: {
            [_cancelButton setHidden:YES];
            [self lsv_updateTitle:NSLocalizedStringFromTable(@"Passcode",    @"JKLockScreen", nil)
                         subtitle:NSLocalizedStringFromTable(@"Enter your Passcode", @"JKLockScreen", nil)];
            
         
            
            break;
        }
        case LockScreenModeNew: {
            {
            [self lsv_updateTitle:NSLocalizedStringFromTable(@"Passcode",    @"JKLockScreen", nil)
                         subtitle:NSLocalizedStringFromTable(@"Enter a new Passcode", @"JKLockScreen", nil)];
            
       
                
            }
            break;
        }
        case LockScreenModeChange:
            [self lsv_updateTitle:NSLocalizedStringFromTable(@"New Passcode",    @"JKLockScreen", nil)
                         subtitle:NSLocalizedStringFromTable(@"Enter a New Passcode", @"JKLockScreen", nil)];
            break;
    }
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NULL
//                                                    message:@"Select a 4-digit passcode. Setting a passcode will help provide quick and secure access to this application."
//                                                   delegate:self
//                                          cancelButtonTitle:@"OK"
//                                          otherButtonTitles:nil];
//    [alert setTintColor:[UIColor primaryColor]];
//    
//    [alert show];
    }

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    BOOL isModeNormal = (_lockScreenMode == LockScreenModeNormal);
    if (isModeNormal && [_delegate respondsToSelector:@selector(allowTouchIDLockScreenViewController:)]) {
        if ([_dataSource allowTouchIDLockScreenViewController:self]) {
            [self lsv_policyDeviceOwnerAuthentication];
        }
    }
    
    if(_lockScreenMode==LockScreenModeNew)
    {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Select a 4-digit passcode. Setting a passcode will help provide quick and secure access to this application." message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    
    // Create the "OK" button.
    NSString *okTitle = NSLocalizedString(@"OK", nil);
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }];
    
    [alertController addAction:okAction];
    

    // Present the alert controller.
    [self presentViewController:alertController animated:YES completion:nil];
    }

}


- (void)lsv_policyDeviceOwnerAuthentication {
    
    NSError   * error   = nil;
    LAContext * context = [[LAContext alloc] init];
    
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                localizedReason:NSLocalizedStringFromTable(@"Please authenticate with Touch ID", @"JKLockScreen", nil)
                          reply:^(BOOL success, NSError * authenticationError) {
                              if (success) {
                                  [self lsv_unlockDelayDismissViewController:LSVDismissWaitingDuration];
                              }
                              else {
                                  NSLog(@"LAContext::Authentication Error : %@", authenticationError);
                              }
                          }];
    }
    else {
        NSLog(@"LAContext::Policy Error : %@", [error localizedDescription]);
    }

}


- (void)lsv_unlockDelayDismissViewController:(NSTimeInterval)delay {
    __weak id weakSelf = self;
    
    [_pincodeView wasCompleted];
       dispatch_time_t delayInSeconds = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(delayInSeconds, dispatch_get_main_queue(), ^(void){
        [self dismissViewControllerAnimated:NO completion:^{
            if ([_delegate respondsToSelector:@selector(unlockWasSuccessfulLockScreenViewController:)]) {
                [_delegate unlockWasSuccessfulLockScreenViewController:weakSelf];
            }
        }];
    });
}


- (BOOL)lsv_isPincodeValid:(NSString *)pincode {
    if (_lockScreenMode == LockScreenModeVerification) {
        return [_confirmPincode isEqualToString:pincode];
    }
    
    return [_dataSource lockScreenViewController:self pincode:pincode];
}
- (void)lsv_updateTitle:(NSString *)title subtitle:(NSString *)subtitle {
    [_titleLabel    setText:title];
    [_subtitleLabel setText:subtitle];
}


- (void)lsv_unlockScreenSuccessful:(NSString *)pincode {
    [self dismissViewControllerAnimated:NO completion:^{
        if ([_delegate respondsToSelector:@selector(unlockWasSuccessfulLockScreenViewController:pincode:)]) {
            [_delegate unlockWasSuccessfulLockScreenViewController:self pincode:pincode];
        }
    }];
}


- (void)lsv_unlockScreenFailure {
    if (_lockScreenMode != LockScreenModeVerification) {
        if ([_delegate respondsToSelector:@selector(unlockWasFailureLockScreenViewController:)]) {
            [_delegate unlockWasFailureLockScreenViewController:self];
        }
    }
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    // make shake animation
    CAAnimation * shake = [self lsv_makeShakeAnimation];
    [_pincodeView.layer addAnimation:shake forKey:@"shake"];
    [_pincodeView setEnabled:NO];
    [_subtitleLabel setText:NSLocalizedStringFromTable(@"Passcode does not match", @"JKLockScreen", nil)];
    
    dispatch_time_t delayInSeconds = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(LSVShakeAnimationDuration * NSEC_PER_SEC));
    dispatch_after(delayInSeconds, dispatch_get_main_queue(), ^(void){
        [_pincodeView setEnabled:YES];
        [_pincodeView initPincode];
        
        switch (_lockScreenMode) {
            case LockScreenModeNormal:
            case LockScreenModeNew: {
                [self lsv_updateTitle:NSLocalizedStringFromTable(@"Passcode ",    @"JKLockScreen", nil)
                             subtitle:NSLocalizedStringFromTable(@"Passcode ", @"JKLockScreen", nil)];
                
                break;
            }
            case LockScreenModeChange:
                [self lsv_updateTitle:NSLocalizedStringFromTable(@"New Passcode ",    @"JKLockScreen", nil)
                             subtitle:NSLocalizedStringFromTable(@"New Passcode ", @"JKLockScreen", nil)];
                break;
            default:
                break;
        }
    });
}


- (CAAnimation *)lsv_makeShakeAnimation {
    
    CAKeyframeAnimation * shake = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    [shake setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    [shake setDuration:LSVShakeAnimationDuration];
    [shake setValues:@[ @(-20), @(20), @(-20), @(20), @(-10), @(10), @(-5), @(5), @(0) ]];
    
    return shake;
}


- (void)lsv_swipeSubtitleAndPincodeView {
    
    __weak UIView * weakView = self.view;
    __weak UIView * weakCode = _pincodeView;
    
    [(id)weakCode setEnabled:NO];
    
    CGFloat width = CGRectGetWidth([self view].bounds);
    NSLayoutConstraint * centerX = [self lsv_findLayoutConstraint:weakView  childView:_subtitleLabel attribute:NSLayoutAttributeCenterX];
    
    centerX.constant = width;
    [UIView animateWithDuration:LSVSwipeAnimationDuration animations:^{
        [weakView layoutIfNeeded];
    } completion:^(BOOL finished) {
        
        [(id)weakCode initPincode];
        centerX.constant = -width;
        [weakView layoutIfNeeded];
        
        centerX.constant = 0;
        [UIView animateWithDuration:LSVSwipeAnimationDuration animations:^{
            [weakView layoutIfNeeded];
        } completion:^(BOOL finished) {
            [(id)weakCode setEnabled:YES];
        }];
    }];
}

#pragma mark -
#pragma mark NSLayoutConstraint
- (NSLayoutConstraint *)lsv_findLayoutConstraint:(UIView *)superview childView:(UIView *)childView attribute:(NSLayoutAttribute)attribute {
    for (NSLayoutConstraint * constraint in superview.constraints) {
        if (constraint.firstItem == superview && constraint.secondItem == childView && constraint.firstAttribute == attribute) {
            return constraint;
        }
    }
    
    return nil;
}

#pragma mark -
#pragma mark IBAction
- (IBAction)onNumberClicked:(id)sender {
    
    NSInteger number = [sender tag];
    [_pincodeView appendingPincode:[@(number) description]];
}

- (IBAction)onCancelClicked:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(unlockWasCancelledLockScreenViewController:)]) {
        [_delegate unlockWasCancelledLockScreenViewController:self];
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)onDeleteClicked:(id)sender {
    
    [_pincodeView removeLastPincode];
}

#pragma mark -
#pragma mark JKLLockScreenPincodeViewDelegate
- (void)lockScreenPincodeView:(LockScreenPincodeView *)lockScreenPincodeView pincode:(NSString *)pincode {
    
    if (_lockScreenMode == LockScreenModeNormal) {
        if ([self lsv_isPincodeValid:pincode]) {
            [self lsv_unlockScreenSuccessful:pincode];
        }
        else {
            [self lsv_unlockScreenFailure];
        }
    } else if (_lockScreenMode == LockScreenModeVerification) {
        if ([self lsv_isPincodeValid:pincode]) {
            [self setLockScreenMode:_prevLockScreenMode];
            [self lsv_unlockScreenSuccessful:pincode];
        }
        else {
            [self setLockScreenMode:_prevLockScreenMode];
            [self lsv_unlockScreenFailure];
        }
    }
    else {
        _confirmPincode = pincode;
        _prevLockScreenMode = _lockScreenMode;
        [self setLockScreenMode:LockScreenModeVerification];
        
        [self lsv_updateTitle:NSLocalizedStringFromTable(@"Re-enter passcode",    @"JKLockScreen", nil)
                     subtitle:NSLocalizedStringFromTable(@"Re-enter your passcode", @"JKLockScreen", nil)];
        
        [self lsv_swipeSubtitleAndPincodeView];
    }
}

#pragma mark - 
#pragma mark LockScreenViewController Orientation
- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {

    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

@end
