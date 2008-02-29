#import "NTLNMessage.h"


@implementation NTLNMessage

@synthesize statusId, name, screenName, text, icon, timestamp, replyType, status;

- (void) dealloc {
    [statusId release];
    [name release];
    [screenName release];
    [text release];
    [icon release];
    [timestamp release];
    [super dealloc];
}

- (BOOL) isEqual:(id)anObject {
    if ([[self statusId] isEqual:[anObject statusId]]) {
        return TRUE;
    }
    return FALSE;
}

- (void) setStatus:(enum NTLNMessageStatus)value {
    status = value;
}

- (void) finishedToSetProperties {
    NSLog(@"%s: warning: this method should be overridden by subclasses.", __PRETTY_FUNCTION__);
}

@end
