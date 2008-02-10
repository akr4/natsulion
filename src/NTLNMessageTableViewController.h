#import <Cocoa/Cocoa.h>
#import "NTLNMessageViewController.h"

@interface NTLNMessageTableView : NSTableView {
}
@end

@interface NTLNMessageTableViewController : NSObject {
    IBOutlet NSTableColumn *viewColumn;
    IBOutlet NSScrollView *scrollView;
    IBOutlet NSArrayController *messageViewControllerArrayController;

    NSScroller *_verticalScroller;
    
    // in the case of ascending sort order, some text are input and then the height is shrinked,
    // the scroll knob position will be changed to smarller value (for example 1.0 -> 0.987)
    // That turns autoscroll off which is not desired.
    // This variable is used to avoid that.
    float _autoscrollMinLimit;
    
    // for determining current text area height is the same as original.
    float _cumulativeDeltaHeight;
}

- (NSView*) viewForTabItem;
- (void) newMessageArrived:(NTLNMessageViewController*)controller;
- (void) resize:(float)deltaHeight;
- (void) reloadTableView;
- (float) knobPosition;
- (void) setKnobPosition:(float)position;
- (float) columnWidth;
- (void) recalculateViewSizes;
- (void) reloadTimelineSortDescriptors;

@end
