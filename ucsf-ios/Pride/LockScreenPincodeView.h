
#import <UIKit/UIKit.h>

@protocol JKLLockScreenPincodeViewDelegate;

IB_DESIGNABLE
@interface LockScreenPincodeView : UIView

@property (nonatomic, weak) IBOutlet id<JKLLockScreenPincodeViewDelegate> delegate;
@property (nonatomic, strong) IBInspectable UIColor * pincodeColor;
@property (nonatomic, unsafe_unretained) IBInspectable BOOL enabled;

- (void)initPincode;
- (void)appendingPincode:(NSString *)pincode;
- (void)removeLastPincode;
- (void)wasCompleted;

@end


@protocol JKLLockScreenPincodeViewDelegate<NSObject>
@required
- (void)lockScreenPincodeView:(LockScreenPincodeView *)lockScreenPincodeView pincode:(NSString *)pincode;
@end