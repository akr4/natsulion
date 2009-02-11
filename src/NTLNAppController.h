#import <Cocoa/Cocoa.h>
#import "NTLNMainWindowController.h"
#import "NTLNWelcomeWindowController.h"
#import "NTLNGrowlNotifier.h"
#import "CTBadge.h"

@class NTLNPreferencesWindowController;

@class NTLNMultiTasksProgressIndicator;

@interface NTLNAppController : NSObject<NTLNWelcomeWindowCallback, NTLNGrowlClickCallbackTarget, 
        TwitterTimelineCallback, TwitterPostCallback, TwitterFavoriteCallback, TwitterRateLimitStatusCallback> {
    IBOutlet NTLNMainWindowController *mainWindowController;
    IBOutlet NTLNPreferencesWindowController *preferencesWindowController;
    IBOutlet NTLNWelcomeWindowController *welcomeWindowController;
    IBOutlet NSMutableArray *messageViewControllerArray;
    IBOutlet NSArrayController *messageViewControllerArrayController;
    IBOutlet NTLNMessageListViewsController *messageListViewsController;
    IBOutlet NTLNMultiTasksProgressIndicator *progressIndicator; // should be hold by MainWindowController?

#pragma mark Timer
    int _refreshInterval;
    NSTimer *_friendsTimelineRefreshTimer;
    NSTimer *_repliesRefreshTimer;
    NSTimer *_directMessagesRefreshTimer;

#pragma mark Twitter
    Twitter *_twitter;
    BOOL _createFavoriteIsWorking;
    NTLNErrorMessageViewController *_lastErrorMessage;
    NTLNBufferedMessageNotifier *_messageNotifier;

#pragma mark Badge
    CTBadge *_badge;
    int _numberOfUnreadMessage;

#pragma mark Growl
    BOOL _growlEnabled;
    NTLNGrowlNotifier *_growl;

#pragma mark Statistics
    NSMutableArray *_messageCountHistory;
    long _numberOfPostedMessages;
}

- (IBAction) showPreferencesSheet:(id)sender;
- (IBAction) closePreferencesSheet:(id)sender;

- (int) refreshInterval;
- (void) setRefreshInterval:(int)interval;
- (void) restartTimer;
- (void) setIconImageToNormal;
- (void) setIconImageForError;
- (void) markAsRead:(NSString*)statusId;

- (void) updateStatus;
- (void) updateReplies;
- (void) updateSentMessages;
- (void) updateDirectMessages;
- (void) rateLimitStatus;
- (void) createFavoriteFor:(NSString*)statusId;
- (void) destroyFavoriteFor:(NSString*)statusId;
- (void) sendReplyMessage:(NSString*)message toStatusId:(NSString*)statusId;
- (void) sendMessage:(NSString*)message;

- (BOOL) isCreatingFavoriteWorking;

@end
