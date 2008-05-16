#import "NTLNAppController.h"
#import "NTLNPreferencesWindowController.h"
#import "NTLNAccount.h"
#import "NTLNConfiguration.h"
#import "NTLNNotification.h"
#import "TwitterStatusViewController.h"

@implementation NTLNAppController

+ (void) setupDefaults {
    NSString *userDefaultsValuesPath = [[NSBundle mainBundle] pathForResource:@"UserDefaults" 
                                                                       ofType:@"plist"]; 
//    NSLog(@"UserDefaults path: %@", userDefaultsValuesPath);

    NSDictionary *userDefaultsValuesDict = [NSDictionary dictionaryWithContentsOfFile:userDefaultsValuesPath]; 
    [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsValuesDict]; 
}

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
    _messageCountHistory = [[NSMutableArray alloc] initWithCapacity:30];
    _numberOfPostedMessages = 0;
    
    return self;
}

- (void) dealloc {
    [_refreshTimer release];
    [_badge release];
    [_growl release];
    [_messageCountHistory release];
    [super dealloc];
}

- (int) refreshInterval {
    return _refreshInterval;
}

- (void) resetTimer {
    if (_refreshTimer) {
        [_refreshTimer invalidate];
        [_refreshTimer release];
    }
}

- (void) stopTimer {
    [self resetTimer];
}

- (void) startTimer {
    [self resetTimer];
    
    if (_refreshInterval < 30) {
        return;
    }

    _refreshTimer = [[NSTimer scheduledTimerWithTimeInterval:_refreshInterval
                                                      target:self
                                                    selector:@selector(expireRefreshInterval)
                                                    userInfo:nil
                                                     repeats:YES] retain];
}

- (void) setRefreshInterval:(int)interval {
    _refreshInterval = interval;
    
    if ([[NTLNAccount instance] username]) {
        [self startTimer];
    }
}

- (void) awakeFromNib { 
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(messageChangedToRead:)
                                                 name:NTLN_NOTIFICATION_MESSAGE_STATUS_MARKED_AS_READ
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(messageAdded:)
                                                 name:NTLN_NOTIFICATION_NEW_MESSAGE_ADDED
                                               object:nil];
    
    _badge = [[CTBadge alloc] init];
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

#pragma mark Statistics
- (void)storeMessageStatistics:(NSArray*)messages {
    // store current data
    _numberOfPostedMessages += [messages count];
    if ([[NTLNConfiguration instance] showMessageStatisticsOnStatusBar]) {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithInt:[messages count]], @"count",
                             [NSDate date], @"timestamp",
                             nil];
        [_messageCountHistory addObject:dic];
    }
}

- (void)updateMessageStatistics {

    if (![[NTLNConfiguration instance] showMessageStatisticsOnStatusBar]) {
        return;
    }

    double period = [self refreshInterval] * NTLN_STATISTICS_CALCULATION_PERIOD_MULTIPLIER * 1.2;
    
    // remove old data
    for (int i = 0; i < [_messageCountHistory count]; i++) {
        NSDictionary *dic = [_messageCountHistory objectAtIndex:i];
        NSDate *timestamp = [dic objectForKey:@"timestamp"];
        if (-[timestamp timeIntervalSinceNow] > period) {
            [_messageCountHistory removeObjectAtIndex:i];
            i--;
        }
    }

#ifdef DEBUG
    NSLog(@"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
    for (int i = 0; i < [_messageCountHistory count]; i++) {
        NSDictionary *dic = [_messageCountHistory objectAtIndex:i];
        NSLog(@"[%@, %d]", [dic objectForKey:@"timestamp"], [[dic objectForKey:@"count"] intValue]);
    }
    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
#endif
    
    // calculate statistics
    float sum = 0;
    for (int i = 0; i < [_messageCountHistory count]; i++) {
        NSDictionary *dic = [_messageCountHistory objectAtIndex:i];
        sum += [[dic objectForKey:@"count"] intValue];
    }

    [mainWindowController setMessagePostLevel:(sum / NTLN_STATISTICS_CALCULATION_PERIOD_MULTIPLIER)];
    [mainWindowController setMessageStatisticsField:[NSString stringWithFormat:@"%ld", _numberOfPostedMessages]];
    
//    NSLog(@"level = %f", (sum / NTLN_STATISTICS_CALCULATION_PERIOD_MULTIPLIER));
}

#pragma mark Refresh interval timer
- (void) expireRefreshInterval {
    [mainWindowController updateStatus];
    [self updateMessageStatistics];
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
            [_refreshTimer fire];
        }
        [mainWindowController updateReplies];
    }
}


#pragma mark WelcomeWindowCallback methods
- (void) finishedToSetup {
    [welcomeWindowController close];
    [mainWindowController showWindow:nil];
    [self startTimer];
    [_refreshTimer fire];
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

#pragma mark Badge
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

#pragma mark Notification methods
- (void) messageAdded:(NSNotification*)notification {
    NSArray *messages = [notification object];
    [self updateBudgeIfNeedIncrease:messages];
    [self notifyByGrowl:messages];
    [self storeMessageStatistics:messages];
    [self updateMessageStatistics];
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
