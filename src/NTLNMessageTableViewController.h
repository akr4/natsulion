#import <Cocoa/Cocoa.h>
#import "NTLNMessageViewController.h"
#import "NTLNMessageInputTextField.h"

@class NTLNMessageListViewsController;
@class NTLNMessageTableViewController;
@class NTLNMessage;

@interface NTLNMessageScrollView : NSScrollView {
    IBOutlet NSArrayController *messageViewControllerArrayController;
    IBOutlet NTLNMessageListViewsController *messageListViewsController;
    IBOutlet NTLNMessageTableViewController *messageTableViewController;
}
- (void)notifyExit;
- (void)notifyEnterExit;
@end

@interface NTLNMessageTableView : NSTableView {
}
@end

@interface NTLNMessageTableViewController : NSObject {
    IBOutlet NSTableColumn *viewColumn;
    IBOutlet NTLNMessageScrollView *scrollView;
    IBOutlet NSArrayController *messageViewControllerArrayController;
    IBOutlet NTLNMessageInputTextField *messageInputTextField;
    
    NSScroller *_verticalScroller;
    
    // in the case of ascending sort order, some text are input and then the height is shrinked,
    // the scroll knob position will be changed to smarller value (for example 1.0 -> 0.987)
    // That turns autoscroll off which is not desired.
    // This variable is used to avoid that.
    float _autoscrollMinLimit;
    
    float _knobPositionBeforeAddingMessage;
    
    // for determining current text area height is the same as original.
    float _cumulativeDeltaHeight;
    
    NTLNMessageViewController *_highlightedViewController;
}

- (NSView*) viewForTabItem;
- (void) newMessageArrived:(NSArray*)controllers;
- (void) resize:(float)deltaHeight;
- (void) resizeTop:(float)deltaHeight;
- (void) reloadTableView;
- (float) knobPosition;
- (void) setKnobPosition:(float)position;
- (float) columnWidth;
- (void) recalculateViewSizes;
- (void) reloadTimelineSortDescriptors;
- (void) nextMessage;
- (void) previousMessage;
- (NTLNMessage*) selectedMessage;
    
- (IBAction) makeSelectionsFavoraite:(id)sender;
- (IBAction) addSelectionsToReplyTo:(id)sender;

@end
