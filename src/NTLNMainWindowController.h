#import <Cocoa/Cocoa.h>
#import <PSMTabBarControl/PSMTabBarControl.h>
#import "Twitter.h"
#import "NTLNMessageTableViewController.h"
#import "NTLNGrowlNotifier.h"
#import "NTLNMessageInputTextField.h"

@protocol NTLNTimelineSortOrderChangeObserver
- (void) timelineSortOrderChangeObserverSortOrderChanged;
@end

@protocol NTLNMessageViewListener
- (void) replyDesiredFor:(NSString*)username;
- (float) viewWidth;
- (void) createFavoriteDesiredFor:(NSString*)statusId;
- (BOOL) isCreatingFavoriteWorking;
@end

@interface NTLNMainWindowController : NSWindowController <NTLNMessageViewListener, NTLNTimelineSortOrderChangeObserver, TwitterTimelineCallback, TwitterPostCallback, TwitterFavoriteCallback, NTLNMessageInputTextFieldCallback> {
    IBOutlet NSWindow *mainWindow;
    IBOutlet NSProgressIndicator *downloadProgress;
    IBOutlet NSProgressIndicator *postProgress;
    IBOutlet NTLNMessageInputTextField *messageTextField;
    IBOutlet NSTextField *statusTextField;
    IBOutlet NSArrayController *messageViewControllerArrayController;
    IBOutlet NTLNMessageTableViewController *messageTableViewController;
    IBOutlet NSSegmentedControl *messageFilterSelector;
    
    Twitter *_twitter;
    NTLNGrowlNotifier *_growl;
    
    // TODO: is it better AppController has this instance instead of MainWindowController?
    // timing after launched
    NSTimer *_afterLaunchedTimer;
    BOOL _growlEnabled;
    BOOL _createFavoriteIsWorking;
    NSPredicate *_predicate;
    NSMutableDictionary *_toolbarItems;
}

- (IBAction) sendMessage:(id) sender;
- (IBAction) changeView:(id) sender;

- (void) showWindowToFront;
- (void) setFrameAutosaveName:(NSString*)name;
- (void) updateReplies;

@end
