#import "R1EmitterLineItem.h"
#import "R1EmitterUserInfo.h"
#import "R1EmitterSocialPermission.h"

@interface R1Emitter : NSObject

/*!
 The application name associated with this emitter. By default, this property is
 populated with the `CFBundleName` string from the application bundle. If you
 wish to override this property, you must do so before making any tracking
 calls.
 */
@property(nonatomic, copy) NSString *appName;

/*!
 The application identifier associated with this emitter. This should be set to
 the iTunes Connect application identifier assigned to your application. By
 default, this property is `nil`. If you wish to set this property, you must do
 so before making any tracking calls.
 
 Note that this is not your app's bundle id (e.g. com.example.appname), but the
 identifier used by the App Store.
 */
@property(nonatomic, copy) NSString *appId;

/*!
 The application version associated with this emitter. By default, this property
 is populated with the `CFBundleShortVersionString` string from the application
 bundle. If you wish to override this property, you must do so before making any
 tracking calls.
 */
@property(nonatomic, copy) NSString *appVersion;

/*!
 If true, indicates the start of a new session. Note that when a tracker is
 first instantiated, this is initialized to true. To prevent this default
 behavior, set this to `NO` when the tracker is first obtained.
 
 By itself, setting this does not send any data. If this is true, when the next
 tracking call is made, a parameter will be added to the resulting tracking
 information indicating that it is the start of a session, and this flag will be
 cleared.
 */
@property(nonatomic, assign) BOOL sessionStart __attribute__((deprecated));

/*!
 If non-negative, indicates how long, in seconds, the application must
 transition to the inactive or background state for before the tracker will
 automatically indicate the start of a new session when the app becomes active
 again by setting sessionStart to true. For example, if this is set to 30
 seconds, and the user receives a phone call that lasts for 45 seconds while
 using the app, upon returning to the app, the sessionStart parameter will be
 set to true. If the phone call instead lasted 10 seconds, sessionStart will not
 be modified.
 
 To disable automatic session tracking, set this to a negative value. To
 indicate the start of a session anytime the app becomes inactive or
 backgrounded, set this to zero.
 
 By default, this is 30 seconds.
 */
@property(nonatomic, assign) NSTimeInterval sessionTimeout;

+ (instancetype) sharedInstance;

@property (nonatomic, readonly) BOOL isStarted;

- (void) start;

- (void) emitEvent:(NSString *) eventName;
- (void) emitEvent:(NSString *) eventName
    withParameters:(NSDictionary *) parameters;

- (void) emitAction:(NSString *) action
              label:(NSString *) label
              value:(int64_t) value
          otherInfo:(NSDictionary *) otherInfo __attribute__((deprecated));

- (void) emitUserInfo:(R1EmitterUserInfo *) userInfo
            otherInfo:(NSDictionary *) otherInfo;

- (void) emitLoginWithUserID:(NSString *) userID
                    userName:(NSString *) userName
                   otherInfo:(NSDictionary *) otherInfo;

- (void) emitRegistrationWithUserID:(NSString *) userID
                           userName:(NSString *) userName
                            country:(NSString *) country
                              state:(NSString *) state
                               city:(NSString *) city
                          otherInfo:(NSDictionary *) otherInfo;

- (void) emitFBConnectWithPermissions:(NSArray *) permissions
                            otherInfo:(NSDictionary *) otherInfo;

- (void) emitTConnectWithUserID:(NSString *) userID
                       userName:(NSString *) userName
                    permissions:(NSArray *) permissions
                      otherInfo:(NSDictionary *) otherInfo;

- (void) emitTransactionWithID:(NSString *) transactionID
                       storeID:(NSString *) storeID
                     storeName:(NSString *) storeName
                        cartID:(NSString *) cartID
                       orderID:(NSString *) orderID
                     totalSale:(double) totalSale
                      currency:(NSString *) currency
                 shippingCosts:(double) shippingCosts
                transactionTax:(double) transactionTax
                     otherInfo:(NSDictionary *) otherInfo;

- (void) emitTransactionItemWithTransactionID:(NSString *) transactionID
                                     lineItem:(R1EmitterLineItem *) lineItem
                                    otherInfo:(NSDictionary *) otherInfo;

- (void) emitCartCreateWithCartID:(NSString *) cartID
                        otherInfo:(NSDictionary *) otherInfo;

- (void) emitCartDeleteWithCartID:(NSString *) cartID
                        otherInfo:(NSDictionary *) otherInfo;

- (void) emitAddToCartWithCartID:(NSString *) cartID
                        lineItem:(R1EmitterLineItem *) lineItem
                       otherInfo:(NSDictionary *) otherInfo;

- (void) emitDeleteFromCartWithCartID:(NSString *) cartID
                             lineItem:(R1EmitterLineItem *) lineItem
                            otherInfo:(NSDictionary *) otherInfo;

- (void) emitUpgradeWithOtherInfo:(NSDictionary *) otherInfo;

- (void) emitTrialUpgradeWithOtherInfo:(NSDictionary *) otherInfo;

- (void) emitScreenViewWithDocumentTitle:(NSString *) documentTitle
                      contentDescription:(NSString *) contentDescription
                     documentLocationUrl:(NSString *) documentLocationUrl
                        documentHostName:(NSString *) documentHostName
                            documentPath:(NSString *) documentPath
                               otherInfo:(NSDictionary *) otherInfo;

@end
