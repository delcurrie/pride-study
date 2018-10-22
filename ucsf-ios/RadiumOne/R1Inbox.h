#import <Foundation/Foundation.h>
#import "R1InboxMessages.h"
#import "R1WebCommand.h"

typedef void (^R1InboxUpdateDidFinishedBlock)(NSError *error);

@protocol R1InboxDelegate;

@interface R1Inbox : NSObject

// Singleton
+ (instancetype) sharedInstance;

// The list of messages
@property (nonatomic, strong, readonly) R1InboxMessages *messages;

// Delegate
@property (nonatomic, assign) id<R1InboxDelegate> delegate;

// Update message list
- (void) updateMessages:(R1InboxUpdateDidFinishedBlock) didFinished;

@property (nonatomic, assign, readonly) BOOL updateInProgress;

// Show WebView with message
- (void) showMessage:(R1InboxMessage *) message messageDidShow:(void (^)(void)) messageDidShow;
- (void) showMessageWithId:(NSString *) messageId messageDidShow:(void (^)(void)) messageDidShow;

- (void) closeActiveMessageAnimated:(BOOL) animated;

@end

@protocol R1InboxDelegate <NSObject>

@optional
// Delegate method which will be called when messages update will be finished
// All right if error == nil
- (void) inboxMessagesUpdatedWithError:(NSError *) error;

// Delegate method which will be called when message received when application in foreground
// If developer implement this method and return YES in it new message alert will be shown automatically.
- (BOOL) applicationReceivedInboxMessage:(R1InboxMessage *) message;
// Delegate method which will be called when message received when application in background and user will click by push.
// If developer implement this method and return YES in it new message will be shown automatically.
- (BOOL) applicationOpenedWithInboxMessage:(R1InboxMessage *) message;

- (void) handleWebCommand:(R1WebCommand *) webCommand;

@end
