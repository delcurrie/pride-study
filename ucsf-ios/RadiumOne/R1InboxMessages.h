#import <Foundation/Foundation.h>
#import "R1InboxMessage.h"

@protocol R1InboxMessagesDelegate;

enum {
    R1InboxMessagesChangeInsert = 1,
    R1InboxMessagesChangeDelete = 2,
    R1InboxMessagesChangeMove = 3,
    R1InboxMessagesChangeUpdate = 4
};
typedef NSUInteger R1InboxMessagesChangeType;

@interface R1InboxMessages : NSObject

// The list of messages
@property (nonatomic, strong, readonly) NSArray *messages;

// Total messages count
@property (nonatomic, readonly) NSUInteger messagesCount;
// Unread messages count
@property (nonatomic, readonly) NSUInteger unreadMessagesCount;

// Add and remove delegate
- (void) addDelegate:(id<R1InboxMessagesDelegate>) delegate;
- (void) removeDelegate:(id<R1InboxMessagesDelegate>) delegate;

// Find message by id. Return nil if message not found
- (R1InboxMessage *) getMessageWithId:(NSString *) messageId;

// Mark message as read.
- (void) markMessageAsRead:(R1InboxMessage *) message;
// Delete message
- (void) deleteMessage:(R1InboxMessage *) message;

@end

@protocol R1InboxMessagesDelegate <NSObject>

@optional

// Used for displaying table with inbox messages
// Called before messages array will be updated.
- (void) inboxMessagesWillChanged;
// Called for each inserted/removed/moved/updated message
- (void) inboxMessagesDidChangeMessage:(R1InboxMessage *) inboxMessage
                               atIndex:(NSUInteger) index
                         forChangeType:(R1InboxMessagesChangeType)changeType
                              newIndex:(NSUInteger) newIndex;
// Called after updating messages array
- (void) inboxMessagesDidChanged;

// Called when message marked as read
- (void) inboxMessageMarkedAsRead:(R1InboxMessage *) inboxMessage;
// Called when message removed
- (void) inboxMessageDeleted:(R1InboxMessage *) inboxMessage;

// Called when unread messages count changed
- (void) inboxMessageUnreadCountChanged;

@end
