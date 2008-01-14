#import <Cocoa/Cocoa.h>
#import "MessageViewController.h"
#import "Configuration.h"

@interface MessageTableViewController : NSObject {
    IBOutlet NSTableColumn *viewColumn;
    IBOutlet NSScrollView *scrollView;
    IBOutlet NSArrayController *messageViewControllerArrayController;
    IBOutlet Configuration *configuration;
    
    NSScroller *_verticalScroller;
}

- (void) newMessageArrived:(MessageViewController*)controller;
- (void) resize:(float)deltaHeight;
- (void) reloadTableView;

@end
