#import "TwitterStatusViewTimestampField.h"
#import "TwitterUtils.h"

@implementation TwitterStatusViewTimestampField

- (void) setStatus:(NTLNMessage*)status {
    _status = status;
    [status retain];
    
    [self setTimestamp:[_status timestamp]];
}

- (void) dealloc {
    [_status release];
    [super dealloc];
}

- (void) mouseDown:(NSEvent *)theEvent {
    if (![self mouseIsOnText]) {
        [super mouseDown:theEvent];
        return;
    }
    
    if ([_status replyType] == NTLN_MESSAGE_REPLY_TYPE_DIRECT) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://twitter.com/direct_messages"]];
    } else {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[[TwitterUtils utils] statusPageURLString:[_status screenName] statusId:[_status statusId]]]];
    }

    [super mouseDown:theEvent];
}

@end
