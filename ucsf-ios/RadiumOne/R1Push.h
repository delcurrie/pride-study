#import <Foundation/Foundation.h>
#import "R1WebCommand.h"
#import "R1PushTags.h"
#import "R1LocationService.h"

@protocol R1PushDelegate;

@interface R1Push : NSObject

// Singleton
+ (instancetype) sharedInstance;

@property (nonatomic) BOOL pushEnabled;

@property (nonatomic, copy, readonly) NSString *deviceToken;

@property (nonatomic, strong, readonly) R1PushTags *tags;

@property (nonatomic, retain) NSTimeZone *timeZone;

@property (nonatomic, assign) NSUInteger badgeNumber;

@property (nonatomic, readonly) BOOL isStarted;

@property (nonatomic, assign) id<R1PushDelegate> delegate;

- (void) registerDeviceToken:(NSData *)token;
- (void) failToRegisterDeviceTokenWithError:(NSError *)error;

- (void) registerForRemoteNotificationTypes:(UIRemoteNotificationType)types;

- (void) handleNotification:(NSDictionary *)notification applicationState:(UIApplicationState)state;

- (void) start;

@end

@protocol R1PushDelegate <NSObject>

@optional

- (void) handleForegroundNotification:(NSDictionary *)notification;
- (void) handleBackgroundNotification:(NSDictionary *)notification;

@end