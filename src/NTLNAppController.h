#import <Cocoa/Cocoa.h>
#import "NTLNMainWindowController.h"
#import "NTLNWelcomeWindowController.h"
#import "NTLNGrowlNotifier.h"
#import "CTBadge.h"

@class NTLNPreferencesWindowController;

@interface NTLNAppController : NSObject<NTLNWelcomeWindowCallback> {
    IBOutlet NTLNMainWindowController *mainWindowController;
    IBOutlet NTLNPreferencesWindowController *preferencesWindowController;
    IBOutlet NTLNWelcomeWindowController *welcomeWindowController;
    IBOutlet NSArrayController *messageViewControllerArrayController;
    IBOutlet NTLNMessageListViewsController *messageListViewsController;
   
    int _refreshInterval;
    NSTimer *_refreshTimer;
    int _numberOfUnreadMessage;

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

@end
