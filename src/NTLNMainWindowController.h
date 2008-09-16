#import <Cocoa/Cocoa.h>
#import "Twitter.h"
#import "NTLNMessageTableViewController.h"
#import "NTLNGrowlNotifier.h"
#import "NTLNMessageInputTextField.h"
#import "NTLNMessageListViewsController.h"
#import "NTLNBufferedMessageNotifier.h"
#import "NTLNErrorMessageViewController.h"
#import "NTLNKeywordFilterView.h"

#define NTLN_STATISTICS_CALCULATION_PERIOD_MULTIPLIER 3.0f

@class NTLNAppController;
@class NTLNTextView;

@interface NTLNMainWindow : NSWindow {
}
@end

@protocol NTLNTimelineSortOrderChangeObserver
- (void) timelineSortOrderChangeObserverSortOrderChanged;
@end

@protocol NTLNMessageViewListener
- (void) replyDesiredFor:(NSString*)username;
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
    IBOutlet NSTextField *statusTextField;
    IBOutlet NSArrayController *messageViewControllerArrayController;
    IBOutlet NSMutableArray *messageViewControllerArray;
    IBOutlet NTLNMessageTableViewController *messageTableViewController;
    IBOutlet NTLNMessageListViewsController *messageListViewsController;
    IBOutlet NSTextField *statisticsTextField;
    IBOutlet NSLevelIndicator *messagePostLevelIndicator;
    IBOutlet NTLNKeywordFilterView *keywordFilterView;
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
- (IBAction) closeKeywordFilterView:(id)sender;

- (void) showWindowToFront;
- (void) setFrameAutosaveName:(NSString*)name;

- (void) setMessageStatisticsField:(NSString*)value;
- (void) setMessagePostLevel:(float)level;

- (void) addMessageViewControllers:(NSArray*)controllers;

#pragma Message input text field
- (void) resetAndFocusMessageTextField;

#pragma Message table view
- (void) reloadTableView;
@end
