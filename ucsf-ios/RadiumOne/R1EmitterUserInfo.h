#import <Foundation/Foundation.h>

@interface R1EmitterUserInfo : NSObject

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *streetAddress;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *state;
@property (nonatomic, copy) NSString *zip;

+ (instancetype) userInfoWithUserID:(NSString *) userID;
+ (instancetype) userInfoWithUserID:(NSString *) userID
                           userName:(NSString *) userName;
+ (instancetype) userInfoWithUserID:(NSString *) userID
                           userName:(NSString *) userName
                              email:(NSString *) email
                          firstName:(NSString *) firstName
                           lastName:(NSString *) lastName
                      streetAddress:(NSString *) streetAddress
                              phone:(NSString *) phone
                               city:(NSString *) city
                              state:(NSString *) state
                                zip:(NSString *) zip;
@end
