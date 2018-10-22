#import <Foundation/Foundation.h>

@interface R1InboxMessage : NSObject

// Message id
@property (nonatomic, strong, readonly) NSString *messageId;

// Message alert
@property (nonatomic, strong, readonly) NSString *alert;

// Message title
@property (nonatomic, strong, readonly) NSString *title;

// Url which will be displayed
@property (nonatomic, strong, readonly) NSURL *contentUrl;

// Is Message unread
@property (nonatomic, readonly) BOOL unread;

// Is Inbox Message
@property (nonatomic, readonly) BOOL inbox;

// The date when message received
@property (nonatomic, strong, readonly) NSDate *createdDate;

// The date when message should be removed
@property (nonatomic, strong, readonly) NSDate *expirationDate;

// Other info????
@property (nonatomic, strong, readonly) NSDictionary *otherInfo;

@end
