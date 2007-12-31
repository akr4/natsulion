#import <Cocoa/Cocoa.h>
#import "Message.h"

@interface MessageTableViewController : NSObject {
    IBOutlet NSTableColumn *viewColumn;
    IBOutlet NSScrollView *scrollView;
    IBOutlet NSArrayController *messageViewControllerArrayController;
    
    NSScroller *_verticalScroller;
}

- (void) newMessageArrived;
- (void) resize:(float)deltaHeight;

@end
