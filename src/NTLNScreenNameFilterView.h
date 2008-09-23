#import <Cocoa/Cocoa.h>
#import "NTLNFilterView.h"

@class NTLNMessageListViewsController;
@class NTLNMessageTableViewController;

@interface NTLNScreenNameSearchField : NSTokenField {
    
}

- (void) setupColors;
@end

@interface NTLNScreenNameFilterView : NSView<NTLNFilterViewContent> {
    IBOutlet NTLNScreenNameSearchField *searchTextField;
    IBOutlet NTLNMessageListViewsController *messageListViewsController;
    IBOutlet NTLNMessageTableViewController *messageTableViewController;
}

- (IBAction) filter:(id)sendar;
- (void) filter;
- (void) filterByQuery:(id)query;
- (void) postOpen;
- (void) postClose;

@end
