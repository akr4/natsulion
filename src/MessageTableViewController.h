#import <Cocoa/Cocoa.h>
#import "Message.h"

@class MainWindowController;

@interface MessageTableViewController : NSObject {
    IBOutlet NSTableColumn *viewColumn;
    
    // TODO: currentlly used for accessing the array of the table data. This should be separated from a window controller.
    IBOutlet MainWindowController *mainWindowController;
}

- (void) reloadTableView;
- (void) scrollLineDown:(id)sender;
- (void) resize:(float)deltaHeight;
- (void) updateSelection;
@end
