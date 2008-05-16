//  Based on NTLNFilterController.h created by mootoh on 4/30/08.
//  Copyright 2008 mootoh. All rights reserved.

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
