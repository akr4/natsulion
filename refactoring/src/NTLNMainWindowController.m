#import "NTLNMainWindowController.h"
#import "NTLNPreferencesWindowController.h"
#import "NTLNAccount.h"
#import "TwitterStatusViewController.h"
#import "TwitterStatus.h"
#import "NTLNErrorMessageViewController.h"
#import "TwitterTestStub.h"
#import "NTLNConfiguration.h"

@implementation NTLNMainWindowController

- (id) init {
    _twitter = [[TwitterImpl alloc] init];
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
    [super dealloc];
}

- (void) awakeFromNib {
    [mainWindow setReleasedWhenClosed:FALSE];
    
    [messageTextField setCallback:self];
    [messageTextField setLengthForWarning:140 max:160];
    
    [self bind:@"windowTransparency"
      toObject:[NSUserDefaultsController sharedUserDefaultsController] 
   withKeyPath:@"values.windowTransparency"
       options:nil];
}

- (NSArray*) timelineSortDescriptors {
    //    NSString *sortOrder = [[NSUserDefaults standardUserDefaults] stringForKey:@"timelineSortOrder"];
    return [NSArray arrayWithObject:[[[NSSortDescriptor alloc] 
                                      initWithKey:@"timestamp" 
                                      ascending:([[NTLNConfiguration instance] timelineSortOrder] == NTLN_CONFIGURATION_TIMELINE_SORT_ORDER_ASCENDING)] autorelease]];
}

// this method is not needed actually but called by array controller's binding
- (void) setTimelineSortDescriptors:(NSArray*)descriptors {
}

- (void) enableGrowl {
    _growlEnabled = TRUE;
    [_afterLaunchedTimer release];
//    NSLog(@"growl enabled");
}

- (void) setWindowTransparency:(float)alpha {
    [mainWindow setAlphaValue:alpha];
}

- (float) windowTransparency {
    return [mainWindow alphaValue];
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

// progress indicators ///////////////////////////////////////////////////////////

- (void) downloadStarted {
    [downloadProgress startAnimation:self];
}

- (void) downloadStopped {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [downloadProgress stopAnimation:self];
}

- (void) postStarted {
    [postProgress startAnimation:self];
}

- (void) postStopped {
    [postProgress stopAnimation:self];
}


- (void) addMessageViewController:(NTLNMessageViewController*)controller {
    [messageViewControllerArrayController addObject:controller];
    [messageTableViewController newMessageArrived:controller];
//    NSLog(@"count: %d", [[messageViewControllerArrayController arrangedObjects] count]);
}

- (BOOL) addIfNewMessage:(NTLNMessage*)message {
    TwitterStatusViewController *newController = [[[TwitterStatusViewController alloc]
                                                   initWithTwitterStatus:(TwitterStatus*)message
                                                   messageViewListener:self] autorelease];
    
    if ([[messageViewControllerArrayController arrangedObjects] containsObject:newController]) {
        return FALSE;
    }
    
    [self addMessageViewController:newController];
    return TRUE;
}

- (void) updateStatus {
    NSString *password = [[NTLNAccount instance] password];
    if (!password) {
        // TODO inform error to user
        NSLog(@"password not set. skip updateStatus");
        return;
    }
    [self downloadStarted];
    [_twitter friendTimelineWithUsername:[[NTLNAccount instance] username]
                                password:password
                                 usePost:[[NTLNConfiguration instance] usePost]
                                callback:self];
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
    [self postStarted];
    [_twitter sendMessage:[messageTextField stringValue]
                 username:[[NTLNAccount instance] username]
                 password:password
                 callback:self];
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

// TwitterPostCallback methods ///////////////////////////////////////////////////
- (void) finishedToPost {
    [self enableMessageTextField];
    [self focusMessageTextFieldAndLocateCursorEnd];
    [self postStopped];
}

- (void) failedToPost:(NSString*)message {
    [self addMessageViewController:[NTLNErrorMessageViewController controllerWithTitle:@"Sending a message failed"
                                                                           message:message
                                                                         timestamp:[NSDate date]]];    
    [self enableMessageTextField];
    [self postStopped];
}

// TimelineCallback methods ///////////////////////////////////////////////////////
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
    [self downloadStopped];
    
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

- (void) finishedAll {
    [self downloadStopped];
}

// MessageInputTextField callback ///////////////////////////////////////////////////////
- (void) messageInputTextFieldResized:(float)heightDelta {
    [self windowTransparency];

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

// TimelineSortOrderChangeObserver //////////////////////////////////////////////////
- (void) timelineSortOrderChangeObserverSortOrderChanged {
    [messageViewControllerArrayController setSortDescriptors:[self timelineSortDescriptors]];
    [messageViewControllerArrayController rearrangeObjects];
    [messageTableViewController reloadTableView];
}

// MessageViewListener ////////////////////////////////////////////////////////////////
- (void) replyDesiredFor:(NSString*)username {
    [messageTextField addReplyTo:username];
    [self focusMessageTextFieldAndLocateCursorEnd];
}

- (float) viewWidth {
    return [messageTableViewController columnWidth];
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
                    password:password
                    callback:self];
}

// NSWindow delegate methods ////////////////////////////////////////////////////////
- (void)windowDidResize:(NSNotification *)notification {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
    [messageTableViewController recluculateViewSizes];
    [messageTableViewController reloadTableView];
}

// TwitterFavoriteCallback /////////////////////////////////////////////////////////////

- (void) finishedToChangeFavorite:(NSString*)statusId {
    for (NTLNMessageViewController *c in [messageViewControllerArrayController arrangedObjects]) {
        if ([statusId isEqualToString:[[c message] statusId]]) {
            [c favoriteCreated];
            break;
        }
    }
    _createFavoriteIsWorking = FALSE;
}

- (void) failedToChangeFavorite:(NSString*)statusId errorInfo:(NTLNErrorInfo*)info {
    for (NTLNMessageViewController *c in [messageViewControllerArrayController arrangedObjects]) {
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

@end
