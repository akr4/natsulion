#import "NTLNBufferedMessageNotifier.h"
#import "NTLNNotification.h"

@implementation NTLNBufferedMessageNotifier
+ (id) notifierWithTimeout:(float)seconds maxMessage:(int)max {
    return [[[self class] alloc] initWithTimeout:seconds maxMessage:max];
}

- (id) initWithTimeout:(float)seconds maxMessage:(int)max {
    _timeoutSeconds = seconds;
    _maxMessage = max;
    _messages = [[NSMutableArray alloc] initWithCapacity:20];
    return self;
}

- (void) dealloc {
    [_messages release];
    if (_entireTimer) {
        [_entireTimer release];
    }
    if (_shortTimer) {
        [_shortTimer release];
    }
    [super dealloc];
}

- (void) resetTimer {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
    if (!_entireTimer) {
        _entireTimer = [[NSTimer scheduledTimerWithTimeInterval:5.0
                                                        target:self 
                                                      selector:@selector(timerExpired:)
                                                      userInfo:nil 
                                                       repeats:FALSE] retain];
    }
    
    [_shortTimer invalidate];
    [_shortTimer release];
    _shortTimer = [[NSTimer scheduledTimerWithTimeInterval:1.0
                                                     target:self 
                                                   selector:@selector(timerExpired:)
                                                   userInfo:nil 
                                                    repeats:FALSE] retain];
}

- (void) notify {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
    [_entireTimer invalidate];
    [_entireTimer release];
    _entireTimer = nil;
    [_shortTimer invalidate];
    [_shortTimer release];
    _shortTimer = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:NTLN_NOTIFICATION_NEW_MESSAGE_RECEIVED object:[[_messages copy] autorelease]];
    [_messages removeAllObjects];
}

- (void) addMessageViewController:(NTLNMessageViewController*)controller {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
    [_messages addObject:controller];
    if ([_messages count] >= _maxMessage) {
        [self notify];
        return;
    }
    [self resetTimer];
}

- (BOOL) contains:(NTLNMessageViewController*)controller {
    return [_messages containsObject:controller];
}

- (void) timerExpired:(NSNotification*)notification {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self notify];
}

@end
