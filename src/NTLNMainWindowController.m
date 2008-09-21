#import "NTLNMainWindowController.h"
#import "NTLNPreferencesWindowController.h"
#import "NTLNAccount.h"
#import "TwitterStatusViewController.h"
#import "NTLNErrorMessageViewController.h"
#import "TwitterTestStub.h"
#import "NTLNConfiguration.h"
#import "NTLNColors.h"
#import "NTLNNotification.h"
#import "NTLNSegmentedCell.h"
#import "NTLNAppController.h"

#define NTLN_RATE_LIMIT_WARNING_THREASHOLD 0.5f
#define NTLN_RATE_LIMIT_CRITICAL_THREASHOLD 0.7f

@interface NTLNTextView : NSTextView {
    
}
@end

@implementation NTLNTextView

- (id)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
    [self setFieldEditor:YES];
	return self;
}

- (void)setMarkedText:(id)aString selectedRange:(NSRange)selRange
{
//    NSLog(@"%@", [aString description]);

    id string;
    
    if ([aString isKindOfClass:[NSAttributedString class]]) {
        string = [[aString mutableCopy] autorelease];
        // in my investigation, selRange is always (0, 0). so replace it here.
        selRange = NSMakeRange( 0, [string length]);
        NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:NSUnderlineStyleSingle], NSUnderlineStyleAttributeName,
                              [[NTLNColors instance] colorForText], NSUnderlineColorAttributeName,
                               nil];
        [string setAttributes:attrs range:selRange];
    } else {
        string = aString;
    }
    
    [super setMarkedText:string selectedRange:selRange];
}

@end


@implementation NTLNMainWindow

- (void)sendEvent:(NSEvent *)event {
    if ([event type] == NSKeyDown) {
        unsigned short keyCode = [event keyCode];
//        NSLog(@"MainWindow: %d - %d", keyCode, [event modifierFlags] & NSShiftKeyMask);
        switch (keyCode) {
            case 53:
                [[self windowController] closeKeywordFilterView:self];
                break;
            default:
                [super sendEvent:event];
                break;
        }
    } else {
        [super sendEvent:event];
    }
}

@end

@implementation NTLNMainWindowController

#pragma mark Initialization
- (id) init {
    [NTLNConfiguration setTimelineSortOrderChangeObserver:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(rateLimitDisplaySettingChanged:)
                                                 name:NTLN_NOTIFICATION_RATE_LIMIT_DISPLAY_SETTING_CHANGED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(messageViewChanged:)
                                                 name:    NTLN_NOTIFICATION_MESSAGE_VIEW_CHANGED
                                               object:nil];
    
    _fieldEditor = [[NTLNTextView alloc] init];
    
    return self;
}

- (void) dealloc {
    [_toolbarItems release];
    [_messageViewToolbarMenuItem release];
    [_fieldEditor release];
    [super dealloc];
}

- (void) changeViewByMenu:(id)sender {
    [_messageViewSelector setSelectedSegment:[sender tag]];
    [messageListViewsController changeViewByMenu:sender];
}

- (NSMenuItem*) addMenuItemWithTitle:(NSString*)title target:(id)target action:(SEL)action keyEquivalent:(NSString*)keyEquivalent tag:(int)tag toMenu:(NSMenu*) menu {
    NSMenuItem *item = [[[NSMenuItem alloc] initWithTitle:title action:action keyEquivalent:keyEquivalent] autorelease];
    [item setTarget:target];
    [item setTag:tag];
    [menu addItem:item];
    return item;
}

- (NSToolbarItem*) addToolbarItemWithIdentifier:(NSString*)identifier label:(NSString*)label target:(id)target action:(SEL)action view:(NSView*)view {
    NSToolbarItem *item = [[[NSToolbarItem alloc] initWithItemIdentifier:identifier] autorelease];
    [item setLabel:label];
    [item setTarget:target];
    [item setAction:action];
    [item setView:view];
    [_toolbarItems setObject:item forKey:[item itemIdentifier]];
    NSMenuItem *menuItem = [[[NSMenuItem alloc] init] autorelease];
    [menuItem setTitle:label];
    [menuItem setTarget:target];
    [menuItem setAction:action];
    [item setMenuFormRepresentation:menuItem];
    return item;
}

- (void) setupMenuAndToolbar {
    NSToolbar *toolbar=[[[NSToolbar alloc] initWithIdentifier:@"mainToolbar"] autorelease];
    [toolbar setDelegate:self];
    [toolbar setAutosavesConfiguration:YES];
    [toolbar setAllowsUserCustomization:YES];
    [toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
    
    _toolbarItems = [[NSMutableDictionary alloc] init];
    
    // setup segumented control
    _messageViewSelector = [[[NSSegmentedControl alloc] initWithFrame:NSMakeRect(0, 0, 180, 25)] autorelease];
    NTLNSegmentedCell *_messageViewSelectorCell = [[[NTLNSegmentedCell alloc] init] autorelease];
    [_messageViewSelector setCell:_messageViewSelectorCell];
    [_messageViewSelectorCell setSegmentCount:4];
    [_messageViewSelectorCell setImage:[NSImage imageNamed:@"friends"] forSegment:0];
    [_messageViewSelectorCell setImage:[NSImage imageNamed:@"replies"] forSegment:1];
    [_messageViewSelectorCell setImage:[NSImage imageNamed:@"sent"] forSegment:2];
    [_messageViewSelectorCell setImage:[NSImage imageNamed:@"unread"] forSegment:3];
    [_messageViewSelectorCell setHighlightedImage:[NSImage imageNamed:@"friends-highlighted"] forSegment:0];
    [_messageViewSelectorCell setHighlightedImage:[NSImage imageNamed:@"replies-highlighted"] forSegment:1];
    [_messageViewSelectorCell setHighlightedImage:[NSImage imageNamed:@"sent-highlighted"] forSegment:2];
    [_messageViewSelectorCell setHighlightedImage:[NSImage imageNamed:@"unread-highlighted"] forSegment:3];
    [_messageViewSelectorCell setToolTip:NSLocalizedString(@"Friends", @"toolbar icon tooltip") forSegment:0];
    [_messageViewSelectorCell setToolTip:NSLocalizedString(@"Replies", @"toolbar icon tooltip") forSegment:1];
    [_messageViewSelectorCell setToolTip:NSLocalizedString(@"Sent", @"toolbar icon tooltip") forSegment:2];
    [_messageViewSelectorCell setToolTip:NSLocalizedString(@"Unread", @"toolbar icon tooltip") forSegment:3];
    [_messageViewSelectorCell setWidth:40.0 forSegment:0];
    [_messageViewSelectorCell setWidth:40.0 forSegment:1];
    [_messageViewSelectorCell setWidth:40.0 forSegment:2];
    [_messageViewSelectorCell setWidth:40.0 forSegment:3];
    [_messageViewSelectorCell setSelectedSegment:0];
    [_messageViewSelectorCell setTarget:messageListViewsController];
    [_messageViewSelectorCell setAction:@selector(changeViewByToolbar:)];
    NSToolbarItem *messageViewSelectorToolbarItem = [self addToolbarItemWithIdentifier:@"messageView" 
                                                                                 label:NSLocalizedString(@"View Mode", @"Toolbar text")
                                                                                target:messageListViewsController 
                                                                                action:@selector(changeView:)
                                                                                  view:_messageViewSelector];
    // action and keyEquivalent is not used
    _messageViewToolbarMenuItem = [[NSMenuItem alloc] init];
    [_messageViewToolbarMenuItem setTitle:NSLocalizedString(@"View Mode", @"Toolbar text")];
    NSMenu *viewTextMenu  = [[[NSMenu alloc] initWithTitle:@"dummy menu"] autorelease];
    [self addMenuItemWithTitle:@"Friends"
                        target:self
                        action:@selector(changeViewByMenu:)
                 keyEquivalent:@"1" 
                           tag:0 
                        toMenu:viewMenu];
    [self addMenuItemWithTitle:@"Replies"
                        target:self
                        action:@selector(changeViewByMenu:)
                 keyEquivalent:@"2" 
                           tag:1 
                        toMenu:viewMenu];
    [self addMenuItemWithTitle:@"Sent"
                        target:self
                        action:@selector(changeViewByMenu:)
                 keyEquivalent:@"3" 
                           tag:2 
                        toMenu:viewMenu];
    [self addMenuItemWithTitle:@"Unread"
                        target:self
                        action:@selector(changeViewByMenu:)
                 keyEquivalent:@"4" 
                           tag:3
                        toMenu:viewMenu];
    [self addMenuItemWithTitle:@"Friends"
                        target:self
                        action:@selector(changeViewByMenu:)
                 keyEquivalent:@"1" 
                           tag:0 
                        toMenu:viewTextMenu];
    [self addMenuItemWithTitle:@"Replies"
                        target:self
                        action:@selector(changeViewByMenu:)
                 keyEquivalent:@"2" 
                           tag:1 
                        toMenu:viewTextMenu];
    [self addMenuItemWithTitle:@"Sent"
                        target:self
                        action:@selector(changeViewByMenu:)
                 keyEquivalent:@"3" 
                           tag:2 
                        toMenu:viewTextMenu];
    [self addMenuItemWithTitle:@"Unread"
                        target:self
                        action:@selector(changeViewByMenu:)
                 keyEquivalent:@"4" 
                           tag:3
                        toMenu:viewTextMenu];
    [_messageViewToolbarMenuItem setSubmenu:viewTextMenu];
    [messageViewSelectorToolbarItem setMenuFormRepresentation:_messageViewToolbarMenuItem];
    
    
    // refresh button
    NSButton *refreshButton = [[[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 25, 25)] autorelease];
    [refreshButton setImage:[NSImage imageNamed:NSImageNameRefreshTemplate]];
    [refreshButton setBezelStyle:NSTexturedSquareBezelStyle];
    [refreshButton setTarget:self];
    [refreshButton setAction:@selector(updateTimelineCorrespondsToView:)];
    [self addToolbarItemWithIdentifier:@"refresh"
                                 label:NSLocalizedString(@"Refresh", @"Toolbar label")
                                target:self
                                action:@selector(updateTimelineCorrespondsToView:)
                                  view:refreshButton];

    // mark all as read button
    NSButton *markAllAsReadButton = [[[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 25, 25)] autorelease];
    [markAllAsReadButton setImage:[NSImage imageNamed:NSImageNameStopProgressTemplate]];
    [markAllAsReadButton setBezelStyle:NSTexturedSquareBezelStyle];
    [markAllAsReadButton setTarget:self];
    [markAllAsReadButton setAction:@selector(markAllAsRead:)];
    [self addToolbarItemWithIdentifier:@"markallasread"
                                 label:NSLocalizedString(@"Mark all as read", @"Toolbar label")
                                target:self
                                action:@selector(markAllAsRead:)
                                  view:markAllAsReadButton];
    
    [[self window] setToolbar:toolbar];
}

- (void) awakeFromNib {
    [mainWindow setReleasedWhenClosed:FALSE];
    
    [messageTextField setCallback:self];
    [messageTextField setLengthForWarning:140 max:160];
    
    [self setupMenuAndToolbar];
    [[self window] setOpaque:FALSE];
    
    [statisticsTextField setToolTip:NSLocalizedString(@"number of messages", @"status bar tool tip")];
    [apiCountIndicator setToolTip:NSLocalizedString(@"API limit", @"status bar tool tip")];
    [apiCountIndicator setHidden:true];
    
    //    NSColor *semiTransparentBlue =
//    [NSColor colorWithDeviceRed:0.0 green:0.0 blue:1.0 alpha:0.5];
//    [[self window] setBackgroundColor:semiTransparentBlue];
    
    NSRect keywordFilterViewRect = [keywordFilterView frame];
//    keywordFilterViewRect.size.height = 0;
    keywordFilterViewRect.origin.y += [keywordFilterView defaultHeight];
    [keywordFilterView setFrame:keywordFilterViewRect];
    
    [messageTableViewController resizeTop:[keywordFilterView defaultHeight]];
}

// this method is not needed actually but called by array controller's binding
- (void) setTimelineSortDescriptors:(NSArray*)descriptors {
}

- (void) showWindowToFront {
    [[self window] makeKeyAndOrderFront:nil];
}

- (void) setFrameAutosaveName:(NSString*)name {
    [mainWindow setFrameAutosaveName:name];
}

- (void) updateMessageCounterText
{
    [statisticsTextField setIntValue:[[messageViewControllerArrayController arrangedObjects] count]];
}

- (void) addMessageViewControllers:(NSArray*)controllers {
//    NSLog(@"%s: count:%d", __PRETTY_FUNCTION__, [controllers count]);
    [messageViewControllerArrayController addObjects:controllers];
    [messageListViewsController applyCurrentPredicate];
    [messageTableViewController newMessageArrived:controllers];
    [self updateMessageCounterText];
}

#pragma mark -

#pragma Message input text field
- (void) resetAndFocusMessageTextField {
    [messageTextField setStringValue:@""];
    [messageTextField setEditable:TRUE];
    [messageTextField setEnabled:TRUE];
    [messageTextField updateState];
    [statusTextField setStringValue:@""];
}

#pragma Message table view
- (void) reloadTableView
{
    [messageTableViewController reloadTableView];
}

- (id) enclosingTextField:(NSTextView*) view {
    id back = view;
    while (true) {
        back = [(NSView*)back superview];
        if ([back isKindOfClass:[NSTextField class]]) {
            return back;
        }
        if ([back isKindOfClass:[NSWindow class]] || !back) {
            return view;
        }
    }
}

- (BOOL) hasKeywordFilterTextFieldFocus {
    if (![[mainWindow firstResponder] isKindOfClass:[NSView class]]) {
        return FALSE;
    }

    NSView *v = (NSView*)[mainWindow firstResponder];
    while (v) {
        v = [v superview];
        if (v == keywordFilterView) {
            return TRUE;
        }
    }
    return FALSE;
}

- (void) openKeywordFilterViewInternal {
    NSRect fromViewFrame = [keywordFilterView frame];
    NSRect toViewFrame = fromViewFrame;
    toViewFrame.origin.y -= [keywordFilterView defaultHeight];

//    NSLog(@"open: %f -> %f", fromViewFrame.origin.y, toViewFrame.origin.y);
    
    NSMutableDictionary *viewDict = [NSMutableDictionary dictionary];
    [viewDict setObject:keywordFilterView forKey:NSViewAnimationTargetKey];
    [viewDict setObject:[NSValue valueWithRect:fromViewFrame] forKey:NSViewAnimationStartFrameKey];
    [viewDict setObject:[NSValue valueWithRect:toViewFrame] forKey:NSViewAnimationEndFrameKey];

    NSRect fromListFrame = [[messageTableViewController viewForTabItem] frame];
    NSRect toListFrame = fromListFrame;
    toListFrame.size.height -= [keywordFilterView defaultHeight];

    NSMutableDictionary *listDict = [NSMutableDictionary dictionary];
    [listDict setObject:[messageTableViewController viewForTabItem] forKey:NSViewAnimationTargetKey];
    [listDict setObject:[NSValue valueWithRect:fromListFrame] forKey:NSViewAnimationStartFrameKey];
    [listDict setObject:[NSValue valueWithRect:toListFrame] forKey:NSViewAnimationEndFrameKey];
    
    NSViewAnimation *theAnim = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObjects:listDict, viewDict, nil]];
    [theAnim setDuration:0.15];
    [theAnim setAnimationCurve:NSAnimationEaseInOut];
    [theAnim startAnimation];
    [theAnim release];
}

- (IBAction) openKeywordFilterView:(id)sender {
    if ([self hasKeywordFilterTextFieldFocus]) {
        return;
    }
    
    if (![keywordFilterView opened]) {
        [self openKeywordFilterViewInternal];
    }

    _previousFirstResponder = [mainWindow firstResponder];
    if ([_previousFirstResponder isKindOfClass:[NSTextView class]]) {
        _previousFirstResponder = [self enclosingTextField:(NSTextView*)_previousFirstResponder];
    }

    [keywordFilterView postOpen];
}

- (IBAction) closeKeywordFilterView:(id)sender {
    if (![keywordFilterView opened]) {
        return;
    }

    NSRect fromViewFrame = [keywordFilterView frame];
    NSRect toViewFrame = fromViewFrame;
    toViewFrame.origin.y += [keywordFilterView defaultHeight];
    
//    NSLog(@"close: %f -> %f", fromViewFrame.origin.y, toViewFrame.origin.y);

    NSMutableDictionary *viewDict = [NSMutableDictionary dictionary];
    [viewDict setObject:keywordFilterView forKey:NSViewAnimationTargetKey];
    [viewDict setObject:[NSValue valueWithRect:fromViewFrame] forKey:NSViewAnimationStartFrameKey];
    [viewDict setObject:[NSValue valueWithRect:toViewFrame] forKey:NSViewAnimationEndFrameKey];
    
    NSRect fromListFrame = [[messageTableViewController viewForTabItem] frame];
    NSRect toListFrame = fromListFrame;
    toListFrame.size.height += [keywordFilterView defaultHeight];
    
    NSMutableDictionary *listDict = [NSMutableDictionary dictionary];
    [listDict setObject:[messageTableViewController viewForTabItem] forKey:NSViewAnimationTargetKey];
    [listDict setObject:[NSValue valueWithRect:fromListFrame] forKey:NSViewAnimationStartFrameKey];
    [listDict setObject:[NSValue valueWithRect:toListFrame] forKey:NSViewAnimationEndFrameKey];

    NSViewAnimation *theAnim = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObjects:listDict, viewDict, nil]];
    [theAnim setDuration:0.15];
    [theAnim setAnimationCurve:NSAnimationEaseInOut];
    [theAnim startAnimation];
    [theAnim release];
    
    [keywordFilterView postClose];
    if ([self hasKeywordFilterTextFieldFocus]) {
        [mainWindow makeFirstResponder:_previousFirstResponder];
    }
}

#pragma mark Rate limit status

- (BOOL) isRateLimitStatusWarningLevel
{
    return [apiCountIndicator intValue] >= [apiCountIndicator warningValue];
}

- (void) setRateLimitStatusWithRemainingHits:(int)remainingHits hourlyLimit:(int)hourlyLimit resetTime:(NSDate*)resetTime
{
    [apiCountIndicator setMaxValue:hourlyLimit];
    [apiCountIndicator setWarningValue:hourlyLimit * NTLN_RATE_LIMIT_WARNING_THREASHOLD];
    [apiCountIndicator setCriticalValue:hourlyLimit * NTLN_RATE_LIMIT_CRITICAL_THREASHOLD];
    [apiCountIndicator setFloatValue:hourlyLimit - remainingHits];
    
    NSMutableString *toolTipText = [NSMutableString stringWithCapacity:200];

    if (remainingHits <= 0) {
        [toolTipText appendString:NSLocalizedString(@"Attention: API limit exceeded", nil)];
        [toolTipText appendString:@"\n"];
    } else if ([self isRateLimitStatusWarningLevel]) {
        [toolTipText appendString:NSLocalizedString(@"Attention: API limit warning", nil)];
        [toolTipText appendString:@"\n"];
    }
    
    [toolTipText appendFormat:@"%d / %d", hourlyLimit - remainingHits, hourlyLimit];
    if (resetTime) {
        [toolTipText appendString:@"\n"];
        [toolTipText appendFormat:NSLocalizedString(@"Reset at %@", nil), [resetTime descriptionWithCalendarFormat:@"%H:%M" timeZone:nil locale:nil]];
    }
    [apiCountIndicator setToolTip:toolTipText];
    
    if ([self isRateLimitStatusWarningLevel]) {
        [apiCountIndicator setHidden:false];
    } else {
        [apiCountIndicator setHidden:![[NTLNConfiguration instance] showRateLimitStatusOnStatusBar]];
    }
}

#pragma mark MessageInputTextField callback
- (void) messageInputTextFieldResized:(float)heightDelta {
    [messageTableViewController resize:heightDelta];
}

- (void) messageInputTextFieldChanged:(int)length state:(enum NTLNMessageInputTextFieldLengthState)state {
    // TODO: statusTextField should do itself (need subclassing)
    if (length > 0) {
        NSString *statusText = [NSString stringWithFormat:@"%d", length];
        [statusTextField setStringValue:statusText];
    } else {
        [statusTextField setStringValue:@""];
    }
}

#pragma mark TimelineSortOrderChangeObserver
- (void) timelineSortOrderChangeObserverSortOrderChanged {
    [messageTableViewController reloadTimelineSortDescriptors];
}

#pragma mark MessageViewListener
- (void) replyDesiredFor:(NSString*)username {
    [messageTextField addReplyTo:username];
    [messageTextField focusAndLocateCursorEnd];
}

- (void) createFavoriteDesiredFor:(NSString*)statusId
{
    [appController createFavoriteFor:statusId];
}

- (void) destroyFavoriteDesiredFor:(NSString*)statusId
{
    [appController destroyFavoriteFor:statusId];
}

- (float) viewWidth {
    return [messageTableViewController columnWidth];
}

- (BOOL) isCreatingFavoriteWorking
{
    return [appController isCreatingFavoriteWorking];
}

#pragma mark NSWindow delegate methods
- (NSSize)windowWillResize:(NSWindow *)window toSize:(NSSize)proposedFrameSize {
    return proposedFrameSize;
}

- (void)windowDidResize:(NSNotification *)notification {
    [messageTableViewController recalculateViewSizes];
    [messageTableViewController reloadTableView];
}

- (void)windowDidBecomeMain:(NSNotification *)notification {
    if ([[NTLNConfiguration instance] increaseTransparencyWhileDeactivated]) {
        [mainWindow setAlphaValue:1.0f];
    }
}

- (void)windowDidResignMain:(NSNotification *)notification {
    if ([[NTLNConfiguration instance] increaseTransparencyWhileDeactivated]) {
        [mainWindow setAlphaValue:0.3f];
    }
}

- (id)windowWillReturnFieldEditor:(NSWindow *)window toObject:(id)anObject
{
    return _fieldEditor;
}

#pragma mark NSToolber delegate methods
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
    return [_toolbarItems objectForKey:itemIdentifier];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar {
    return [NSArray arrayWithObjects:@"messageView", @"refresh", @"markallasread", nil];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar {
    return [NSArray arrayWithObjects:@"messageView", @"refresh", @"markallasread", nil];
}

#pragma mark Actions

- (IBAction) sendMessage:(id) sender
{
    if ([[messageTextField stringValue] length] == 0) {
        return;
    }
    
    [messageTextField setEnabled:FALSE];
    [appController sendMessage:[messageTextField stringValue]];
}
    
- (IBAction) updateTimelineCorrespondsToView:(id)sender {
    switch ([_messageViewSelector selectedSegment]) {
        case 0:
        case 3:
            [appController updateStatus];
            break;
        case 1:
            [appController updateReplies];
            break;
        case 2:
            [appController updateSentMessages];
        default:
            break;
    }
}

- (IBAction) markAllAsRead:(id)sender {
    [messageViewControllerArrayController setFilterPredicate:nil];
    [messageViewControllerArrayController rearrangeObjects];
    NSArray *a = [messageViewControllerArrayController arrangedObjects];
    int count = [a count];
    for (int i = 0; i < count; i++) {
        TwitterStatusViewController *c = [a objectAtIndex:i];
        [c markAsRead:false];
    }
    [messageListViewsController applyCurrentPredicate];
    [messageTableViewController reloadTableView];
    [[NSNotificationCenter defaultCenter] postNotificationName:NTLN_NOTIFICATION_MESSAGE_STATUS_MARKED_AS_READ
                                                        object:nil];            
}

#pragma mark Notifications
- (void) rateLimitDisplaySettingChanged:(NSNotification*)notification {
    BOOL show = [[notification object] boolValue];
    if (![self isRateLimitStatusWarningLevel]) {
        [apiCountIndicator setHidden:!show];
    }
    [statisticsTextField setHidden:!show];
}

- (void) messageViewChanged:(NSNotification*)notification
{
    [self updateMessageCounterText];
}

@end
