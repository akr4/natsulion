#import "MessageTableViewController.h"
#import "MainWindowController.h"
#import "CustomViewCell.h"
#import "TwitterStatusViewController.h"

@implementation MessageTableViewController

- (void) awakeFromNib {
    [viewColumn setDataCell:[[[CustomViewCell alloc] init] autorelease]];
}

- (void) dealloc {
    [super dealloc];
}

- (void) selectedRowIndexes:(NSIndexSet*)indexSet {
//    NSLog(@"%s", __PRETTY_FUNCTION__);    
    int i;
    for (i = 0; i < [[mainWindowController messageViewControllerArray] count]; i++) {
        if ([indexSet containsIndex:i]) {
            [[[mainWindowController messageViewControllerArray] objectAtIndex:i] highlight];
        } else {
            [[[mainWindowController messageViewControllerArray] objectAtIndex:i] lowlight];
        }
    }
}

- (void) updateSelection {
    [self selectedRowIndexes:[[viewColumn tableView] selectedRowIndexes]];
}


- (void) resize:(float)deltaHeight {
    NSView *scrollView = [[[viewColumn tableView] superview] superview];
    NSRect frame = [scrollView frame];
    frame.size.height += deltaHeight;
    frame.origin.y -= deltaHeight;
    [scrollView setFrame:frame];
}


// NSTableView datasource method ///////////////////////////////////////////////
- (int)numberOfRowsInTableView:(NSTableView *)aTableView {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
    return [[mainWindowController messageViewControllerArray] count];
}

- (id)tableView:(NSTableView *)aTableView 
            objectValueForTableColumn:(NSTableColumn *)aTableColumn
            row:(int)rowIndex {
    return @"";
}

// NSTableView delegate method /////////////////////////////////////////////////
- (void)tableViewSelectionIsChanging:(NSNotification *)aNotification {
//    NSLog(@"MessageTableViewController#tableViewSelectionIsChanging[%@]", [aNotification description]);
    [self updateSelection];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
//    NSLog(@"MessageTableViewController#tableViewSelectionDidChange[%@]", [aNotification description]);
//    NSLog(@"selectedRow:%d", [[viewColumn tableView] selectedRow]);
    [self updateSelection];
}

- (void) tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(int)row {
    TwitterStatusViewController *controller = [[mainWindowController messageViewControllerArray] objectAtIndex:row];
    [(CustomViewCell*)cell addView:[controller view]];
}

// for display custom view /////////////////////////////////////////////////////
- (void) reloadTableView {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
    while ([[[viewColumn tableView] subviews] count] > 0) {
        [[[[viewColumn tableView] subviews] lastObject] removeFromSuperviewWithoutNeedingDisplay];
    }
    [self updateSelection];
    [[viewColumn tableView] reloadData];
}

- (void) scrollLineDown:(id)sender {
    NSLog(@"MessageTableViewController#scrollLineDown");
    [[viewColumn tableView] scrollLineDown:sender];
}

@end
