// Based on NTLNFilterController.m created by mootoh on 4/30/08.
// http://blog.deadbeaf.org/2008/05/01/hack-natsulion-to-filter-messages/

#import <Cocoa/Cocoa.h>
#import "NTLNMessageListViewsController.h"
#import "NTLNMessageTableViewController.h"

@interface NTLNKeywordSearchField : NSSearchField {
    
}

- (void) setupColors;
@end

@interface NTLNKeywordFilterView : NSView {
    IBOutlet NTLNKeywordSearchField *searchTextField;
    IBOutlet NTLNMessageListViewsController *messageListViewsController;
    IBOutlet NTLNMessageTableViewController *messageTableViewController;
    
    BOOL _opened;
}

- (IBAction) filter:(id)sender;
- (float) defaultHeight;
- (BOOL) opened;
- (void) postOpen;
- (void) postClose;

@end
