#import "NTLNMessageTableViewController.h"
#import "NTLNCustomViewCell.h"
#import "TwitterStatusViewController.h"
#import "NTLNConfiguration.h"
#import "NTLNColors.h"
#import "NTLNMessageListViewsController.h"
#import "NTLNNotification.h"

@implementation NTLNMessageScrollView 

- (void) awakeFromNib {
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(colorSettingChanged:)
                                                 name:NTLN_NOTIFICATION_WINDOW_ALPHA_CHANGED
                                               object:nil];
}

- (void)notifyExit {
    for (int i = 0; i < [[messageViewControllerArrayController arrangedObjects] count]; i++) {
        TwitterStatusViewController *c = [[messageViewControllerArrayController arrangedObjects] objectAtIndex:i];
        [c exitFromScrollView];
    }
}

- (void)notifyEnterExit {
    if ([messageListViewsController currentViewIndex] == 3) {
        return;
    }
    
    if (![[self window] isMainWindow]) {
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
//    NSLog(@"%f %f", [self documentVisibleRect].size.width, [self documentVisibleRect].size.height);
}

- (void)reflectScrolledClipView:(NSClipView *)aClipView {
    [super reflectScrolledClipView:aClipView];
    [self notifyEnterExit];
}

- (void) keyDown:(NSEvent*)event {
    unichar keyChar = [[event characters] characterAtIndex:0];
//    NSLog(@"%d - %d", keyChar, [event modifierFlags] & NSShiftKeyMask);
    switch (keyChar) {
        case 0x20:
            if ([event modifierFlags] & NSShiftKeyMask) {
                [self pageUp:self];
            } else {
                [self pageDown:self];
            }
            break;
        case 0x6a:
            [messageTableViewController nextMessage];
            break;
        case 0x6b:
            [messageTableViewController previousMessage];
            break;
        default:
            [super keyDown:event];
            break;
    }
}

- (void)drawRect:(NSRect)aRect {
    [[[NTLNColors instance] colorForBackground] set];
    NSRectFillUsingOperation(aRect, NSCompositeCopy);
}

#pragma mark Notification
- (void) colorSettingChanged:(NSNotification*)notification {
    [self setNeedsDisplay:TRUE];
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
                                                 name:NTLN_NOTIFICATION_COLOR_SCHEME_CHANGED 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(fontSizeChanged:)
                                                 name:NTLN_NOTIFICATION_FONT_SIZE_CHANGED2
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(windowAlphaChanged:)
                                                 name:NTLN_NOTIFICATION_WINDOW_ALPHA_CHANGED
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(messageViewChanging:)
                                                 name:NTLN_NOTIFICATION_MESSAGE_VIEW_CHANGING
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(messageViewChanged:)
                                                 name:NTLN_NOTIFICATION_MESSAGE_VIEW_CHANGED
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(windowActivated:)
                                                 name:NSWindowDidBecomeMainNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(windowDeactivated:)
                                                 name:NSWindowDidResignMainNotification
                                               object:nil];
    
    
    // TODO
    [scrollView setBackgroundColor:[[NTLNColors instance] colorForBackground]];
}

- (id) init {
    return self;
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
    [_highlightedViewController unhighlight];
    if ([indexSet firstIndex] != NSNotFound) {
        _highlightedViewController = [[messageViewControllerArrayController arrangedObjects] objectAtIndex:[indexSet firstIndex]];
        [_highlightedViewController highlight];
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

- (void) selectionUp {
    NSIndexSet *target = [NSIndexSet indexSetWithIndex:[[[viewColumn tableView] selectedRowIndexes] firstIndex] - 1];
    [[viewColumn tableView] selectRowIndexes:target byExtendingSelection:FALSE];
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
    if (_knobPositionBeforeAddingMessage < _autoscrollMinLimit) {
        return;
    }
    
    NSPoint targetPoint = NSMakePoint(0, [[[viewColumn tableView] superview] bounds].origin.y + [[controller view] bounds].size.height);
    [[viewColumn tableView] scrollPoint:targetPoint];
}

- (void) newMessageArrived:(NSArray*)controllers {
    _knobPositionBeforeAddingMessage = [_verticalScroller floatValue];
    [self reloadTableView];
    for (int i = 0; i < [controllers count]; i++) {
        NTLNMessageViewController *controller = [controllers objectAtIndex:i];
        if ([[NTLNConfiguration instance] timelineSortOrder] == NTLN_CONFIGURATION_TIMELINE_SORT_ORDER_DESCENDING) {
            [self selectionDown];
            [self scrollDownInDescendingOrder:controller];
        } else {
            [self scrollDownInAscendingOrder:controller];
        }
    }
}

- (float) columnWidth {
    return [viewColumn width];
}

- (void) reloadTimelineSortDescriptors {
    [messageViewControllerArrayController setSortDescriptors:
     [NSArray arrayWithObject:
      [[[NSSortDescriptor alloc] initWithKey:@"timestamp" 
                                   ascending:([[NTLNConfiguration instance] timelineSortOrder] == NTLN_CONFIGURATION_TIMELINE_SORT_ORDER_ASCENDING)] autorelease]]];
    [messageViewControllerArrayController rearrangeObjects];
    [self reloadTableView];
}

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

- (void) nextMessage {
    [self selectionDown];
    [[viewColumn tableView] scrollRowToVisible:[[[viewColumn tableView] selectedRowIndexes] firstIndex]];
}

- (void) previousMessage {
    [self selectionUp];
    [[viewColumn tableView] scrollRowToVisible:[[[viewColumn tableView] selectedRowIndexes] firstIndex]];
}

#pragma mark NSTableView datasource methods
- (int)numberOfRowsInTableView:(NSTableView *)aTableView {
    return [[messageViewControllerArrayController arrangedObjects] count];
}

- (id)tableView:(NSTableView *)aTableView 
            objectValueForTableColumn:(NSTableColumn *)aTableColumn
            row:(int)rowIndex {
    return @"";
}

#pragma mark NSTableView delegate methods
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

#pragma mark Notification
- (void) colorSchemeChanged:(NSNotification*)notification {
    [self reloadTableView];
}

- (void) fontSizeChanged:(NSNotification*)notification {
    [self reloadTableView];
}

- (void) windowAlphaChanged:(NSNotification*)notification {
//    [[viewColumn tableView] setAlphaValue:[[NTLNConfiguration instance] windowAlpha]];
}

- (void) messageViewChanging:(NSNotification*)notification {
    [_highlightedViewController unhighlight];
    [scrollView notifyExit];
}

- (void) messageViewChanged:(NSNotification*)notification {
    _highlightedViewController = nil;
    [self reloadTableView];
    [scrollView notifyEnterExit];
}

- (void) windowActivated:(NSNotification*)notification {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
    [scrollView notifyEnterExit];
}

- (void) windowDeactivated:(NSNotification*)notification {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
    [scrollView notifyExit];
}

#pragma mark Actions
- (IBAction) makeSelectionsFavoraite:(id)sender {
    NSIndexSet* indices = [[viewColumn tableView] selectedRowIndexes];
    unsigned int bufSize = [indices count];
    unsigned int* buf = malloc(sizeof(unsigned int) * bufSize);
    NSRange range = NSMakeRange([indices firstIndex], [indices lastIndex]);
    [indices getIndexes:buf maxCount:bufSize inIndexRange:&range];
    for(unsigned int i = 0; i != bufSize; i++) {
        unsigned int index = buf[i];
        [[[messageViewControllerArrayController arrangedObjects] objectAtIndex:index] toggleFavorite:self];
    }
    free(buf);
}

- (IBAction) addSelectionsToReplyTo:(id)sender {
    NSIndexSet* indices = [[viewColumn tableView] selectedRowIndexes];
    unsigned int bufSize = [indices count];
    unsigned int* buf = malloc(sizeof(unsigned int) * bufSize);
    NSRange range = NSMakeRange([indices firstIndex], [indices lastIndex]);
    [indices getIndexes:buf maxCount:bufSize inIndexRange:&range];
    for(unsigned int i = 0; i != bufSize; i++) {
        unsigned int index = buf[i];
        TwitterStatusViewController *c = [[messageViewControllerArrayController arrangedObjects] objectAtIndex:index];
        TwitterStatus *m = [c message];
        NSString *s = [m screenName];
        [messageInputTextField addReplyTo:s];
    }
    free(buf);
    
    [messageInputTextField focusAndLocateCursorEnd];
}

@end
