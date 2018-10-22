#import <Foundation/Foundation.h>

@interface R1PushTags : NSObject

@property (nonatomic, copy) NSArray *tags;

- (void) addTag:(NSString *) tag;

- (void) addTags:(NSArray *) tags;

- (void) removeTag:(NSString *) tag;

- (void) removeTags:(NSArray *) tags;

@end
