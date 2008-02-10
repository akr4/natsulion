#import <Cocoa/Cocoa.h>
#import <PSMTabBarControl/PSMTabBarControl.h>
#import "Twitter.h"
#import "NTLNMessageTableViewController.h"
#import "NTLNGrowlNotifier.h"
#import "NTLNMessageInputTextField.h"
#import "NTLNMessageListViewsController.h"

@protocol NTLNTimelineSortOrderChangeObserver
- (void) timelineSortOrderChangeObserverSortOrderChanged;
@end

@protocol NTLNMessageViewListener
- (void) replyDesiredFor:(NSString*)username;
- (float) viewWidth;
- (void) createFavoriteDesiredFor:(NSString*)statusId;
- (BOOL) isCreatingFavoriteWorking;
@end

// defined and used internally
@class NTLNMessageListViewsController;

@interface NTLNMainWindowController : NSWindowController <NTLNMessageViewListener, NTLNTimelineSortOrderChangeObserver, TwitterTimelineCallback, TwitterPostCallback, TwitterFavoriteCallback, NTLNMessageInputTextFieldCallback> {
    IBOutlet NSWindow *mainWindow;
    IBOutlet NSProgressIndicator *downloadProgress;
    IBOutlet NSProgressIndicator *postProgress;
    IBOutlet NTLNMessageInputTextField *messageTextField;
    IBOutlet NSTextField *statusTextField;
    IBOutlet NSArrayController *messageViewControllerArrayController;
    IBOutlet NTLNMessageTableViewController *messageTableViewController;
    IBOutlet NSSegmentedControl *messageViewSelector;
    IBOutlet NTLNMessageListViewsController *messageListViewsController;
    
    Twitter *_twitter;
    NTLNGrowlNotifier *_growl;
    
    // TODO: is it better AppController has this instance instead of MainWindowController?
    // timing after launched
    NSTimer *_afterLaunchedTimer;

    BOOL _growlEnabled;
    BOOL _createFavoriteIsWorking;
    NSMutableDictionary *_toolbarItems;
    
    NTLNMessageListViewsController *_viewsController;
}

- (IBAction) sendMessage:(id) sender;

- (void) showWindowToFront;
- (void) setFrameAutosaveName:(NSString*)name;
- (void) updateReplies;

@end
