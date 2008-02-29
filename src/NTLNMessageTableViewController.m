#import "NTLNMessageTableViewController.h"
#import "NTLNCustomViewCell.h"
#import "TwitterStatusViewController.h"
#import "NTLNConfiguration.h"
#import "NTLNColors.h"
#import "NTLNMessageListViewsController.h"

@implementation NTLNMessageScrollView 
- (void)reflectScrolledClipView:(NSClipView *)aClipView {
    [super reflectScrolledClipView:aClipView];

    if ([messageListViewsController currentViewIndex] == 3) {
        return;
    }
    
    float viewYMin = [self documentVisibleRect].origin.y;
    float viewYMax = [self documentVisibleRect].origin.y + [self documentVisibleRect].size.height;
    float max = 0;
    for (int i = 0; i < [[messageViewControllerArrayController arrangedObjects] count]; i++) {
        TwitterStatusViewController *c = [[messageViewControllerArrayController arrangedObjects] objectAtIndex:i];
        float min = max;
        max += [c requiredHeight];
        if (viewYMax < max) {
            for (; i < [[messageViewControllerArrayController arrangedObjects] count]; i++) {
                TwitterStatusViewController *c = [[messageViewControllerArrayController arrangedObjects] objectAtIndex:i];
                [c exitFromScrollView];
            }
            break;
        }
        if (viewYMin <= min) { // viewYMin <= min < max < viewYMax
            [c enterInScrollView];
        } else { // min < viewMin
            [c exitFromScrollView];
        }
    }
//    NSLog(@"%f %f", [[scrollView contentView] documentVisibleRect].size.width, [[scrollView contentView] documentVisibleRect].size.height);
}
@end

@implementation NTLNMessageTableView

- (void) _highlightRow:(int) row clipRect:(NSRect) clip {
    [[[NTLNColors instance] colorForHighlightedBackground] set];
    NSRectFill([self rectOfRow:row]);
//    NSRectFillUsingOperation([self rectOfRow:row], NSCompositeCopy);
}

- (void) drawBackgroundInClipRect:(NSRect)clipRect {
	// make sure we do nothing so the drawRow method's drawing will take effect
}

- (void) drawRow:(int)row clipRect:(NSRect)rect {
	[super drawRow:row clipRect:rect];
    if ([self selectedRow] != row) {
        [[[[NTLNColors instance] controlAlternatingRowBackgroundColors] objectAtIndex:(row % 2)] set];
        NSRectFillUsingOperation([self rectOfRow:row], NSCompositeCopy);
    }
}

@end

@implementation NTLNMessageTableViewController

- (void) awakeFromNib {
    [viewColumn setDataCell:[[[NTLNCustomViewCell alloc] init] autorelease]];
    _verticalScroller = [[scrollView verticalScroller] retain];

    [[viewColumn tableView] setIntercellSpacing:NSMakeSize(0, 0)];
    [[viewColumn tableView] setDataSource:self];
    [[viewColumn tableView] setDelegate:self];
    [[viewColumn tableView] setBackgroundColor:nil];
    
    [self reloadTimelineSortDescriptors];
    
    _autoscrollMinLimit = 1.0;
    _cumulativeDeltaHeight = 0.0;

    // add objservers
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(colorSchemeChanged:)
                                                 name:NTLN_NOTIFICATION_NAME_COLOR_SCHEME_CHANGED 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(windowAlphaChanged:)
                                                 name:NTLN_NOTIFICATION_NAME_WINDOW_ALPHA_CHANGED
                                               object:nil];
    
    // TODO
    [scrollView setBackgroundColor:[[NTLNColors instance] colorForBackground]];
}

- (void) dealloc {
    [_verticalScroller release];
    [messageViewControllerArrayController release];
    [super dealloc];
}


- (NSView*) viewForTabItem {
    return scrollView;
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
}

- (void) recalculateViewSizes {
    for (NTLNMessageViewController *c in [messageViewControllerArrayController arrangedObjects]) {
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

- (float) knobPosition {
    return [[[viewColumn tableView] superview] bounds].origin.y;
}

- (void) setKnobPosition:(float)position {
    [[viewColumn tableView] scrollPoint:NSMakePoint(0, position)];
}

- (void) selectionDown {
    NSIndexSet *target = [NSIndexSet indexSetWithIndex:[[[viewColumn tableView] selectedRowIndexes] firstIndex] + 1];
    [[viewColumn tableView] selectRowIndexes:target byExtendingSelection:FALSE];
}

- (void) scrollDownInDescendingOrder:(NTLNMessageViewController*)controller {
    if ([_verticalScroller floatValue] == 0.0) {
        return;
    }

    NSPoint targetPoint = NSMakePoint(0, [[[viewColumn tableView] superview] bounds].origin.y + [[controller view] bounds].size.height);
    [[viewColumn tableView] scrollPoint:targetPoint];
}

- (void) scrollDownInAscendingOrder:(NTLNMessageViewController*)controller {
    if ([_verticalScroller floatValue] < _autoscrollMinLimit) {
        return;
    }
    
    NSPoint targetPoint = NSMakePoint(0, [[[viewColumn tableView] superview] bounds].origin.y + [[controller view] bounds].size.height);
    [[viewColumn tableView] scrollPoint:targetPoint];
}

- (void) newMessageArrived:(NTLNMessageViewController*)controller {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//    float newestMessageHeight = [controller requiredHeight];
//    NSLog(@"newestMessageHeight: %f - %@", newestMessageHeight, [[controller message] text]);

    [self reloadTableView];
    if ([[NTLNConfiguration instance] timelineSortOrder] == NTLN_CONFIGURATION_TIMELINE_SORT_ORDER_DESCENDING) {
        [self selectionDown];
        [self scrollDownInDescendingOrder:controller];
    } else {
        [self scrollDownInAscendingOrder:controller];
    }
}

- (float) columnWidth {
    return [viewColumn width];
}

- (void) reloadTimelineSortDescriptors {
    [messageViewControllerArrayController setSortDescriptors:
     [NSArray arrayWithObject:
      [[[NSSortDescriptor alloc] initWithKey:@"message.timestamp" 
                                   ascending:([[NTLNConfiguration instance] timelineSortOrder] == NTLN_CONFIGURATION_TIMELINE_SORT_ORDER_ASCENDING)] autorelease]]];
    [messageViewControllerArrayController rearrangeObjects];
    [self reloadTableView];
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
    [(NTLNCustomViewCell*)cell addView:[controller view]];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    TwitterStatusViewController *controller = [[messageViewControllerArrayController arrangedObjects] objectAtIndex:row];
//    NSLog(@"%s: %d - %f", __PRETTY_FUNCTION__, row, [controller requiredHeight]);
    return [controller requiredHeight];
}

/////////////////////////////////////////////////////////////////////////////////////////
- (void) resize:(float)deltaHeight {
    float originalKnobPosition = [_verticalScroller floatValue];
    
    NSRect frame = [scrollView frame];
    frame.size.height += deltaHeight;
    frame.origin.y -= deltaHeight;
    [scrollView setFrame:frame];
    
    if ([[NTLNConfiguration instance] timelineSortOrder] == NTLN_CONFIGURATION_TIMELINE_SORT_ORDER_ASCENDING
        && originalKnobPosition >= _autoscrollMinLimit) {
        _autoscrollMinLimit = [_verticalScroller floatValue];
    }
}

#pragma mark Notification
- (void) colorSchemeChanged:(NSNotification*)notification {
    [self reloadTableView];
}

- (void) windowAlphaChanged:(NSNotification*)notification {
//    [[viewColumn tableView] setAlphaValue:[[NTLNConfiguration instance] windowAlpha]];
}

@end
