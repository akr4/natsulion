#import "NTLNMainWindowController.h"
#import "NTLNPreferencesWindowController.h"
#import "NTLNAccount.h"
#import "TwitterStatusViewController.h"
#import "TwitterStatus.h"
#import "NTLNErrorMessageViewController.h"
#import "TwitterTestStub.h"
#import "NTLNConfiguration.h"
#import "NTLNColors.h"

@implementation NTLNMainWindowController

#pragma mark Initialization
- (id) init {
    _twitter = [[TwitterImpl alloc] initWithCallback:self];
//    _twitter = [[TwitterTestStub alloc] init];
    _growlEnabled = FALSE;
    
    _afterLaunchedTimer = [[NSTimer scheduledTimerWithTimeInterval:60 // TODO: consider refreshInterval
                                                            target:self
                                                          selector:@selector(enableGrowl)
                                                          userInfo:nil
                                                           repeats:FALSE] retain];
    [NTLNConfiguration setTimelineSortOrderChangeObserver:self];
    return self;
}

- (void) dealloc {
    [_twitter release];
    [_growl release];
    [_afterLaunchedTimer release];
    [_toolbarItems release];
    [super dealloc];
}

- (void) changeViewByMenu:(id)sender {
    [_messageViewSelector setSelected:TRUE forSegment:[sender tag]];
    [messageListViewsController changeViewByMenu:sender];
}

- (void) addMenuItemWithTitle:(NSString*)title target:(id)target action:(SEL)action keyEquivalent:(NSString*)keyEquivalent tag:(int)tag toMenu:(NSMenu*) menu {
    NSMenuItem *item = [[[NSMenuItem alloc] initWithTitle:title action:action keyEquivalent:keyEquivalent] autorelease];
    [item setTarget:target];
    [item setTag:tag];
    [menu addItem:item];
}

- (void) addToolbarItemWithIdentifier:(NSString*)identifier label:(NSString*)label target:(id)target action:(SEL)action view:(NSView*)view {
    NSToolbarItem *item = [[[NSToolbarItem alloc] initWithItemIdentifier:identifier] autorelease];
    [item setLabel:label];
    [item setTarget:target];
    [item setAction:action];
    [item setView:view];
    [_toolbarItems setObject:item forKey:[item itemIdentifier]];
}

- (void) setupMenuAndToolbar {
    NSToolbar *toolbar=[[[NSToolbar alloc] initWithIdentifier:@"mainToolbar"] autorelease];
    [toolbar setDelegate:self];
    [toolbar setAutosavesConfiguration:YES];
    [toolbar setAllowsUserCustomization:YES];
    [toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
    
    _toolbarItems = [[NSMutableDictionary alloc] init];
    
    // setup segumented control
    _messageViewSelector = [[[NSSegmentedControl alloc] initWithFrame:NSMakeRect(0, 0, 235, 25)] autorelease];
    [_messageViewSelector setSegmentCount:3];
    [_messageViewSelector setLabel:@"Friends" forSegment:0];
    [_messageViewSelector setLabel:@"Replies" forSegment:1];
    [_messageViewSelector setLabel:@"My Updates" forSegment:2];
    [_messageViewSelector setSelected:TRUE forSegment:0];
    [_messageViewSelector setTarget:messageListViewsController];
    [_messageViewSelector setAction:@selector(changeViewByToolbar:)];
    [self addToolbarItemWithIdentifier:@"messageView" 
                                 label:@"View Mode"
                                target:messageListViewsController 
                                action:@selector(changeView:)
                                  view:_messageViewSelector];
    
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
    [[self window] setToolbar:toolbar];

    // menu
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

    [self addMenuItemWithTitle:@"My Updates"
                        target:self
                        action:@selector(changeViewByMenu:)
                 keyEquivalent:@"3" 
                           tag:2 
                        toMenu:viewMenu];
}

- (void) awakeFromNib {
    [mainWindow setReleasedWhenClosed:FALSE];
    
    [messageTextField setCallback:self];
    [messageTextField setLengthForWarning:140 max:160];
    
    [self setupMenuAndToolbar];
    [[self window] setOpaque:FALSE];
    
    //    NSColor *semiTransparentBlue =
//    [NSColor colorWithDeviceRed:0.0 green:0.0 blue:1.0 alpha:0.5];
//    [[self window] setBackgroundColor:semiTransparentBlue];
}

// this method is not needed actually but called by array controller's binding
- (void) setTimelineSortDescriptors:(NSArray*)descriptors {
}

- (void) enableGrowl {
    _growlEnabled = TRUE;
    [_afterLaunchedTimer release];
//    NSLog(@"growl enabled");
}

- (void) showWindowToFront {
    [[self window] makeKeyAndOrderFront:nil];
}

- (void) setFrameAutosaveName:(NSString*)name {
    [mainWindow setFrameAutosaveName:name];
}

- (void) sendToGrowlTitle:(NSString*)title
           andDescription:(NSString*)description
                  andIcon:(NSData*)iconData 
              andPriority:(int)priority
                andSticky:(BOOL)sticky {
    if (!_growlEnabled || ![[NSUserDefaults standardUserDefaults] boolForKey:NTLN_PREFERENCE_USE_GROWL]) {
        return;
    }
    
    if (!_growl) {
        _growl = [[NTLNGrowlNotifier alloc] init];
    }

    [_growl sendToGrowlTitle:title
              andDescription:description
                     andIcon:iconData
                 andPriority:priority
                   andSticky:sticky];
}

- (void) addMessageViewController:(NTLNMessageViewController*)controller {
    [messageViewControllerArrayController addObject:controller];
    [messageListViewsController applyCurrentPredicate];
    [messageTableViewController newMessageArrived:controller];
}

- (BOOL) addIfNewMessage:(NTLNMessage*)message {
    TwitterStatusViewController *newController = [[[TwitterStatusViewController alloc]
                                                   initWithTwitterStatus:(TwitterStatus*)message
                                                   messageViewListener:self] autorelease];
    
    [messageViewControllerArrayController setFilterPredicate:nil];
    if ([[messageViewControllerArrayController arrangedObjects] containsObject:newController]) {
        return FALSE;
    }
    
    [self addMessageViewController:newController];
    return TRUE;
}

- (void) updateStatus {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
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

- (void) focusMessageTextFieldAndLocateCursorEnd {
    [[self window] makeFirstResponder:messageTextField];
    [(NSText *)[[messageTextField window] firstResponder] setSelectedRange:NSMakeRange([[messageTextField stringValue] length], 0)];
}

#pragma mark TwitterPostCallback
- (void) finishedToPost {
    [self enableMessageTextField];
    [self focusMessageTextFieldAndLocateCursorEnd];
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
        if ([self addIfNewMessage:s]) {
            int priority = 0;
            BOOL sticky = FALSE;
            switch ([s replyType]) {
                case MESSAGE_REPLY_TYPE_REPLY:
                    priority = 2;
                    sticky = TRUE;
                    break;
                case MESSAGE_REPLY_TYPE_REPLY_PROBABLE:
                    priority = 1;
                    sticky = TRUE;
                    break;
                default:
                    break;
            }
            
            [self sendToGrowlTitle:[s name]
                    andDescription:[s text]
                           andIcon:[[s icon] TIFFRepresentation]
                       andPriority:priority
                         andSticky:sticky];
            
            if ([[NSUserDefaults standardUserDefaults] boolForKey:NTLN_PREFERENCE_SHOW_WINDOW_WHEN_NEW_MESSAGE]) {
                [mainWindow makeKeyAndOrderFront:nil];
            }
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
    [self focusMessageTextFieldAndLocateCursorEnd];
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
- (void)windowDidResize:(NSNotification *)notification {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
    [messageTableViewController recalculateViewSizes];
    [messageTableViewController reloadTableView];
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
    return [NSArray arrayWithObjects:@"messageView", @"refresh", nil];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar {
    return [NSArray arrayWithObjects:@"messageView", @"refresh", nil];
}

- (IBAction) updateTimelineCorrespondsToView:(id)sender {
    switch ([_messageViewSelector selectedSegment]) {
        case 0:
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

@end
