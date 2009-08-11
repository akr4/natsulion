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
#import "NTLNURLUtils.h"
#import "NTLNFilterView.h"
#import "iTunes.h"

#define NTLN_RATE_LIMIT_WARNING_THREASHOLD 0.8f
#define NTLN_RATE_LIMIT_CRITICAL_THREASHOLD 0.9f

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
                [[self windowController] closeFilterView:self];
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
                                                 name:NTLN_NOTIFICATION_MESSAGE_VIEW_CHANGED
                                               object:nil];

    // happens also after NTLN_NOTIFICATION_MESSAGE_VIEW_CHANGED
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(messageViewChanged:)
                                                 name:NTLN_NOTIFICATION_KEYWORD_FILTER_APPLIED
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
    [self addMenuItemWithTitle:NSLocalizedString(@"Friends", nil)
                        target:self
                        action:@selector(changeViewByMenu:)
                 keyEquivalent:@"1" 
                           tag:0 
                        toMenu:viewMenu];
    [self addMenuItemWithTitle:NSLocalizedString(@"Replies", nil)
                        target:self
                        action:@selector(changeViewByMenu:)
                 keyEquivalent:@"2" 
                           tag:1 
                        toMenu:viewMenu];
    [self addMenuItemWithTitle:NSLocalizedString(@"Sent", nil)
                        target:self
                        action:@selector(changeViewByMenu:)
                 keyEquivalent:@"3" 
                           tag:2 
                        toMenu:viewMenu];
    [self addMenuItemWithTitle:NSLocalizedString(@"Unread", nil)
                        target:self
                        action:@selector(changeViewByMenu:)
                 keyEquivalent:@"4" 
                           tag:3
                        toMenu:viewMenu];
    [self addMenuItemWithTitle:NSLocalizedString(@"Friends", nil)
                        target:self
                        action:@selector(changeViewByMenu:)
                 keyEquivalent:@"1" 
                           tag:0 
                        toMenu:viewTextMenu];
    [self addMenuItemWithTitle:NSLocalizedString(@"Replies", nil)
                        target:self
                        action:@selector(changeViewByMenu:)
                 keyEquivalent:@"2" 
                           tag:1 
                        toMenu:viewTextMenu];
    [self addMenuItemWithTitle:NSLocalizedString(@"Sent", nil)
                        target:self
                        action:@selector(changeViewByMenu:)
                 keyEquivalent:@"3" 
                           tag:2 
                        toMenu:viewTextMenu];
    [self addMenuItemWithTitle:NSLocalizedString(@"Unread", nil)
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
    
    // find button
    NSButton *findButton = [[[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 25, 25)] autorelease];
    [findButton setImage:[NSImage imageNamed:@"find"]];
    [findButton setBezelStyle:NSTexturedSquareBezelStyle];
    [findButton setTarget:self];
    [findButton setAction:@selector(openKeywordFilterView:)];
    [self addToolbarItemWithIdentifier:@"find"
                                 label:NSLocalizedString(@"Find", @"Toolbar label")
                                target:self
                                action:@selector(openKeywordFilterView:)
                                  view:findButton];
    
    // show conversation button
    NSButton *conversationButton = [[[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 25, 25)] autorelease];
    [conversationButton setImage:[NSImage imageNamed:@"conversation"]];
    [conversationButton setBezelStyle:NSTexturedSquareBezelStyle];
    [conversationButton setTarget:self];
    [conversationButton setAction:@selector(openScreenNameFilterView:)];
    [self addToolbarItemWithIdentifier:@"conversation"
                                 label:NSLocalizedString(@"Conversation", @"Toolbar label")
                                target:self
                                action:@selector(openScreenNameFilterView:)
                                  view:conversationButton];
    
    // paste itunes track name button
    NSButton *iTunesButton = [[[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 25, 25)] autorelease];
    [iTunesButton setImage:[NSImage imageNamed:@"music"]];
    [iTunesButton setBezelStyle:NSTexturedSquareBezelStyle];
    [iTunesButton setTarget:self];
    [iTunesButton setAction:@selector(setPlayingTrackName:)];
    [self addToolbarItemWithIdentifier:@"itunes"
                                 label:NSLocalizedString(@"iTunes Track", @"Toolbar label")
                                target:self
                                action:@selector(setPlayingTrackName:)
                                  view:iTunesButton];

    [[self window] setToolbar:toolbar];
}

- (void) awakeFromNib {
    [mainWindow setReleasedWhenClosed:FALSE];
    
    [messageTextField setCallback:self];
    [messageTextField setLengthForWarning:140 max:160];
    
    [self setupMenuAndToolbar];
    [[self window] setOpaque:FALSE];
    
    [statisticsTextField setToolTip:NSLocalizedString(@"number of messages", @"status bar tool tip")];
    [statisticsTextField setHidden:![[NTLNConfiguration instance] showRateLimitStatusOnStatusBar]];
    [apiCountIndicator setToolTip:NSLocalizedString(@"API limit", @"status bar tool tip")];
    [apiCountIndicator setHidden:![[NTLNConfiguration instance] showRateLimitStatusOnStatusBar]];
    
    //    NSColor *semiTransparentBlue =
//    [NSColor colorWithDeviceRed:0.0 green:0.0 blue:1.0 alpha:0.5];
//    [[self window] setBackgroundColor:semiTransparentBlue];
    
    NSRect filterViewRect = [filterView frame];
//    filterViewRect.size.height = 0;
    filterViewRect.origin.y += [filterView defaultHeight];
    [filterView setFrame:filterViewRect];
    
    [messageTableViewController resizeTop:[filterView defaultHeight]];
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
    
    int overflowed = [[messageViewControllerArrayController arrangedObjects] count] - 50;
    if (overflowed > 0) {
        NSMutableArray* controllers = [NSMutableArray arrayWithArray:[messageViewControllerArrayController arrangedObjects]];
        while (overflowed > 0 && [controllers count] > 0) {
            TwitterStatusViewController* c = [controllers objectAtIndex:0];
            [controllers removeObject:c];
            if ([[c message] replyType] == NTLN_MESSAGE_REPLY_TYPE_NORMAL) {
                [messageViewControllerArrayController removeObject:c];
                overflowed--;
            }
            
        }
        
        [messageViewControllerArrayController removeObjectsAtArrangedObjectIndexes:
         [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, overflowed)]];
    }
    
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
    [messageLengthLabel setStringValue:@""];
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

#pragma mark Keyword Filter
- (BOOL) hasKeywordFilterTextFieldFocus {
    if (![[mainWindow firstResponder] isKindOfClass:[NSView class]]) {
        return FALSE;
    }

    NSView *v = (NSView*)[mainWindow firstResponder];
    while (v) {
        v = [v superview];
        if (v == filterView) {
            return TRUE;
        }
    }
    return FALSE;
}

- (void) openFilterViewInternal {
    //    if ([self hasKeywordFilterTextFieldFocus]) {
    //        return;
    //    }
    //    
    
    if (![filterView opened]) {
        NSRect fromViewFrame = [filterView frame];
        NSRect toViewFrame = fromViewFrame;
        toViewFrame.origin.y -= [filterView defaultHeight];
        
        //    NSLog(@"open: %f -> %f", fromViewFrame.origin.y, toViewFrame.origin.y);
        
        NSMutableDictionary *viewDict = [NSMutableDictionary dictionary];
        [viewDict setObject:filterView forKey:NSViewAnimationTargetKey];
        [viewDict setObject:[NSValue valueWithRect:fromViewFrame] forKey:NSViewAnimationStartFrameKey];
        [viewDict setObject:[NSValue valueWithRect:toViewFrame] forKey:NSViewAnimationEndFrameKey];
        
        NSRect fromListFrame = [[messageTableViewController viewForTabItem] frame];
        NSRect toListFrame = fromListFrame;
        toListFrame.size.height -= [filterView defaultHeight];
        
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
    
    _previousFirstResponder = [mainWindow firstResponder];
    if ([_previousFirstResponder isKindOfClass:[NSTextView class]]) {
        _previousFirstResponder = [self enclosingTextField:(NSTextView*)_previousFirstResponder];
    }
}

- (IBAction) openKeywordFilterView:(id)sender {
    [filterView changeContentToKeywordSearch];
    [self openFilterViewInternal];
    [filterView postOpen];
    [filterView filterByQuery:nil];
}

- (IBAction) openScreenNameFilterView:(id)sender
{
    NTLNMessage *message = [messageTableViewController selectedMessage];
    NSMutableSet *screenNames = [NSMutableSet setWithCapacity:10];
    NTLNURLUtils *utils = [NTLNURLUtils utils];

    [screenNames addObject:[message screenName]];
    for (NSString *token in [utils tokenizeByID:[message text]]) {
        if ([utils isIDToken:token]) {
            [screenNames addObject:[token substringFromIndex:1]]; // remove @
        }
    }

    [filterView changeContentToScreenNameSearch];
    [self openFilterViewInternal];
    [filterView postOpen];
    [filterView filterByQuery:[screenNames allObjects]];
}

- (IBAction) closeFilterView:(id)sender {
    if (![filterView opened]) {
        return;
    }

    NSRect fromViewFrame = [filterView frame];
    NSRect toViewFrame = fromViewFrame;
    toViewFrame.origin.y += [filterView defaultHeight];
    
//    NSLog(@"close: %f -> %f", fromViewFrame.origin.y, toViewFrame.origin.y);

    NSMutableDictionary *viewDict = [NSMutableDictionary dictionary];
    [viewDict setObject:filterView forKey:NSViewAnimationTargetKey];
    [viewDict setObject:[NSValue valueWithRect:fromViewFrame] forKey:NSViewAnimationStartFrameKey];
    [viewDict setObject:[NSValue valueWithRect:toViewFrame] forKey:NSViewAnimationEndFrameKey];
    
    NSRect fromListFrame = [[messageTableViewController viewForTabItem] frame];
    NSRect toListFrame = fromListFrame;
    toListFrame.size.height += [filterView defaultHeight];
    
    NSMutableDictionary *listDict = [NSMutableDictionary dictionary];
    [listDict setObject:[messageTableViewController viewForTabItem] forKey:NSViewAnimationTargetKey];
    [listDict setObject:[NSValue valueWithRect:fromListFrame] forKey:NSViewAnimationStartFrameKey];
    [listDict setObject:[NSValue valueWithRect:toListFrame] forKey:NSViewAnimationEndFrameKey];

    NSViewAnimation *theAnim = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObjects:listDict, viewDict, nil]];
    [theAnim setDuration:0.15];
    [theAnim setAnimationCurve:NSAnimationEaseInOut];
    [theAnim startAnimation];
    [theAnim release];
    
    [filterView postClose];
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
    if (length > 0) {
        [messageLengthLabel setStringValue:[NSString stringWithFormat:@"%d", 140 - length]];
        switch (state) {
            case NTLN_LENGTH_STATE_NORMAL:
                [messageLengthLabel setToolTip:[NSString stringWithFormat:NSLocalizedString(@"%d characters remain", nil), 140 - length]];
                break;
            case NTLN_LENGTH_STATE_WARNING:
                [messageLengthLabel setToolTip:NSLocalizedString(@"Your message can be truncated because it's too long.", nil)];
                break;
            case NTLN_LENGTH_STATE_MAXIMUM:
                [messageLengthLabel setToolTip:NSLocalizedString(@"Your message will be truncated because it's too long.", nil)];
                break;
        }
    } else {
        [messageLengthLabel setStringValue:@""];
    }
}

#pragma mark TimelineSortOrderChangeObserver
- (void) timelineSortOrderChangeObserverSortOrderChanged {
    [messageTableViewController reloadTimelineSortDescriptors];
}

#pragma mark MessageViewListener
- (void) replyDesiredFor:(NTLNMessage*)message {
    switch ([message replyType]) {
        case NTLN_MESSAGE_REPLY_TYPE_DIRECT:
            [messageTextField addDmReplyTo:message];
            [messageTextField focusAndLocateCursorEnd];
            break;

        default:
            if ([[[messageTextField stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
                [messageRepliedTo release];
                [message retain];
                messageRepliedTo = message;
            }

            [messageTextField addReplyTo:message];
            [messageTextField focusAndLocateCursorEnd];
    }
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
    return [NSArray arrayWithObjects:@"messageView", @"refresh", @"markallasread", @"find", @"conversation", @"itunes", nil];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar {
    return [NSArray arrayWithObjects:@"messageView", @"refresh", @"markallasread", @"find", @"conversation", @"itunes", nil];
}

#pragma mark Actions

- (IBAction) sendMessage:(id) sender
{
    if ([[messageTextField stringValue] length] == 0) {
        return;
    }
    
    [messageTextField setEnabled:FALSE];
    
    if ([messageRepliedTo screenName] && [[messageTextField stringValue] rangeOfString:[messageRepliedTo screenName]].location != NSNotFound) {
        [appController sendReplyMessage:[messageTextField stringValue] toStatusId:[messageRepliedTo statusId]];
    } else if ([messageRepliedTo screenName]
               && [[messageTextField stringValue] rangeOfString:
                   [NSString stringWithFormat:@"(via %@)", [messageRepliedTo screenName]]].location != NSNotFound) {
        [appController sendReplyMessage:[messageTextField stringValue] toStatusId:[messageRepliedTo statusId]];
    } else {
        [appController sendMessage:[messageTextField stringValue]];
    }
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

- (IBAction) replyToSelectedMessage:(id)sender
{
    [self replyDesiredFor:[messageTableViewController selectedMessage]];
}

- (IBAction) repostSelectedMessage:(id)sender
{
    NTLNMessage *message = [messageTableViewController selectedMessage];
    if ([message replyType] == NTLN_MESSAGE_REPLY_TYPE_DIRECT) {
        return;
    }

    [messageRepliedTo release];
    [message retain];
    messageRepliedTo = message;
            
    [messageTextField setRepostMessage:message];
    [messageTextField focusAndLocateCursorEnd];
}

- (IBAction) setPlayingTrackName:(id)sender
{
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    if ([iTunes isRunning]) {
        iTunesTrack *current = [iTunes currentTrack];
        [messageTextField setStringValue:[[messageTextField stringValue] stringByAppendingFormat:@"Now Playing: %@ (%@)", [current name], [current artist]]];
        [messageTextField focusAndLocateCursorEnd];
    }
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
