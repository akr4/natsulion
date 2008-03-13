#import "NTLNMainWindowController.h"
#import "NTLNPreferencesWindowController.h"
#import "NTLNAccount.h"
#import "TwitterStatusViewController.h"
#import "TwitterStatus.h"
#import "NTLNErrorMessageViewController.h"
#import "TwitterTestStub.h"
#import "NTLNConfiguration.h"
#import "NTLNColors.h"
#import "NTLNNotification.h"

@implementation NTLNMainWindowController

#pragma mark Initialization
- (id) init {
    _twitter = [[TwitterImpl alloc] initWithCallback:self];
//    _twitter = [[TwitterTestStub alloc] init];
    
    [NTLNConfiguration setTimelineSortOrderChangeObserver:self];
    
    _messageNotifier = [[NTLNBufferedMessageNotifier alloc] initWithTimeout:5.0 maxMessage:20];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(addNewMessage:)
                                                 name:NTLN_NOTIFICATION_NEW_MESSAGE_RECEIVED
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(statisticsDisplaySettingChanged:)
                                                 name:NTLN_NOTIFICATION_STATISTICS_DISPLAY_SETTING_CHANGED
                                               object:nil];

    return self;
}

- (void) dealloc {
    [_twitter release];
    [_toolbarItems release];
    [_messageNotifier release];
    [super dealloc];
}

- (void) changeViewByMenu:(id)sender {
    [_messageViewSelector setSelected:TRUE forSegment:[sender tag]];
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
    _messageViewSelector = [[[NSSegmentedControl alloc] initWithFrame:NSMakeRect(0, 0, 260, 25)] autorelease];
    [_messageViewSelector setSegmentCount:4];
    [_messageViewSelector setLabel:@"Friends" forSegment:0];
    [_messageViewSelector setLabel:@"Replies" forSegment:1];
    [_messageViewSelector setLabel:@"Sent" forSegment:2];
    [_messageViewSelector setLabel:@"Unread" forSegment:3];
    [_messageViewSelector setSelected:TRUE forSegment:0];
    [_messageViewSelector setTarget:messageListViewsController];
    [_messageViewSelector setAction:@selector(changeViewByToolbar:)];
    NSToolbarItem *messageViewSelectorToolbarItem = [self addToolbarItemWithIdentifier:@"messageView" 
                                                                                 label:@"View Mode"
                                                                                target:messageListViewsController 
                                                                                action:@selector(changeView:)
                                                                                  view:_messageViewSelector];
    // action and keyEquivalent is not used
    NSMenuItem *item = [[[NSMenuItem alloc] init] autorelease];
    [item setTitle:@"View Mode"];
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
    [item setSubmenu:viewTextMenu];
    [messageViewSelectorToolbarItem setMenuFormRepresentation:item];
    
    
    // refresh button
    NSButton *refreshButton = [[[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 25, 25)] autorelease];
    [refreshButton setImage:[NSImage imageNamed:NSImageNameRefreshTemplate]];
    [refreshButton setBezelStyle:NSTexturedSquareBezelStyle];
    [refreshButton setTarget:self];
    [refreshButton setAction:@selector(updateTimelineCorrespondsToView:)];
    [self addToolbarItemWithIdentifier:@"refresh"
                                 label:@"Refresh"
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
                                 label:@"Mark all as read"
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
    
    [statisticsTextField setToolTip:@"number of posted messages"];
    [messagePostLevelIndicator setToolTip:@"timeline speed"];
    [messagePostLevelIndicator setHidden:![[NTLNConfiguration instance] showMessageStatisticsOnStatusBar]];
    
    //    NSColor *semiTransparentBlue =
//    [NSColor colorWithDeviceRed:0.0 green:0.0 blue:1.0 alpha:0.5];
//    [[self window] setBackgroundColor:semiTransparentBlue];
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

- (void) addMessageViewController:(NTLNMessageViewController*)controller {
    [messageViewControllerArrayController addObject:controller];
    [messageListViewsController applyCurrentPredicate];
    [messageTableViewController newMessageArrived:[NSArray arrayWithObject:controller]];
}

- (void) addMessageViewControllers:(NSArray*)controllers {
//    NSLog(@"%s: count:%d", __PRETTY_FUNCTION__, [controllers count]);
    [messageViewControllerArrayController addObjects:controllers];
    [messageListViewsController applyCurrentPredicate];
    [messageTableViewController newMessageArrived:controllers];
}

- (BOOL) isNewMessage:(TwitterStatusViewController*)controller {
    if ([messageViewControllerArray containsObject:controller] || [_messageNotifier contains:controller]) {
        return FALSE;
    }
    return TRUE;
}

- (void) updateStatus {
    NSString *password = [[NTLNAccount instance] password];
    if (!password) {
        // TODO inform error to user
        NSLog(@"password not set. skip updateStatus");
        return;
    }
    [_twitter friendTimelineWithUsername:[[NTLNAccount instance] username]
                                password:password
                                 usePost:[[NTLNConfiguration instance] usePost]];
}

- (void) updateReplies {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSString *password = [[NTLNAccount instance] password];
    if (!password) {
        // TODO inform error to user
        NSLog(@"password not set. skip updateStatus");
        return;
    }
    [_twitter repliesWithUsername:[[NTLNAccount instance] username]
                         password:password
                          usePost:[[NTLNConfiguration instance] usePost]];
}

- (void) updateSentMessages {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSString *password = [[NTLNAccount instance] password];
    if (!password) {
        // TODO inform error to user
        NSLog(@"password not set. skip updateStatus");
        return;
    }
    [_twitter sentMessagesWithUsername:[[NTLNAccount instance] username]
                              password:password
                               usePost:[[NTLNConfiguration instance] usePost]];
}

- (IBAction) sendMessage:(id) sender {
    if ([[messageTextField stringValue] length] == 0) {
        return;
    }
    
    NSString *password = [[NTLNAccount instance] password];
    if (!password) {
        // TODO inform error to user
        NSLog(@"password not set. skip updateStatus");
        return;
    }
    [messageTextField setEnabled:FALSE];
    [_twitter sendMessage:[messageTextField stringValue]
                 username:[[NTLNAccount instance] username]
                 password:password];
}

- (void) enableMessageTextField {
    [messageTextField setStringValue:@""];
    [messageTextField setEditable:TRUE];
    [messageTextField setEnabled:TRUE];
    [messageTextField updateHeight];
    [statusTextField setStringValue:@""];
}

#pragma mark Statistics

- (void) setMessagePostLevel:(float)level {
    [messagePostLevelIndicator setFloatValue:level];
}

- (void) setMessageStatisticsField:(NSString*)value {
    [statisticsTextField setStringValue:value];
}

#pragma mark TwitterPostCallback
- (void) finishedToPost {
    [self enableMessageTextField];
    [messageTextField focusAndLocateCursorEnd];
}

- (void) failedToPost:(NSString*)message {
    [self addMessageViewController:[NTLNErrorMessageViewController controllerWithTitle:@"Sending a message failed"
                                                                           message:message
                                                                         timestamp:[NSDate date]]];    
    [self enableMessageTextField];
}

#pragma mark TimelineCallback
- (void) finishedToGetTimeline:(NSArray*)statuses {
    for (int i = 0; i < [statuses count]; i++) {
        TwitterStatus *s = [statuses objectAtIndex:i];
        TwitterStatusViewController *controller = [[[TwitterStatusViewController alloc]
                                                    initWithTwitterStatus:(TwitterStatus*)s
                                                    messageViewListener:self] autorelease];
        if ([self isNewMessage:controller]) {
            [_messageNotifier addMessageViewController:controller];
            [progressIndicator startTask];
        }
    }
}

- (void) failedToGetTimeline:(NTLNErrorInfo*)info {
    NSString *message;
    
    switch ([info type]) {
        case NTLN_ERROR_TYPE_HIT_API_LIMIT:
            message = @"Reached API Limitation";
            break;
        case NTLN_ERROR_TYPE_NOT_AUTHORIZED:
            message = @"Not Authorized";
            break;
        case NTLN_ERROR_TYPE_SERVER_ERROR:
            message = @"Twitter Server Error";
            break;
        case NTLN_ERROR_TYPE_CONNECTION:
            if ([info originalMessage]) {
                message = [info originalMessage];
            } else {
                message = @"Connection Error";
            }
            break;
        case NTLN_ERROR_TYPE_OTHER:
        default:
            message = @"Unknown Error (might be a server error)";
            break;
    }
    [self addMessageViewController:[NTLNErrorMessageViewController controllerWithTitle:@"Retrieving timeline failed"
                                                                           message:message
                                                                         timestamp:[NSDate date]]];
}

- (void) twitterStartTask {
    [progressIndicator startTask];
}

- (void) twitterStopTask {
    [progressIndicator stopTask];
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

- (void) createFavoriteDesiredFor:(NSString*)statusId {
    NSString *password = [[NTLNAccount instance] password];
    if (!password) {
        // TODO inform error to user
        NSLog(@"password not set. skip create favorite");
        return;
    }
    _createFavoriteIsWorking = TRUE;
    [_twitter createFavorite:statusId
                    username:[[NTLNAccount instance] username]
                    password:password];
}

- (float) viewWidth {
    return [messageTableViewController columnWidth];
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
    [mainWindow setAlphaValue:1.0f];
}

- (void)windowDidResignMain:(NSNotification *)notification {
    [mainWindow setAlphaValue:0.3f];
}

#pragma mark TwitterFavoriteCallback
- (void) finishedToChangeFavorite:(NSString*)statusId {           
    for (int i = 0; i < [[messageViewControllerArrayController arrangedObjects] count]; i++) {
        NTLNMessageViewController *c = [[messageViewControllerArrayController arrangedObjects] objectAtIndex:i];
        if ([statusId isEqualToString:[[c message] statusId]]) {
            [c favoriteCreated];
            break;
        }
    }
    _createFavoriteIsWorking = FALSE;
}

- (void) failedToChangeFavorite:(NSString*)statusId errorInfo:(NTLNErrorInfo*)info {
    for (int i = 0; i < [[messageViewControllerArrayController arrangedObjects] count]; i++) {
        NTLNMessageViewController *c = [[messageViewControllerArrayController arrangedObjects] objectAtIndex:i];
        if ([statusId isEqualToString:[[c message] statusId]]) {
            [c favoriteCreationFailed];
            break;
        }
    }
    _createFavoriteIsWorking = FALSE;
}

- (BOOL) isCreatingFavoriteWorking {
    return _createFavoriteIsWorking;
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

- (IBAction) updateTimelineCorrespondsToView:(id)sender {
    switch ([_messageViewSelector selectedSegment]) {
        case 0:
        case 3:
            [self updateStatus];
            break;
        case 1:
            [self updateReplies];
            break;
        case 2:
            [self updateSentMessages];
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
- (void) addNewMessage:(NSNotification*)notification {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSArray *messageArray = [notification object];
    for (int i = 0; i < [messageArray count]; i++) {
        TwitterStatusViewController *controller = [messageArray objectAtIndex:i];
        NTLNMessage *s = [controller message];
        if ([s replyType] == MESSAGE_REPLY_TYPE_REPLY || [s replyType] == MESSAGE_REPLY_TYPE_REPLY_PROBABLE) {
            if ([[NTLNConfiguration instance] latestTimestampOfMessage] < [[s timestamp] timeIntervalSince1970]) {
                [[NTLNConfiguration instance] setLatestTimestampOfMessage:[[s timestamp] timeIntervalSince1970]];
            } else {
                // might be retrieved in previous run
                [controller markAsRead:false];
            }
        }
        [progressIndicator stopTask];
    }
    
    // adding
    [messageViewControllerArrayController setFilterPredicate:nil];
    [self addMessageViewControllers:messageArray];
    [[NSNotificationCenter defaultCenter] postNotificationName:NTLN_NOTIFICATION_NEW_MESSAGE_ADDED object:messageArray];
    
    if ([[NTLNConfiguration instance] raiseWindowWhenNewMessageArrives]) {
        [mainWindow makeKeyAndOrderFront:nil];
    }
}

- (void) statisticsDisplaySettingChanged:(NSNotification*)notification {
    BOOL show = [[notification object] boolValue];
    [messagePostLevelIndicator setHidden:!show];
    [statisticsTextField setHidden:!show];
}

@end
