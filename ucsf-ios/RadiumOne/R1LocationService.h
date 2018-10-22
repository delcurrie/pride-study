#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef enum
{
    R1LocationServiceStateDisabled,
    R1LocationServiceStateOff,
    R1LocationServiceStateSearching,
    R1LocationServiceStateHasLocation,
    R1LocationServiceStateWaitNextUpdate
} R1LocationServiceState;

@interface R1LocationService : NSObject

@property (nonatomic, assign) BOOL enabled;

/*!
 By default, this is 600 seconds.
 This value can not be small then 60 seconds.
 */
@property (nonatomic, assign) NSTimeInterval autoupdateTimeout;

@property (nonatomic, readonly) CLLocation *lastLocation;
@property (nonatomic, readonly) R1LocationServiceState state;

@property (nonatomic, readonly) BOOL locationServiceEnabled;
@property (nonatomic, readonly) CLAuthorizationStatus locationServiceAuthorizationStatus;

- (void) updateNow;

@end
