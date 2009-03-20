#import "NTLNAppController.h"
#import "NTLNPreferencesWindowController.h"
#import "NTLNAccount.h"
#import "NTLNConfiguration.h"
#import "NTLNNotification.h"
#import "NTLNMultiTasksProgressIndicator.h"
#import "TwitterStatusViewController.h"
#import "Adium.h"

//#pragma mark -
//OSStatus handleHotKey(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData)
//{
//    NSLog(@"hotkey pressed!");
//    //    [userData showWindow];
//    return noErr;
//}
//
@implementation NTLNAppController

+ (void) setupDefaults {
    NSString *userDefaultsValuesPath = [[NSBundle mainBundle] pathForResource:@"UserDefaults" 
                                                                       ofType:@"plist"]; 
    NSDictionary *userDefaultsValuesDict = [NSDictionary dictionaryWithContentsOfFile:userDefaultsValuesPath]; 
    [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsValuesDict]; 
}

#pragma mark -
#pragma mark initialization

+ (void) initialize {
//    NSLog(@"%s", __PRETTY_FUNCTION__); 
    [NTLNAppController setupDefaults];
    [NSColor setIgnoresAlpha:FALSE];
}

- (id) init {
    _growlEnabled = FALSE;
    [NSTimer scheduledTimerWithTimeInterval:60 // TODO: consider refreshInterval
                                     target:self
                                   selector:@selector(enableGrowl)
                                   userInfo:nil
                                    repeats:FALSE];
    
    _goodNightEnabled = FALSE;
    [NSTimer scheduledTimerWithTimeInterval:180
                                     target:self
                                   selector:@selector(enableGoodNight)
                                   userInfo:nil
                                    repeats:FALSE];

    _messageCountHistory = [[NSMutableArray alloc] initWithCapacity:30];
    _numberOfPostedMessages = 0;
    
    _twitter = [[TwitterImpl alloc] initWithCallback:self];

    return self;
}

- (void) dealloc {
    [_friendsTimelineRefreshTimer release];
    [_repliesRefreshTimer release];
    [_directMessagesRefreshTimer release];
    [_badge release];
    [_growl release];
    [_messageCountHistory release];
    [_messageNotifier release];
    [_twitter release];
    [super dealloc];
}

- (void) awakeFromNib { 
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(messageChangedToRead:)
                                                 name:NTLN_NOTIFICATION_MESSAGE_STATUS_MARKED_AS_READ
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(addNewMessageWithControllers:)
                                                 name:NTLN_NOTIFICATION_NEW_MESSAGE_RECEIVED
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(messageAdded:)
                                                 name:NTLN_NOTIFICATION_NEW_MESSAGE_ADDED
                                               object:nil];
    
    _messageNotifier = [[NTLNBufferedMessageNotifier alloc] initWithTimeout:5.0 maxMessage:20 progressIndicator:progressIndicator];

    _badge = [[CTBadge alloc] init];
    
    // global hotkey
//    EventHotKeyRef gMyHotKeyRef;
//    EventHotKeyID gMyHotKeyID;
//    EventTypeSpec eventType;
//    eventType.eventClass=kEventClassKeyboard;
//    eventType.eventKind=kEventHotKeyPressed;
//    InstallApplicationEventHandler(&handleHotKey, 1, &eventType, self, NULL);
//    gMyHotKeyID.signature = 'post';
//    gMyHotKeyID.id = 1;
//    
//    RegisterEventHotKey(49, cmdKey+optionKey, gMyHotKeyID, 
//                        GetApplicationEventTarget(), 0, &gMyHotKeyRef);
}

#pragma mark Timer

- (void) restartFriendsTimelineRefreshTimer
{
    if (_friendsTimelineRefreshTimer) {
        [_friendsTimelineRefreshTimer invalidate];
        [_friendsTimelineRefreshTimer release];
    }
    
    _friendsTimelineRefreshTimer = [[NSTimer scheduledTimerWithTimeInterval:_refreshInterval
                                                                     target:self
                                                                   selector:@selector(expireFriendsTimelineRefreshInterval)
                                                                   userInfo:nil
                                                                    repeats:YES] retain];
}

- (void) restartFriendsTimelineRefreshTimerAfter:(int)next
{
    if (_friendsTimelineRefreshTimer) {
        [_friendsTimelineRefreshTimer invalidate];
        [_friendsTimelineRefreshTimer release];
    }
    
    _friendsTimelineRefreshTimer = [[NSTimer scheduledTimerWithTimeInterval:next
                                                                     target:self
                                                                   selector:@selector(expireFriendsTimelineRefreshInterval)
                                                                   userInfo:nil
                                                                    repeats:YES] retain];
}

- (void) restartRepliesRefreshTimer
{
    if (_repliesRefreshTimer) {
        [_repliesRefreshTimer invalidate];
        [_repliesRefreshTimer release];
    }

    _repliesRefreshTimer = [[NSTimer scheduledTimerWithTimeInterval:_refreshInterval * 8.5
                                                             target:self
                                                           selector:@selector(expireRepliesRefreshInterval)
                                                           userInfo:nil
                                                            repeats:YES] retain];
}

- (void) restartDirectMessagesRefreshTimer
{
    if (_directMessagesRefreshTimer) {
        [_directMessagesRefreshTimer invalidate];
        [_directMessagesRefreshTimer release];
    }

    _directMessagesRefreshTimer = [[NSTimer scheduledTimerWithTimeInterval:_refreshInterval * 10.5
                                                                    target:self
                                                                  selector:@selector(expireDirectMessagesRefreshInterval)
                                                                  userInfo:nil
                                                                   repeats:YES] retain];
}

- (void) expireFriendsTimelineRefreshInterval
{
    [self updateStatus];
}

- (void) expireRepliesRefreshInterval
{
    [self updateReplies];
    
    // check rate limit status at this time
    [self rateLimitStatus];
}

- (void) expireDirectMessagesRefreshInterval
{
    [self updateDirectMessages];
}

- (void) restartTimer
{
    if (_refreshInterval < 30) {
        return;
    }

    [self restartFriendsTimelineRefreshTimer];
    [self restartRepliesRefreshTimer];
    [self restartDirectMessagesRefreshTimer];
}

- (int) refreshInterval {
    return _refreshInterval;
}

- (void) setRefreshInterval:(int)interval {
    _refreshInterval = interval;
    
    if ([[NTLNAccount instance] username]) {
        [self restartTimer];
    }
}

- (IBAction) showPreferencesSheet:(id)sender {
    [[NSApplication sharedApplication] beginSheet:[preferencesWindowController window]
                                   modalForWindow:[mainWindowController window]
                                    modalDelegate:self
                                   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) 
                                      contextInfo:nil];
}

- (IBAction) closePreferencesSheet:(id)sender {
    [[NSApplication sharedApplication] endSheet:[preferencesWindowController window] returnCode:0];
}

- (void)sheetDidEnd:(NSWindow*)sheet returnCode:(int)returnCode contextInfo:(void*)contextInfo {
    [[preferencesWindowController window] orderOut:self];
}

#pragma mark NSApplicatoin delegate methods
- (BOOL)applicationOpenUntitledFile:(NSApplication *)theApplication {
    //    NSLog(@"%s", __PRETTY_FUNCTION__);    
    [mainWindowController showWindowToFront];
    return TRUE;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
//    NSLog(@"%s", __PRETTY_FUNCTION__);    
    
    [mainWindowController setFrameAutosaveName:@"MainWindow"];
    
    [self bind:@"refreshInterval"
      toObject:[NSUserDefaultsController sharedUserDefaultsController] 
   withKeyPath:@"values.refreshIntervalSeconds"
       options:nil];
    
    [welcomeWindowController setWelcomeWindowControllerCallback:self];
    
    NSString *username = [[NTLNAccount instance] username];
    if (!username) {
        // first time
        [mainWindowController close];
      	[NSBundle loadNibNamed:@"Welcome" owner:welcomeWindowController];
        [welcomeWindowController showWindow:nil];
    } else {
        [mainWindowController showWindow:nil];
        if ([[NTLNAccount instance] password]) {
            [_friendsTimelineRefreshTimer fire];
        }
        [self updateReplies];
        [self updateDirectMessages];
        [self rateLimitStatus];
    }
}


#pragma mark WelcomeWindowCallback methods
- (void) finishedToSetup {
    [welcomeWindowController close];
    [mainWindowController showWindow:nil];
    [self restartTimer];
    [_friendsTimelineRefreshTimer fire];
}

#pragma mark Growl
- (void) enableGrowl {
    _growlEnabled = TRUE;
}

- (void) notifyByGrowl:(NSArray*)controllers {
    if (!_growlEnabled || ![[NSUserDefaults standardUserDefaults] boolForKey:NTLN_PREFERENCE_USE_GROWL]) {
        return;
    }
    
    if (!_growl) {
        _growl = [[NTLNGrowlNotifier alloc] init];
        [_growl setCallbackTarget:self];
    }
    
    // remove my updates
    NSMutableArray *controllersWithoutMine = [NSMutableArray arrayWithArray:controllers];
    for (int i = 0; i < [controllersWithoutMine count]; i++) {
        NTLNMessage *m = [(TwitterStatusViewController*)[controllersWithoutMine objectAtIndex:i] message];
        if ([m replyType] == NTLN_MESSAGE_REPLY_TYPE_MYUPDATE) {
            [controllersWithoutMine removeObjectAtIndex:i];
            i--;
        }
    }

    int i;

    NSMutableArray *messages = [NSMutableArray arrayWithCapacity:20];
    
    int numberOfReplies = 0;
    int showDetailThreashold = 0; // if controllers has my updates only, this is left as 0.
    if ([[NTLNConfiguration instance] summarizeGrowl]) {
        // order reply first
        for (i = 0; i < [controllersWithoutMine count]; i++) {
            NTLNMessage *m = [(TwitterStatusViewController*)[controllersWithoutMine objectAtIndex:i] message];
            if ([m replyType] == NTLN_MESSAGE_REPLY_TYPE_REPLY || [m replyType] == NTLN_MESSAGE_REPLY_TYPE_REPLY_PROBABLE) {
                [messages insertObject:m atIndex:numberOfReplies];
                numberOfReplies++;
            } else {
                [messages addObject:m];
            }
        }
        
        showDetailThreashold = [[NTLNConfiguration instance] growlSummarizeThreshold] < [messages count]
        ? [[NTLNConfiguration instance] growlSummarizeThreshold] - 1 : [messages count];
    } else {
        for (i = 0; i < [controllersWithoutMine count]; i++) {
            NTLNMessage *m = [(TwitterStatusViewController*)[controllersWithoutMine objectAtIndex:i] message];
            [messages addObject:m];
        }
        showDetailThreashold = [messages count]; // show details for all messages
    }
    
    for (i = 0; i < showDetailThreashold; i++) {
        NTLNMessage *m = [messages objectAtIndex:i];
        int priority = 0;
        BOOL sticky = FALSE;
        switch ([m replyType]) {
            case NTLN_MESSAGE_REPLY_TYPE_REPLY:
                priority = 2;
                sticky = TRUE;
                break;
            case NTLN_MESSAGE_REPLY_TYPE_REPLY_PROBABLE:
                priority = 1;
                sticky = TRUE;
                break;
            default:
                break;
        }
        
        [_growl sendToGrowl:m];
    }

    // summary
    if (i < [messages count]) {
        enum NTLNReplyType type;

        // replies still remain
        if (i < numberOfReplies) {
            type = NTLN_MESSAGE_REPLY_TYPE_REPLY;
        } else {
            type = NTLN_MESSAGE_REPLY_TYPE_NORMAL;
        }
        
        NSMutableSet *names = [NSMutableSet setWithCapacity:20];
        for (; i < [messages count]; i++) {
            NTLNMessage *m = [messages objectAtIndex:i];
            [names addObject:[m screenName]];
        }
        NSMutableString *s = [NSMutableString stringWithCapacity:500];
//        [s appendString:@"New Messages from:"];
        NSArray *namesArray = [names allObjects];
        for (int j = 0; j < [namesArray count]; j++) {
            [s appendString:[namesArray objectAtIndex:j]];
            [s appendString:@" "];
        }
        [_growl sendToGrowlTitle:NSLocalizedString(@"New Messages from:", @"Growl notifiies summarized messages")
                     description:s
                       replyType:type];
    } 
}

- (void) markAsRead:(NSString*)statusId
{
    for (TwitterStatusViewController* c in [messageViewControllerArrayController arrangedObjects]) {
        if ([[[c message] statusId] isEqualToString:statusId]) {
            [c markAsRead];
            break;
        }
    }
}

#pragma mark Good Night
- (void) enableGoodNight {
    _goodNightEnabled = TRUE;
}

- (void) checkShouldSleepByGoodNight
{
    if (_sendReceiveGoodNightCount < 0) {
        NSLog(@"shutting down by goodnight NatsuLion command");
        [[NSApplication sharedApplication] terminate:nil];
    }
}

- (void) processSendMessageIfGoodNight:(NSString*)message
{
    if (_goodNightEnabled && [NTLNMessage isGoodNightMessageText:message]) {
        _sendReceiveGoodNightCount++;
        NSLog(@"sending good night message. count=%d", _sendReceiveGoodNightCount);
    }
}

- (void) processReceivedMessageIfGoodNight:(NTLNMessage*)message
{
    if (_goodNightEnabled && [message isGoodNightMessage]) {
        if ([[message timestamp] timeIntervalSinceNow] > -[[NTLNConfiguration instance] refreshIntervalSeconds]) {
            _sendReceiveGoodNightCount--;
            NSLog(@"received good night message (%@). count=%d", [message statusId], _sendReceiveGoodNightCount);
            if (_sendReceiveGoodNightCount < 0) {
                [self sendReplyMessage:@"zzz..." toStatusId:[message statusId]];
            }
        } else {
            NSLog(@"ignored good night message (%@) because of too old", [message statusId]);
        }
    }
}

#pragma mark -

#pragma mark TwitterRateLimitStatusCallback

- (void) updateRateLimitStatusIndicator
{
    [mainWindowController setRateLimitStatusWithRemainingHits:[_twitter remainingHits]
                                                  hourlyLimit:[_twitter hourlyLimit]
                                                    resetTime:[_twitter resetTime]];
}

- (void) rateLimitStatusWithRemainingHits:(int)remainingHits hourlyLimit:(int)hourlyLimit resetTime:(NSDate*)resetTime
{
    [self updateRateLimitStatusIndicator];
}

#pragma mark Twitter API Call

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
    [self restartFriendsTimelineRefreshTimer];
    [self updateRateLimitStatusIndicator];
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
    [self restartRepliesRefreshTimer];
    [self updateRateLimitStatusIndicator];
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
    [self updateRateLimitStatusIndicator];
}

- (void) updateDirectMessages {
    //    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSString *password = [[NTLNAccount instance] password];
    if (!password) {
        // TODO inform error to user
        NSLog(@"password not set. skip updateStatus");
        return;
    }
    [_twitter directMessagesWithUsername:[[NTLNAccount instance] username]
                                password:password
                                 usePost:[[NTLNConfiguration instance] usePost]];
    [self updateRateLimitStatusIndicator];
    [self restartDirectMessagesRefreshTimer];
}

- (void) sendReplyMessage:(NSString*)message toStatusId:(NSString*)statusId
{
    [self processSendMessageIfGoodNight:message];
    
    NSString *password = [[NTLNAccount instance] password];
    [_twitter sendMessage:message
                 username:[[NTLNAccount instance] username]
                 password:password
          replyToStatusId:statusId];
}

- (void) sendMessage:(NSString*)message {
    [self processSendMessageIfGoodNight:message];

    NSString *password = [[NTLNAccount instance] password];
    [_twitter sendMessage:message
                 username:[[NTLNAccount instance] username]
                 password:password];

    NSRange dmPrefixRange = [message rangeOfString:@"D "];
    if (dmPrefixRange.location != NSNotFound && dmPrefixRange.location == 0) {
        NSLog(@"ignored DM for Adium status");
        return;
    }
    if ([[NTLNConfiguration instance] useAdiumStatus]) {
        AdiumApplication *adium = [SBApplication applicationWithBundleIdentifier:@"com.adiumX.adiumX"];
        if ([adium isRunning]) {
            NSEnumerator *e = [[adium accounts] objectEnumerator];
            AdiumAccount *a;
            while ((a = [e nextObject]) != nil) {
                NSLog(@"account: %@", a);
                [[a statusMessage] setTo:message];
            }
        } else {
            NSLog(@"Adium is not running.");
        }
    }
}

- (void) createFavoriteFor:(NSString*)statusId {
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
    [self updateRateLimitStatusIndicator];
}

- (void) destroyFavoriteFor:(NSString*)statusId {
    NSString *password = [[NTLNAccount instance] password];
    if (!password) {
        NSLog(@"password not set. skip destroy favorite");
        return;
    }
    _createFavoriteIsWorking = TRUE;
    [_twitter destroyFavorite:statusId
                     username:[[NTLNAccount instance] username]
                     password:password];
    [self updateRateLimitStatusIndicator];
}

- (void) rateLimitStatus {
    //    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSString *password = [[NTLNAccount instance] password];
    if (!password) {
        // TODO inform error to user
        NSLog(@"password not set. skip updateStatus");
        return;
    }
    [_twitter rateLimitStatusWithUsername:[[NTLNAccount instance] username]
                                 password:password];
}

#pragma mark Add new message
- (void) clearErrorMessage {
    if (_lastErrorMessage) {
        [messageViewControllerArrayController removeObject:_lastErrorMessage];
        [mainWindowController reloadTableView];
        _lastErrorMessage = nil;
    }
}

- (void) processNewMessage:(TwitterStatusViewController*)controller {
    NTLNMessage *s = [controller message];
    if ([s replyType] == NTLN_MESSAGE_REPLY_TYPE_REPLY || [s replyType] == NTLN_MESSAGE_REPLY_TYPE_REPLY_PROBABLE) {
        if ([[NTLNConfiguration instance] latestTimestampOfMessage] < [[s timestamp] timeIntervalSince1970]) {
            [[NTLNConfiguration instance] setLatestTimestampOfMessage:[[s timestamp] timeIntervalSince1970]];
        } else {
            // might be retrieved in previous run
            [controller markAsRead:false];
        }
    }
    if ([s replyType] == NTLN_MESSAGE_REPLY_TYPE_DIRECT) {
        if ([[NTLNConfiguration instance] latestTimestampOfDirectMessage] < [[s timestamp] timeIntervalSince1970]) {
            [[NTLNConfiguration instance] setLatestTimestampOfDirectMessage:[[s timestamp] timeIntervalSince1970]];
        } else {
            // might be retrieved in previous run
            [controller markAsRead:false];
        }
    }
}

- (void) addNewErrorMessageWirthController:(NTLNErrorMessageViewController*)controller {
    [self clearErrorMessage];
    _lastErrorMessage = controller;
    [messageViewControllerArrayController setFilterPredicate:nil];
    [mainWindowController addMessageViewControllers:[NSArray arrayWithObject:controller]];
}

// controllers: TwitterStatusViewController objects
- (void) addNewMessageWithControllers:(NSNotification*)notification {
    NSArray *controllers = [notification object];

    for (int i = 0; i < [controllers count]; i++) {
        id o = [controllers objectAtIndex:i];
        if (![o isKindOfClass:[TwitterStatusViewController class]]) {
            NSLog(@"ERROR: addNewMessageWithControllers received non-TwitterStatusViewController");
        }
        [self clearErrorMessage];
        [self processNewMessage:o];
    }
    
    // add
    [messageViewControllerArrayController setFilterPredicate:nil];
    [mainWindowController addMessageViewControllers:controllers];
    [[NSNotificationCenter defaultCenter] postNotificationName:NTLN_NOTIFICATION_NEW_MESSAGE_ADDED object:controllers];
    
    if ([[NTLNConfiguration instance] raiseWindowWhenNewMessageArrives]) {
        [mainWindowController showWindowToFront];
    }
}

- (BOOL) isNewMessage:(TwitterStatusViewController*)controller {
    if ([messageViewControllerArray containsObject:controller] || [_messageNotifier contains:controller]) {
        return FALSE;
    }
    return TRUE;
}

#pragma mark TwitterPostCallback
- (void) finishedToPost {
    [self checkShouldSleepByGoodNight];
    [mainWindowController resetAndFocusMessageTextField];
    [self setIconImageToNormal];
    [self restartFriendsTimelineRefreshTimerAfter:1];
}

- (void) failedToPost:(NSString*)message {
    [self checkShouldSleepByGoodNight];
    [self addNewErrorMessageWirthController:
     [NTLNErrorMessageViewController controllerWithTitle:NSLocalizedString(@"Sending a message failed", @"Title of error message")
                                                 message:message
                                               timestamp:[NSDate date]]];
    [mainWindowController resetAndFocusMessageTextField];
    [self setIconImageForError];
}

#pragma mark TimelineCallback
- (void) finishedToGetTimeline:(NSArray*)statuses {
    for (int i = 0; i < [statuses count]; i++) {
        NTLNMessage *s = [statuses objectAtIndex:i];
        TwitterStatusViewController *controller = [[[TwitterStatusViewController alloc]
                                                    initWithTwitterStatus:(NTLNMessage*)s
                                                    messageViewListener:mainWindowController] autorelease];
        if ([self isNewMessage:controller]) {
            [self processReceivedMessageIfGoodNight:s];
            [_messageNotifier addMessageViewController:controller];
        }
    }
    [self setIconImageToNormal];
}

- (void) failedToGetTimeline:(NTLNErrorInfo*)info {
    NSString *s;
    if ([info type] == NTLN_ERROR_TYPE_HIT_API_LIMIT) {
        if ([_twitter resetTime]) {
            s = [NSString stringWithFormat:NSLocalizedString(@"Exceeded API rate limit\nwill be reset at %@", nil),
                 [[_twitter resetTime] descriptionWithCalendarFormat:@"%H:%M" timeZone:nil locale:nil]];
        } else {
            s = [NSString stringWithFormat:NSLocalizedString(@"Exceeded API rate limit", nil)];
        }
    } else {
        s = [info originalMessage];
    }

    [self addNewErrorMessageWirthController:
     [NTLNErrorMessageViewController controllerWithTitle:NSLocalizedString(@"Retrieving timeline failed", @"Title of error message")
                                                 message:s
                                               timestamp:[NSDate date]]];
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, [self description]);
    [self setIconImageForError];
}

- (void) twitterStartTask {
    [progressIndicator startTask];
}

- (void) twitterStopTask {
    [progressIndicator stopTask];
}

#pragma mark TwitterFavoriteCallback
- (void) finishedToChangeFavorite:(NSString*)statusId {           
    for (int i = 0; i < [[messageViewControllerArrayController arrangedObjects] count]; i++) {
        NTLNMessageViewController *c = [[messageViewControllerArrayController arrangedObjects] objectAtIndex:i];
        if ([statusId isEqualToString:[c messageId]]) {
            [c favoriteCreated];
            break;
        }
    }
    _createFavoriteIsWorking = FALSE;
    [self setIconImageToNormal];
}

- (void) failedToChangeFavorite:(NSString*)statusId errorInfo:(NTLNErrorInfo*)info {
    for (int i = 0; i < [[messageViewControllerArrayController arrangedObjects] count]; i++) {
        NTLNMessageViewController *c = [[messageViewControllerArrayController arrangedObjects] objectAtIndex:i];
        if ([statusId isEqualToString:[c messageId]]) {
            [c favoriteCreationFailed];
            break;
        }
    }
    _createFavoriteIsWorking = FALSE;
    [self setIconImageForError];
}

- (BOOL) isCreatingFavoriteWorking {
    return _createFavoriteIsWorking;
}

#pragma mark -
#pragma mark Application icon
- (void) writeNumberOfUnread {
    if (_numberOfUnreadMessage == 0) {
        [NSApp setApplicationIconImage:nil];
    } else {
        [_badge badgeApplicationDockIconWithValue:_numberOfUnreadMessage insetX:3 y:0];
    }
}

- (void) updateBudgeIfNeedIncrease:(NSArray*)messages {
    for (int i = 0; i < [messages count]; i++) {
        NTLNMessage *m = [(TwitterStatusViewController*)[messages objectAtIndex:i] message];
        if ([m status] != NTLN_MESSAGE_STATUS_READ
            && ([m replyType] == NTLN_MESSAGE_REPLY_TYPE_REPLY || [m replyType] == NTLN_MESSAGE_REPLY_TYPE_REPLY_PROBABLE)) {
            _numberOfUnreadMessage++;
        }
    }
    [self writeNumberOfUnread];
}

- (void) setIconImageToNormal
{
    [NSApp setApplicationIconImage:[NSImage imageNamed:@"NatsuLion"]];
}

- (void) setIconImageForError
{
    [NSApp setApplicationIconImage:[NSImage imageNamed:@"NatsuLion_error"]];
}

#pragma mark Notification methods
- (void) messageAdded:(NSNotification*)notification {
    NSArray *messages = [notification object];
    [self updateBudgeIfNeedIncrease:messages];
    [self notifyByGrowl:messages];
}

- (void) messageChangedToRead:(NSNotification*)notification {
    NTLNMessage *m = [(TwitterStatusViewController*)[notification object] message];
    if (m == nil) {
        _numberOfUnreadMessage = 0;
    } else if ([m replyType] == NTLN_MESSAGE_REPLY_TYPE_REPLY || [m replyType] == NTLN_MESSAGE_REPLY_TYPE_REPLY_PROBABLE) {
        _numberOfUnreadMessage--;
    } else {
        return;
    }
    [self writeNumberOfUnread];
}
@end
