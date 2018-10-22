#import <Foundation/Foundation.h>

@class R1Emitter, R1Push, R1LocationService, CLLocation;

@interface R1SDK : NSObject

@property(nonatomic, copy) NSString *applicationId;
@property(nonatomic, copy) NSString *clientKey; // Only for push

@property(nonatomic, copy) NSString *applicationUserId;

@property(nonatomic, assign) BOOL disableAllAdvertisingIds;

@property(nonatomic, assign) BOOL geofencingEnabled;
@property(nonatomic, assign) BOOL engageEnabled;

@property(nonatomic, assign) BOOL cookieMapping;

@property(nonatomic, copy) NSString *deferredDeeplinkScheme;

/*!
 The current user location.
 Use this variable only if your application already used location services.
 */
@property(nonatomic, copy) CLLocation *location;

+ (R1SDK *) sharedInstance;

@property (nonatomic, readonly) R1Emitter *emitter;
@property (nonatomic, readonly) R1Push    *push;
@property (nonatomic, readonly) R1LocationService *locationService;

- (void) startEmitter;
- (void) startPush;

- (void) start; // Start emitter and push

+ (NSString *) sha1:(NSString *) inputString;
+ (NSString *) md5:(NSString *) inputString;

@end
