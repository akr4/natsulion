#import <Cocoa/Cocoa.h>
#import "Twitter.h"
#import "NTLNMessageTableViewController.h"
#import "NTLNGrowlNotifier.h"
#import "NTLNMessageInputTextField.h"
#import "NTLNMessageListViewsController.h"
#import "NTLNBufferedMessageNotifier.h"
#import "NTLNErrorMessageViewController.h"

@class NTLNAppController;
@class NTLNTextView;
@class NTLNFilterView;

@interface NTLNMainWindow : NSWindow {
}
@end

@protocol NTLNTimelineSortOrderChangeObserver
- (void) timelineSortOrderChangeObserverSortOrderChanged;
@end

@protocol NTLNMessageViewListener
- (void) replyDesiredFor:(NTLNMessage*)message;
- (float) viewWidth;
- (void) createFavoriteDesiredFor:(NSString*)statusId;
- (void) destroyFavoriteDesiredFor:(NSString*)statusId;
- (BOOL) isCreatingFavoriteWorking;
@end

// defined and used internally
@class NTLNMessageListViewsController;

@interface NTLNMainWindowController : NSWindowController <NTLNMessageViewListener, NTLNTimelineSortOrderChangeObserver, NTLNMessageInputTextFieldCallback> {
    IBOutlet NSWindow *mainWindow;
    IBOutlet NTLNMessageInputTextField *messageTextField;
    IBOutlet NSTextField *messageLengthLabel;
    IBOutlet NSArrayController *messageViewControllerArrayController;
    IBOutlet NTLNMessageTableViewController *messageTableViewController;
    IBOutlet NTLNMessageListViewsController *messageListViewsController;
    IBOutlet NSTextField *statisticsTextField;
    IBOutlet NSLevelIndicator *apiCountIndicator;
    IBOutlet NTLNFilterView *filterView;
    IBOutlet NTLNAppController *appController;
    
    NSResponder *_previousFirstResponder;
    NTLNTextView *_fieldEditor;
    
    // Menu & Toolbar
    IBOutlet NSMenu *viewMenu;
    IBOutlet NSMenuItem *refreshMenuItem;
    NSMutableDictionary *_toolbarItems;
    NSSegmentedControl *_messageViewSelector;
    NSMenuItem *_messageViewToolbarMenuItem;
}

- (IBAction) sendMessage:(id) sender;
- (IBAction) updateTimelineCorrespondsToView:(id)sender;
- (IBAction) markAllAsRead:(id)sender;
- (IBAction) openKeywordFilterView:(id)sender;
- (IBAction) openScreenNameFilterView:(id)sender;
- (IBAction) closeFilterView:(id)sender;
- (IBAction) replyToSelectedMessage:(id)sender;

- (void) showWindowToFront;
- (void) setFrameAutosaveName:(NSString*)name;

- (void) addMessageViewControllers:(NSArray*)controllers;

#pragma mark API count
- (void) setRateLimitStatusWithRemainingHits:(int)remainingHits hourlyLimit:(int)hourlyLimit resetTime:(NSDate*)resetTime;

#pragma mark Message input text field
- (void) resetAndFocusMessageTextField;

#pragma mark Message table view
- (void) reloadTableView;
@end
