#import "Message.h"


@implementation Message

@synthesize statusId, name, screenName, text, icon, timestamp, replyType;

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

- (replyType_t) replyType {
    return NORMAL;
}

@end
