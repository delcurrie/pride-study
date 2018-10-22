#import <Foundation/Foundation.h>

@interface R1EmitterSocialPermission : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) BOOL granted;

- (id) init;
- (id) initWithName:(NSString *) name granted:(BOOL) granted;

+ (R1EmitterSocialPermission *) socialPermissionWithName:(NSString *) name granted:(BOOL) granted;

@end
