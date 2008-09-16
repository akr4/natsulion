#import <Cocoa/Cocoa.h>
#import "NTLNMainWindowController.h"
#import "NTLNWelcomeWindowController.h"
#import "NTLNGrowlNotifier.h"
#import "CTBadge.h"

@class NTLNPreferencesWindowController;

@class NTLNMultiTasksProgressIndicator;

@interface NTLNAppController : NSObject<NTLNWelcomeWindowCallback, NTLNGrowlClickCallbackTarget, TwitterTimelineCallback, TwitterPostCallback, TwitterFavoriteCallback> {
    IBOutlet NTLNMainWindowController *mainWindowController;
    IBOutlet NTLNPreferencesWindowController *preferencesWindowController;
    IBOutlet NTLNWelcomeWindowController *welcomeWindowController;
    IBOutlet NSArrayController *messageViewControllerArrayController;
    IBOutlet NTLNMessageListViewsController *messageListViewsController;
    IBOutlet NTLNMultiTasksProgressIndicator *progressIndicator; // should be hold by MainWindowController?
   
    int _refreshInterval;
    int _refreshCount;
    NSTimer *_refreshTimer;
    int _numberOfUnreadMessage;

    Twitter *_twitter;
    BOOL _createFavoriteIsWorking;
    NTLNErrorMessageViewController *_lastErrorMessage;
    NTLNBufferedMessageNotifier *_messageNotifier;

    CTBadge *_badge;
    
    BOOL _growlEnabled;
    NTLNGrowlNotifier *_growl;

                
                
    // statistics
    NSMutableArray *_messageCountHistory;
    long _numberOfPostedMessages;
}

- (IBAction) showPreferencesSheet:(id)sender;
- (IBAction) closePreferencesSheet:(id)sender;

- (int) refreshInterval;
- (void) setRefreshInterval:(int)interval;
- (void) startTimer;
- (void) stopTimer;
- (void) setIconImageToNormal;
- (void) setIconImageForError;
- (void) markAsRead:(NSString*)statusId;

- (void) updateStatus;
- (void) updateReplies;
- (void) updateSentMessages;
- (void) updateDirectMessages;
- (void) createFavoriteFor:(NSString*)statusId;
- (void) destroyFavoriteFor:(NSString*)statusId;
- (void) sendMessage:(NSString*)message;

- (BOOL) isCreatingFavoriteWorking;
@end
