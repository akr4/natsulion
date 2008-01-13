#import "MessageTableViewController.h"
#import "CustomViewCell.h"
#import "TwitterStatusViewController.h"

@implementation MessageTableViewController

- (void) awakeFromNib {
    [viewColumn setDataCell:[[[CustomViewCell alloc] init] autorelease]];
    _verticalScroller = [[scrollView verticalScroller] retain];

    [self bind:@"changeExpandMode"
      toObject:[NSUserDefaultsController sharedUserDefaultsController] 
   withKeyPath:@"values.alwaysExpandMessage"
       options:nil];
}

- (void) dealloc {
    [_verticalScroller release];
    [super dealloc];
}

// for display custom view /////////////////////////////////////////////////////
- (void) selectedRowIndexes:(NSIndexSet*)indexSet {
    int i;
    for (i = 0; i < [[messageViewControllerArrayController arrangedObjects] count]; i++) {
        if ([indexSet containsIndex:i]) {
            [[[messageViewControllerArrayController arrangedObjects] objectAtIndex:i] highlight];
        } else {
            [[[messageViewControllerArrayController arrangedObjects] objectAtIndex:i] unhighlight];
        }
    }
}

- (void) updateSelection {
    [self selectedRowIndexes:[[viewColumn tableView] selectedRowIndexes]];
    [[viewColumn tableView] noteHeightOfRowsWithIndexesChanged:[[viewColumn tableView] selectedRowIndexes]];
}

- (void) reloadTableView {
    while ([[[viewColumn tableView] subviews] count] > 0) {
        [[[[viewColumn tableView] subviews] lastObject] removeFromSuperviewWithoutNeedingDisplay];
    }
    [[viewColumn tableView] reloadData];
    [self updateSelection];
}

- (void) selectionDown {
    NSIndexSet *target = [NSIndexSet indexSetWithIndex:[[[viewColumn tableView] selectedRowIndexes] firstIndex] + 1];
    [[viewColumn tableView] selectRowIndexes:target byExtendingSelection:FALSE];
}

- (void) scrollUpInDescendingOrder {
    NSRect bounds = [[[viewColumn tableView] superview] bounds];
    float newestMessageHeight = [[[messageViewControllerArrayController arrangedObjects] objectAtIndex:0] requiredHeight];
    NSLog(@"newestMessageHeight: %f - %@", newestMessageHeight, [[[[messageViewControllerArrayController arrangedObjects] objectAtIndex:0] status] text]);
    NSPoint targetPoint = NSMakePoint(0, bounds.origin.y - (newestMessageHeight + 2.0));
    [[viewColumn tableView] scrollPoint:targetPoint];
}

- (void) scrollDownInAscendingOrder {
    NSRect bounds = [[[viewColumn tableView] superview] bounds];
    float newestMessageHeight = [[[messageViewControllerArrayController arrangedObjects] lastObject] requiredHeight];

    NSLog(@"newestMessageHeight: %f - %@", newestMessageHeight, [[[[messageViewControllerArrayController arrangedObjects] lastObject] status] text]);
    NSPoint targetPoint = NSMakePoint(0, bounds.origin.y + newestMessageHeight + 2.0);
    [[viewColumn tableView] scrollPoint:targetPoint];
}

- (void) newMessageArrived {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self reloadTableView];
    
    if ([configuration timelineSortOrder] == NTLN_CONFIGURATION_TIMELINE_SORT_ORDER_DESCENDING) {
        [self selectionDown];
        [self scrollUpInDescendingOrder];
    } else {
        [self scrollDownInAscendingOrder];
    }
}

- (void) resize:(float)deltaHeight {
    NSRect frame = [scrollView frame];
    frame.size.height += deltaHeight;
    frame.origin.y -= deltaHeight;
    [scrollView setFrame:frame];
}


// NSTableView datasource method ///////////////////////////////////////////////
- (int)numberOfRowsInTableView:(NSTableView *)aTableView {
    return [[messageViewControllerArrayController arrangedObjects] count];
}

- (id)tableView:(NSTableView *)aTableView 
            objectValueForTableColumn:(NSTableColumn *)aTableColumn
            row:(int)rowIndex {
    return @"";
}

// NSTableView delegate method /////////////////////////////////////////////////
- (void)tableViewSelectionIsChanging:(NSNotification *)aNotification {
    [self updateSelection];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    [self updateSelection];
}

- (void) tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(int)row {
    TwitterStatusViewController *controller = [[messageViewControllerArrayController arrangedObjects] objectAtIndex:row];
    [(CustomViewCell*)cell addView:[controller view]];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    TwitterStatusViewController *controller = [[messageViewControllerArrayController arrangedObjects] objectAtIndex:row];
//    NSLog(@"%s: %d - %f", __PRETTY_FUNCTION__, row, [controller requiredHeight]);
    return [controller requiredHeight];
}

// //////////////////////////////////////////////////////////////////////////////
- (void) setChangeExpandMode:(BOOL)mode {
    [self reloadTableView];
}

- (BOOL) changeExpandMode {
    return TRUE;
}



@end
