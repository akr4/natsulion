#import "MainWindowController.h"
#import "PreferencesWindow.h"
#import "Account.h"
#import "TwitterStatusViewController.h"
#import "TwitterStatus.h"
#import "ErrorMessageViewController.h"

@implementation MainWindowController

- (id) init {
    _twitter = [[Twitter alloc] init];
    _growlEnabled = FALSE;
    _afterLaunchedTimer = [[NSTimer scheduledTimerWithTimeInterval:60 // TODO: consider refreshInterval
                                                            target:self
                                                          selector:@selector(enableGrowl)
                                                          userInfo:nil
                                                           repeats:FALSE] retain];
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
}

- (NSArray*) timelineSortDescriptors {
    //    NSString *sortOrder = [[NSUserDefaults standardUserDefaults] stringForKey:@"timelineSortOrder"];
    return [NSArray arrayWithObject:[[[NSSortDescriptor alloc] 
                                      initWithKey:@"timestamp" 
                                      ascending:([configuration timelineSortOrder] == NTLN_CONFIGURATION_TIMELINE_SORT_ORDER_ASCENDING)] autorelease]];
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
    if (!_growlEnabled || ![[NSUserDefaults standardUserDefaults] boolForKey:PREFERENCE_USE_GROWL]) {
        return;
    }
    
    if (!_growl) {
        _growl = [[GrowlNotifier alloc] init];
    }

    [_growl sendToGrowlTitle:title
              andDescription:description
                     andIcon:iconData
                 andPriority:priority
                   andSticky:sticky];
}

- (BOOL) isNewMessage:(Message*)message {
    TwitterStatusViewController *newController = [[[TwitterStatusViewController alloc] initWithTwitterStatus:(TwitterStatus*)message] autorelease];
    return ![[messageViewControllerArrayController arrangedObjects] containsObject:newController];
}

- (void) addMessageViewController:(MessageViewController*)controller {
    [messageViewControllerArrayController addObject:controller];
    [messageTableViewController newMessageArrived];
}

- (void) addIfNewMessage:(Message*)message {
    TwitterStatusViewController *newController = [[[TwitterStatusViewController alloc] initWithTwitterStatus:(TwitterStatus*)message] autorelease];
    
    if ([[messageViewControllerArrayController arrangedObjects] containsObject:newController]) {
        return;
    }
    
    [self addMessageViewController:newController];
}

- (void) updateStatus {
    NSString *password = [[Account instance] password];
    if (!password) {
        // TODO inform error to user
        NSLog(@"password not set. skip updateStatus");
        return;
    }
    [_twitter friendTimelineWithUsername:[[Account instance] username]
                                password:password
                                callback:self];
}

- (IBAction) sendMessage:(id) sender {    
    NSString *password = [[Account instance] password];
    if (!password) {
        // TODO inform error to user
        NSLog(@"password not set. skip updateStatus");
        return;
    }
    [messageTextField setEnabled:FALSE];
    [_twitter sendMessage:[messageTextField stringValue]
                 username:[[Account instance] username]
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


// TwitterPostCallback methods ///////////////////////////////////////////////////
- (void) finishedToPost {
    [self enableMessageTextField];
}

- (void) failedToPost:(NSString*)message {
    [self addMessageViewController:[ErrorMessageViewController controllerWithTitle:@"Sending a message failed"
                                                                           message:message
                                                                         timestamp:[NSDate date]]];    
    [self enableMessageTextField];
}

// TimelineCallback methods ///////////////////////////////////////////////////////
- (void) finishedToGetTimeline:(NSArray*)statuses {
    int i;
    for (i = 0; i < [statuses count]; i++) {
        TwitterStatus *s = [statuses objectAtIndex:i];
        if ([self isNewMessage:s]) {
            [self addIfNewMessage:s];
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
            
            if ([[NSUserDefaults standardUserDefaults] boolForKey:PREFERENCE_SHOW_WINDOW_WHEN_NEW_MESSAGE]) {
                [mainWindow makeKeyAndOrderFront:nil];
            }
        }
    }
}

- (void) failedToGetTimeline:(NSString*)message {
    [self addMessageViewController:[ErrorMessageViewController controllerWithTitle:@"Retrieving timeline failed"
                                                                           message:message
                                                                         timestamp:[NSDate date]]];
}

- (void) started {
    [downloadProgress startAnimation:self];
}

- (void) stopped {
    [downloadProgress stopAnimation:self];
}

// MessageInputTextField callback ///////////////////////////////////////////////////////
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

// TimelineSortOrderChangeObserver //////////////////////////////////////////////////
- (void) timelineSortOrderChangeObserverSortOrderChanged {
    [messageViewControllerArrayController setSortDescriptors:[self timelineSortDescriptors]];
    [messageViewControllerArrayController rearrangeObjects];
    [messageTableViewController reloadTableView];
}

@end
