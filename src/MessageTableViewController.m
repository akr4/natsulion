#import "MessageTableViewController.h"
#import "CustomViewCell.h"
#import "TwitterStatusViewController.h"
#import "Configuration.h"

@implementation MessageTableViewController

- (void) awakeFromNib {
    [viewColumn setDataCell:[[[CustomViewCell alloc] init] autorelease]];
    _verticalScroller = [[scrollView verticalScroller] retain];

    [[viewColumn tableView] setIntercellSpacing:NSMakeSize(0, 0)];

    _autoscrollMinLimit = 1.0;
    _cumulativeDeltaHeight = 0.0;
    
    [self bind:@"changeExpandMode"
      toObject:[NSUserDefaultsController sharedUserDefaultsController] 
   withKeyPath:@"values.alwaysExpandMessarage"
       options:nil];
}

- (void) dealloc {
    [_verticalScroller release];
    [super dealloc];
}

// for display custom view /////////////////////////////////////////////////////
- (void) selectedRowIndexes:(NSIndexSet*)indexSet {
    for (int i = 0; i < [[messageViewControllerArrayController arrangedObjects] count]; i++) {
        if ([indexSet containsIndex:i]) {
            [[[messageViewControllerArrayController arrangedObjects] objectAtIndex:i] highlight];
        } else {
            [[[messageViewControllerArrayController arrangedObjects] objectAtIndex:i] unhighlight];
        }
    }
}

- (void) updateSelection {
    [self selectedRowIndexes:[[viewColumn tableView] selectedRowIndexes]];
    if (![[Configuration instance] alwaysExpandMessage]) {
        [[viewColumn tableView] noteHeightOfRowsWithIndexesChanged:[[viewColumn tableView] selectedRowIndexes]];
    }
}

- (void) recluculateViewSizes {
    for (MessageViewController *c in [messageViewControllerArrayController arrangedObjects]) {
        [c markNeedCalculateHeight];
    }
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

- (void) scrollDownInDescendingOrder:(MessageViewController*)controller {
    if ([_verticalScroller floatValue] == 0.0) {
        return;
    }

    NSPoint targetPoint = NSMakePoint(0, [[[viewColumn tableView] superview] bounds].origin.y + [[controller view] bounds].size.height);
    [[viewColumn tableView] scrollPoint:targetPoint];
}

- (void) scrollDownInAscendingOrder:(MessageViewController*)controller {
    if ([_verticalScroller floatValue] < _autoscrollMinLimit) {
        return;
    }
    
    NSPoint targetPoint = NSMakePoint(0, [[[viewColumn tableView] superview] bounds].origin.y + [[controller view] bounds].size.height);
    [[viewColumn tableView] scrollPoint:targetPoint];
}

- (void) newMessageArrived:(MessageViewController*)controller {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//    float newestMessageHeight = [controller requiredHeight];
//    NSLog(@"newestMessageHeight: %f - %@", newestMessageHeight, [[controller message] text]);

    [self reloadTableView];
    
    if ([[Configuration instance] timelineSortOrder] == NTLN_CONFIGURATION_TIMELINE_SORT_ORDER_DESCENDING) {
        [self selectionDown];
        [self scrollDownInDescendingOrder:controller];
    } else {
        [self scrollDownInAscendingOrder:controller];
    }
}

- (void) resize:(float)deltaHeight {
    float originalKnobPosition = [_verticalScroller floatValue];
    
    NSRect frame = [scrollView frame];
    frame.size.height += deltaHeight;
    frame.origin.y -= deltaHeight;
    [scrollView setFrame:frame];

    if ([[Configuration instance] timelineSortOrder] == NTLN_CONFIGURATION_TIMELINE_SORT_ORDER_ASCENDING
        && originalKnobPosition >= _autoscrollMinLimit) {
        _autoscrollMinLimit = [_verticalScroller floatValue];
    }
}

- (float) columnWidth {
    return [viewColumn width];
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

// Configuration change makes below method call //////////////////////////////////////////////////////////////////////////////
- (void) setChangeExpandMode:(BOOL)mode {
    [self recluculateViewSizes];
    [self reloadTableView];
}

- (BOOL) changeExpandMode {
    return TRUE;
}

@end
